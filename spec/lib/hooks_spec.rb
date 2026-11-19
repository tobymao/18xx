# frozen_string_literal: true

require_relative '../../lib/hooks'

describe Hooks do
  describe '.public_ip?' do
    it 'accepts public addresses' do
      ['1.1.1.1', '8.8.8.8', '140.82.121.4'].each do |ip|
        expect(Hooks.public_ip?(ip)).to be(true)
      end
    end

    it 'rejects loopback, private, link-local, and CGNAT ranges' do
      ['127.0.0.1', '10.0.0.1', '172.16.5.5', '192.168.1.1',
       '169.254.169.254', '100.64.0.1'].each do |ip|
        expect(Hooks.public_ip?(ip)).to be(false)
      end
    end

    it 'rejects IPv6 loopback/ULA/link-local and the IPv4-mapped bypass' do
      ['::1', 'fc00::1', 'fe80::1', '::ffff:127.0.0.1'].each do |ip|
        expect(Hooks.public_ip?(ip)).to be(false)
      end
    end

    it 'rejects IPv6 that embeds an internal IPv4 (NAT64 / 6to4 / IPv4-compatible)' do
      ['64:ff9b::7f00:1', '2002:7f00:1::', '::7f00:1'].each do |ip|
        expect(Hooks.public_ip?(ip)).to be(false)
      end
    end

    it 'rejects unparseable input' do
      expect(Hooks.public_ip?('garbage')).to be(false)
      expect(Hooks.public_ip?(nil)).to be(false)
    end
  end

  describe '.safe_target' do
    # IP-literal URLs make this deterministic: Resolv echoes the literal, no DNS.
    it 'allows an https URL whose address is public, pinning to that IP' do
      uri, ip = Hooks.safe_target('https://1.1.1.1/services/abc')
      expect(uri).to be_a(URI::HTTPS)
      expect(ip).to eq('1.1.1.1')
    end

    it 'refuses non-https schemes' do
      expect(Hooks.safe_target('http://1.1.1.1/hook')).to be_nil
      expect(Hooks.safe_target('ftp://1.1.1.1')).to be_nil
    end

    it 'refuses internal-facing addresses (SSRF guard)' do
      ['https://127.0.0.1/h', 'https://169.254.169.254/latest/meta-data',
       'https://10.0.0.5/x', 'https://192.168.1.1/x', 'https://[::1]/x'].each do |url|
        expect(Hooks.safe_target(url)).to be_nil
      end
    end

    it 'fails closed on junk / blank / nil input' do
      ['garbage', '', nil].each do |url|
        expect(Hooks.safe_target(url)).to be_nil
      end
    end
  end
end
