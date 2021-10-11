# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1849
      module Step
        class Token < Engine::Step::Token
          def can_place_token?(entity)
            current_entity == entity &&
              !available_tokens(entity).empty? &&
              (entity.sms_hexes || @game.graph.can_token?(entity))
          end

          def place_token(entity, city, token, connected: true, extra_action: false, special_ability: nil)
            return super unless entity.sms_hexes

            hex = city.hex
            raise GameError, 'Must place token on SMS hex' unless entity.sms_hexes.find { |h| hex.id == h }

            super(entity, city, token, connected: false, extra_action: extra_action, special_ability: special_ability)
          end

          def process_place_token(action)
            entity = action.entity

            place_token(entity, action.city, action.token)

            index = @game.corporations.index { |c| c.name == @game.class::CORP_CHOOSES_HOME }
            afg = index ? @game.corporations[index] : nil
            if afg && !afg.floated? && @game.home_token_locations(afg).empty?
              if afg.next_to_par && afg != @game.corporations.last
                @game.corporations[index + 1].next_to_par = true
                afg.next_to_par = false
              end
              afg.slot_open = false
              @game.corporations.delete(afg)
              @game.corporations << afg
              @log << "#{afg.name} has no home token locations and cannot be opened until one becomes available."
            end

            pass!
          end

          def available_hex(entity, hex)
            return super unless entity.sms_hexes

            return [0, 1, 2, 3, 4, 5] if entity.sms_hexes.find { |h| h == hex.id }
          end
        end
      end
    end
  end
end
