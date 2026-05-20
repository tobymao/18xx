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
            if exchange && entity == @game.london_company&.owner
              return false unless @game.p4_invested_in.nil?
              return false if bought?
              return false unless bundle.corporation.ipoed
              return false if bundle.corporation.operated?
            end
            super
          end

          def can_exchange?(entity, bundle = nil)
            return super unless entity == @game.london_company

            return false unless entity.owner == @round.current_entity
            return false unless @game.p4_invested_in.nil?
            return false if bought?
            return false if @game.sell_queue.any?

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
            @round.current_actions << action if @round.respond_to?(:current_actions)
            @round.players_history[company.owner][bundle.corporation] << action if @round.respond_to?(:players_history)

            if company == @game.london_company
              @game.p4_invested_in = bundle.corporation
              @game.log << "#{company.name} invests in #{bundle.corporation.name}; closes after first dividend"
            else
              company.close!
            end
          end

          private

          def bought?
            return false unless @round.respond_to?(:current_actions)

            @round.current_actions.any? do |x|
              x.is_a?(Action::BuyShares) || x.is_a?(Action::Par) || x.is_a?(Action::BuyCompany)
            end
          end
        end
      end
    end
  end
end
