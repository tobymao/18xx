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

          def active_entities
            [pending_entity.owner]
          end

          def process_place_token(action)
            city = action.city
            if action.entity.companies.empty? && action.entity.placed_tokens.empty?
              # This is a public company floated directly after the start of phase 5.
              # Home token cost for public companies is twice the city's revenue.
              color = city.tile.color
              token.price = 2 * city.revenue[color] unless color == :white
            else
              # This is a token acquired when a private company is exchanged,
              # either for the president's certificate or for a share from the
              # public company's treasury. These tokens are free.
              token.price = 0

              # Test for a corner case: if any of the Madrid private railway
              # companies are being acquired by a public company and one of the
              # other Madrid slots is empty and unreserved (after another
              # Madrid private closed without their slot being taken), then the
              # player can select either the slot for the private being
              # acquired or the empty slot. Only the first of these is a legal
              # choice.
              if @round.pending_tokens.none? { |t| !t.key?(:cities) || t[:cities].include?(city) }
                raise GameError, "#{action.entity.id} cannot place a token in " \
                                 "#{city.hex.coordinates} " \
                                 "(#{city.hex.location_name}) " \
                                 "city ##{city.index} "
              end
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
