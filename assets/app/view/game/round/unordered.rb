# frozen_string_literal: true

module View
  module Game
    module Round
      class Unordered < Snabberb::Component
        needs :game
        needs :user
        needs :hotseat
        needs :selected_company, default: nil, store: true

        def render
          round = @game.round
          @step = round.active_step
          @entities = @hotseat ? @step.active_entities : [@game.player_by_id(@user['id'])]
          @current_actions = @entities.flat_map { |e| round.actions_for(e) }.uniq.compact

          div_props = {
            style: {
              display: 'flex',
              maxWidth: '100%',
              width: 'max-content',
            },
          }

          h(:div, div_props, render_player_entities)
        end

        def render_player_entities
          div_props = {
            style: {
              display: 'grid',
              grid: 'auto / repeat(auto-fill, minmax(17rem, 1fr))',
              gap: '3rem 1.2rem',
            },
          }
          players = @game.players
          if (i = players.map(&:name).rindex(@user&.dig(:name)))
            players = players.rotate(i)
          end

          bankrupt_players, players = players.partition(&:bankrupt)

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
        end

        def render_company(company)
          inputs = []
          if @current_actions.include?('propose') && @selected_company == company
            @entities.each do |entity|
              corps = []
              @step.player_corporations(entity).each do |corp|
                corps << corp if @step.can_propose?(entity, corp, company)
              end
              inputs << h(Propose, player: entity, corporations: corps, company: company) unless corps.empty?
            end
          end
          h(:div, [ h(Company, company: company), *inputs ])
        end

        def render_corporation(corp)
          subsidiaries = corp.companies.map { |c| render_company(c) }
          h(:div, [ h(Corporation, corporation: corp), *subsidiaries ])
        end
      end
    end
  end
end
