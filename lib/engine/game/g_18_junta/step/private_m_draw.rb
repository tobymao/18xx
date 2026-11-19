# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 11 (M): once per Stock Round, on their turn, the owner of Sociedade Caja Negra may
        # draw a corruption token and receive $5 times the phase number. It does not use up the turn, so
        # the step never blocks; the button shows in the company's abilities panel.
        class PrivateMDraw < Engine::Step::SpecialChoose
          DRAW_CHOICE = 'draw'

          def actions(entity)
            return [] unless entity&.company?
            return [] unless entity.sym == '(M)'
            return [] unless @game.private_m_usable?(entity.owner)
            return [] unless entity.owner == current_entity

            ACTIONS
          end

          def description
            'Private (M): Draw Corruption Token'
          end

          def choices_ability(entity)
            return {} unless actions(entity).any?

            payment = @game.format_currency(@game.private_m_payment)
            { DRAW_CHOICE => "Draw 1 corruption token from the bag and receive #{payment} from the bank" }
          end

          def process_choose_ability(action)
            entity = action.entity
            raise GameError, 'Private (M) cannot be used now' unless actions(entity).any?
            raise GameError, "Invalid Private (M) choice: #{action.choice}" unless action.choice == DRAW_CHOICE

            @game.use_private_m!(entity.owner)
          end
        end
      end
    end
  end
end
