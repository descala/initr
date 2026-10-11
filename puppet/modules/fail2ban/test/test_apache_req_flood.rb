#!/usr/bin/ruby
#
# test_apache_req_flood.rb — proves del filtre apache-req-flood
#
# El filtre compta una coincidència per cada petició no estàtica d'un
# access_log en format combined. Els estàtics no han de comptar: una visita
# normal en demana desenes per pàgina i faria saltar el llindar del jail.
#
# Fa servir el fail2ban-regex de debò, no una imitació del regex en Ruby
# (<HOST>, la detecció de la data i la sintaxi de Python són de fail2ban).
#
# Ús: ruby test_apache_req_flood.rb
#     FAIL2BAN_REGEX=/camí/fail2ban-regex ruby test_apache_req_flood.rb

require 'minitest/autorun'
require 'open3'

FILTER = File.expand_path('../files/apache-req-flood.conf', __dir__)
FAIL2BAN_REGEX = ENV.fetch('FAIL2BAN_REGEX', 'fail2ban-regex')

class TestApacheReqFlood < Minitest::Test
  def log_line(request, status = 200, host: '192.0.2.10')
    %(#{host} - - [10/Oct/2026:10:37:24 +0200] "#{request}" #{status} 1234 "-" "Mozilla/5.0")
  end

  def matches?(line)
    out, status = Open3.capture2e(FAIL2BAN_REGEX, line, FILTER)
    assert status.success?, out
    out[/^Failregex: (\d+) total/, 1].to_i == 1
  end

  def test_counts_dynamic_requests
    [
      'GET / HTTP/1.1',
      'POST /wp-admin/admin-ajax.php HTTP/1.1',
      'GET /wp-login.php HTTP/2.0',
      'GET /?page_id=1&pagename=templates%252f%252e%252e HTTP/1.1',
      'GET /?rest_route=/batch/v1 HTTP/1.1',
      'GET /old/.env HTTP/1.1',
      'HEAD /categoria/ahorro/ HTTP/1.1',
    ].each { |req| assert matches?(log_line(req)), req }
  end

  def test_counts_404_and_410
    assert matches?(log_line('GET /x/f6nqwcbbcq31cpk.phtml HTTP/1.1', 410))
  end

  def test_counts_ipv6_clients
    assert matches?(log_line('GET / HTTP/1.1', host: '2001:db8::1'))
  end

  def test_ignores_static_files
    [
      'GET /wp-content/themes/t/style.css?ver=6.4 HTTP/1.1',
      'GET /wp-includes/js/jquery/jquery.min.js HTTP/1.1',
      'GET /wp-content/uploads/2026/10/foto.JPG HTTP/1.1',
      'GET /logo.svg HTTP/2.0',
      'GET /fonts/x.woff2 HTTP/1.1',
      'GET /favicon.ico HTTP/1.1',
    ].each { |req| refute matches?(log_line(req)), req }
  end

  # el plugin Converter for Media serveix cada imatge per PHP quan no hi ha
  # regles de rewrite (nginx): una pàgina amb 200 imatges són 200 peticions
  def test_ignores_webp_converter_passthru
    refute matches?(log_line('GET /wp-content/webpc-passthru.php?src=https://x.example/wp-content/uploads/2020/10/02.jpg&nocache=1 HTTP/2.0'))
  end

  # una extensió estàtica a la query no fa estàtica la petició
  def test_static_extension_in_query_still_counts
    assert matches?(log_line('GET /index.php?f=style.css HTTP/1.1'))
  end

  def test_ignores_malformed_request_lines
    refute matches?(log_line('\x16\x03\x01', 400))
  end
end
