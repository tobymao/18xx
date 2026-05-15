# frozen_string_literal: true

module Engine
  module Game
    module G1862UsaCanada
      module Step
        # Handles parring a corporation whose president's share was granted by a
        # private company (P8 NHSC → NYH director cert).
        # NHSC forces NYH to par at exactly $100; no other pending-par case exists
        # in this game, but the restriction is applied generally via get_par_prices.
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def get_par_prices(entity, corporation)
            prices = super
            nhsc = @game.company_by_id('NHSC')
            return prices if corporation&.id != 'NYH' || !nhsc || nhsc.closed?

            prices.select { |p| p.price == 100 }
          end
        end
      end
    end
  end
end
