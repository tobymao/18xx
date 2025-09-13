# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'upwards_auction'

module Engine
  module Game
    module GSystem18
      module Step
        class ConsecutiveAuction < GSystem18::Step::UpwardsAuction
          def available
            [@companies.first]
          end
        end
      end
    end
  end
end
