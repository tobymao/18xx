# frozen_string_literal: true

require_relative '../../../step/assign'
require_relative 'skip_abbreviated_round'

module Engine
  module Game
    module G18OE
      module Step
        class Assign < Engine::Step::Assign
          include SkipAbbreviatedRound

          def actions(entity)
            return [] unless entity.company?
            return [] unless operator_may_assign?(entity)

            super
          end

          def available_hex(entity, hex)
            return unless entity.company?
            return unless @game.abilities(entity, :assign_hexes)
            return unless hochberg?(entity) ? @game.hochberg_hex?(hex) : @game.minor_d_city?(hex)

            hex.neighbors.keys
          end

          def process_assign(action)
            hex = action.target
            company = action.entity
            raise GameError, "#{hex.name} cannot hold #{company.name}'s token" unless available_hex(company, hex)

            hochberg?(company) ? @game.place_hochberg_token!(hex) : @game.place_minor_d_token!(hex)
          end

          private

          def hochberg?(company)
            company == @game.hochberg_private
          end

          def operator_may_assign?(company)
            operator = @round.current_operator
            return @game.hochberg_token_placeable?(operator) if hochberg?(company)

            company.owner == operator
          end
        end
      end
    end
  end
end
