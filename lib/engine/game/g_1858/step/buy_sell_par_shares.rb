# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1858
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include Engine::Step::PassableAuction

          def actions(entity)
            return entity == current_entity ? %w[bid pass] : [] if @auctioning || @game.turn == 1

            super
          end

          def setup
            setup_auction
            super
          end

          def active_entities
            return super unless @auctioning

            [@active_bidders[(@active_bidders.index(highest_bid(@auctioning).entity) + 1) % @active_bidders.size]]
          end

          def auctioning_company
            return @winning_bid.company if @winning_bid

            @auctioning
          end

          def min_bid(company)
            return unless company
            return company.value - company.discount if @bids[company].empty?

            highest_bid(company).price + min_increment
          end

          def max_bid(player, _company)
            player.cash
          end

          def can_bid?(_entity, company)
            @auctioning.nil? || @auctioning == company
          end

          def pass!
            return super unless @auctioning

            pass_auction(current_entity)
            resolve_bids
          end

          def process_bid(action)
            if @auctioning
              add_bid(action)
            else
              selection_bid(action)
              track_action(action, action.company)
            end
          end

          def add_bid(action)
            entity = action.entity
            company = action.company
            price = action.price

            if @auctioning
              @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"
            else
              @log << "#{entity.name} auctions #{company.name} for #{@game.format_currency(price)}"
              @round.last_to_act = action.entity
              @round.current_actions.clear
            end
            super(action)

            resolve_bids
          end

          def win_bid(winner, _company)
            @winning_bid = winner
            entity = @winning_bid.entity
            company = @winning_bid.company
            price = @winning_bid.price

            entity.spend(price, @game.bank)

            entity.companies << company
            company.owner = entity

            minor = @game.minors.find { |m| m.id == company.id }
            minor.owner = entity
            minor.float!

            @log << "#{entity.name} wins bid on #{company.name} for #{@game.format_currency(price)}"

            @auctioning = nil
            @winning_bid = nil
            pass!
          end
        end
      end
    end
  end
end
