#!/usr/bin/ruby
#
# test_check_letsencrypt.rb — proves de check_letsencrypt.rb sense cap servidor
#
# El que es prova aquí és el que no es pot provar a un host de veritat sense
# esperar-ho: certificats servits caducats o a punt, un lineage servit que
# certbot no coneix (live/ copiat d'un altre servidor), un fitxer que no hi és,
# el timer parat, i que els lineages morts (els que fan fallar certbot.service
# a cada execució) no toquin l'estat però surtin a la sortida.
#
# Els certificats es generen amb la llibreria OpenSSL de Ruby; els volcats de
# `nginx -T` i `apache2ctl -S` són retalls dels de la granja.
#
# Ús: ruby test_check_letsencrypt.rb
#     I a un host stretch/buster (Ruby 2.3/2.5) abans de desplegar:
#     `ruby -c check_letsencrypt.rb` peta si s'hi ha colat sintaxi moderna.

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'openssl'
require_relative '../files/check_letsencrypt'

NOW = Time.utc(2026, 9, 22, 10, 0, 0)

module CertFixtures
  def write_cert(path, days_left, now = NOW)
    key = OpenSSL::PKey::RSA.new(1024)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.parse("/CN=#{File.basename(File.dirname(path))}")
    cert.issuer = cert.subject
    cert.public_key = key.public_key
    cert.not_before = now - 86_400
    cert.not_after = now + days_left * 86_400
    cert.sign(key, OpenSSL::Digest::SHA256.new)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, cert.to_pem)
    path
  end

  # Un lineage de certbot: live/<name>/{cert,fullchain}.pem i, si es demana,
  # renewal/<name>.conf.
  def lineage(le_dir, name, days_left, conf: true)
    write_cert(File.join(le_dir, 'live', name, 'cert.pem'), days_left)
    FileUtils.cp(File.join(le_dir, 'live', name, 'cert.pem'),
                 File.join(le_dir, 'live', name, 'fullchain.pem'))
    if conf
      FileUtils.mkdir_p(File.join(le_dir, 'renewal'))
      File.write(File.join(le_dir, 'renewal', "#{name}.conf"), "[renewalparams]\n")
    end
    File.join(le_dir, 'live', name, 'fullchain.pem')
  end
end

class NginxParsingTest < Minitest::Test
  DUMP = <<-NGINX
