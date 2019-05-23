# frozen_string_literal: true

module Engine
  module Passer
    attr_reader :passed

    def passed?
      @passed
    end

    def active?
      !@passed
    end

    def pass!
      @passed = true
    end

    def unpass!
      @passed = false
    end
  end
end
