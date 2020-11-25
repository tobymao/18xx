# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative '../passable_auction'

module Engine
  module Step
    module G1867
      class BuySellParShares < BuySellParShares
        include PassableAuction
        TOKEN_COST = 50
        MIN_BID = 100
        MAX_BID = 400

        def actions(entity)
          return [] unless entity == current_entity
          return %w[bid pass] if @auctioning

          actions = super
          unless bought?
            actions << 'bid' if can_bid?(entity)
          end
          actions << 'pass' if actions.any? && !actions.include?('pass')
          actions
        end

        def auctioning_corporation
          return @winning_bid.corporation if @winning_bid

          @auctioning
        end

        def active_entities
          return super unless @auctioning

          [@active_bidders[(@active_bidders.index(highest_bid(@auctioning).entity) + 1) % @active_bidders.size]]
        end

        def log_pass(entity)
          return if @auctioning

          super
        end

        def pass!
          return super unless @auctioning

          pass_auction(current_entity)
          resolve_bids
        end

        def process_bid(action)
          if auctioning
            add_bid(action)
          else
            selection_bid(action)
          end
        end

        def add_bid(action)
          entity = action.entity
          corporation = action.corporation
          price = action.price

          if @auctioning
            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
          else
            @log << "#{entity.name} auctions #{corporation.name} for #{@game.format_currency(price)}"
            @game.place_home_token(action.corporation)
          end
          super(action)

          resolve_bids
        end

        def win_bid(winner, _company)
          entity = winner.entity
          corporation = winner.corporation
          price = winner.price

          @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(price)}"
          par_price = price / 2

          share_price = @game.find_share_price(par_price)

          # Temporarily give the entity cash to buy the corporation PAR shares
          @game.bank.spend(share_price.price * 2, entity)

          action = Action::Par.new(entity, corporation: corporation, share_price: share_price)
          process_par(action)

          # Clear the corporation of 'share' cash grabbed earlier.
          corporation.spend(corporation.cash, @game.bank)

          # Then move the full amount.
          entity.spend(price, corporation)

          @auctioning = nil
          pass!
        end

        def can_bid?(entity)
          # @todo: check theres things to bid on
          max_bid(entity) >= MIN_BID
        end

        def min_bid(corporation)
          return MIN_BID unless @auctioning

          highest_bid(corporation).price + min_increment
        end

        def max_bid(player, _corporation = nil)
          [MAX_BID, player.cash].min
        end

        def pass_description
          if @auctioning
            'Pass (Bid)'
          else
            super
          end
        end

        def ipo_via_par?(entity)
          # Major's are par, minors are bid
          entity.total_shares == 10
        end

        def setup
          setup_auction
          super
        end
      end
    end
  end
end
