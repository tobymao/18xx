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
            'remaining privates will be auctioned out before the share round following the operation round.'
          end

          def setup
            @finished = false
          end

          def actions(entity)
            return [] if available.one? || finished?

            entity == current_entity ? ACTIONS_WITH_PASS : []
          end

          def available
            @game.buyable_companies
          end

          def may_purchase?(company)
            available.include?(company)
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
            available.one? || @game.passers_first_stock_round.size == @game.players.size
          end

          def min_bid(company)
            company&.value
          end

          def max_bid(_entity, company)
            may_purchase?(company) ? min_bid(company) : 0
          end

          def process_bid(action)
            company = action.company
            player = action.entity
            price = action.price

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank)

            @log << "#{player.name} buys \"#{company.name}\" for #{@game.format_currency(price)}"

            handle_connected_minor(company, player, price)

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
              @round.reset_entity_index!
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
