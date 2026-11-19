# frozen_string_literal: true

require 'argon2'
require_relative '../../lib/auth'

describe Auth do
  let(:hash) { Argon2::Password.create('correct horse') }

  describe '.password_match?' do
    it 'accepts the correct password' do
      expect(Auth.password_match?(hash, 'correct horse')).to be(true)
    end

    it 'rejects a wrong password' do
      expect(Auth.password_match?(hash, 'wrong')).to be(false)
    end

    it 'rejects a blank submission' do
      expect(Auth.password_match?(hash, '')).to be(false)
    end

    it 'rejects a nil submission' do
      expect(Auth.password_match?(hash, nil)).to be(false)
    end

    it 'rejects when the stored hash is nil (no password set)' do
      expect(Auth.password_match?(nil, 'anything')).to be(false)
    end

    it 'rejects when the stored hash is empty' do
      expect(Auth.password_match?('', 'anything')).to be(false)
    end
  end
end
