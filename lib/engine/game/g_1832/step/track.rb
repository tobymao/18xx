# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G1832
      module Step
        class Track < Engine::Step::Track
          def process_lay_tile(action)
            lay_tile_action(action)

            action.hex.remove_assignment!('boomtown') if action.hex.assigned?('boomtown')

            if Engine::Game::G1832::Game::BOOMTOWN_HEXES.include?(action.hex.id) && action.hex.tile.color == :white
              action.hex.assign!('boomtown')
            end

            pass! unless can_lay_tile?(action.entity)
          end

          def actions(entity)
            actions = super.dup
            actions += %w[choose pass] if can_buy_coal_token?(entity)

            actions.uniq
          end

          def choices
            choices = []
            choices << ['Buy Coal Token'] if can_buy_coal_token?(current_entity)
            choices
          end

          def choice_name
            'Additional Track Actions'
          end

          def process_choose(action)
            buy_coal_token(action.entity) if action.choice == 'Buy Coal Token'
            @round.num_laid_track += 1
          end

          def buy_coal_token(corporation)
            total_cost = 80
            amount_to_owner = @game.coal_company.closed? ? 0 : 40
            amount_to_bank = amount_to_owner.positive? ? 40 : 80

            corporation.spend(amount_to_bank, @game.bank)
            corporation.spend(amount_to_owner, @game.coal_company.owner) if amount_to_owner.positive?

            @game.coal_token_counter -= 1

            log_message = "#{corporation.name} buys a Coal token for #{@game.format_currency(total_cost)}. "
            if amount_to_owner.positive?
              log_message += "#{@game.coal_company.owner.name} receives #{@game.format_currency(amount_to_owner)}. "
            end
            log_message += "#{@game.coal_token_counter} Coal tokens left in the game"
            @log << log_message
            corporation.coal_token = true
            @game.clear_graph_for_entity(corporation)
          end

          def hex_neighbors(entity, hex)
            connected = super
            @game.clear_graph_for_entity(entity) if entity.tokens.none?(&:city)
            connected
          end

          def can_buy_coal_token?(entity)
            entity.corporation? &&
            !entity.coal_token &&
            @game.coal_company_sold_or_closed &&
            @game.coal_token_counter.positive? &&
            entity.cash >= 80 &&
            hex_neighbors(entity, @game.coal_hex) &&
            get_tile_lay(entity)
          end
        end
      end
    end
  end
end
