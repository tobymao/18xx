# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'
require_relative 'buy_minor'

module Engine
  module Game
    module G1893
      module Step
        class StartingPackageInitialAuction < Engine::Step::Base
          include BuyMinor

          ACTIONS_WITH_PASS = %w[bid pass].freeze

          def help
            'Buy or Pass. If you pass you cannot act more this round. This continues until just one ' \
              'certificate remains after which regular share round commences. If everyone passes earlier ' \
              'this means the game will skip the share round and go directly to operation round, and the ' \
              'remaining privates will be auctioned out before the share round following the operation round. ' \
              'Note! Only two lowest numbered remaining minors are available. If one is bought, the next one '\
              'becomes available, and so on.'
          end

          def setup
            @finished = false
          end

          def actions(entity)
            return [] if @game.draftables.one? || finished?

            entity == current_entity ? ACTIONS_WITH_PASS : []
          end

          def available
            @game.buyable_bank_owned_companies.reject { |c| @game.bond?(c) }
          end

          def may_purchase?(entity)
            @game.draftables.include?(entity)
          end

          def may_choose?(_minor)
            false
          end

          def auctioning; end

          def auctioneer?
            true
          end

          def bids
            {}
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def name
            'Draft'
          end

          def description
            'Initial Drafting of Privates/Minors'
          end

          def pass_description
            'Pass (Buy)'
          end

          def finished?
            @game.draftables.one? || @game.passers_first_stock_round.size == @game.players.size
          end

          def min_bid(entity)
            entity.value
          end

          def min_increment
            0
          end

          def max_place_bid(_player, _object)
            0
          end

          def max_bid(_player, object)
            min_bid(object)
          end

          def process_bid(action)
            player = action.entity
            price = action.price

            draft_object(action.company, player, price)

            action_finalized
          end

          def process_pass(action)
            @log << "#{action.entity.name} passes"
            @game.passers_first_stock_round << action.entity

            action_finalized
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          private

          def action_finalized
            @round.next_entity_index!
            if finished?
              # Do not call reset_entity_index, as we need to keep "left of last to act" entity
              # (or first passer) as priority dealer for next draft/stock round.
              @game.next_turn!
            else
              entity = entities[entity_index]
              return unless @game.passers_first_stock_round.include?(entity)

              @log << "#{entity.name} has already passed"
              action_finalized
            end
          end
        end
      end
    end
  end
end
