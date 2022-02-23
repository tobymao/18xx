# frozen_string_literal: true

require_relative '../../g_1817/step/buy_sell_par_shares'
require_relative 'scrap_train_module'

module Engine
  module Game
    module G18USA
      module Step
        class BuySellParShares < G1817::Step::BuySellParShares
          include ScrapTrainModule
          MIN_BID = 100
          MAX_BID = 100_000
          MAX_PAR_PRICE = 200

          def corporate_actions(entity)
            actions = super
            actions << 'scrap_train' if !@winning_bid && @round.current_actions.none? && can_scrap_train?(entity)
            actions
          end

          def auto_actions(entity)
            return [Engine::Action::Pass.new(entity)] if @auctioning && max_bid(entity, @auctioning) < min_bid(@auctioning)

            []
          end

          def min_increment
            1
          end

          def must_bid_increment_multiple?
            false
          end

          def validate_bid(entity, corporation, bid)
            max_bid = max_bid(entity, corporation)
            raise GameError, "Invalid bid, maximum bidding power is #{max_bid}" if bid > max_bid
          end

          def max_bid(entity, corporation = nil)
            super + (corporation&.tokens&.first&.used ? city_subsidy(corporation)&.value || 0 : max_city_subsidy)
          end

          def max_city_subsidy
            @game.subsidies_by_hex.values.map { |s| s[:value] }.max || 0
          end

          def add_bid(action)
            unless @auctioning
              bid = action.price
              max_bid = @game.bidding_power(action.entity)
              @round.minimum_city_subsidy = bid - max_bid if bid > max_bid
            end

            super
          end

          def win_bid(winner, company)
            corporation = winner.corporation
            unless corporation.tokens.first.hex
              @pending_winning_bid = { winner: winner, company: company }
              return
            end
            @pending_winning_bid = nil

            super

            # Corporation only gets share price * 2 in cash, not the full winning bid
            extra_cash = corporation.cash - (corporation.share_price.price * 2)
            corporation.spend(extra_cash, @game.bank) if extra_cash.positive?

            @game.apply_subsidy(corporation)
          end

          def par_price(bid)
            par_price = super
            [par_price, self.class::MAX_PAR_PRICE].min
          end

          def city_subsidy(corporation)
            corporation.companies.find { |c| c.value.positive? }
          end

          def available_subsidiaries(entity)
            entity ||= current_entity
            return [] if !@winning_bid || @winning_bid.entity != entity

            entity.companies
          end

          def process_assign(action)
            company = action.target
            corporation = @winning_bid.corporation
            price = @winning_bid.price

            current_value = corporation.companies.sum(&:value)
            if current_value + company.value > price
              raise GameError, 'Total company contributions cannot exceed winning bid. ' \
                               "#{@game.format_currency(price - current_value)} remaining."
            end

            super

            if company.id == 'P29'
              if corporation.companies.any? { |c| c.name == 'No Subsidy' }
                @game.log << "#{corporation.name} started in a city with no subsidy and receives a 2 " \
                             "train from #{company.name}"
                @game.buy_train(corporation, @game.depot.depot_trains.first, :free)
              else
                @game.log << "#{corporation.name} not started in city with no subsidy and does not receive " \
                             "a 2 train from #{company.name}"
              end
              company.close!
            end

            company.close! if company.id == 'P14'

            corporation_hex = corporation.tokens.first.hex
            if company.id == 'P10' && @game.potential_metropolitan_hexes.include?(corporation_hex) &&
                !@game.active_metropolitan_hexes.include?(corporation_hex)
              @game.log << "#{company.name} turns #{corporation_hex.location_name} into a metropolis"
              @game.convert_potential_metro(corporation_hex)
              @game.graph.clear
            end

            @game.bank.spend(corporation.cash.abs, corporation) if corporation.cash.negative?
          end

          def contribution_can_exceed_corporation_cash?
            true
          end

          def par_corporation
            return unless @corporation_size

            corporation = @winning_bid.corporation
            corporation.companies.find { |c| c.name == 'No Subsidy' }&.close!
            if corporation.tokens.first.hex.id == 'E11' && @game.metro_denver && @game.hex_by_id('E11').tile.name == 'X04s'
              @round.pending_tracks << {
                entity: corporation,
                hexes: [corporation.tokens.first.hex],
              }
            end

            super
          end

          def after_process_before_skip(_action)
            return unless @pending_winning_bid

            win_bid(@pending_winning_bid[:winner], @pending_winning_bid[:company])
          end
        end
      end
    end
  end
end
