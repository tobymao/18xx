# frozen_string_literal: true

require 'mini_racer'
require 'opal'

class JsContext
  def initialize(file)
    @file = file
    # Create a snapshot that includes both Opal runtime and the target file
    opal_runtime = Opal::Builder.build('opal').to_s
    file_contents = File.read(@file, encoding: 'UTF-8')
    @snapshot = MiniRacer::Snapshot.new("#{opal_runtime}\n#{file_contents}")
  end

  def eval(script)
    MiniRacer::Context
      .new(snapshot: @snapshot)
      .eval(script, filename: @file)
  end
end
