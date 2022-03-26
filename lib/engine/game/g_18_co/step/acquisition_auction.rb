# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/auctioner'

module Engine
  module Game
    module G18CO
      module Step
        class AcquisitionAuction < Engine::Step::Base
          include Engine::Step::Auctioner

          ACTIONS = %w[bid pass].freeze

          def actions(entity)
            return [] unless @auctioning
            return [] unless can_bid?(entity)

            ACTIONS
          end

          def description
            'Acquire Corporations'
          end

          def pass_description
            'Pass (Bid)'
          end

          def log_pass(entity)
            @log << "#{entity.name} passes bidding on #{@auctioning.name}"
          end

          def log_skip(entity)
            if same_president(entity)
              @log << "#{entity.name} has the same president as #{@auctioning.name} and cannot participate"
              return
            end

            @log << "#{entity.name} cannot afford bidding on #{@auctioning.name}"
          end

          def process_bid(action)
            entity = action.entity
            corporation = action.corporation
            price = action.price
            min = min_bid(corporation)

            raise GameError, "#{entity.name} must bid at least #{@game.format_currency(min)}" if price < min

            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
            @round.next_entity_index!
            add_bid(action)
          end

          def process_pass(action)
            log_pass(action.entity)
            action.entity.pass!
            @round.next_entity_index!
            resolve_bids
          end

          def same_president(entity)
            entity.owner == @auctioning.owner
          end

          def can_bid?(entity)
            return unless entity.corporation?
            return if same_president(entity)
            return if @bids[@auctioning].any? { |b| b.entity == entity }

            min_bid(@auctioning) < max_bid(entity, @auctioning)
          end

          def starting_bid(_corporation)
            1
          end

          def min_increment
            1
          end

          def min_bid(corporation)
            if (bid = highest_bid(corporation)&.price)
              bid + min_increment
            else
              starting_bid(corporation)
            end
          end

          def max_bid(corporation, _entity)
            corporation.cash
          end

          def setup
            setup_auction
          end

          def auctioning_corporation
            @auctioning
          end

          def merge_target
            current_entity
          end

          def buyer
            current_entity
          end

          def setup_auction
            super
            @auctioning = @round.offer.first
            resolve_bids
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          protected

          def add_bid(bid)
            bidder = bid.entity
            corporation = bid.corporation
            price = bid.price
            min = min_bid(corporation)
            raise GameError, "Minimum bid is #{@game.format_currency(min)} for #{corporation.name}" if price < min

            @bids[corporation] << bid

            bidder.pass!
            resolve_bids
          end

          def resolve_bids
            return unless @auctioning

            entities.each do |participant|
              next if participant.passed?

              unless can_bid?(participant)
                log_skip(participant)
                participant.pass!
              end
            end

            return unless entities.all?(&:passed?)

            entity = @auctioning
            winning_bid = highest_bid(entity)

            win_bid(winning_bid, entity)

            @bids.clear
            @round.offer.delete(entity)
            entities.each(&:unpass!)
            @round.reset_entity_index!
            @auctioning = @round.offer.first
          end

          def win_bid(winning_bid, entity)
            return nobody_wanted_me(entity) unless winning_bid&.entity

            corporation = winning_bid.entity
            price = winning_bid.price
            @log << "#{corporation.name} wins the auction for #{entity.name}"\
                    " with a bid of #{@game.format_currency(price)}"

            corporation.spend(price, @game.bank)

            @round.pending_acquisition = { source: entity, corporation: corporation }
          end

          def nobody_wanted_me(entity)
            @log << "#{entity.name} is closed due to no bids during the acquisition round"
            @game.close_corporation(entity, quiet: true)
          end
        end
      end
    end
  end
end
