# frozen_string_literal: true

require 'argon2'

module Auth
  # True only when a non-blank password is supplied and matches the stored
  # Argon2 hash. Safely returns false when no password has been set on the
  # account (nil/empty hash) or nothing was submitted, so callers can use it
  # to gate sensitive actions without risking a nil/empty bypass.
  def self.password_match?(password_hash, submitted)
    return false if password_hash.nil? || password_hash.empty?
    return false if submitted.nil? || submitted.empty?

    Argon2::Password.verify_password(submitted, password_hash)
  end
end
