namespace :initr do
  namespace :bind do
    desc "Imports zones using AXFR"
    task :import => :environment do
      bind_id = ENV['ID']
      file = ENV['FILE']
      server = ENV['SERVER'] || 'localhost'
      abort "ID=bind_id the id of the bind class (see /bind/configure/[id] URL)" unless bind_id and Initr::Bind.exists?(bind_id)
      abort "FILE=domain_list.txt one domain per line" unless file
      abort "FILE=#{file} does not exist" unless File.exists?(file)
      bind = Initr::Bind.find(bind_id)
      File.read(file).split.each do |domain|
        puts domain
        zone = `dig axfr #{domain} @#{server} |grep -v "^;"|grep -v "SOA.* .*"|grep -v "^$"`
        bind.bind_zones << Initr::BindZone.new(domain: domain, zone: zone)
      end
    end
  end
end

