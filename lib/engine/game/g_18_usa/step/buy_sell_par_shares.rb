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
            # Determine the subsidy before proessing the winning bid
            corporation = winner.corporation
            unless corporation.tokens.first.hex
              @pending_winning_bid = { winner: winner, company: company }
              return
            end
            @pending_winning_bid = nil

            @winning_bid = winner
            entity = @winning_bid.entity
            price = @winning_bid.price

            @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(price)}"

            par_price = [price / 2, self.class::MAX_PAR_PRICE].min
            share_price = @game.find_share_price(par_price)

            # Temporarily give the entity cash to buy the corporation PAR shares
            @game.bank.spend(share_price.price * 2, entity)

            action = Action::Par.new(entity, corporation: corporation, share_price: share_price)
            process_par(action)

            # Clear the corporation of 'share' cash
            corporation.spend(corporation.cash, @game.bank)

            # Player spends cash to start corporation, even if it forces them negative
            # which they'll need to sort by adding companies.
            starting_cash = share_price.price * 2
            entity.spend(starting_cash, corporation, check_cash: false)
            entity.spend(price - starting_cash, @game.bank, check_cash: false) if price > starting_cash

            @corporation_size = nil
            size_corporation(@game.phase.corporation_sizes.first) if @game.phase.corporation_sizes.one?

            @remaining_bid_amount = price
            @game.apply_subsidy(corporation)
            par_corporation if available_subsidiaries(winner.entity).none?
          end

          def city_subsidy(corporation)
            corporation.companies.find { |c| c.value.positive? }
          end

          def available_subsidiaries(entity)
            entity ||= current_entity
            return [] if !@winning_bid || @winning_bid.entity != entity

            max_total = @remaining_bid_amount
            min_total = entity.cash.negative? ? entity.cash.abs : 0

            # Filter potential values to those that are valid options
            options = available_company_options(entity).select do |option|
              total = option.sum
              total >= min_total && total <= max_total
            end.flatten

            entity.companies.select do |company|
              options.include?(company.value)
            end
          end

          def process_assign(action)
            super
            @remaining_bid_amount -= action.target.value
          end

          def use_on_assign_abilities(company)
            case company.id
            when 'P10'
              use_p10_ability(company)
            when 'P14'
              company.close!
            when 'P29'
              use_p29_ability(company)
            else
              super
            end
          end

          def use_p10_ability(company)
            corporation = company.owner
            corporation_hex = corporation.tokens.first.hex
            hex_name = "#{corporation_hex.name} (#{corporation_hex.location_name})"
            if @game.active_metropolitan_hexes.include?(corporation_hex)
              @game.log << "#{hex_name} is already a Metropolis"
            elsif !@game.potential_metropolitan_hexes.include?(corporation_hex)
              @game.log << "#{hex_name} is not an unselected Metropolis and cannot become a Metroplis"
            elsif corporation_hex.tile.color != :white
              @game.log << "#{hex_name} has already been improved and can no longer become a Metropolis"
            else
              @game.log << "#{hex_name} becomes a Metropolis"
              @game.convert_potential_metro(corporation_hex)
            end
            company.close!
          end

          def use_p29_ability(company)
            corporation = company.owner
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

          def contribution_can_exceed_corporation_cash?
            true
          end

          def par_corporation
            return unless @corporation_size

            @remaining_bid_amount = 0
            corporation = @winning_bid.corporation
            @game.bank.spend(corporation.cash.abs, corporation) if corporation.cash.negative?
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
