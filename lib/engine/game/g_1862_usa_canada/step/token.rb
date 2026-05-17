# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class Token < Engine::Step::Token
          # GHU (Bahnhoflizenz) gives the director's corporation an $80 discount
          # on station token placement (minimum $0). The discount is auto-applied
          # whenever the operating corporation's director holds GHU.
          def process_place_token(action)
            apply_ghu_discount!(action.entity, action.token)
            super
          end

          private

          def ghu_company
            @game.companies.find { |c| c.sym == 'GHU' && !c.closed? }
          end

          def apply_ghu_discount!(corporation, token)
            ghu = ghu_company
            return unless ghu&.owner == corporation.owner

            discount = ghu.abilities.find { |a| a.type == :tile_discount }&.discount.to_i
            token.price = [token.price - discount, 0].max
          end
        end
      end
    end
  end
end
