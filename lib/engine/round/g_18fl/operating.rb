# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G18FL
      class Operating < Operating
        attr_accessor :laid_token

        def setup
          @laid_token = {}
          super
        end
      end
    end
  end
end
