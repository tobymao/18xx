# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18CZ
      class BuyCorporation < Base
        ACTIONS = %w[buy_corporation pass].freeze

        def actions(entity)
          return [] if entity != current_entity || @game.corporations.none? { |item| can_buy?(entity, item) }

          ACTIONS
        end

        def description
          'Buy Corporations'
        end

        def process_buy_corporation(action)
          entity = action.entity
          corporation = action.corporation
          price = action.price

          @log << "#{entity.name} buys #{corporation.name} for #{price} per share"

          max_cost = corporation.num_player_shares * price
          raise GameError,
                "#{entity.name} cannot buy #{corporation.name} for #{price} per share.
                 #{max_cost} is needed but only #{entity.cash} available" if entity.cash < max_cost

          # each player gets 1 price per share of corporation
          # trains move to new corporation and can be discarded or upgraded
          # free tokens move to new corporations
          # placed tokens transform to new corporation, double are now free tokens
          # corporation closes
          corporation.close!
        end

        def pass_description
          @acted ? 'Done (Corporations)' : 'Skip (Corporations)'
        end

        def can_buy?(entity, corporation)
          return false if entity.type == :small || !corporation.floated? || corporation.closed?

          if entity.type == :medium && corporation.type == :small ||
             entity.type == :large && (corporation.type == :small || corporation.type == :medium)
            return true
          end

          false
        end
      end
    end
  end
end
