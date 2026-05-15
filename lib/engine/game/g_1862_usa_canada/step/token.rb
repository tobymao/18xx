# frozen_string_literal: true

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class Token < Engine::Step::Token
          # Apply P3 (GHU) Bahnhoflizenz: $80 discount on station token placement.
          # The ability uses type :tile_discount with terrain: :station so it does not
          # accidentally discount tile lays (which check terrain or require !terrain).
          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            token, ability = super

            @game.abilities(entity, :tile_discount) do |a, _company|
              next unless a.terrain == :station

              discount = [a.discount, token.price].min
              next unless discount.positive?

              token.price -= discount
              @log << "#{entity.name} receives a #{@game.format_currency(discount)} station " \
                      "discount from #{a.owner.name}"
            end

            [token, ability]
          end
        end
      end
    end
  end
end
