# frozen_string_literal: true

require_relative '../../../step/exchange'
require_relative '../../../action/buy_shares'
require_relative '../../../action/par'
require_relative '../../../action/buy_company'

module Engine
  module Game
    module G1832
      module Step
        class Exchange < Engine::Step::Exchange
          def can_gain?(entity, bundle, exchange: false)
            if exchange && entity == @game.london_company.owner
              return false if @game.p4_invested_in
              return false if bought?
              return false if bundle.corporation.operated?
              return false unless bundle.corporation.ipoed
            end
            super
          end

          def can_exchange?(entity, bundle = nil)
            return super unless entity == @game.london_company

            return false unless entity.owner == @round.current_entity
            return false unless @game.sell_queue.empty?
            return false if @game.p4_invested_in
            return false if bought?

            ability = @game.abilities(entity, :exchange)
            return false unless ability

            if bundle
              return false unless bundle.corporation.ipoed
              return false if bundle.corporation.operated?

              can_gain?(entity.owner, bundle, exchange: true)
            else
              @game.corporations.any? do |corp|
                next false unless corp.ipoed
                next false if corp.operated?

                share = corp.available_share
                share && can_gain?(entity.owner, share.to_bundle, exchange: true)
              end
            end
          end

          # P4 (London Investment) does not close immediately on exchange.
          # It stays open until the invested corporation pays its first dividend.
          def process_buy_shares(action)
            company = action.entity
            bundle = action.bundle
            raise GameError, "Cannot exchange #{company.id} for #{bundle.corporation.id}" unless can_exchange?(company, bundle)

            ability = @game.abilities(company, :exchange)
            buy_shares(company.owner, bundle, exchange: company)
            ability&.use!

            if @round.stock?
              @round.current_actions << action
              @round.players_history[company.owner][bundle.corporation] << action[:players_history]
            end

            @game.p4_invested_in = bundle.corporation
            @game.log << "#{company.name} invests in #{bundle.corporation.name}; closes after first dividend"
          end

          private

          def bought?
            return false unless @round.stock?

            @round.current_actions.any? { |action| BuySellParShares::PURCHASE_ACTIONS.include?(action.class) }
          end
        end
      end
    end
  end
end
