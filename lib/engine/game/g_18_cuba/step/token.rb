# frozen_string_literal: true

require_relative '../../../step/token'
require_relative 'skip_for_national'

module Engine
  module Game
    module G18Cuba
      module Step
        class Token < Engine::Step::Token
          include SkipForNational
        end
      end
    end
  end
end
