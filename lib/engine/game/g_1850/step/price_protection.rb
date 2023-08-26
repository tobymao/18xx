# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../g_1870/step/price_protection'

module Engine
  module Game
    module G1850
      module Step
        class PriceProtection < G1870::Step::PriceProtection
          def can_buy?(entity, bundle)
            return unless bundle&.buyable
            return unless bundle == price_protection

            have_cert_room = if bundle.corporation.counts_for_limit
                               @game.num_certs(entity, price_protecting: true) + bundle.num_shares <= @game.cert_limit
                             else
                               true # can price protect yellow/green/brown even if over cert limit
                             end

            entity.cash >= bundle.price && have_cert_room
          end

          def process_pass(_action, forced = false)
            bundle, corporation_owner = @game.sell_queue.shift

            @game.change_price(bundle, corporation_owner, forced)

            @round.recalculate_order if @round.respond_to?(:recalculate_order)
          end
        end
      end
    end
  end
end
