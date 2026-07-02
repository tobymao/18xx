# frozen_string_literal: true

require_relative '../../lib/disposable_email'

describe DisposableEmail do
  describe '.blocked?' do
    it 'blocks a known upstream disposable domain' do
      expect(DisposableEmail.blocked?('mailinator.com')).to be(true)
    end

    it 'blocks via a full email address' do
      expect(DisposableEmail.blocked?('someone@guerrillamail.com')).to be(true)
    end

    it 'blocks minitts.net' do
      expect(DisposableEmail.blocked?('player@minitts.net')).to be(true)
    end

    it 'blocks a custom-added domain below the marker' do
      expect(DisposableEmail.blocked?('disiok.com')).to be(true)
    end

    it 'is case insensitive' do
      expect(DisposableEmail.blocked?('USER@MailInator.COM')).to be(true)
    end

    it 'allows a normal provider' do
      expect(DisposableEmail.blocked?('user@gmail.com')).to be(false)
    end

    it 'returns false for nil or blank input' do
      expect(DisposableEmail.blocked?(nil)).to be(false)
      expect(DisposableEmail.blocked?('')).to be(false)
    end

    it 'blocks a listed domain even with a trailing dot (FQDN-form bypass)' do
      expect(DisposableEmail.blocked?('x@mailinator.com.')).to be(true)
    end
  end

  describe '.banned_mx_host?' do
    it 'matches a banned provider MX host exactly' do
      expect(DisposableEmail.banned_mx_host?('10minutemail.com')).to be(true)
    end

    it 'matches the real 10minutemail backend subdomain' do
      expect(DisposableEmail.banned_mx_host?('prd-smtp.10minutemail.com')).to be(true)
    end

    it 'ignores a trailing dot and is case insensitive' do
      expect(DisposableEmail.banned_mx_host?('PRD-SMTP.10MinuteMail.CoM.')).to be(true)
    end

    it 'does not match a legitimate provider' do
      expect(DisposableEmail.banned_mx_host?('gmail-smtp-in.l.google.com')).to be(false)
    end

    it 'does not match a lookalike that only shares a suffix (no subdomain boundary)' do
      expect(DisposableEmail.banned_mx_host?('evil10minutemail.com')).to be(false)
    end

    it 'returns false for nil or blank' do
      expect(DisposableEmail.banned_mx_host?(nil)).to be(false)
      expect(DisposableEmail.banned_mx_host?('')).to be(false)
    end
  end

  describe '.allowed?' do
    it 'allowlists privacy-relay / forwarding services (never disposable)' do
      expect(DisposableEmail.allowed?('me@icloud.com')).to be(true)
      expect(DisposableEmail.allowed?('x@duck.com')).to be(true)
    end

    it 'allowlists subdomains of a relay (e.g. Firefox Relay)' do
      expect(DisposableEmail.allowed?('a@abc.mozmail.com')).to be(true)
    end

    it 'does not allowlist an ordinary provider' do
      expect(DisposableEmail.allowed?('user@gmail.com')).to be(false)
    end

    it 'keeps an allowlisted relay out of blocked?/mx_blocked? regardless of lists' do
      expect(DisposableEmail.blocked?('me@icloud.com')).to be(false)
      expect(DisposableEmail.mx_blocked?('me@icloud.com')).to be(false)
    end
  end

  describe '.domain_of' do
    it 'extracts the lowercased domain from a full address' do
      expect(DisposableEmail.domain_of('User@Example.COM')).to eq('example.com')
    end

    it 'accepts a bare domain' do
      expect(DisposableEmail.domain_of('example.com')).to eq('example.com')
    end

    it 'returns empty string for nil or blank' do
      expect(DisposableEmail.domain_of(nil)).to eq('')
      expect(DisposableEmail.domain_of('  ')).to eq('')
    end

    it 'strips trailing dot(s) so the FQDN form cannot bypass the blocklist' do
      expect(DisposableEmail.domain_of('user@Example.COM.')).to eq('example.com')
      expect(DisposableEmail.domain_of('example.com..')).to eq('example.com')
    end
  end
end
