# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/corporation'
require 'view/game/sell_shares'
require 'view/game/bid'

module View
  module Game
    module Round
      class Merger < Snabberb::Component
        include Actionable
        needs :selected_corporation, default: nil, store: true

        def render
          entity = @game.current_entity
          @round = @game.round
          @step = @round.active_step
          actions = @round.actions_for(entity)
          auctioning_corporation = @step.auctioning_corporation if @step.respond_to?(:auctioning_corporation)
          children = []

          if (%w[buy_shares sell_shares] & actions).any?
            corporation = @round.converted
            children << h(BuySellShares, corporation: corporation)
            children << h(Corporation, corporation: corporation)
            return h(:div, children)
          end

          children << render_convert(entity) if actions.include?('convert')
          children << render_loan(entity) if actions.include?('take_loan')
          children << render_offer(entity, auctioning_corporation) if actions.include?('assign')

          children << render_merge(entity, auctioning_corporation) if actions.include?('merge') && @selected_corporation
          merge_entity = auctioning_corporation || entity

          if auctioning_corporation && !actions.include?('merge')
            props = {
              style: {
                display: 'inline-block',
                verticalAlign: 'top',
              },
            }

            inner = []
            inner << h(Corporation, corporation: auctioning_corporation, selectable: false)
            inner << h(Bid, entity: entity, corporation: auctioning_corporation) if actions.include?('bid')
            children << h(:div, props, inner)
          elsif merge_entity
            children << h(:div, [h(Corporation, corporation: merge_entity, selectable: false)])
          end

          if merge_entity.corporation?
            @step.mergeable(merge_entity).each do |target|
              children << h(Corporation, corporation: target)
            end
          end

          h(:div, children)
        end

        def render_convert(corporation)
          h(
            :button,
            { on: { click: -> { process_action(Engine::Action::Convert.new(corporation)) } } },
            'Convert',
          )
        end

        def render_offer(entity, corporation)
          h(
            :button,
            { on: { click: -> { process_action(Engine::Action::Assign.new(entity, target: corporation)) } } },
            'Offer for Sale',
          )
        end

        def render_merge(corporation, auctioning_corporation)
          merge = lambda do
            process_action(Engine::Action::Merge.new(
              corporation,
              corporation: @selected_corporation,
            ))
          end

          h(:button, { on: { click: merge } }, auctioning_corporation ? 'Acquire' : 'Merge')
        end

        def render_loan(corporation)
          take_loan = lambda do
            process_action(Engine::Action::TakeLoan.new(
              corporation,
              loan: @game.loans[0],
            ))
          end

          h(:button, { on: { click: take_loan } }, 'Take Loan')
        end
      end
    end
  end
end