# configuration file /etc/nginx/nginx.conf:
http {
    include /etc/nginx/sites-enabled/*;
}
# configuration file /etc/nginx/sites-enabled/shop.example.conf:
server {
    listen 443 ssl;
    server_name shop.example www.shop.example;
    ssl_certificate /etc/letsencrypt/live/shop.example/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/shop.example/privkey.pem;
    # ssl_certificate /etc/letsencrypt/live/shop.example-old/fullchain.pem;
}
server {
    listen 443 ssl;
    server_name next.shop.example;
	ssl_certificate	/etc/letsencrypt/live/shop.example/fullchain.pem;
}
# configuration file /etc/nginx/sites-enabled/default:
server {
    listen 443 ssl default_server;
    ssl_certificate snippets/snakeoil.pem;
    ssl_certificate $ssl_cert_from_variable;
}
  NGINX

  def test_extracts_unique_certificate_paths_in_order
    assert_equal ['/etc/letsencrypt/live/shop.example/fullchain.pem', '/etc/nginx/snippets/snakeoil.pem'],
                 nginx_cert_paths(DUMP)
  end

  def test_relative_paths_resolve_against_the_given_conf_dir
    assert_includes nginx_cert_paths(DUMP, '/opt/nginx'), '/opt/nginx/snippets/snakeoil.pem'
  end

  def test_ignores_keys_comments_and_variables
    paths = nginx_cert_paths(DUMP)
    refute paths.any? { |p| p.include?('privkey') }
    refute paths.any? { |p| p.include?('shop.example-old') }
    refute paths.any? { |p| p.start_with?('$') }
  end

  def test_survives_non_utf8_bytes_in_comments
    # El cron corre sense LANG: Ruby llegeix `nginx -T` com US-ASCII i un
    # comentari amb accents (o en latin-1, als vhosts de fa 10 anys) feia
    # petar el regex amb "invalid byte sequence" (a tots els hosts provats).
    dump = "# Configuraci\xF3n del sitio\nserver {\n  ssl_certificate /a.pem; # caf\xC3\xA9\n}\n"
    assert_equal ['/a.pem'], nginx_cert_paths(dump)
    assert_equal ['/a.pem'], nginx_cert_paths(dump.dup.force_encoding('US-ASCII'))
    assert nginx_cert_paths(dump).first.valid_encoding?
  end
end

class ApacheParsingTest < Minitest::Test
  STATUS = <<-APACHE
VirtualHost configuration:
*:443                  is a NameVirtualHost
         default server web1.example.net (/etc/apache2/sites-enabled/000-default-le-ssl.conf:2)
         port 443 namevhost web1.example.net (/etc/apache2/sites-enabled/000-default-le-ssl.conf:2)
         port 443 namevhost old.example (/etc/apache2/sites-enabled/old.example-le-ssl.conf:2)
                 alias www.old.example
         port 443 namevhost other.example (/etc/apache2/sites-enabled/other.example.conf:15)
*:80                   is a NameVirtualHost
         default server web1.example.net (/etc/apache2/sites-enabled/000-default.conf:1)
         port 80 namevhost old.example (/etc/apache2/sites-enabled/old.example.conf:1)
ServerRoot: "/etc/apache2"
Main DocumentRoot: "/var/www/html"
  APACHE

  def test_vhost_files_are_unique_and_keep_config_order
    assert_equal ['/etc/apache2/sites-enabled/000-default-le-ssl.conf',
                  '/etc/apache2/sites-enabled/old.example-le-ssl.conf',
                  '/etc/apache2/sites-enabled/other.example.conf',
                  '/etc/apache2/sites-enabled/000-default.conf',
                  '/etc/apache2/sites-enabled/old.example.conf'],
                 apache_vhost_files(STATUS)
  end

  def test_cert_paths_follow_symlinks_and_skip_comments
    Dir.mktmpdir do |dir|
      avail = File.join(dir, 'sites-available')
      enabled = File.join(dir, 'sites-enabled')
      FileUtils.mkdir_p([avail, enabled])
      File.write(File.join(avail, 'a.conf'), <<-CONF)
<VirtualHost *:443>
    ServerName old.example
    SSLCertificateFile /etc/letsencrypt/live/old.example/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/old.example/privkey.pem
    #SSLCertificateFile /etc/letsencrypt/live/old.example-old/fullchain.pem
</VirtualHost>
      CONF
      File.symlink(File.join(avail, 'a.conf'), File.join(enabled, 'a.conf'))
      File.write(File.join(enabled, 'b.conf'), "\tSSLCertificateFile\tssl/relative.pem\n")
      File.write(File.join(enabled, 'plain80.conf'), "<VirtualHost *:80>\n</VirtualHost>\n")
      files = %w[a.conf b.conf plain80.conf missing.conf].map { |f| File.join(enabled, f) }
      assert_equal ['/etc/letsencrypt/live/old.example/fullchain.pem', File.join(dir, 'ssl/relative.pem')],
                   apache_cert_paths(files, dir)
    end
  end

  def test_survives_non_utf8_bytes_in_vhost_files
    Dir.mktmpdir do |dir|
      f = File.join(dir, 'latin1.conf')
      File.binwrite(f, "# Configuraci\xF3n\n  SSLCertificateFile /c.pem\n")
      old = Encoding.default_external
      begin
        Encoding.default_external = Encoding::US_ASCII
        assert_equal ['/c.pem'], apache_cert_paths([f], dir)
      ensure
        Encoding.default_external = old
      end
    end
  end
end

class LineageTest < Minitest::Test
  def test_lineage_name_comes_from_the_live_directory
    assert_equal 'shop.example', lineage_of('/etc/letsencrypt/live/shop.example/fullchain.pem', '/etc/letsencrypt')
    assert_equal 'x-0001', lineage_of('/etc/letsencrypt/live/x-0001/cert.pem', '/etc/letsencrypt')
  end

  def test_non_letsencrypt_paths_have_no_lineage
    assert_nil lineage_of('/etc/ssl/certs/ssl-cert-snakeoil.pem', '/etc/letsencrypt')
    assert_nil lineage_of('/etc/letsencrypt/archive/shop.example/cert1.pem', '/etc/letsencrypt')
  end
end

class InspectTest < Minitest::Test
  include CertFixtures

  def test_days_left_conf_presence_and_missing_files
    Dir.mktmpdir do |le|
      ok = lineage(le, 'ok.example', 60)
      noconf = lineage(le, 'orphan.example', 57, conf: false)
      expired = lineage(le, 'dead.example', -375)
      other = write_cert(File.join(le, 'other', 'snakeoil.pem'), 649)
      missing = File.join(le, 'live', 'gone.example', 'fullchain.pem')

      certs = inspect_certs([ok, noconf, expired, other, missing], le_dir: le, now: NOW)
      by = certs.each_with_object({}) { |c, h| h[c[:label]] = c }

      assert_equal 60, by['ok.example'][:days]
      assert by['ok.example'][:conf]
      assert_equal 57, by['orphan.example'][:days]
      refute by['orphan.example'][:conf]
      assert_equal(-375, by['dead.example'][:days])
      assert_equal 649, by['snakeoil.pem'][:days]
      assert_nil by['snakeoil.pem'][:lineage], 'non-LE certs are not held to the renewal conf rule'
      assert_nil by['gone.example'][:days]
      assert_match(/not found/, by['gone.example'][:error])
    end
  end

  def test_unreadable_pem_is_an_error_not_a_crash
    Dir.mktmpdir do |le|
      bad = File.join(le, 'live', 'bad.example', 'fullchain.pem')
      FileUtils.mkdir_p(File.dirname(bad))
      File.write(bad, "this is not a certificate\n")
      cert = inspect_certs([bad], le_dir: le, now: NOW).first
      assert_nil cert[:days]
      assert_match(/unreadable/, cert[:error])
    end
  end
end

class UnusedLineagesTest < Minitest::Test
  include CertFixtures

  def test_lists_renewal_confs_nobody_serves_with_their_days_left
    Dir.mktmpdir do |le|
      lineage(le, 'served.example', 60)
      lineage(le, 'stale.example', -261)
      lineage(le, 'spare.example', 72)
      lineage(le, 'orphan.example', 10, conf: false)
      FileUtils.mkdir_p(File.join(le, 'renewal'))
      File.write(File.join(le, 'renewal', 'nopem.example.conf'), '')

      unused = unused_lineages(['served.example'], le_dir: le, now: NOW)
      assert_equal({ 'nopem.example' => nil, 'spare.example' => 72, 'stale.example' => -261 },
                   unused.each_with_object({}) { |u, h| h[u[:name]] = u[:days] })
    end
  end

  def test_no_renewal_dir_means_no_unused_lineages
    Dir.mktmpdir { |le| assert_equal [], unused_lineages([], le_dir: le, now: NOW) }
  end
end

class EvaluateTest < Minitest::Test
  def cert(label, days, lineage: label, conf: true, error: nil)
    { label: label, path: "/x/#{label}", lineage: lineage, days: days, conf: conf, error: error }
  end

  def run_eval(certs, unused: [], **opts)
    defaults = { warn: 25, crit: 14, timer_active: true, notes: [] }
    evaluate(certs, unused, **defaults.merge(opts))
  end

  def test_all_healthy_is_ok_with_the_count_and_the_minimum
    state, line = run_eval([cert('a.example', 60), cert('b.example', 31),
                            cert('snakeoil.pem', 649, lineage: nil, conf: false)])
    assert_equal 0, state
    assert_match(/^LETSENCRYPT OK - 3 served certs OK \(min 31d\)/, line)
    assert_match(/\| served=3 expired=0 expiring=0 noconf=0 unused_failing=0 min_days=31$/, line)
  end

  def test_below_warn_is_warning_and_below_crit_is_critical
    state, line = run_eval([cert('a.example', 24), cert('b.example', 60)])
    assert_equal 1, state
    assert_match(/^LETSENCRYPT WARNING - 1 expiring: a.example 24d / 1 served certs OK/, line)

    state, line = run_eval([cert('a.example', 14), cert('b.example', 24)])
    assert_equal 2, state
    assert_match(/^LETSENCRYPT CRITICAL - 2 expiring: a.example 14d, b.example 24d \//, line)
  end

  def test_expired_served_certs_are_critical_and_listed_worst_first
    state, line = run_eval([cert('a.example', 60), cert('old.example', -375), cert('nova.example', -254)])
    assert_equal 2, state
    assert_match(/^LETSENCRYPT CRITICAL - 2 expired: old.example -375d, nova.example -254d / 1 served certs OK \(min 60d\)/, line)
    assert_match(/expired=2 .*min_days=-375$/, line)
  end

  def test_served_letsencrypt_cert_without_renewal_conf_is_warning
    # live/ copiat d'un altre servidor sense el renewal/<nom>.conf: 57 dies de
    # vida i certbot ni el mirava (cas real del 08/2026).
    state, line = run_eval([cert('moved.example', 57, conf: false), cert('b.example', 60)])
    assert_equal 1, state
    assert_match(/1 without renewal conf: moved.example 57d \//, line)
    assert_match(/noconf=1/, line)
  end

  def test_missing_or_unreadable_file_is_critical
    state, line = run_eval([cert('gone.example', nil, error: 'not found'), cert('b.example', 60)])
    assert_equal 2, state
    assert_match(/1 unreadable: gone.example \(not found\) \//, line)
  end

  def test_inactive_timer_is_warning
    state, line = run_eval([cert('a.example', 60)], timer_active: false)
    assert_equal 1, state
    assert_match(/certbot.timer not active \//, line)
  end

  def test_notes_from_collection_are_warnings
    state, line = run_eval([cert('a.example', 60)], notes: ['nginx -t fails, parsed sites-enabled'])
    assert_equal 1, state
    assert_match(/nginx -t fails, parsed sites-enabled \//, line)
  end

  def test_unused_lineages_are_informational_only
    # Els lineages morts fan fallar certbot.service dos cops al dia però no
    # afecten cap web: surten a la sortida
    # per netejar-los, i no canvien l'estat.
    unused = [{ name: 'spare.example', days: 72 }, { name: 'dead.example', days: -261 },
              { name: 'failing.example', days: 20 }, { name: 'nopem.example', days: nil }]
    state, line = run_eval([cert('a.example', 60)], unused: unused)
    assert_equal 0, state
    assert_match(/^LETSENCRYPT OK - 1 served certs OK \(min 60d\) / 4 unused lineages, 3 failing renewal: dead.example -261d, failing.example 20d, nopem.example no cert/, line)
    assert_match(/unused_failing=3/, line)
  end

  def test_long_lists_are_truncated
    certs = (1..9).map { |i| cert("site#{i}.example", -i) }
    _, line = run_eval(certs)
    assert_match(/9 expired: site9.example -9d, site8.example -8d, site7.example -7d, site6.example -6d, site5.example -5d, site4.example -4d, \+3 more \//, line)
  end

  def test_nothing_served_is_unknown
    state, line = run_eval([])
    assert_equal 3, state
    assert_match(/^LETSENCRYPT UNKNOWN - no served certificates found/, line)
  end

  def test_output_is_one_line_without_shell_globs
    # nsca_wrapper fa `echo $output` sense cometes: un * o ? s'expandiria al host.
    # I Icinga converteix els ; en : (delimitador de la comanda externa).
    unused = [{ name: 'dead.example', days: -1 }]
    _, line = run_eval([cert('a.example', 5), cert('b.example', -3), cert('c', nil, error: 'x')],
                       unused: unused, timer_active: false, notes: ['note'])
    refute_match(/[\n*?\[;]/, line)
  end
end
