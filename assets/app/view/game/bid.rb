# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    module Round
      class Bid < Snabberb::Component
        include Actionable
        needs :entity
        needs :corporation, default: nil
        needs :company, default: nil

        def render
          step = @game.round.active_step
          min_increment = step.min_increment

          corp = (@corporation.nil? ? @company : @corporation)
          min_bid = step.min_bid(corp)
          max_bid = step.max_bid(@entity, corp)
          price_input = h(:input, style: { marginRight: '1rem' }, props: {
                            value: min_bid,
                            step: min_increment,
                            min: min_bid,
                            max: max_bid,
                            type: 'number',
                            size: [@entity.cash.to_s.size, max_bid.to_s.size].max,
                          })

          place_bid = lambda do
            process_action(Engine::Action::Bid.new(
              @entity,
              corporation: @corporation,
              company: @company,
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
