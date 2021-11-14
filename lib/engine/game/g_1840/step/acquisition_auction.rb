# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G1840
      module Step
        class AcquisitionAuction < Engine::Step::Base
          include Engine::Step::PassableAuction

          ACTIONS = %w[bid pass merge].freeze

          def actions(_entity)
            # TODO: Maximum of 3 trams per corporation
            actions = []
            actions << 'pass' unless @auctioning && @bids[@auctioning].empty?
            actions << 'bid' if @auctioning
            actions << 'merge' unless @auctioning

            actions
          end

          def description
            'Acquire Corporations'
          end

          def pass_description
            'Pass (Bid)'
          end

          def log_pass(entity)
            message = "#{entity.name} passes bidding"
            message << "on #{@auctioning.name}" if @auctioning
            @log << message
          end

          def log_skip(entity)
            @log << "#{entity.name} cannot afford bidding on #{@auctioning.name}"
          end

          def process_bid(action)
            corporation = action.corporation

            if @bids[corporation].empty?
              @available_corporations.delete(corporation)
              selection_bid(action)
            else
              add_bid(action)
            end
          end

          def process_pass(action)
            entity = action.entity

            if auctioning
              pass_auction(entity)
              resolve_bids
            else
              @log << "#{entity.name} passes bidding"
              entity.pass!
              return all_passed! if entities.all?(&:passed?)

              next_entity!
            end
          end

          def process_merge(action)
            @auctioning = action.corporation
            @log << "#{action.entity.id} selects #{action.corporation.full_name} for auctioning"
          end

          def can_bid?(entity)
            return unless entity.corporation?
            return if @bids[@auctioning].any? { |b| b.entity == entity }

            min_bid(@auctioning) < max_bid(entity, @auctioning)
          end

          def initial_auction_entities
            entities.reject(&:passed?)
          end

          def active_entities
            if @auctioning && !@active_bidders.empty?
              winning_bid = highest_bid(@auctioning)
              return [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]] if winning_bid
            end

            super
          end

          def starting_bid(_corporation)
            20
          end

          def min_increment
            5
          end

          def show_bidding_corporation?
            true
          end

          def min_bid(company)
            return unless company

            return starting_bid(company) if @bids[company].empty?

            high_bid = highest_bid(company)
            (high_bid.price || company.min_bid) + min_increment
          end

          def max_bid(corporation, _entity)
            corporation.cash
          end

          def setup
            @available_corporations = @round.offer.dup
            @corporations_who_bought = []
            setup_auction
          end

          def auctioning_corporation
            @auctioning
          end

          def merge_name(_entity = nil)
            'Select Tram for auction'
          end

          def mergeable
            @available_corporations
          end

          def mergeable_type(_corporation)
            'Available Tramways'
          end

          def show_other_players
            true
          end

          def merge_target
            current_entity
          end

          def buyer
            current_entity
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          def next_entity!
            return all_passed! if entities.all?(&:passed?)

            @round.next_entity_index!
            entity = entities[entity_index]
            next_entity! if entity&.passed?
          end

          protected

          def add_bid(bid)
            super(bid)
            corporation = bid.corporation
            entity = bid.entity
            price = bid.price

            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"

            @bids[corporation] << bid
          end

          def resolve_bids
            super
            @round.goto_entity!(@auction_triggerer)
            next_entity! if @auction_triggerer.passed?
          end

          def win_bid(winner, _company)
            buying_corporation = winner.entity
            corporation = winner.corporation
            price = winner.price

            buying_corporation.spend(price, @game.bank)

            @game.buy_tram_corporation(buying_corporation, corporation)
            @log << "#{buying_corporation.name} wins the auction for #{corporation.name} "\
                    "with a bid of #{@game.format_currency(price)}"

            @round.corporation_bought_minor << {
              entity: buying_corporation,
            }

            @corporations_who_bought << buying_corporation
            buying_corporation.pass!
          end

          def all_passed!
            (entities - @corporations_who_bought).each do |item|
              @round.corporation_bought_minor << {
                entity: item,
              }
            end

            if @game.major_corporations.none? { |item| @game.corporate_card_minors(item).size < 3 }
              @game.remove_open_tram_corporations
            else
              @game.restock_tram_corporations
            end

            pass!
          end
        end
      end
    end
  end
end
