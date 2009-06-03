#
# Delayed job responsible of:
#
# - Mantain /etc/puppet/autosign file
#   to allow nodes connect to puppetmaster
#
class Initr::DelayedJob::AutosignJob

  def perform
    content = generate_content
    path = Setting.plugin_initr_plugin['autosign']

    unless can_write? path
      puts "Can't write file: #{path}"
      return 1
    end
    lines=(`echo -n "#{content}" | wc -l`).to_i
    unless lines > 0
      puts "Not overwriten file #{path} with empty content #{content}"
      return 1
    end

    File.open(path,"w") {|f| f << content}
    `chmod 644 #{path}`
    `chown apache: #{path}`
    puts "Updated #{path}"
  end

  private

  def generate_content
      h=""
      Initr::Node.find(:all).each do |n|
        h += "#{n.hostname}\n" if n.puppet_host.nil?
      end
      h
  end

  # we have rights to write a given file ?
  def can_write?(file)
    dir=file.gsub(/\/[^\/]*$/,"/")
    is_w_dir=( File.directory?(dir) and File.writable?(dir) )
    is_w_file=( !File.exist?(file) or File.writable?(file) )
    unless is_w_dir and is_w_dir
      puts "#{dir} is writable directory? [#{is_w_dir}]"
      puts "can write #{file}? [#{is_w_file}]"
    end
    return (is_w_dir and is_w_file)
  end

end

