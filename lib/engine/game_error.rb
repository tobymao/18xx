# frozen_string_literal: true

module Engine
  class GameError < RuntimeError
    attr_accessor :action_id
    def initialize(msg, action_id = nil)
      @action_id = action_id
      super(msg)
    end
  end
end
