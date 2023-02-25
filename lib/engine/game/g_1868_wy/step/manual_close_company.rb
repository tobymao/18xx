# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1868WY
      module Step
        class ManualCloseCompany < Engine::Step::Base
          ACTIONS = %w[manual_close_company].freeze

          def description
            'Manually Close Companies'
          end

          def actions(entity)
            return [] if !entity.company? ||
                         entity.closed? ||
                         entity.player != current_entity.player ||
                         !@game.abilities(entity, :manual_close_company)

            ACTIONS
          end

          def blocks?
            false
          end

          def process_manual_close_company(action)
            company = action.entity
            case company
            when @game.upc_private
              @game.event_close_upc!
            when @game.bonanza_private
              @game.event_close_bonanza!
            when @game.big_boy_private
              @game.event_close_big_boy!
            when @game.pure_oil
              @game.event_close_pure_oil!
            when @game.no_bust
              @game.event_close_no_bust!
            end

            @log << "#{company.owner.name} closes company #{company.name}."
            company.close!
          end
        end
      end
    end
  end
end
