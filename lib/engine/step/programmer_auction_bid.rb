# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module ProgrammerAuctionBid
      include Programmer

      def auto_actions(entity)
        programmed_auto_actions(entity)
      end

      def activate_program_auction_bid(entity, program)
        target = program.bid_target

        if target&.owner&.player?
          return [Action::ProgramDisable.new(entity,
                                             reason: "#{target.name} is owned by #{target.owner.name}")]
        end

        if auto_requires_auctioning?(entity, program)
          return [Action::ProgramDisable.new(entity,
                                             reason: "#{@auctioning.name} chosen instead of #{target.name}")]
        end

        unless available.include?(target)
          return [Action::ProgramDisable.new(entity,
                                             reason: "#{target.name} is no longer available")]
        end

        high_bid = highest_bid(target)
        if high_bid&.entity == entity
          return [Action::ProgramDisable.new(entity,
                                             reason: "#{entity.name} is already the high bid on #{target.name}")]
        end

        bid_params = { price: min_bid(target) }
        bid_params[:corporation] = target if target.corporation?
        bid_params[:company] = target if target.company?
        bid_params[:minor] = target if target.minor?

        return [Action::Bid.new(entity, **bid_params)] if auto_buy?(entity, program)
        return [Action::Bid.new(entity, **bid_params)] if auto_bid?(entity, program)

        if auto_disable_if_bids?(entity, program)
          return [Action::ProgramDisable.new(entity,
                                             reason: "Bids submitted for #{target.name}")]
        end

        if auto_disable_if_exceeded_price?(entity, program)
          return [Action::ProgramDisable.new(entity,
                                             reason: "Price for #{target.name} exceeded maximum bid")]
        end

        [Action::Pass.new(entity)]
      end

      def auto_buy?(_entity, program)
        program.enable_buy_price &&
          min_bid(program.bid_target) <= program.buy_price.to_i &&
          may_purchase?(program.bid_target)
      end

      def auto_bid?(entity, program)
        return false unless program.enable_maximum_bid
        return false if auto_bid_on_empty?(entity, program)

        min_bid(program.bid_target) <= program.maximum_bid.to_i
      end

      def auto_disable_if_bids?(_entity, program)
        !program.auto_pass_after &&
          program.enable_buy_price &&
          !program.enable_maximum_bid &&
          !@bids[program.bid_target].empty?
      end

      def auto_disable_if_exceeded_price?(_entity, program)
        !program.auto_pass_after &&
          program.enable_maximum_bid &&
          min_bid(program.bid_target) > program.maximum_bid.to_i
      end

      def auto_requires_auctioning?(_entity, _program)
        false
      end

      def auto_bid_on_empty?(_entity, program)
        program.enable_buy_price
      end
    end
  end
end
