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
        needs :show_other_players, default: nil, store: true

        def render
          entity = @game.current_entity
          @round = @game.round
          @step = @round.active_step
          actions = @round.actions_for(entity)
          auctioning_corporation = @step.auctioning_corporation if @step.respond_to?(:auctioning_corporation)
          corporation_to_merge_into = @step.merge_target if @step.respond_to?(:merge_target)
          buyer = @step.buyer if @step.respond_to?(:buyer)
          merge_entity = buyer || auctioning_corporation || corporation_to_merge_into || entity

          if @step.respond_to?(:mergeable)
            mergeable_entities = @step.mergeable(merge_entity)
            player_corps = mergeable_entities.select do |target|
              target.owner == merge_entity.owner || @step.show_other_players
            end
            @selected_corporation = player_corps.first if player_corps.one? && !@selected_corporation
          end

          children = []

          children << h(Choose) if actions.include?('choose')

          if (%w[buy_shares sell_shares] & actions).any?
            return h(CashCrisis) if @step.respond_to?(:needed_cash)

            corporation = @round.converted

            children << h(Corporation, corporation: corporation)
            children << h(BuySellShares, corporation: corporation)
            children << h(Player, game: @game, player: entity) if entity.player?
            return h(:div, children.compact)
          end

          buttons = []
          buttons << render_convert(entity) if actions.include?('convert')
          buttons << h(Loans, corporation: entity) if (%w[take_loan payoff_loan] & actions).any?

          corps_actionable = (%w[assign merge] & actions).any?
          buttons << render_offer(entity, auctioning_corporation) if actions.include?('assign')

          buttons << render_merge(entity) if actions.include?('merge')
          buttons << h(ScrapTrains, corporation: entity) if actions.include?('scrap_train')
          children << h(:div, buttons) if buttons.any?

          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          if auctioning_corporation && !actions.include?('merge')
            inner = []
            inner << h(Corporation, corporation: auctioning_corporation || corporation_to_merge_into, selectable: false)
            inner << h(Bid, entity: entity, corporation: auctioning_corporation) if actions.include?('bid')
            children << h(:div, props, inner)

            if @step.respond_to?(:show_bidding_corporation?) && @step.show_bidding_corporation?
              children << h(:div, props,
                            [h(Corporation, corporation: entity, selectable: false)])
            end

          elsif merge_entity&.corporation? || merge_entity&.minor?
            children << h(:div, props, [h(Corporation, corporation: merge_entity, selectable: false)])
          end
          children << h(Player, game: @game, player: entity.owner) if entity.owner.player?

          if mergeable_entities
            props = {
              style: {
                margin: '0.5rem 1rem 0 0',
              },
            }
            if @step.respond_to?(:mergeable_type) && mergeable_entities.any?
              children << h(:div, props, @step.mergeable_type(merge_entity))
            end

            hidden_corps = false
            mergeable_entities.each do |target|
              corp = @selected_corporation if corps_actionable
              if @step.show_other_players || @show_other_players || target.owner == merge_entity.owner || !target.owner
                children << h(Corporation, corporation: target, selected_corporation: corp)
              else
                hidden_corps = true
              end
            end

            button_props = {
              style: {
                display: 'grid',
                gridColumn: '1/4',
                width: 'max-content',
              },
            }

            if hidden_corps
              children << h('button',
                            { on: { click: -> { store(:show_other_players, true) } }, **button_props },
                            'Show corporations from other players')
            elsif @show_other_players
              children << h('button',
                            { on: { click: -> { store(:show_other_players, false) } }, **button_props },
                            'Hide corporations from other players')
            end
          end

          right = []
          right << h(Map, game: @game) if actions.include?('remove_token') || actions.include?('place_token')
          # Switch to the OR mode layout
          if right.any?
            left_props = {
              style: {
                overflow: 'hidden',
                verticalAlign: 'top',
              },
            }

            right_props = {
              style: {
                maxWidth: '100%',
                width: 'max-content',
              },
            }

            children = [
              h('div#left.inline-block', left_props, children),
              h('div#right.inline-block', right_props, right),
            ]
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

        def render_merge(corporation)
          merge = lambda do
            if @selected_corporation
              merge_corporation = @selected_corporation
              do_merge = lambda do
                if merge_corporation.corporation?
                  process_action(Engine::Action::Merge.new(
                   corporation,
                   corporation: merge_corporation,
                 ))
                else
                  process_action(Engine::Action::Merge.new(
                   corporation,
                   minor: merge_corporation,
                 ))
                end
              end

              if @step.show_other_players ||
                !merge_corporation.owner ||
                merge_corporation.owner == corporation.owner
                do_merge.call
              else
                check_consent(corporation, merge_corporation.owner, do_merge)
              end

            else
              store(:flash_opts, 'Select a corporation to merge with')
            end
          end
          h(:button, { attrs: { disabled: !@selected_corporation }, on: { click: merge } },
            @step.merge_name(@selected_corporation))
        end
      end
    end
  end
end
