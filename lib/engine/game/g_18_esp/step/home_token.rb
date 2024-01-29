# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18ESP
      module Step
        class HomeToken < Engine::Step::HomeToken
          def auto_actions(entity)
            return super unless entity.name == 'MZ'

            [Engine::Action::PlaceToken.new(entity,
                                            city: @game.city_by_id('F24-0-2'),
                                            slot: 0)]
          end

          def process_place_token(action)
            hex = action.city.hex
            raise GameError, "Cannot place token on #{hex.name} as the hex is not available" unless available_hex(action.entity,
                                                                                                                  hex)

            if action.entity.name == 'MZ'
              # remove reservation in the chosen slot
              action.city.remove_all_reservations!
            end
            place_token(
              token.corporation,
              action.city,
              token,
              connected: false,
              extra_action: true,
              check_tokenable: false
            )
            @round.pending_tokens.shift
            action.entity.goal_reached!(:destination) if @game.check_for_destination_connection(action.entity)
          end

          def help
            'Select which of the three Madrid locations MZ should place its home token' if current_entity.name == 'MZ'
          end
        end
      end
    end
  end
end
