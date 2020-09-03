# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative '../../action/take_loan'

module Engine
  module Step
    module G1817
      class BuySellParShares < BuySellParShares
        def actions(entity)
          return ['take_loan'] if @game.can_take_loan?(entity) && entity.owned_by?(current_entity)
          return [] if !entity.player? || @current_actions.any? { |a| a.is_a?(Action::TakeLoan) }

          if available_subsidiaries(entity).any?
            actions = %w[assign]
            actions << 'pass' if entity.cash >= @bid.price
            return actions
          end

          return %w[bid pass] if @bid

          actions = super
          actions |= %w[bid pass] unless bought?
          actions
        end

        def active_entities
          return super unless @bid

          [@bidders[(@bidders.index(@bid.entity) + 1) % @bidders.size]]
        end

        def pass_description
          return 'Pass (Subsidiaries)' if available_subsidiaries.any?
          return super unless @bid

          'Pass (Bid)'
        end

        def log_pass(entity)
          return super unless @bid

          @log << "#{entity.name} passes on #{@bid.corporation.name}"
        end

        def pass!
          return super unless @bid
          return par_corporation if available_subsidiaries.any?

          @bidders.delete(current_entity)
          finalize_auction
        end

        def process_bid(action)
          entity = action.entity
          corporation = action.corporation
          price = action.price

          if @bid
            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
          else
            @log << "#{entity.name} auctions #{corporation.name} for #{@game.format_currency(price)}"
            @round.last_to_act = action.entity
            @current_actions.clear
            @game.place_home_token(action.corporation)
          end

          @bid = action

          @bidders = @round.entities.select do |player|
            player == entity || bidding_power(player) >= min_bid(corporation)
          end

          finalize_auction
        end

        def process_assign(action)
          entity = action.entity
          company = action.target
          @game.game_error('Cannot use company in formation') unless available_subsidiaries(entity).include?(company)
          @subsidiaries << company
          @log << "#{company.name} used for forming #{@bid.corporation.name} "\
            "contributing #{@game.format_currency(company.value)} value"
          par_corporation if available_subsidiaries(entity).empty?
        end

        def process_take_loan(action)
          @current_actions << action
          @game.take_loan(action.entity, action.loan)
        end

        def par_corporation
          entity = @bid.entity
          corporation = @bid.corporation
          price = @bid.price
          par_price = price / 2

          share_price = @game.find_share_price(par_price)
          process_par(Action::Par.new(@bid.entity, corporation: @bid.corporation, share_price: share_price))
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

          @bid = nil
          @bidders = nil
          @subsidiaries = []
          pass!
        end

        def finalize_auction
          return if @bidders.size > 1
          return if available_subsidiaries

          par_corporation
        end

        def available_subsidiaries(entity)
          entity ||= current_entity
          return [] unless @bidders&.one?
          return [] if @bid.entity != entity

          total = @subsidiaries.sum(&:value)

          (entity.companies - @subsidiaries).select do |company|
            @bid.price > company.value + total
          end
        end

        def committed_cash
          0
        end

        def min_increment
          5
        end

        def min_bid(_corporation)
          return 100 unless @bid

          @bid.price + min_increment
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
          super
          @subsidiaries = []
          @bid ||= nil
        end

        def auctioning_corporation
          @bid&.corporation
        end
      end
    end
  end
end
