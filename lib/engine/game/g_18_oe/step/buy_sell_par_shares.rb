# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18OE
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            actions = super
            actions << 'pass' if actions.any?
            actions
          end

          def float_minor(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            company = find_minor_company(corporation)

            @log << "#{entity.name} floats #{company.sym}"
            @log << "Available track rights zones: #{@game.minor_available_regions}"

            @game.stock_market.set_par(corporation, share_price)
            share = corporation.ipo_shares.first
            @round.players_bought[entity][corporation] += share.percent
            buy_shares(entity, share.to_bundle, exchange: company, silent: true)
            company.close!
            track_action(action, action.corporation)
          end

          def find_minor_company(minor)
            @game.companies.find { |c| c.id == minor.id }
          end

          def ipo_type(entity)
            if entity.type == :minor && current_entity.companies.include?(find_minor_company(entity))
              :form
            elsif entity.type == :minor
              'Must have bought minor in auction phase'
            else
              :par
            end
          end

          def visible_corporations
            # @game.corporations + @game.minors
            @game.sorted_corporations.reject { |c| (c.type == :minor && c.ipoed) }
          end

          def process_par(action)
            if action.corporation.type == :minor
              float_minor(action)
            else
              super
            end

            # Add regional to the minor/regional operating order
            @game.minor_regional_order << action.corporation
          end
        end
      end
    end
  end
end
