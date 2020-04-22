# frozen_string_literal: true

require 'opal'
require 'tilt/opal'

class OpalTemplate < Opal::TiltTemplate
  OPAL_PATH = 'build/compiled-opal.js'

  def evaluate(_scope, _locals)
    builder = Opal::Builder.new(stubs: 'opal')
    builder.append_paths('assets/js')
    builder.append_paths('lib')
    builder.append_paths('build')

    File.binwrite(OPAL_PATH, Opal::Builder.build('opal')) unless File.exist?(OPAL_PATH)
    content = builder.build(file).to_s

    return content if ENV['RACK_ENV'] == 'production'

    map_json = builder.source_map.to_json
    "#{content}\n#{to_data_uri_comment(map_json)}"
  end

  def to_data_uri_comment(map_json)
    "//# sourceMappingURL=data:application/json;base64,#{Base64.encode64(map_json).delete("\n")}"
  end
end

Tilt.register 'rb', OpalTemplate
