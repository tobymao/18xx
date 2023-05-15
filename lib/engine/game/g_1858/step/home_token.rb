# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1858
      module Step
        class HomeToken < Engine::Step::HomeToken
          def actions(entity)
            return [] unless entity == pending_entity

            if entity.placed_tokens.empty?
              %w[place_token]
            else
              %w[place_token pass]
            end
          end

          def pass_description
            'Do not place station token'
          end

          def process_place_token(action)
            if action.entity.companies.empty? && action.entity.placed_tokens.empty?
              # This is a public company floated directly after the start of phase 5.
              # Home token cost for public companies is twice the city's revenue.
              city = action.city
              color = city.tile.color
              token.price = 2 * city.revenue[color] unless color == :white
            else
              # This is a token acquired when a private company is exchanged,
              # either for the president's certificate or for a share from the
              # public company's treasury. These tokens are free.
              token.price = 0
            end

            super

            delete_reservations(action.entity)
          end

          def process_pass(action)
            super
            @round.pending_tokens.shift
            delete_reservations(action.entity)
          end

          def delete_reservations(corporation)
            return unless @game.private_closure_round == :in_progress

            # Delete any reservations acquired from a just closed private
            # railway company. These are only needed for this token step.
            reservations = Array(@game.abilities(corporation, :reservation))
            reservations.each { |r| corporation.remove_ability(r) }
          end
        end
      end
    end
  end
end
