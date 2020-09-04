# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/corporation'
require 'view/game/sell_shares'

module View
  module Game
    module Round
      class Merger < Snabberb::Component
        include Actionable

        needs :selected_corporation, default: nil, store: true

        def render
          entity = @game.current_entity
          @round = @game.round
          step = @round.active_step
          actions = @round.actions_for(entity)
          children = []

          if (%w[buy_shares sell_shares] & actions).any?
            corporation = @round.converted
            children << h(BuySellShares, corporation: corporation)
            children << h(Corporation, corporation: corporation)
            return h(:div, children)
          end

          children << render_convert(entity) if actions.include?('convert')
          children << render_loan(entity) if actions.include?('take_loan')
          children << render_merge(entity) if actions.include?('merge')
          children << h(Corporation, corporation: entity)

          step.mergeable(entity).each do |target|
            children << h(Corporation, corporation: target)
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

        def render_merge(corporation)
          merge = lambda do
            process_action(Engine::Action::Merge.new(
              corporation,
              corporation: @selected_corporation,
            ))
          end

          h(:button, { on: { click: merge } }, 'Merge')
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
