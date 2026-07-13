# frozen_string_literal: true

# File: scripts/build_frontend.rb

# 1. Pre-emptively mock mini_racer to bypass local ARM64 native extension compilation blocks
module MiniRacer
  class Context
    # Dummy mock context placeholder for compiler stability
  end

  class Platform
    # Dummy mock platform placeholder for compiler stability
  end
end
$LOADED_FEATURES << 'mini_racer.rb'
$LOADED_FEATURES << 'mini_racer'

# Mock JsContext to prevent it from trying to instantiate a V8 engine core during compile phase
class JsContext
  def initialize(*args)
    # Void initializer to suppress uncompiled binary lookup crashes
  end
end

require_relative '../lib/assets'
require 'fileutils'

puts '[Asset Pipeline] Initializing native Opal asset translation...'
FileUtils.mkdir_p('public/assets')

# Instantiate the engine's asset compiler manager
assets = Assets.new(compress: false, gzip: false, cache: false, source_maps: false)

puts '[Asset Pipeline] Bundling 1835 view templates and application layouts...'
begin
  compiled_paths = assets.combine(['1835'])
  puts "\n[Asset Pipeline] Success! Compiled frontend assets written to:"
  compiled_paths.each { |path| puts "  -> #{path}" }
rescue StandardError => e
  puts '[Asset Pipeline] Compilation error encountered:'
  puts e.message
  puts e.backtrace.first(5)
end