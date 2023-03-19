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
            corporation = bundle.corporation
            floated = corporation.floated?

            unless can_exchange?(company, bundle)
              raise GameError, "Cannot exchange #{action.entity.id} for #{bundle.corporation.id}"
            end

            bundle.corporation.shares.each { |share| share.buyable = true }

            buy_shares(company.owner, bundle, exchange: company)
            company.close!
          end

          def can_buy?(entity, bundle)
            can_gain?(entity, bundle, exchange: true)
          end

          private

          def can_exchange?(entity, bundle = nil)
            return false unless ['3+3', '4', '4+4'].include?(@game.phase.current[:name])
            return false unless entity.company?
            return false unless (ability = @game.abilities(entity, :exchange))
            
            owner = entity.owner
            return can_gain?(owner, bundle, exchange: true) if bundle
            
            corporation = @game.exchange_corporations(ability).first
            return corporation.floated
          end
        end
      end
    end
  end
end
