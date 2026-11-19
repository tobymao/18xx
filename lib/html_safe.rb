# frozen_string_literal: true

# Helpers for safely embedding data into the HTML we render server-side in
# api.rb. Both guard the same page (the inline bootstrap <script> and its
# surrounding tags) against injection, from two different inputs.
module HtmlSafe
  module_function

  # Characters that must not appear literally inside an inline <script>:
  #   <  > &  -> break out of the script / comment context
  #   U+2028 U+2029 (JS line separators) -> invalid raw inside a JS string
  # Built from code points so this source file stays pure ASCII.
  UNSAFE_IN_SCRIPT = Regexp.union('<', '>', '&', [0x2028].pack('U'), [0x2029].pack('U')).freeze

  # Escape a JS source string so it is safe to drop inside an *inline* HTML
  # <script> element. JSON/JS quoting does NOT help here: the HTML tokenizer
  # scans script-data as raw text for the literal "</script" before any JS
  # runs, so a value like "</script><script>...</script>" (e.g. a username)
  # closes the block early and the trailing markup executes.
  #
  # Rewriting the unsafe characters as \uXXXX keeps the string byte-identical
  # at runtime (< decodes to "<" inside a JS string) while ensuring the
  # literal "</script>" never appears in the HTML source. Note this is NOT
  # HTML-entity escaping (&lt;) -- entities are not decoded inside <script>,
  # so that would corrupt the data and still be unsafe.
  def escape_inline_script(js)
    js.to_s.gsub(UNSAFE_IN_SCRIPT) { |c| format('\\u%04x', c.ord) }
  end

  # A game "pin" is a short hex digest (e.g. "01fc40d00") naming a /pinned/*.js
  # bundle. It is interpolated raw into a <script src> and the <title>, so an
  # attacker-supplied ?pin= (or a tampered game setting) that isn't a plain hex
  # token is reflected XSS. Accept only hex; anything else becomes nil so the
  # page renders un-pinned instead of reflecting the input.
  PIN_FORMAT = /\A[a-f0-9]+\z/.freeze

  def safe_pin(pin)
    pin.to_s.match?(PIN_FORMAT) ? pin.to_s : nil
  end
end
