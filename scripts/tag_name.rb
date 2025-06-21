# frozen_string_literal: true

require 'json'

# Prints to STDOUT the timestamp found in version.json in a compact format
# suitable for creating a git tag

file = File.join(File.dirname(__FILE__), '../public/assets/version.json')
version = JSON.parse(File.read(file))
timestamp = version['version_epochtime'].to_i
version_localtime = Time.at(timestamp)

print version_localtime.strftime('%Y-%m-%d_%H.%M.%S')
