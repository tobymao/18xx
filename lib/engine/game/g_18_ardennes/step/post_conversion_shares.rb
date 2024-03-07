# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Ardennes
      module Step
        class PostConversionShares < Engine::Step::Base
          include Engine::Step::ShareBuying
          ACTIONS = %w[buy_shares pass].freeze

          def actions(entity)
            return [] unless @round.converted
            return [] unless entity == current_entity
            return [] unless can_acquire?(entity)

            ACTIONS
          end

          def description
            'Buy shares'
          end

          def log_skip(_entity); end

          def active_entities
            [president]
          end

          def visible_corporations
            [corporation] + connected_minors
          end

          def process_buy_shares(action)
            buy_shares(action.entity, action.bundle)
          end

          def process_pass(_action)
            @round.converted = nil
          end

          def skip!
            @round.converted = nil
          end

          # Prevent player's shares from being shown as buyable (this is called
          # from View::Game::BuySellParShares.render_other_player_shares).
          def can_buy?(_entity, bundle)
            !bundle.shares.first.owner.player?
          end

          private

          # Can the company director acquire any additional shares?
          # This can either be by paying cash or exchanging a minor company.
          def can_acquire?(player)
            return false if corporation.num_treasury_shares.zero? &&
                            corporation.num_market_shares.zero?

            can_buy_any?(player) || can_exchange?(player)
          end

          # Checks whether a player can afford to buy a share in the corporation
          # that has just been converted.
          def can_buy_any?(player)
            player.cash >= corporation.share_price.price
          end

          # Checks whether a player can afford to exchange one of their minors
          # for a share in the corporation that has just been converted.
          # **Note** This does not check whether there is a track connection
          # between the minor and the major, which is required to carry out the
          # exchange. This is not checked to avoid having to recalculate the
          # game graph whilst a game is being loaded.
          def can_exchange?(player)
            @game.minor_corporations.any? do |minor|
              next false unless minor.owner == player

              (minor.share_price.price * 2) + player.cash >=
                corporation.share_price.price
            end
          end

          def corporation
            @round.converted
          end

          def president
            corporation&.owner
          end

          def connected_minors
            # TODO: check there is a track connection to the major corporation.
            # Or will that require calculating the game graph on game load?
            @game.minor_corporations.select { |minor| minor.owner == president }
          end
        end
      end
    end
  end
end
