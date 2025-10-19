# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1866
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return ['choose_ability'] unless choices_ability(entity).empty?
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            player_debt = entity.debt
            actions = []
            actions << 'buy_shares' if can_buy_any?(entity) && player_debt.zero?
            actions << 'par' if can_ipo_any?(entity) && player_debt.zero?
            actions << 'payoff_player_debt' if player_debt.positive? && entity.cash.positive?
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'pass' unless actions.empty?
            actions
          end

          def bought?
            super || bought_stock_token? || paid_off_player_debt?
          end

          def bought_stock_token?
            @round.current_actions.any? { |x| x.instance_of?(Action::ChooseAbility) && x.choice != 'SELL' }
          end

          def choices_ability(entity)
            return {} if !entity.company? || (entity.company? && !@game.stock_turn_token_company?(entity))
            return {} if @game.stock_turn_token_removed?(active_entities[0])

            choices = {}
            operator = entity.company? ? entity.owner : entity
            valid_token = @game.stock_turn_token?(operator)
            if operator.debt.zero? && !@game.game_end_triggered? && valid_token &&
              @game.num_certs(operator) < @game.cert_limit
              get_par_prices(operator).sort_by(&:price).each do |p|
                par_str = @game.par_price_str(p)
                choices[par_str] = par_str
              end
            end
            price = @game.format_currency(active_entities[0].share_price.price)
            choices['SELL'] = "Sell the Stock Turn Token (#{price})"
            choices
          end

          def description
            'Stock Turn Token Action'
          end

          def get_par_prices(entity, corp = nil)
            return [@game.forced_formation_par_prices(corp).last] if @game.germany_or_italy_national?(corp)

            par_type = @game.phase_par_type
            @game.par_prices_sorted.select do |p|
              multiplier = corp.nil? || @game.major_national_corporation?(corp) ? 1 : 2
              p.types.include?(par_type) && (p.price * multiplier) <= entity.cash &&
                @game.can_par_share_price?(p, corp)
            end
          end

          def log_pass(entity)
            @log << "#{entity.name} passes" if @round.current_actions.empty?
          end

          def process_choose_ability(action)
            entity = action.entity
            choice = action.choice
            if choice == 'SELL'
              @game.sell_stock_turn_token(active_entities[0])
              @game.stock_turn_token_name!(entity)
              track_action(action, entity.owner)
            else
              share_price = nil
              get_par_prices(entity.owner).each do |p|
                next unless choice == @game.par_price_str(p)

                share_price = p
              end
              if share_price
                @game.purchase_stock_turn_token(entity.owner, share_price)
                @game.stock_turn_token_name!(entity)
                track_action(action, entity.owner)
                log_pass(entity.owner)
                pass!
              end
            end
          end

          def process_par(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            raise GameError, "#{corporation} can't be parred" unless @game.can_par?(corporation, entity)

            if corporation.par_via_exchange
              @game.stock_market.set_par(corporation, share_price)

              # Select the president share to buy
              share = corporation.ipo_shares.first

              # Move all to the market
              bundle = ShareBundle.new(corporation.shares_of(corporation).select(&:buyable))
              @game.share_pool.transfer_shares(bundle, @game.share_pool)

              # Buy the share from the bank
              bundle = share.to_bundle
              @game.share_pool.buy_shares(action.entity,
                                          bundle,
                                          exchange: corporation.par_via_exchange,
                                          exchange_price: bundle.price)

              # Close the concession company
              corporation.par_via_exchange.close!

              @game.after_par(corporation)
              track_action(action, corporation)

            elsif corporation.id == @game.class::ITALY_NATIONAL
              @game.forced_formation_major(@game.corporation_by_id(@game.class::ITALY_NATIONAL), %w[K2S SAR LV PAP TUS])
              track_action(action, corporation)

            elsif corporation.id == @game.class::GERMANY_NATIONAL
              @game.forced_formation_major(@game.corporation_by_id(@game.class::GERMANY_NATIONAL), %w[PRU HAN BAV WTB SAX])
              track_action(action, corporation)

            else
              super
            end

            log_pass(action.entity)
            pass!
          end

          def process_payoff_player_debt(action)
            player = action.entity
            @game.payoff_player_loan(player)
            track_action(action, player)
            log_pass(player)
            pass!
          end

          def paid_off_player_debt?
            @round.current_actions.any? { |x| x.instance_of?(Action::PayoffPlayerDebt) }
          end

          def setup
            @round.players_sold = Hash.new { |h, k| h[k] = {} }
            @round.players_history[current_entity].clear
            @round.current_actions = []
            @round.bought_from_ipo = false
          end

          def sold?
            super || sold_stock_token?
          end

          def sold_stock_token?
            @round.current_actions.any? { |x| x.instance_of?(Action::ChooseAbility) && x.choice == 'SELL' }
          end
        end
      end
    end
  end
end
