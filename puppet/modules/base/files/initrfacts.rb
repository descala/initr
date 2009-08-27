# rubygems_version -- fetch rubygems installed version

Facter.add("initrdbversion") do

    ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"

    setcode do
      begin
        a=`su - postgres -c 'psql -d initr -U postgres -c "select * from schema_info"' |grep "^[ ,0-9][ ,0-9]*$" |sed 's/ //g'`
      ensure
        a="0" unless a.size > 0
      end
      a
    end
end

Facter.add("initrlastmigration") do

    ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"

    setcode do
      `ls -l $(gem env gempath)/gems/initr-0.0.1/db/migrate/* | sed 's/  / /g' | cut -d" " -f9 | cut -d"/" -f11 |sort |tail -1 |cut -d"_" -f1 |sed 's/^0*//g'`
    end
end

Facter.add("puppetdbcreated") do

    ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"

    setcode do
      begin
        r=`su - postgres -c 'psql -d initr -U postgres -c "select * from hosts"' >> /dev/null ; echo -n "$?"`
      rescue
        r=1
      end
      r
    end
end
