# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module GFrost1831
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          PHASES_WITHOUT_PRIVATES = %w[5 6 D].freeze

          def actions(entity)
            return [] if phases_without_privates.include?(@game.phase.name)

            super
          end

          private

          def phases_without_privates
            self.class::PHASES_WITHOUT_PRIVATES
          end
        end
      end
    end
  end
end
