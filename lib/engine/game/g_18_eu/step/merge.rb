# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'
require_relative '../../../step/token_merger'

module Engine
  module Game
    module G18EU
      module Step
        class Merge < Engine::Step::Base
          include Engine::Step::TokenMerger

          # TODO: Implement Mergers
        end
      end
    end
  end
end
