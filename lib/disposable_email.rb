# frozen_string_literal: true

require 'set'
require 'resolv'
require 'timeout'

# Blocklist of disposable/throwaway email domains, used to reject them at
# signup. The list is a single file (config/disposable_email_domains.txt): the
# upstream open-source list lives above a `#` marker line and is replaced by the
# `disposable:refresh` rake task, while hand-added domains live below the marker
# and are preserved across refreshes. Lookups ignore the marker (and any blank
# or comment line), so both sections feed the same set.
#
# Some providers (notably 10minutemail) also rotate through an endless supply of
# random domain names faster than any static list can track, so we additionally
# match the shared mail-server (MX) backend those domains funnel through -- see
# BANNED_MX_DOMAINS / .mx_blocked?.
#
# This only gates new account creation; existing users are never re-checked, so
# grandfathered accounts on a now-blocked domain are unaffected.
module DisposableEmail
  PATH = File.expand_path('../config/disposable_email_domains.txt', __dir__)
  MARKER = '# === custom additions below (refresh replaces everything above this line) ==='

  # Registrable domains of throwaway-provider MX backends. Domain blocklists
  # can't keep up with providers that mint random domains on demand (e.g.
  # 10minutemail: kjkpc.net, vtmpj.com, ... all MX -> prd-smtp.10minutemail.com),
  # but every rotated domain still shares one MX backend. Matching that backend
  # catches the whole provider regardless of the domain-of-the-day. Each entry
  # matches the host itself and any subdomain of it.
  #
  # Derived by resolving MX for the whole disposable_email_domains.txt list and
  # keeping backends that (a) serve many disposable domains and (b) are exclusive
  # to a throwaway provider. Refresh via `rake disposable:mx_cluster` (below).
  #
  # DELIBERATELY EXCLUDED (legit shared infra that also serves disposable domains
  # -- adding these would block real users): Google (aspmx.l.google.com), Mailgun
  # (*.mailgun.org), AWS SES (*.amazonaws.com), Outlook/Microsoft, Zoho, Proton
  # (protonmail.ch), Yandex, OVH, Namecheap (registrar-servers.com /
  # privateemail.com), and domain parking (park-mx.above.com, hostedmxserver.com).
  BANNED_MX_DOMAINS = %w[
    10minutemail.com
    1secmail.com
    aerospaceemail.com
    beavis99.com
    beavis99.net
    blueberrymail.net
    brushemail.com
    bumpemail.com
    casadorock.com
    catchservers.com
    catchservers.net
    discard.email
    email-fake.com
    emailfake.com
    erinn.biz
    fex.plus
    generator.email
    generic-isp.com
    gravityengine.cc
    guerrillamail.com
    h-email.net
    infos.st
    m1bp.com
    mailbox49.com
    mailcore.email
    mailinator.com
    mainnetmail.com
    mail.tm
    mb5p.com
    moakt.com
    mx.cloudflare.net
    nukemail.app
    oneb.net
    papierkorb.me
    rejecthost.com
    spam4.me
    spamgourmet.com
    tempm.com
    trashmail.com
    wabblywabble.com
    wallywatts.com
    yopmail.com
  ].freeze

  MX_TIMEOUT = 2 # seconds -- DNS resolves inline at signup, so keep it short

  # Privacy-relay / forwarding services. They mint unique addresses tied to REAL
  # people and never auto-expire, so they must NEVER be treated as disposable --
  # even if a blocklist entry or MX heuristic would otherwise flag them. Matches
  # the domain itself and any subdomain of it.
  ALLOWED_DOMAINS = %w[
    icloud.com
    privaterelay.appleid.com
    mozmail.com
    relay.firefox.com
    simplelogin.io
    aleeas.com
    slmail.me
    duck.com
  ].freeze

  def self.domains
    @domains ||= load_domains(PATH)
  end

  def self.load_domains(path)
    File.foreach(path).each_with_object(Set.new) do |line, set|
      domain = line.strip.downcase
      next if domain.empty? || domain.start_with?('#')

      set << domain
    end.freeze
  end

  # Accepts a full email address or a bare domain; returns the lowercased domain
  # (empty string for nil/blank).
  def self.domain_of(email_or_domain)
    domain = email_or_domain.to_s.downcase.strip
    domain = domain.split('@').last if domain.include?('@')
    # Strip trailing dot(s): "gmail.com." is the same deliverable domain, but the
    # trailing dot would miss the exact static-list lookup and evade the block.
    domain.to_s.sub(/\.+\z/, '')
  end

  # True if the domain is an allowlisted privacy-relay / forwarding service that
  # must never be treated as disposable (see ALLOWED_DOMAINS). Matches the domain
  # itself or any subdomain of an allowlisted entry.
  def self.allowed?(email_or_domain)
    domain = domain_of(email_or_domain)
    return false if domain.empty?

    ALLOWED_DOMAINS.any? { |a| domain == a || domain.end_with?(".#{a}") }
  end

  # Fast, no-network check against the static blocklist. Returns false for
  # nil/blank input and for allowlisted relays, so callers can use it directly to
  # gate signups without a nil guard.
  def self.blocked?(email_or_domain)
    domain = domain_of(email_or_domain)
    return false if domain.empty? || allowed?(domain)

    domains.include?(domain)
  end

  # True if a hostname is, or is a subdomain of, a banned provider MX backend.
  def self.banned_mx_host?(host)
    host = host.to_s.downcase.chomp('.')
    return false if host.empty?

    BANNED_MX_DOMAINS.any? { |bad| host == bad || host.end_with?(".#{bad}") }
  end

  # True if the domain's MX records point at a banned provider backend. Resolves
  # DNS inline, so it FAILS OPEN: any resolver error/timeout (or a domain with no
  # MX) returns false rather than blocking a legitimate signup on a transient DNS
  # hiccup. Check .blocked? first (it's free) and only fall through to this.
  def self.mx_blocked?(email_or_domain, timeout: MX_TIMEOUT)
    domain = domain_of(email_or_domain)
    return false if domain.empty? || allowed?(domain)

    # Hard wall-clock cap: dns.timeouts is per-attempt, so with retries/multiple
    # nameservers a slow/blackholed domain could otherwise stall the signup thread
    # for many seconds (DoS). Timeout::Error is a StandardError -> rescued -> false.
    hosts = Timeout.timeout(timeout + 1) do
      Resolv::DNS.open do |dns|
        dns.timeouts = timeout
        dns.getresources(domain, Resolv::DNS::Resource::IN::MX).map { |mx| mx.exchange.to_s }
      end
    end
    hosts.any? { |host| banned_mx_host?(host) }
  rescue StandardError
    false
  end
end
