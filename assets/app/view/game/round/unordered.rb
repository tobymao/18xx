# frozen_string_literal: true

require 'lib/settings'
require 'view/game/actionable'

module View
  module Game
    module Round
      class Unordered < Snabberb::Component
        include Actionable
        include Lib::Settings

        needs :user
        needs :hotseat
        needs :selected_company, default: nil, store: true

        def render
          round = @game.round
          @step = round.active_step
          @entities = @hotseat ? @step.active_entities : [@game.player_by_id(@user['id'])]
          @current_actions = @entities.flat_map { |e| round.actions_for(e) }.uniq.compact

          children = []
          children << render_offers
          children << render_player_entities

          h(:div, children.compact)
        end

        def render_offers
          return nil if (offers = @step.offers).empty?

          section_props = {
            style: {
              width: 'max-content',
              marginTop: '1rem',
            },
          }

          offer_props = {
            style: {
              border: '1px solid',
              borderRadius: '5px',
              marginBottom: '0.5rem',
              padding: '0.2rem 0.5rem 0.2rem 0.5rem',
            },
          }

          offers = offers.map do |offer|
            line = []
            line << @step.offer_text(offer)
            if @current_actions.include?('respond') &&
              @entities.any? { |entity| @step.can_respond?(entity, offer) }
              offer_props[:style][:background] = color_for(:your_turn)

              accept = lambda do
                process_action(Engine::Action::Respond.new(
                  offer[:responder],
                  corporation: offer[:corporation],
                  company: offer[:company],
                  accept: true,
                ))
              end

              reject = lambda do
                process_action(Engine::Action::Respond.new(
                  offer[:responder],
                  corporation: offer[:corporation],
                  company: offer[:company],
                  accept: false,
                ))
              end

              line << h(:div, [
                h(:button, { on: { click: accept } }, 'Accept'),
                h(:button, { on: { click: reject } }, 'Reject'),
              ])
            else
              offer_props[:style][:background] = color_for(:bg2)
            end
            h(:div, offer_props, line)
          end

          h(:div, section_props, [
            *offers,
          ])
        end

        def render_player_entities
          flex_props = {
            style: {
              display: 'flex',
              maxWidth: '100%',
              width: 'max-content',
            },
          }

          players = @game.player_entities
          if (i = players.map(&:name).rindex(@user&.dig(:name)))
            players = players.rotate(i)
          end

          player_owned = @game.player_sort(@game.corporations.select(&:owner))
          children = players.map do |p|
            companies = p.companies.map { |c| render_company(c) }
            corps = player_owned[p]&.map { |c| render_corporation(c) }

            h(:div, [
              h(Player, player: p, game: @game),
              *companies,
              *corps,
            ])
          end
          h(:div, flex_props, children)
        end

        def render_company(company)
          inputs = []

          if @current_actions.include?('offer') && @selected_company == company
            @entities.each do |entity|
              corps = []
              @step.player_corporations(entity).each do |corp|
                corps << corp if @step.can_offer?(entity, corp, company)
              end
              inputs << h(Offer, player: entity, corporations: corps, company: company) unless corps.empty?
            end
          end

          if @current_actions.include?('sell_company') && @selected_company == company
            @entities.each do |entity|
              inputs << close_input(entity, company) if @step.can_close?(entity, company)
            end
          end

          h(:div, [h(Company, company: company), *inputs])
        end

        def close_input(entity, company)
          close = lambda do
            process_action(Engine::Action::SellCompany.new(
              entity,
              company: company,
              price: 0
            ))
            store(:selected_company, nil, skip: true)
          end

          h(:button, { on: { click: close } }, "Close #{company.sym}")
        end

        def render_corporation(corp)
          subsidiaries = corp.companies.map { |c| render_company(c) }
          h(:div, [h(Corporation, corporation: corp), *subsidiaries])
        end
      end
    end
  end
end
