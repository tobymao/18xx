# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1880
      class SharePool < Engine::SharePool
        def sell_shares(bundle, allow_president_change: true, swap: nil, silent: nil)
          entity = bundle.owner

          verb = entity.corporation? && entity == bundle.corporation ? 'issues' : 'sells'

          price = bundle.price
          price -= swap.price if swap

          percent = bundle.percent
          percent -= swap.percent if swap
          broker_fee = (percent / 10) * 5
          price -= broker_fee
          swap_text = swap ? " and a #{swap.percent}% share" : ''
          swap_to_entity = swap ? entity : nil

          unless silent
            @log << "#{entity.name} #{verb} #{num_presentation(bundle)} " \
                    "of #{bundle.corporation.name} and receives #{@game.format_currency(price)} '\
                    '(broker fee: #{@game.format_currency(broker_fee)})#{swap_text}"
          end

          transfer_shares(bundle,
                          bundle.corporation,
                          spender: @bank,
                          receiver: entity,
                          price: price,
                          allow_president_change: allow_president_change,
                          swap: swap,
                          swap_to_entity: swap_to_entity)
        end
      end
    end
  end
end
