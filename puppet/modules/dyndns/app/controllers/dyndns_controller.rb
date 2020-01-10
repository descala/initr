class DyndnsController < InitrController

  menu_item :initr
  before_action :find_dyndns, except: [:update]
  before_action :authorize,   except: [:update]
  before_action :basic_auth,  only:   [:update]

  def update
    if params["myip"] and params["hostname"]
      if @klass.current_ip == params["myip"] and @klass.current_url == params["hostname"]
        render plain: "nochg #{params["myip"]}"
      else
        stderr = ""
        IO.popen("nsupdate -k /etc/bind/keys/Klocalhost*.private 2>&1 >/dev/null", 'r+') { |io|
          io.puts "server #{@klass.ddns_domain}"
          if @klass.current_url
            io.puts "update delete #{@klass.current_url}"
          else
            io.puts "update delete #{params["hostname"]}"
          end
          io.puts "update add #{params["hostname"]} 300 A #{params["myip"]}"
          io.puts "send"
          io.close_write
          stderr = io.readlines.join(" ")
        }
        if $?.success?
          @klass.current_ip=params["myip"]
          @klass.current_url=params["hostname"]
          @klass.save
          render plain: "good #{params["myip"]}"
        else
          render plain: "error calling nsupdate: '#{stderr}'"
        end
      end
    else
      render plain: "error: missing parameters"
    end
  rescue Exception => e
    render plain: e.message
  end

  private

  def find_dyndns
    @klass = Initr::Dyndns.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

  def basic_auth
    authenticate_or_request_with_http_basic do |user, pass|
      Initr::Klass.where(type: "Initr::Dyndns").each do |ddns|
        if ddns.ddns_user==user and ddns.ddns_pass==pass
          @klass = ddns
          # nodes can't update other zone entries
          if "#{@klass.ddns_user}.#{@klass.ddns_domain}" == params["hostname"]
            return true
          end
        end
      end
      false
    end
  end

end
