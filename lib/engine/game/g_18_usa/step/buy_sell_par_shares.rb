# frozen_string_literal: true

require_relative '../../g_1817/step/buy_sell_par_shares'

module Engine
  module Game
    module G18USA
      module Step
        class BuySellParShares < G1817::Step::BuySellParShares
          MIN_BID = 100
          MAX_BID = 400

          def min_increment
            1
          end

          def max_bid(entity, _corporation = nil)
            return 0 if @game.num_certs(entity) >= @game.cert_limit

            @game.bidding_power(entity)
          end

          def add_bid(action)
            entity = action.entity
            corporation = action.corporation
            price = action.price

            available_privates = entity.companies.sum(&:value)
            max_bid_power = available_privates + entity.cash

            raise GameError, "Invalid bid, maximum bidding power is #{max_bid_power}" if price > max_bid_power

            if @auctioning
              @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
            else
              @log << "#{entity.name} auctions #{corporation.name} for #{@game.format_currency(price)}"
              @round.last_to_act = action.entity
              @round.current_actions.clear
              @game.place_home_token(action.corporation)
            end
            super(action)

            resolve_bids
          end

          def win_bid(winner, _company)
            @winning_bid = winner
            entity = @winning_bid.entity
            corporation = @winning_bid.corporation
            price = @winning_bid.price

            @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(price)}"

            par_price = price / 2
            if par_price > 200
              @log << "Par price is capped at #{@game.format_currency(200)}"
              par_price = 200
            end

            share_price = @game.find_share_price(par_price)

            # Temporarily give the entity cash to buy the corporation PAR shares
            @game.bank.spend(share_price.price * 2, entity)

            action = Action::Par.new(entity, corporation: corporation, share_price: share_price)
            process_par(action)

            # Clear the corporation of 'share' cash
            corporation.spend(corporation.cash, @game.bank)

            @subsidy = find_bank_subsidy(corporation)
            if @subsidy
              @game.log << "Bank provides a #{@game.format_currency(@subsidy.value)} "\
                           "subsidy to #{entity.name}"
            end

            transfer_subsidy_ownership(entity) if @subsidy

            # Player spends cash to the *BANK* to start corporation, even if it forces them negative
            # which they'll need to sort by adding companeis.
            entity.spend(price, @game.bank, check_cash: false) # min bid is 100, max subsidy is 50; no if needed.

            # The bank gives the corporation 2x par price
            @game.bank.spend(share_price.price * 2, corporation)

            @corporation_size = nil
            size_corporation(@game.phase.corporation_sizes.first) if @game.phase.corporation_sizes.one?

            par_corporation if available_subsidiaries(winner.entity).none?
          end

          def transfer_subsidy_ownership(to)
            from = @subsidy.owner
            @subsidy.owner = to
            from.companies.delete(@subsidy)
            to.companies << @subsidy
          end

          def find_bank_subsidy(corporation)
            corporation.companies.find { |c| c.value.positive? }
          end

          def available_subsidiaries(entity)
            entity ||= current_entity
            return [] if !@winning_bid || @winning_bid.entity != entity

            entity.companies
          end

          def process_assign(action)
            entity = action.entity
            company = action.target
            corporation = @winning_bid.corporation
            raise GameError, 'Cannot use company in formation' unless available_subsidiaries(entity).include?(company)

            company.owner = corporation
            entity.companies.delete(company)
            corporation.companies << company
            company_contribution = [company.value, corporation.cash].min

            # Pay the player for the company
            corporation.spend(company_contribution, entity) if company_contribution.positive?

            @log << "#{company.name} used for forming #{corporation.name} "\
                    "contributing #{@game.format_currency(company_contribution)} value"

            @game.abilities(company, :additional_token) do |ability|
              corporation.tokens << Engine::Token.new(corporation)
              ability.use!
            end

            if company.id == 'P29' && corporation.companies.any? { |c| c.name == 'No Subsidy' }
              @game.log << "#{corporation.name} immediately gets a free 2 train and #{company.name} closes"
              @game.buy_train(corporation, @game.depot.depot_trains.first, :free)
              company.close!
            end

            par_corporation if available_subsidiaries(entity).empty?
          end

          def handle_plus_ten(subsidy_company)
            subsidy_company.owner.tokens.first.hex.tile.icons << Engine::Part::Icon.new('18_usa/plus_ten', sticky: true)
            subsidy_company.close!
          end

          def handle_plus_ten_twenty(subsidy_company)
            subsidy_company.owner.tokens.first.hex.tile.icons << Engine::Part::Icon.new('18_usa/plus_ten_twenty', sticky: true)
            subsidy_company.close!
          end

          def par_corporation
            return unless @corporation_size

            corporation = @winning_bid.corporation
            corporation.companies.each { |c| c.close! if c.name == 'No Subsidy' }
            corporation.companies.each { |c| handle_plus_ten(c) if c.name == '+10' }
            corporation.companies.each { |c| handle_plus_ten_twenty(c) if c.name == '+10 / +20' }

            # Close all unused value subsidies. Don't get greedy
            corporation.owner.companies.each do |c|
              if c.value.positive?
                @game.log << "#{corporation.owner.name} forfeits the #{@game.format_currency(c.value)} subsidy"
                c.close!
              end
            end

            @log << "#{corporation.name} starts with #{@game.format_currency(corporation.cash)} "\
                    "and #{@corporation_size} shares"

            try_buy_tokens(corporation)

            @auctioning = nil
            @winning_bid = nil
            pass!
          end
        end
      end
    end
  end
end
