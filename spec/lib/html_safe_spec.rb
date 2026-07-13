# frozen_string_literal: true

require 'json'
require_relative '../../lib/html_safe'

describe HtmlSafe do
  describe '.escape_inline_script' do
    # The real stored payload used in the pompomsaturin defacement.
    payload = %(</script><script>document.body.innerHTML='x';fetch('//evil')</script>)

    it 'removes the literal </script> that breaks out of an inline <script>' do
      wrapped = JSON.generate(payload) # what Snabberb.wrap_s emits today
      expect(wrapped).to include('</script>') # the bug

      safe = described_class.escape_inline_script(wrapped)
      expect(safe).not_to include('</script>')
      expect(safe).not_to include('<')
    end

    it 'neutralizes every HTML-parser breakout sequence' do
      ['</script>', '<script', '<!--', '<SCRIPT', ']]>'].each do |seq|
        expect(described_class.escape_inline_script(seq)).not_to include('<')
      end
    end

    it 'escapes < > & to \\uXXXX (matching Django json_script)' do
      expect(described_class.escape_inline_script('<')).to eq('\\u003c')
      expect(described_class.escape_inline_script('>')).to eq('\\u003e')
      expect(described_class.escape_inline_script('&')).to eq('\\u0026')
    end

    it 'escapes the JS line separators U+2028 and U+2029' do
      # Ruby's JSON.generate emits these raw, unlike Python's json.dumps.
      expect(described_class.escape_inline_script([0x2028].pack('U'))).to eq('\\u2028')
      expect(described_class.escape_inline_script([0x2029].pack('U'))).to eq('\\u2029')
    end

    it 'is transparent: the escaped JSON still parses back to the original value' do
      safe = described_class.escape_inline_script(JSON.generate(payload))
      expect(JSON.parse(safe)).to eq(payload)
    end

    it 'preserves ordinary user text through a round-trip' do
      ['Tom & Jerry <3', 'Ann', 'emoji 🎲', 'quote " and \\ slash'].each do |name|
        safe = described_class.escape_inline_script(JSON.generate(name))
        expect(JSON.parse(safe)).to eq(name)
      end
    end

    it 'leaves a string with no unsafe characters unchanged' do
      expect(described_class.escape_inline_script('"hello world"')).to eq('"hello world"')
    end
  end

  describe '.safe_pin' do
    it 'accepts a real hex pin' do
      expect(described_class.safe_pin('01fc40d00')).to eq('01fc40d00')
    end

    it 'rejects a script-breakout pin (reflected XSS via ?pin=)' do
      expect(described_class.safe_pin("x'></script><script>alert(1)</script>")).to be_nil
    end

    it 'rejects non-hex, uppercase, dots, and whitespace' do
      ['abcDEF', 'zzz', '01fc40d00.js', '../secret', 'a b', ''].each do |bad|
        expect(described_class.safe_pin(bad)).to be_nil
      end
    end

    it 'rejects a hex value with a trailing newline (\\z, not \\Z)' do
      expect(described_class.safe_pin("01fc40d00\n")).to be_nil
    end

    it 'returns nil for nil' do
      expect(described_class.safe_pin(nil)).to be_nil
    end
  end
end
