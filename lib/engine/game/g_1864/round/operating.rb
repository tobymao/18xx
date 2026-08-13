# frozen_string_literal: true

require_relative '../../g_1867/round/operating'

module Engine
  module Game
    module G1864
      module Round
        class Operating < G1867::Round::Operating
          def skip_entity?(entity)
            return super if entity.type != :national

            !@game.up_operating? || entity.owner.nil?
          end

          def start_operating
            entity = @entities[@entity_index]
            @game.reveal_up_consist!(@game.phase.name) if entity.type == :national

            if entity.respond_to?(:companies) && entity.companies.any? { |c| c.name == Entities::GOVERNMENT_SUBSIDY }
              @game.bank.spend(20, entity)
              @game.log << "#{entity.name} receives #{@game.format_currency(20)} in U.S. Government Subsidy"
            end

            super
          end
        end
      end
    end
  end
end
