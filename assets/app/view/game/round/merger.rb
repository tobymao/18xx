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
          corporation_to_merge_into = @step.merge_target if @step.respond_to?(:merge_target)
          if @step.respond_to?(:mergeable) && @step.mergeable(entity).one?
            @selected_corporation = @step.mergeable(entity)[0]
          end
          children = []

          if (%w[buy_shares sell_shares] & actions).any?
            return h(CashCrisis) if @step.respond_to?(:needed_cash)

            corporation = @round.converted

            children << h(Corporation, corporation: corporation)
            children << h(BuySellShares, corporation: corporation)
            children << h(Player, game: @game, player: entity) if entity.player?
            return h(:div, children)
          end

          children << render_convert(entity) if actions.include?('convert')
          children << h(Loans, corporation: entity) if (%w[take_loan payoff_loan] & actions).any?
          children << render_offer(entity, auctioning_corporation) if actions.include?('assign')

          children << render_merge(entity, auctioning_corporation) if actions.include?('merge') && @selected_corporation
          merge_entity = auctioning_corporation || corporation_to_merge_into || entity

          if auctioning_corporation && !actions.include?('merge')
            props = {
              style: {
                display: 'inline-block',
                verticalAlign: 'top',
              },
            }

            inner = []
            inner << h(Corporation, corporation: auctioning_corporation || corporation_to_merge_into, selectable: false)
            inner << h(Bid, entity: entity, corporation: auctioning_corporation) if actions.include?('bid')
            children << h(:div, props, inner)
          elsif merge_entity
            children << h(:div, [h(Corporation, corporation: merge_entity, selectable: false)])
          end

          if merge_entity.corporation? && @step.respond_to?(:mergeable)
            @step.mergeable(merge_entity).each do |target|
              children << h(Corporation, corporation: target, selected_corporation: @selected_corporation)
            end
          end

          children << h(Map, game: @game) if actions.include?('remove_token')

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
      end
    end
  end
end
