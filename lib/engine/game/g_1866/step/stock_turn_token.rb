# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G1866
      module Step
        class StockTurnToken < Engine::Game::G1866::Step::BuySellParShares
          def actions(entity)
            return ['choose_ability'] unless choices_ability(entity).empty?
            return [] if entity != current_entity || !current_entity.player?
            return %w[buy_shares sell_shares] if must_sell?(current_entity)

            player_debt = entity.debt
            actions = []
            # Must have the buy_shares action, otherwise we dont show the stock page during a operating round
            actions << 'buy_shares'
            actions << 'par' if can_ipo_any?(entity) && player_debt.zero?
            actions << 'payoff_player_debt' if player_debt.positive? && entity.cash.positive?
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'pass' unless actions.empty?
            actions
          end

          def current_entity
            entity = active_entities[0]
            return unless entity

            entity.corporation? && @game.stock_turn_corporation?(entity) ? entity.owner : entity
          end

          def description
            'Stock Turn Token'
          end

          def log_skip(entity)
            return unless @game.stock_turn_corporation?(entity)

            @log << "#{entity.name} has no valid actions and passes"
          end

          def process_buy_shares(action)
            entity = current_entity
            player_debt = entity.debt
            unless player_debt.zero?
              raise GameError, "#{entity.name} can't buy any shares as long there is a loan "\
                               "(#{@game.format_currency(player_debt)})"
            end
            if must_sell?(entity)
              if @game.num_certs(entity) > @game.cert_limit
                raise GameError, "#{entity.name} is above cert limit, must sell shares before any other "\
                                 'actions can be made'
              else
                sell_corporation = @game.corporations.find { |c| !c.holding_ok?(entity) }
                raise GameError, "#{entity.name} must sell shares in #{sell_corporation.name}, before any other "\
                                 'actions can be made'
              end
            end

            corporation = action.bundle.corporation
            previous_president = corporation.owner
            super

            @game.corporation_token_rights!(corporation) unless previous_president == corporation.owner
            check_graph_clear(corporation)
            change_market
            @round.force_next_entity!
          end

          def process_choose_ability(action)
            super
            return if action.choice == 'SELL'

            change_market
            @round.force_next_entity!
          end

          def process_par(action)
            super

            @game.game_end_corporation_operated(action.corporation) if @game.game_end_triggered?
            check_graph_clear(action.corporation)
            change_market
            @round.force_next_entity!
          end

          def process_pass(action)
            super

            change_market
            @round.force_next_entity!
          end

          def process_payoff_player_debt(action)
            super

            change_market
            @round.force_next_entity!
          end

          def process_sell_shares(action)
            entity = current_entity
            corporation = action.bundle.corporation
            previous_president = corporation.owner
            super

            check_graph_clear(corporation)
            @round.recalculate_order
            @game.corporation_token_rights!(corporation) unless previous_president == corporation.owner
            @game.all_corporation_token_rights(entity) if @game.national_corporation?(corporation)
          end

          def issuable_shares(_entity)
            []
          end

          def redeemable_shares(_entity)
            []
          end

          def check_graph_clear(corporation)
            return unless @game.national_corporation?(corporation)

            @game.graph.clear
          end

          def change_market
            entity = active_entities[0]
            return if @game.stock_turn_token_removed?(entity)

            if @game.game_end_triggered?
              @log << 'End game is triggered, the stock turn token will be sold'
              @game.sell_stock_turn_token(entity)
              player = entity.owner
              st_company = player.companies.find { |c| @game.stock_turn_token_company?(c) }
              @game.stock_turn_token_name!(st_company)
              return
            end

            bought = bought?
            sold = sold?
            times = 2
            times = 1 if bought || sold
            times = 0 if bought && sold
            return unless times.positive?

            current_price = entity.share_price.price
            times.times { @game.stock_market.move_right(entity) }
            @log << "#{current_entity.name}'s stock turn token price changes from "\
                    "#{@game.format_currency(current_price)} to #{@game.format_currency(entity.share_price.price)}"\
                    "#{times > 1 ? " (#{times} steps)" : ''}"
          end
        end
      end
    end
  end
end
