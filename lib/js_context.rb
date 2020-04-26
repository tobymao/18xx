# frozen_string_literal: true

require 'mini_racer'

class JsContext
  def initialize(file)
    @snapshot = MiniRacer::Snapshot.new(File.read(file, encoding: 'UTF-8'))
  end

  def eval(script)
    context = MiniRacer::Context.new(snapshot: @snapshot)
    context.eval(script, filename: 'app.rb')
  end
end
