# frozen_string_literal: true

# sets a breakpoint that works on the server and in the browser; once the
# breakpoint is hit, navigate up the call stack* to reach the code where you
# inserted the breakpoint
#
# * Ruby: `up` in the IRB console; JavaScript: use the call stack panel in the
# browser's dev tools
def debug!(js: true, ruby: true)
  if ENV['RACK_ENV'] == 'production'
    LOGGER.warn 'Should not call debug! in production; skipping breakpoint'
    return
  end

  if RUBY_ENGINE == 'opal'
    `debugger;` if js
  elsif ruby
    # rubocop:disable Lint/Debugger
    require 'pry-byebug'
    binding.pry
    # rubocop:enable Lint/Debugger
  end

  nil
end
