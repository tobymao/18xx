# frozen_string_literal: true

module Engine
  class System < Corporation
    def initialize(sym:, name:, **opts)
      super
    end

    def system?
      true
    end
  end
end
