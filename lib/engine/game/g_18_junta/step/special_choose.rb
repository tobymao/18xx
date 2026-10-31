# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 11 (E): from the first 3-train, the owner may donate Casa Ruiz de Assistencia to
        # a company they preside over; the bank gives that company $150.
        class SpecialChoose < Engine::Step::SpecialChoose
          def choices_ability(entity)
            corporation = current_entity
            return {} if entity.sym != '(E)' || !@game.private_e_donatable?(corporation)

            fee = @game.format_currency(@game.class::PRIVATE_E_DONATION)
            { 'donate' => "Donate to #{corporation.name} (it receives #{fee} from the bank)" }
          end

          def process_choose_ability(action)
            corporation = current_entity
            raise GameError, "#{action.entity.name} cannot be donated now" unless @game.private_e_donatable?(corporation)

            @game.donate_private_e!(corporation)
          end
        end
      end
    end
  end
end
