# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G1850
      module Step
        class Track < Engine::Step::Track
          def actions(entity)
            actions = super.dup
            actions += %w[choose pass] if can_buy_mesabi_token?(entity)

            actions.uniq
          end

          def choices
            choices = []
            choices << ['Buy Mesabi Token'] if can_buy_mesabi_token?(current_entity)
            choices
          end

          def choice_name
            'Additional Track Actions'
          end

          def pass!
            super
            @game.track_action_processed(current_entity)
          end

          def legal_tile_rotation?(entity, hex, tile)
            return false if hex.id == 'I18' && tile.color == :yellow && tile.rotation == 2

            super
          end

          def update_token!(action, entity, tile, old_tile)
            return super unless entity == @game.cbq_corp
            return if entity.tokens.first&.used

            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(entity) } || cities[0]
            token = entity.find_token_by_type

            @log << "#{entity.name} places a token on #{hex.name}"
            city.place_token(entity, token)
          end

          def process_choose(action)
            buy_mesabi_token(action.entity) if action.choice == 'Buy Mesabi Token'
            @round.num_laid_track += 1
          end

          def buy_mesabi_token(corporation)
            total_cost = 80
            amount_to_owner = @game.mesabi_company.closed? ? 0 : 40
            amount_to_bank = amount_to_owner.positive? ? 40 : 80

            corporation.spend(amount_to_bank, @game.bank)
            corporation.spend(amount_to_owner, @game.mesabi_company.owner) if amount_to_owner.positive?

            log_message = "#{corporation.name} buys a Mesabi token for #{@game.format_currency(total_cost)}. "
            if amount_to_owner.positive?
              log_message += "#{@game.mesabi_company.owner.name} receives #{@game.format_currency(amount_to_owner)}"
            end
            @log << log_message
            corporation.mesabi_token = true
          end

          def hex_neighbors(entity, hex)
            connected = super
            @game.clear_token_graph_for_entity(entity) if entity.tokens.none?(&:city)
            connected
          end

          def can_buy_mesabi_token?(entity)
            entity.corporation? &&
            !entity.mesabi_token &&
            @game.mesabi_compnay_sold_or_closed &&
            @game.mesabi_token_counter.positive? &&
            entity.cash >= 80 &&
            hex_neighbors(entity, @game.mesabi_hex) &&
            get_tile_lay(entity)
          end
        end
      end
    end
  end
end
