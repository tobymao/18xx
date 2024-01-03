# frozen_string_literal: true

require_relative '../../g_1870/step/price_protection'

module Engine
  module Game
    module G1850
      module Step
        class PriceProtection < G1870::Step::PriceProtection
          def price_protection_seller
            @game.sell_queue.dig(0, 2)
          end

          def can_buy?(entity, bundle)
            return unless bundle&.buyable
            return unless bundle == price_protection

            have_cert_room = if bundle.corporation.counts_for_limit
                               @game.num_certs(entity, price_protecting: true) + bundle.num_shares <= @game.cert_limit
                             else
                               true # can price protect yellow/green/brown even if over cert limit
                             end

            entity.cash >= bundle.price &&
              price_protection_seller != entity &&
              have_cert_room
          end
        end
      end
    end
  end
end
