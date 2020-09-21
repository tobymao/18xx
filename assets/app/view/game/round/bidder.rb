# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/bank'
require 'view/game/buy_sell_shares'
require 'view/game/company'
require 'view/game/corporation'
require 'view/game/par'
require 'view/game/players'
require 'view/game/sell_shares'
require 'view/game/stock_market'
require 'view/game/undo_and_pass'

module View
  module Game
    module Round
      module Bidder
        def render_bid(entity, corporation)
          step = @step.min_increment

          min_bid = @step.min_bid(corporation)
          max_bid = @step.max_bid(entity, corporation)
          price_input = h(:input, style: { marginRight: '1rem' }, props: {
            value: min_bid,
            step: step,
            min: min_bid + step,
            max: max_bid,
            type: 'number',
            size: [entity.cash.to_s.size, max_bid.to_s.size].max,
          })

          place_bid = lambda do
            process_action(Engine::Action::Bid.new(
              entity,
              corporation: corporation,
              price: Native(price_input)[:elm][:value].to_i,
            ))
          end

          bid_button = h(:button, { on: { click: place_bid } }, 'Place Bid')

          h('div.center', [price_input, bid_button])
        end
      end
    end
  end
end
