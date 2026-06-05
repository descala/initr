class BindRecordsController < InitrController
  accept_api_auth :index, :create, :destroy, :update
  protect_from_forgery except: [:index, :create, :destroy, :update]

  before_action :find_bind_zone
  before_action :authorize
  before_action :require_line, only: [:create, :destroy, :update]

  def index
    if params[:line].present?
      render json: { exists: contains_record?(params[:line]) }
    elsif params[:name].present?
      records = records_for_owner(params[:name])
      render json: { exists: records.any?, records: records }
    else
      render json: { zone: @bind_zone.zone }
    end
  end

  def create
    return render_error('unparseable record') unless parse_record(@line)
    return render_error('record already exists') if contains_record?(@line)
    update_zone(zone_with_record(@line))
  end

  def destroy
    new_zone, removed = zone_without_record(@line)
    return render_error('record not found', :not_found) if removed.zero?
    update_zone(new_zone)
  end

  # Update-by-key: replace the *value* of the record that has the same owner and
  # type as @line, leaving its rdata to whatever @line carries. Identified by
  # (owner, type) only, so the caller need not know the old value. Refuses to act
  # unless exactly one record matches: zero -> 404 (nothing to update), more than
  # one (e.g. round-robin A, multiple MX) -> 422 (ambiguous, delete+add instead).
  def update
    target = parse_record(@line)
    return render_error('unparseable record') unless target

    matches = records_for_owner_type(target)
    if matches.empty?
      return render_error("no #{target.type} record found for #{target.owner}", :not_found)
    elsif matches.size > 1
      return render_error("#{matches.size} #{target.type} records found for #{target.owner}; " \
                          'refusing to update an ambiguous match — delete the specific record then add the new one')
    end

    update_zone(zone_with_replaced_record(target, @line))
  end

  private

  # --- request / response helpers ----------------------------------------------

  # Sets @line for the write actions and aborts early when it is missing.
  def require_line
    @line = params[:line].to_s.strip
    render_error('line is required') if @line.blank?
  end

  # All error responses share one shape: { errors: [<message>, ...] }. Single
  # messages are wrapped so a client never has to juggle an `error`/`errors`
  # split (validation failures in update_zone already render this shape).
  def render_error(message, status = :unprocessable_entity)
    render json: { errors: [message] }, status: status
  end

  # Persists the new zone text, rendering the shared success / validation-error
  # response. Used by both create and destroy.
  def update_zone(new_zone)
    if @bind_zone.update(zone: new_zone)
      render json: { status: 'ok' }
    else
      render json: { errors: @bind_zone.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # --- semantic record search over @bind_zone.zone (no model changes) ----------

  def parse_record(line)
    Initr::DnsRecord.parse(line, origin: @bind_zone.domain)
  end

  # Raw zone lines whose owner matches the given name (subdomain). The name is
  # normalised the same way record owners are (@==FQDN, relative==absolute), so
  # "www", "www.domain.com" and "www.domain.com." all match the same records.
  def records_for_owner(name)
    target = Initr::DnsRecord.normalize_name(name, @bind_zone.domain)
    each_zone_line.select { |_raw, rec| rec && rec.owner == target }
                  .map { |raw, _rec| raw.rstrip }
  end

  # True when the zone already holds a record equivalent (by meaning, not text)
  # to the given line.
  def contains_record?(line)
    target = parse_record(line)
    return false unless target
    each_zone_line.any? { |_raw, rec| rec == target }
  end

  # Raw zone lines whose owner AND type both match the parsed target record
  # (matched by meaning, like records_for_owner). The set update operates on.
  def records_for_owner_type(target)
    each_zone_line.select { |_raw, rec| rec&.same_key?(target) }
                  .map { |raw, _rec| raw }
  end

  # Zone text with the single owner+type match replaced by new_line, preserving
  # every other line (and all comments / blanks) verbatim. Assumes exactly one
  # match — the caller (update) guarantees it; the `replaced` guard keeps it to
  # one substitution regardless.
  def zone_with_replaced_record(target, new_line)
    replaced = false
    each_zone_line.map do |raw, rec|
      if !replaced && rec&.same_key?(target)
        replaced = true
        new_line.to_s.strip
      else
        raw
      end
    end.join("\n")
  end

  # Zone text with every record equivalent to the given line removed, plus the
  # number of lines removed. Comments and blank lines are preserved.
  def zone_without_record(line)
    target = parse_record(line)
    return [@bind_zone.zone, 0] unless target
    removed = 0
    kept = each_zone_line.reject do |_raw, rec|
      match = (rec == target)
      removed += 1 if match
      match
    end
    [kept.map(&:first).join("\n"), removed]
  end

  # Append a record line, preserving the existing (possibly indented) content.
  def zone_with_record(line)
    @bind_zone.zone.sub(/\s*\z/, '') + "\n" + line.to_s.strip
  end

  # Yields [raw_line, DnsRecord-or-nil] for every line of the zone, resolving the
  # owner of indented continuation lines from the preceding record. Each line is
  # parsed once; the owner is carried forward as the previous record's absolute
  # name (a trailing dot makes it absolute so it normalises back to itself). The
  # single scan both search helpers are built on.
  def each_zone_line
    return enum_for(:each_zone_line) unless block_given?
    current_owner = '@'
    @bind_zone.zone.split("\n").each do |raw|
      rec = Initr::DnsRecord.parse(raw, origin: @bind_zone.domain, inherited_owner: current_owner)
      current_owner = "#{rec.owner}." if rec
      yield raw, rec
    end
  end

  def api_request?
    true
  end

  def find_bind_zone
    # Look up by domain, but only among zones whose bind klass still exists.
    # Orphaned zones (bind_id pointing at a deleted klass) keep their content,
    # so they must be excluded by joining klasses, not by checking for an empty
    # zone. order(:id) makes the pick deterministic when more than one matches.
    @bind_zone = Initr::BindZone
      .where(domain: params[:id], bind_id: Initr::Bind.select(:id))
      .order(:id)
      .first
    raise ActiveRecord::RecordNotFound unless @bind_zone
    @klass = @bind_zone.bind
    @node = @klass.node
    @project = @node.project
  end
end
