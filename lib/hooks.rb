# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require 'ipaddr'
require 'resolv'
require 'timeout'

module Hooks
  # IP ranges a user-supplied webhook URL must never reach (SSRF guard):
  # loopback, private, link-local (incl. cloud metadata 169.254.169.254), CGNAT,
  # multicast/reserved, and the IPv4-mapped-IPv6 range (::ffff:0:0/96) that would
  # otherwise let ::ffff:127.0.0.1 slip past the IPv4 checks.
  BLOCKED_IP_RANGES = %w[
    0.0.0.0/8
    10.0.0.0/8
    100.64.0.0/10
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.0.0.0/24
    192.168.0.0/16
    198.18.0.0/15
    224.0.0.0/4
    240.0.0.0/4
    ::/96
    ::1/128
    ::ffff:0:0/96
    64:ff9b::/96
    2002::/16
    2001:db8::/32
    fc00::/7
    fe80::/10
  ].map { |range| IPAddr.new(range) }.freeze

  # Hard cap on webhook-host DNS resolution (Resolv.getaddresses has no timeout of
  # its own); a slow/blackholed host would otherwise stall the notification thread.
  RESOLVE_TIMEOUT = 3

  # True only if +ip+ parses and falls in none of the blocked ranges.
  def self.public_ip?(ip)
    addr = IPAddr.new(ip.to_s)
    BLOCKED_IP_RANGES.none? { |range| range.include?(addr) }
  rescue IPAddr::InvalidAddressError
    false
  end

  # Validate a user-supplied webhook URL and return [uri, ip_to_connect_to], or
  # nil if it must be refused. Requires https and that EVERY resolved address is
  # public. We return the vetted IP so the caller pins the socket to it rather
  # than re-resolving the hostname -- otherwise DNS rebinding could swap in an
  # internal address between this check and the connect. FAILS CLOSED: any parse/
  # resolve error returns nil (an SSRF guard should refuse on doubt).
  def self.safe_target(url)
    uri = URI.parse(url.to_s)
    return nil unless uri.is_a?(URI::HTTPS)
    return nil unless uri.hostname

    ips = Timeout.timeout(RESOLVE_TIMEOUT) { Resolv.getaddresses(uri.hostname) }
    return nil if ips.empty? || ips.any? { |ip| !public_ip?(ip) }

    [uri, ips.first]
  rescue StandardError
    nil
  end

  def self.send(user, message)
    return unless ENV['RACK_ENV'] == 'production'

    target = safe_target(user.settings['webhook_url'] || ENV['SLACK_WEBHOOK_URL'])
    return unless target # non-https, unresolvable, or internal-facing: refuse (SSRF guard)

    uri, ip = target
    req = Net::HTTP::Post.new(uri)
    req.content_type = 'application/json'

    notify_prefix =
      case uri.host
      when 'chat.googleapis.com'
        'users/'
      else
        '@'
      end

    message = "<#{notify_prefix}#{user.settings['webhook_user_id']}> #{message}"

    req.body =
      case uri.host
      when 'discord.com', 'discordapp.com'
        JSON.generate(
          content: message,
          allowed_mentions: { parse: ['users'] },
        )
      else
        JSON.generate(text: message)
      end

    # Pin the connection to the vetted IP; the hostname is still used for TLS
    # SNI/cert verification and the Host header, so this stays rebinding-safe.
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.ipaddr = ip
    http.use_ssl = true
    http.start do |conn|
      conn.request(req).body
    end
  end
end
