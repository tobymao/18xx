# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative '../../action/take_loan'
require_relative 'passable_auction'

module Engine
  module Step
    module G1817
      class BuySellParShares < BuySellParShares
        include PassableAuction

        def actions(entity)
          return ['take_loan'] if @game.can_take_loan?(entity) && entity.owned_by?(current_entity)
          return [] if !entity.player? || @current_actions.any? { |a| a.is_a?(Action::TakeLoan) }

          if available_subsidiaries(entity).any?
            actions = %w[assign]
            actions << 'pass' if entity.cash >= @winning_bid.price
            return actions
          end

          return %w[bid pass] if @auctioning

          actions = super
          actions |= %w[bid pass] unless bought?
          actions
        end

        def active_entities
          return [@winning_bid.entity] if @winning_bid
          return super unless @auctioning

          [@active_bidders[(@active_bidders.index(highest_bid(@auctioning).entity) + 1) % @active_bidders.size]]
        end

        def auctioning_corporation
          return @winning_bid.corporation if @winning_bid

          @auctioning
        end

        def pass_description
          return 'Pass (Subsidiaries)' if available_subsidiaries.any?
          return super unless @auctioning

          'Pass (Bid)'
        end

        def log_pass(entity)
          return super unless @auctioning
        end

        def pass!
          return par_corporation if @winning_bid
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
            @round.last_to_act = action.entity
            @current_actions.clear
            @game.place_home_token(action.corporation)
          end
          super(action)

          resolve_bids
        end

        def process_assign(action)
          entity = action.entity
          company = action.target
          corporation = @winning_bid.corporation
          @game.game_error('Cannot use company in formation') unless available_subsidiaries(entity).include?(company)
          @subsidiaries << company
          @log << "#{company.name} used for forming #{corporation.name} "\
            "contributing #{@game.format_currency(company.value)} value"
          par_corporation if available_subsidiaries(entity).empty?
        end

        def process_take_loan(action)
          @current_actions << action
          @game.take_loan(action.entity, action.loan)
        end

        def par_corporation
          entity = @winning_bid.entity
          corporation = @winning_bid.corporation
          price = @winning_bid.price
          par_price = price / 2

          share_price = @game.find_share_price(par_price)
          action = Action::Par.new(@winning_bid.entity, corporation: @winning_bid.corporation, share_price: share_price)
          process_par(action)
          corporation.spend(corporation.cash, entity)

          @subsidiaries.each do |company|
            company.owner = corporation
            entity.companies.delete(company)
            corporation.companies << company
            price -= company.value
            company.abilities(:additional_token) do |ability|
              corporation.tokens << Engine::Token.new(corporation)
              ability.use!
            end
          end

          entity.spend(price, corporation)
          @log << "#{corporation.name} starts with #{@game.format_currency(price)}"

          @auctioning = nil
          @winning_bid = nil
          @subsidiaries = []
          pass!
        end

        def win_bid(winner, _company)
          @winning_bid = winner
          par_corporation unless available_subsidiaries(winner.entity).any?
        end

        def available_subsidiaries(entity)
          entity ||= current_entity
          return [] if !@winning_bid || @winning_bid.entity != entity

          total = @subsidiaries.sum(&:value)

          (entity.companies - @subsidiaries).select do |company|
            @winning_bid.price > company.value + total
          end
        end

        def committed_cash
          0
        end

        def min_bid(corporation)
          return 100 unless @auctioning

          highest_bid(corporation).price + min_increment
        end

        def max_bid(player, _corporation)
          [400, bidding_power(player)].min
        end

        def bidding_power(player)
          player.cash + player.companies.sum(&:value)
        end

        def can_ipo_any?(_entity)
          false
        end

        def setup
          setup_auction
          super
          @subsidiaries = []
        end
      end
    end
  end
end
