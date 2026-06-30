# frozen_string_literal: true

require 'set'

# Blocklist of disposable/throwaway email domains, used to reject them at
# signup. The list is a single file (config/disposable_email_domains.txt): the
# upstream open-source list lives above a `#` marker line and is replaced by the
# `disposable:refresh` rake task, while hand-added domains live below the marker
# and are preserved across refreshes. Lookups ignore the marker (and any blank
# or comment line), so both sections feed the same set.
#
# This only gates new account creation; existing users are never re-checked, so
# grandfathered accounts on a now-blocked domain are unaffected.
module DisposableEmail
  PATH = File.expand_path('../config/disposable_email_domains.txt', __dir__)
  MARKER = '# === custom additions below (refresh replaces everything above this line) ==='

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

  # Accepts a full email address or a bare domain. Returns false for nil/blank
  # so callers can use it directly to gate signups without a nil guard.
  def self.blocked?(email_or_domain)
    domain = email_or_domain.to_s.downcase.strip
    domain = domain.split('@').last if domain.include?('@')
    return false if domain.nil? || domain.empty?

    domains.include?(domain)
  end
end
