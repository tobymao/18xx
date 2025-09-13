# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module GSystem18
      module Step
        class HomeToken < Engine::Step::HomeToken
          def description
            return super unless @game.merging

            'Place Token'
          end

          def process_place_token(action)
            corporation = action.entity

            if @game.merging && action.city != @game.merge_a_city && action.city != @game.merge_b_city
              raise GameError, 'Must select one of two cities originally tokened'
            end

            super

            # after placing token in chosen hex, must remove reservation in other hex
            if @game.class::REMOVE_UNUSED_RESERVATIONS
              @game.hexes.each do |hex|
                hex.tile.cities.each do |city|
                  if city.reserved_by?(corporation)
                    city.reservations.delete(corporation)
                    @log << "Removing unused reservation for #{corporation.name} in #{hex.id}"
                  end
                end
              end
            end

            @game.finish_merge if @round.pending_tokens.empty? && @game.merging
          end
        end
      end
    end
  end
end
