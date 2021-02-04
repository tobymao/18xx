# frozen_string_literal: true

require 'mini_racer'

class JsContext
  def initialize(files)
    @files = files
    combined_files = files.map { |f| File.read(f, encoding: 'UTF-8').to_s }.join
    @snapshot = MiniRacer::Snapshot.new(combined_files)
  end

  def eval(script)
    MiniRacer::Context
      .new(snapshot: @snapshot)
      .eval(script, filename: @files.join('|'))
  end
end
