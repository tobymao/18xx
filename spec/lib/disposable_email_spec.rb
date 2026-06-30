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
  end
end
