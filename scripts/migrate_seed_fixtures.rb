# frozen_string_literal: true

require 'json'

FIXTURES_DIR = File.join(File.dirname(__FILE__), '..', '..', 'public', 'fixtures')

FIXTURE_FILES = Dir.glob("#{FIXTURES_DIR}/**/*json")

def update_fixtures
  FIXTURE_FILES.each do |filename|
    filename = Pathname.new(filename).realpath.to_s

    g = JSON.parse(File.read(filename))

    # update seed for fixing #7465
    g['settings']['seed'] = g['id'].to_s.scan(/\d+/).first.to_i if g['settings'] && g['settings']['seed']

    File.write(filename, g.to_json)

    puts "wrote #{filename}"
  end
end
