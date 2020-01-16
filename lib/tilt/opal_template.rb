# frozen_string_literal: true

require 'opal'
require 'tilt/opal'

class OpalTemplate < Opal::TiltTemplate
  def evaluate(_scope, _locals)
    builder = Opal::Builder.new(stubs: 'opal')
    builder.append_paths('assets/js')
    builder.append_paths('lib')
    builder.append_paths('build')

    opal_path = 'build/compiled-opal.js'
    File.write(opal_path, Opal::Builder.build('opal')) unless File.exist?(opal_path)

    content = builder.build(file).to_s
    map_json = builder.source_map.to_json
    "#{content}\n#{to_data_uri_comment(map_json)}"
  end

  def to_data_uri_comment(map_json)
    "//# sourceMappingURL=data:application/json;base64,#{Base64.encode64(map_json).delete("\n")}"
  end
end

Tilt.register 'rb', OpalTemplate
