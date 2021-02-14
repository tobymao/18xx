# frozen_string_literal: true

require 'mini_racer'

class JsContext
  def initialize(file)
    @file = file
    @snapshot = MiniRacer::Snapshot.new(File.read(@file, encoding: 'UTF-8'))
  end

  def eval(script)
    MiniRacer::Context
      .new(snapshot: @snapshot)
      .eval(script, filename: @file)
  end
end
