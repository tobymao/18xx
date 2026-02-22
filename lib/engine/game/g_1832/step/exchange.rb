# frozen_string_literal: true

require_relative '../../../step/exchange'
require_relative '../../../step/share_buying'

module Engine
  module Game
    module G1832
      module Step
        class Exchange < Engine::Step::Exchange

          def process_buy_shares(action)
            company = action.entity
            bundle = action.bundle
            unless (ability = @game.abilities(company, :exchange))
              raise GameError,
                    "Could not assign #{company.name} to #{target.name}; :exchange ability not found"
            end
            raise GameError, "Cannot exchange #{action.entity.id} for #{bundle.corporation.id}" unless can_exchange?(company,
                                                                                                                     bundle)

            buy_shares(company.owner, bundle, exchange: company)
            @round.players_history[company.owner][bundle.corporation] << action if @round.respond_to?(:players_history)
            if company.name == 'London Investment'
              @game.assign_london_company(bundle.corporation)
              ability.use!
              @round.current_actions << action
            end
            company.close! if company.name != 'London Investment'
          end

          def can_buy?(entity, bundle)
            can_gain?(entity, bundle, exchange: true)
          end

          def can_exchange?(entity, bundle = nil)
            return false unless entity.company?
            return false unless (ability = @game.abilities(entity, :exchange))

            owner = entity.owner
            return can_gain?(owner, bundle, exchange: true) if bundle

            shares = []
            @game.exchange_corporations(ability).each do |corporation|
              shares << corporation.reserved_shares.first if ability.from.include?(:reserved)
              shares << corporation.available_share if ability.from.include?(:ipo)
              shares << @game.share_pool.shares_by_corporation[corporation]&.first if ability.from.include?(:market)
            end

            shares.compact.any? { |s| can_gain?(entity.owner, s&.to_bundle, exchange: true) }
          end
        end
      end
    end
  end
end
