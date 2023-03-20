# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/share_buying'

module Engine
  module Game
    module G1847AE
      module Step
        class Exchange < Engine::Step::Base
          include Engine::Step::ShareBuying

          EXCHANGE_ACTIONS = %w[buy_shares].freeze

          def actions(entity)
            actions = []
            actions.concat(EXCHANGE_ACTIONS) if can_exchange?(entity)
            actions
          end

          def blocks?
            false
          end

          def process_buy_shares(action)
            company = action.entity
            bundle = action.bundle

            unless can_exchange?(company, bundle)
              raise GameError, "Cannot exchange #{action.entity.id} for #{bundle.corporation.id}"
            end

            bundle.shares.each { |share| share.buyable = true }
            buy_shares(company.owner, bundle, exchange: company)
            company.close!

            # count this as a buy action
            @round.current_actions << action
          end

          def can_buy?(entity, bundle)
            can_gain?(entity, bundle, exchange: true)
          end

          private

          def can_exchange?(entity, _bundle = nil)
            return false unless entity.company?
            return false unless (ability = @game.abilities(entity, :exchange))

            corporation = @game.exchange_corporations(ability).first
            @game.can_corporation_have_investor_shares_exchanged?(corporation)
          end
        end
      end
    end
  end
end
