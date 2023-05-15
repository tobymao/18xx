# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1880
      class SharePool < Engine::SharePool
        def log_sell_shares(entity, verb, bundle, price, swap_text)
          fee = additional_price_adjustments(bundle)
          @log << "#{entity.name} #{verb} #{num_presentation(bundle)} " \
                  "of #{bundle.corporation.name} and receives #{@game.format_currency(price)}" \
                  " (broker fee: #{@game.format_currency(fee)})#{swap_text}"
        end

        def additional_price_adjustments(bundle)
          percent = bundle.percent
          (percent / 10) * 5
        end
      end
    end
  end
end
