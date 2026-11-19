# frozen_string_literal: true

# Canonical form of an email, used to collapse provider aliases (a +tag on any
# provider, and dots that Gmail ignores) so one inbox maps to one account.
module EmailCanonical
  GMAIL_DOMAINS = %w[gmail.com googlemail.com].freeze

  def self.normalize(email)
    local, at, domain = email.to_s.downcase.strip.rpartition('@')
    return email.to_s.downcase.strip if at.empty?

    local = local.gsub(/\+[^@]*/, '')
    local = local.delete('.') if GMAIL_DOMAINS.include?(domain)
    "#{local}@#{domain}"
  end
end
