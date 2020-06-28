# frozen_string_literal: true

require 'mini_racer'

class JsContext
  WARMUP_LIMIT = 20

  def initialize(file)
    @file = file
    @snapshot = MiniRacer::Snapshot.new(File.read(@file, encoding: 'UTF-8'))
    @warmups = {}
  end

  def eval(script, warmup: nil)
    if warmup && !@warmups[warmup] && @warmups.size < WARMUP_LIMIT
      @snapshot.warmup!(script)
      @warmups[warmup] = true
    end

    context = MiniRacer::Context.new(snapshot: @snapshot)
    context.eval(script, filename: @file)
  end
end
