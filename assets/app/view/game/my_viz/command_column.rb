# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class CommandColumn < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :game, store: true
      needs :routes, store: true, default: []
      needs :last_routed_action_id, store: true, default: nil
      needs :last_entity, store: true, default: nil

      def active_routes
        @routes.select { |r| r.chains.any? }
      end

      def render
        step = @game.round.active_step
        current_entity = step&.current_entity

        if @last_entity != current_entity
          store(:last_entity, current_entity, skip: true)
          @routes = []
          store(:routes, @routes, skip: true)
        end

        actions = current_entity ? step.actions(current_entity) : []

        phase = :waiting
        if actions.include?('lay_tile') then phase = :build_track
        elsif actions.include?('place_token') then phase = :place_token
        elsif actions.include?('run_routes') then phase = :run_routes
        elsif actions.include?('dividend') then phase = :dividend
        elsif actions.include?('buy_train') then phase = :buy_train
        end

        company_logo = current_entity&.id || 'N/A'
        player_name = current_entity&.owner&.name || ''
        treasury = current_entity&.cash || 0

        if current_entity && current_entity.respond_to?(:color)
          bg_color = current_entity.color || '#4169e1'
          text_color = current_entity.text_color || 'white'
        else
          bg_color = '#333333'
          text_color = 'white'
          player_name = current_entity&.name || ''
        end

        current_revenue = active_routes.any? ? active_routes.sum(&:revenue) : 0
        formatted_revenue = @game.format_revenue_currency(current_revenue)

        upper_content = []
        upper_content << h(:div, { style: { backgroundColor: bg_color, color: text_color, padding: '0.2rem', textAlign: 'center', fontWeight: 'bold', border: '1px solid #999', marginBottom: '0.2rem', fontSize: '0.75rem' } }, [
          h(:div, { style: { fontSize: '1.2rem' } }, company_logo),
          h(:div, { style: { fontSize: '0.9rem' } }, player_name),
          h(:div, { style: { fontSize: '0.8rem', textTransform: 'uppercase', marginTop: '1px' } }, phase.to_s.tr('_', ' ')),
        ])

        upper_content << h(:div, { style: { border: '1px solid #999', padding: '0.2rem', marginBottom: '0.2rem', backgroundColor: '#e6e6fa', textAlign: 'center', fontSize: '0.85rem' } }, [
          h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold' } }, 'Treasury'),
          h(:div, { style: { fontSize: '1.1rem', fontWeight: 'bold' } }, treasury.to_s),
        ])

        upper_content << h(:div, { style: { border: '1px solid #999', padding: '0.2rem', marginBottom: '0.2rem', backgroundColor: '#f0f0f0', textAlign: 'center' } }, [
                  h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold', marginBottom: '2px' } }, 'Owned Trains'),
                  render_owned_trains(current_entity),
                ])

        upper_content << h(:div, { style: { border: '1px solid #999', padding: '0.2rem', marginBottom: '0.2rem', backgroundColor: '#f0f0f0', textAlign: 'center' } }, [
          h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold', marginBottom: '2px' } }, 'Tokens'),
          render_company_tokens(current_entity),
        ])

        upper_content << render_phase_box('1. Build Track', phase == :build_track, ['Skip'], actions, current_entity, nil)

        upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
          render_phase_box('2. Place Token', phase == :place_token, ['Skip'], actions, current_entity, nil),
        ])

        revenue_overlay = if %i[run_routes dividend].include?(phase)
                            h(:div, { style: { fontSize: '1.8rem', fontWeight: 'bold', color: 'green', margin: '0.3rem 0' } },
                              formatted_revenue)
                          end

        if phase == :run_routes
          upper_content << render_phase_box('3. Run Routes', true, ["Submit #{formatted_revenue}"], actions, current_entity,
                                            revenue_overlay)
        elsif phase == :dividend
          div_buttons = if @game.class.name.include?('1835') && current_entity.respond_to?(:minor?) && current_entity.minor?
                          ['Split']
                        else
                          %w[Pay Hold Split]
                        end
          upper_content << render_phase_box('3. Dividend', true, div_buttons, actions, current_entity, revenue_overlay)
        else
          upper_content << render_phase_box('3. Revenue', false, %w[Pay Hold Split], actions, current_entity, nil)
        end

        buyable_list = phase == :buy_train ? render_buyable_trains(step, current_entity) : h(:div)
        upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
          render_phase_box('4. Buy Trains', phase == :buy_train, ['Done Buying'], actions, current_entity, buyable_list),
        ])

        undo_ok = @game.undo_possible
        redo_ok = @game.respond_to?(:redo_possible) ? @game.redo_possible : true

        # AUTOMATED REVENUE PATH ROUTER WITH ASYNC TIMING GATE
        current_action_id = @game.raw_actions.size
        if phase == :run_routes && @last_routed_action_id != current_action_id
          store(:last_routed_action_id, current_action_id, skip: true)

          if @routes.empty?
            trains = @game.route_trains(current_entity) || []
            operating = current_entity.respond_to?(:operating_history) ? current_entity.operating_history : {}
            last_run = operating.any? ? operating[operating.keys.max]&.routes : nil

            if last_run
              halts = operating[operating.keys.max]&.halts
              nodes = operating[operating.keys.max]&.nodes
              last_run.each do |train, connection_hexes|
                next unless trains.include?(train)

                @routes << Engine::Route.new(@game, @game.phase, train, connection_hexes: connection_hexes, routes: @routes,
                                                                        halts: halts[train], nodes: nodes[train])
              end
            else
              trains.each do |train|
                @routes << Engine::Route.new(@game, @game.phase, train, routes: @routes)
              end
            end
            store(:routes, @routes, skip: true)
          end

          lambda {
            `setTimeout(function() {`
            begin
              router = Engine::AutoRouter.new(@game, ->(_msg) {})
              router.compute(
                current_entity,
                routes: @routes.reject { |r| r.respond_to?(:paths) && r.paths.empty? },
                path_timeout: 3000,
                route_timeout: 3000,
                callback: lambda do |computed_routes|
                  store(:routes, computed_routes)
                end
              )
            rescue StandardError => e
              `console.warn('AutoRouter skipped layout matching: ' + e)`
            end
            `}, 100);`
          }.call
        end

        footer_content = h(:div, { style: { display: 'flex', flexDirection: 'row', gap: '0.4rem', width: '100%' } }, [
          h(:button, {
              style: {
                flex: '1',
                padding: '0.4rem',
                fontSize: '0.8rem',
                fontWeight: 'bold',
                backgroundColor: undo_ok ? '#cc0000' : '#888888',
                color: 'white',
                border: '1px solid #999',
                cursor: undo_ok ? 'pointer' : 'not-allowed',
              },
              attrs: { id: 'undo', disabled: !undo_ok },
              on: { click: -> { process_action(Engine::Action::Undo.new(@game.current_entity)) if undo_ok } },
            }, 'Undo'),
          h(:button, {
              style: {
                flex: '1',
                padding: '0.4rem',
                fontSize: '0.8rem',
                fontWeight: 'bold',
                backgroundColor: redo_ok ? '#008800' : '#888888',
                color: 'white',
                border: '1px solid #999',
                cursor: redo_ok ? 'pointer' : 'not-allowed',
              },
              attrs: { id: 'redo', disabled: !redo_ok },
              on: { click: -> { process_action(Engine::Action::Redo.new(@game.current_entity)) if redo_ok } },
            }, 'Redo'),
        ])

        h(:div, { style: { display: 'flex', flexDirection: 'column', height: '100%', maxHeight: '100%', overflow: 'hidden', padding: '0.2rem', backgroundColor: '#c0c0c0', boxSizing: 'border-box', position: 'relative' } }, [
          h(:div,
            { style: { position: 'absolute', top: '0.2rem', left: '0.2rem', right: '0.2rem', bottom: '45px', overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '0.1rem' } }, upper_content),
          h(:div,
            { style: { position: 'absolute', bottom: '0.2rem', left: '0.2rem', right: '0.2rem', height: '35px', borderTop: '1px solid #aaa', paddingTop: '0.2rem' } }, [footer_content]),
        ])
      end

      def render_company_tokens(current_entity)
        return h(:div) unless current_entity

        unplaced_tokens = []
        if current_entity.respond_to?(:tokens)
          unplaced_tokens = current_entity.tokens.select do |t|
            # A token is unplaced if it doesn't have a hex, or if its status says it's not used/placed on the map
            has_hex = t.respond_to?(:hex) && t.hex
            is_placed = t.respond_to?(:placed?) && t.placed?

            !has_hex && !is_placed
          end
        end

        if unplaced_tokens.nil? || unplaced_tokens.empty?
          return h(:div, { style: { fontSize: '0.75rem', color: '#666', fontStyle: 'italic' } }, 'No tokens remaining')
        end

        logo_src = begin
          setting_for(:simple_logos, @game) ? current_entity.simple_logo : current_entity.logo
        rescue StandardError
          nil
        end

        token_icons = unplaced_tokens.map do |_token|
          style = {
            width: '26px',
            height: '26px',
            margin: '2px',
            borderRadius: '50%',
            boxSizing: 'border-box',
            display: 'inline-block',
            border: '1px solid #333',
          }

          if logo_src
            style[:backgroundColor] = current_entity.color || '#fff'
            h(:img, { attrs: { src: logo_src }, style: style })
          else
            style[:lineHeight] = '24px'
            style[:textAlign] = 'center'
            style[:backgroundColor] = current_entity.color || '#4169e1'
            style[:color] = current_entity.text_color || '#fff'
            style[:fontSize] = '0.65rem'
            style[:fontWeight] = 'bold'
            h(:div, { style: style }, current_entity.id.to_s[0..2])
          end
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'row', justifyContent: 'center', flexWrap: 'wrap', padding: '0.1rem 0' } }, token_icons)
      end

      def render_buyable_trains(step, current_entity)
        return h(:div) unless step.respond_to?(:buyable_trains)

        trains = step.buyable_trains(current_entity)
        if trains.empty?
          return h(:div, { style: { fontSize: '0.75rem', color: '#666', fontStyle: 'italic', padding: '0.2rem' } },
                   'No trains available')
        end

        train_groups = trains.group_by(&:name)

        train_boxes = train_groups.map do |name, group|
          train = group.first
          price = train.respond_to?(:price) ? @game.format_currency(train.price) : ''
          count = group.size
          label = count > 1 ? "#{name} (#{price}) x#{count}" : "#{name} (#{price})"

          click_buy = lambda do
            process_action(Engine::Action::BuyTrain.new(
              current_entity,
              train: train,
              price: train.price
            ))
          end

          h(:div, {
              style: {
                padding: '4px 8px',
                backgroundColor: '#add8e6',
                border: '1px solid #555',
                borderRadius: '3px',
                margin: '2px',
                fontSize: '0.75rem',
                fontWeight: 'bold',
                cursor: 'pointer',
              },
              on: { click: click_buy },
            }, label)
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'row', justifyContent: 'center', flexWrap: 'wrap', padding: '0.2rem 0', margin: '0.2rem 0' } }, train_boxes)
      end

      def render_owned_trains(current_entity)
        return h(:div) unless current_entity&.respond_to?(:trains)

        owned_trains = current_entity.trains
        limit = begin
          @game.phase.train_limit(current_entity)
        rescue StandardError
          owned_trains.size
        end
        limit = owned_trains.size if limit < owned_trains.size

        train_boxes = owned_trains.map do |train|
          h(:div,
            { style: { padding: '4px 8px', minWidth: '20px', textAlign: 'center', backgroundColor: '#fff', border: '1px solid #777', borderRadius: '3px', margin: '2px', fontSize: '0.8rem', fontWeight: 'bold' } }, train.name)
        end

        empty_count = [limit - owned_trains.size, 0].max
        empty_count.times do
          train_boxes << h(:div,
                           {
                             style: {
                               padding: '4px 8px',
                               minWidth: '20px',
                               minHeight: '15px',
                               backgroundColor: 'transparent',
                               border: '1px dashed #999',
                               borderRadius: '3px',
                               margin: '2px',
                             },
                           })
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'row', justifyContent: 'center', flexWrap: 'wrap', padding: '0.2rem 0', margin: '0.2rem 0' } }, train_boxes)
      end

      def render_phase_box(title, is_active, button_labels, available_actions, current_entity, custom_overlay)
        bg_color = is_active ? '#ffebcd' : '#d3d3d3'
        border_color = is_active ? '#8b4513' : '#999'
        buttons = button_labels.map do |label|
          click_action = lambda do
            next unless is_active

            if ['Skip', 'Done Buying'].include?(label) && available_actions.include?('pass')
              process_action(Engine::Action::Pass.new(current_entity))

            elsif label.start_with?('Submit') && available_actions.include?('run_routes')
              routes_to_submit = active_routes
              process_action(Engine::Action::RunRoutes.new(
                current_entity,
                routes: routes_to_submit,
                extra_revenue: @game.extra_revenue(current_entity, routes_to_submit),
                subsidy: @game.routes_subsidy(routes_to_submit)
              ))

            elsif label == 'Pay' && available_actions.include?('dividend')
              process_action(Engine::Action::Dividend.new(current_entity, kind: 'payout'))
            elsif label == 'Hold' && available_actions.include?('dividend')
              process_action(Engine::Action::Dividend.new(current_entity, kind: 'withhold'))
            elsif label == 'Split' && available_actions.include?('dividend')
              process_action(Engine::Action::Dividend.new(current_entity, kind: 'half'))
            end
          end

          attrs = { disabled: !is_active }
          attrs[:id] = 'submit' if label.start_with?('Submit')

          h(:button,
            { style: { width: '100%', padding: '0.2rem', marginTop: '0.2rem', fontSize: '0.75rem', backgroundColor: is_active ? '#4169e1' : '#f5f5f5', color: is_active ? 'white' : '#a9a9a9', border: '1px solid #999', cursor: is_active ? 'pointer' : 'not-allowed', fontWeight: 'bold' }, attrs: attrs, on: { click: click_action } }, label)
        end
        h(:div, { style: { border: "2px solid #{border_color}", padding: '0.2rem', backgroundColor: bg_color, textAlign: 'center' } }, [
          h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold', color: is_active ? '#8b4513' : '#666' } }, title),
          custom_overlay, *buttons
        ].compact)
      end
    end
  end
end
