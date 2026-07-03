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
        elsif actions.include?('dividend') || actions.include?('payout') || actions.include?('withhold') || actions.include?('half') || actions.include?('split') then phase = :dividend
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

        base_revenue = active_routes.any? ? active_routes.sum(&:revenue) : 0
        if phase == :dividend && base_revenue == 0 && current_entity&.respond_to?(:operating_history)
          operating = current_entity.operating_history || {}
          base_revenue = (operating[operating.keys.max]&.revenue || 0).to_i
        end

        storage_key = "rev_override_#{current_entity&.id}"
        last_base_key = "last_base_rev_#{current_entity&.id}"

        if Lib::Storage[last_base_key] != base_revenue
          Lib::Storage[storage_key] = base_revenue
          Lib::Storage[last_base_key] = base_revenue
        end

        current_revenue = Lib::Storage[storage_key].to_i
        formatted_revenue = @game.format_revenue_currency(current_revenue)
        upper_content = []

        if current_entity
          logo_src = begin
            setting_for(:simple_logos, @game) ? current_entity.simple_logo : current_entity.logo
          rescue StandardError
            nil
          end

          header_elements = []

          header_elements << h(:div, { style: { fontSize: '1.2rem' } }, company_logo)
          header_elements << h(:div, { style: { fontSize: '0.9rem' } }, player_name) if player_name && !player_name.empty?
          header_elements << h(:div, { style: { fontSize: '0.8rem', textTransform: 'uppercase', marginTop: '1px' } },
                               phase.to_s.tr('_', ' '))

          upper_content << h(:div,
                             { style: { backgroundColor: bg_color, color: text_color, padding: '0.2rem', textAlign: 'center', fontWeight: 'bold', border: '1px solid #999', marginBottom: '0.2rem', fontSize: '0.75rem' } }, header_elements)
        end

        upper_content << h(:div, { style: { border: '1px solid #999', padding: '0.4rem', marginBottom: '0.4rem', backgroundColor: '#dda0dd', borderRadius: '4px', display: 'flex', flexDirection: 'column', gap: '0.4rem' } }, [
           h(:div, { style: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #b886b8', paddingBottom: '0.2rem' } }, [
             h(:div, { style: { fontSize: '0.8rem', fontWeight: 'bold' } }, 'Cash'),
             h(:div, { style: { fontSize: '1.2rem', fontWeight: 'bold' } }, treasury.to_s),
           ]),
           h(:div, { style: { textAlign: 'center' } }, [
             h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold', marginBottom: '2px' } }, 'Owned Trains'),
             render_owned_trains(current_entity),
           ]),
           h(:div, { style: { textAlign: 'center' } }, [
             h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold', marginBottom: '2px' } }, 'Tokens'),
             render_company_tokens(current_entity),
           ]),
         ])
        upper_content << render_phase_box('1. Build Track', phase == :build_track, ['Skip'], actions, current_entity, nil)

        upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
          render_phase_box('2. Place Token', phase == :place_token, ['Skip'], actions, current_entity, nil),
        ])

        revenue_overlay = if %i[run_routes dividend].include?(phase)
                            h(:div, { style: { display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem', margin: '0.3rem 0' } }, [
                              h(:button, {
                                  style: {
                                    padding: '0.1rem 0.4rem',
                                    fontSize: '1.1rem',
                                    fontWeight: 'bold',
                                    cursor: 'pointer',
                                    backgroundColor: '#e0e0e0',
                                    border: '1px solid #999',
                                    borderRadius: '3px',
                                  },
                                  on: {
                                    click: lambda {
                                             Lib::Storage[storage_key] = [current_revenue - 10, 0].max
                                             update
                                           },
                                  },
                                }, '-'),
                              h(:div, { style: { fontSize: '1.8rem', fontWeight: 'bold', color: 'green', minWidth: '4rem', textAlign: 'center' } },
                                formatted_revenue),
                              h(:button, {
                                  style: {
                                    padding: '0.1rem 0.4rem',
                                    fontSize: '1.1rem',
                                    fontWeight: 'bold',
                                    cursor: 'pointer',
                                    backgroundColor: '#e0e0e0',
                                    border: '1px solid #999',
                                    borderRadius: '3px',
                                  },
                                  on: {
                                    click: lambda {
                                             Lib::Storage[storage_key] = current_revenue + 10
                                             update
                                           },
                                  },
                                }, '+'),
                            ])
                          end

        if phase == :run_routes
          upper_content << render_phase_box('3. Run Routes', true, ["Submit #{formatted_revenue}"], actions, current_entity,
                                            revenue_overlay)
        elsif phase == :dividend
          options = step.respond_to?(:dividend_options) ? step.dividend_options(current_entity).map(&:to_s) : []
          div_buttons = []
          if actions.include?('payout') || options.include?('payout') || (actions.include?('dividend') && !(current_entity.respond_to?(:minor?) && current_entity.minor?))
            div_buttons << 'Pay'
          end
          if actions.include?('withhold') || options.include?('withhold') || (actions.include?('dividend') && !(current_entity.respond_to?(:minor?) && current_entity.minor?))
            div_buttons << 'Hold'
          end
          if actions.include?('half') || actions.include?('split') || options.include?('half') || options.include?('split') || (actions.include?('dividend') && current_entity.respond_to?(:minor?) && current_entity.minor?)
            div_buttons << 'Split'
          end

          upper_content << render_phase_box('3. Dividend', true, div_buttons, actions, current_entity, revenue_overlay)
        else
          options = step.respond_to?(:dividend_options) ? step.dividend_options(current_entity).map(&:to_s) : []
          div_buttons = []
          div_buttons << 'Pay' if actions.include?('payout') || options.include?('payout') || actions.include?('dividend')
          div_buttons << 'Hold' if actions.include?('withhold') || options.include?('withhold') || actions.include?('dividend')
          div_buttons << 'Split' if actions.include?('half') || options.include?('half') || actions.include?('dividend')

          upper_content << render_phase_box('3. Revenue', false, div_buttons, actions, current_entity, nil)

        end

        buyable_list = phase == :buy_train ? render_buyable_trains(step, current_entity) : h(:div)
        upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
          render_phase_box('4. Buy Trains', phase == :buy_train, ['Done Buying'], actions, current_entity, buyable_list),
        ])
        upper_content << h(Abilities)

        standard_actions = %w[lay_tile place_token run_routes dividend payout withhold half split
                              buy_train pass]
        special_actions = actions - standard_actions

        if special_actions.any?
          special_buttons = special_actions.map do |action|
            label = action.split('_').map(&:capitalize).join(' ')
            click_action = lambda do
              # Placeholder for action instantiation to be confirmed with exact class structure
              action_class = begin
                Engine::Action.const_get(action.split('_').map(&:capitalize).join)
              rescue NameError
                nil
              end
              process_action(action_class.new(current_entity)) if action_class
            end

            h(:button, {
                style: {
                  width: '100%',
                  padding: '0.3rem',
                  marginTop: '0.2rem',
                  fontSize: '0.8rem',
                  backgroundColor: '#f0f8ff',
                  color: '#004085',
                  border: '2px dashed #007bff',
                  cursor: 'pointer',
                  fontWeight: 'bold',
                  borderRadius: '4px',
                },
                on: { click: click_action },
              }, label)
          end

          upper_content << h(:div, { style: { border: '2px solid #007bff', padding: '0.4rem', backgroundColor: '#e2e3e5', textAlign: 'center', marginBottom: '0.4rem' } }, [
            h(:div, { style: { fontSize: '0.8rem', fontWeight: 'bold', color: '#1b1e21', marginBottom: '0.2rem' } },
              '5. Special Actions'),
            *special_buttons,
          ])
        end

        if @game.round.stock?
          upper_content = [
            h(:div,
              { style: { padding: '2rem', textAlign: 'center', fontSize: '1.2rem', fontWeight: 'bold', textTransform: 'uppercase' } }, 'Stock Round'),
          ]
        end

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

        h(:div, { style: { display: 'flex', flexDirection: 'column', height: '100%', maxHeight: '100%', overflow: 'hidden', padding: '0.2rem', backgroundColor: '#c0c0c0', boxSizing: 'border-box', position: 'relative' } }, [
            h(:div,
              { style: { position: 'absolute', top: '0.2rem', left: '0.2rem', right: '0.2rem', bottom: '0.2rem', overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '0.1rem' } }, upper_content),
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

        active_p = current_entity&.player? ? current_entity : current_entity&.owner

        train_boxes = trains.map do |t|
          owner_entity = t.owner
          next nil unless owner_entity && owner_entity.respond_to?(:owner)

          # Strictly filter out trains that are not owned by the same player or belong to the active company itself
          owned_by_same_player = active_p && owner_entity.owner == active_p
          not_own_train = current_entity && owner_entity != current_entity

          next nil unless not_own_train && owned_by_same_player

          train_border_color = '#00cc00'
          menu_storage_key = "cmd_buy_train_menu_#{owner_entity.id}_#{t.id}"
          price_storage_key = "cmd_buy_train_price_#{owner_entity.id}_#{t.id}"

          train_click_handler = lambda {
            Lib::Storage[menu_storage_key] = true
            Lib::Storage[price_storage_key] = 1
            update
          }

          if Lib::Storage[menu_storage_key]
            menu_title = "#{current_entity.name} buys #{t.name} from #{owner_entity.name} for how much?"

            confirm_handler = lambda {
              price_value = Lib::Storage[price_storage_key].to_i
              price_value = 1 if price_value < 1

              Lib::Storage[menu_storage_key] = nil
              Lib::Storage[price_storage_key] = nil
              process_action(Engine::Action::BuyTrain.new(
                current_entity,
                train: t,
                price: price_value
              ))
            }

            cancel_handler = lambda {
              Lib::Storage[menu_storage_key] = nil
              Lib::Storage[price_storage_key] = nil
              update
            }

            menu_dropdown = h(:div, {
                                style: {
                                  position: 'absolute',
                                  top: '105%',
                                  left: '50%',
                                  transform: 'translateX(-50%)',
                                  backgroundColor: '#ffffff',
                                  border: '2px solid #333333',
                                  borderRadius: '4px',
                                  padding: '0.5rem',
                                  zIndex: '9999',
                                  boxShadow: '0px 4px 10px rgba(0,0,0,0.3)',
                                  color: '#000000',
                                },
                              }, [
              h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold', marginBottom: '0.4rem', whiteSpace: 'nowrap' } },
                menu_title),
              h(:input, {
                  style: {
                    display: 'block',
                    width: '100%',
                    marginBottom: '0.4rem',
                    boxSizing: 'border-box',
                    padding: '3px 6px',
                    fontSize: '0.85rem',
                  },
                  attrs: {
                    type: 'number',
                    min: '1',
                    value: Lib::Storage[price_storage_key] || '1',
                  },
                  on: {
                    input: lambda { |event|
                      Lib::Storage[price_storage_key] = event.JS[:target].JS[:value]
                    },
                  },
                }),
              h(:button, {
                  style: {
                    display: 'block',
                    width: '100%',
                    marginBottom: '0.2rem',
                    cursor: 'pointer',
                    fontSize: '0.75rem',
                    fontWeight: 'bold',
                    padding: '3px 6px',
                    backgroundColor: '#007bff',
                    border: '1px solid #0056b3',
                    color: '#ffffff',
                    borderRadius: '3px',
                  },
                  on: { click: confirm_handler },
                }, 'Confirm'),
              h(:button, {
                  style: {
                    display: 'block',
                    width: '100%',
                    cursor: 'pointer',
                    fontSize: '0.75rem',
                    padding: '3px 6px',
                    backgroundColor: '#e0e0e0',
                    border: '1px solid #999',
                    borderRadius: '3px',
                  },
                  on: { click: cancel_handler },
                }, 'Cancel'),
            ])
          end

          card_text = "#{t.name} from #{owner_entity.name}"

          # Formatted block display layout structure pushing cards into individual wide lines
          h(:div, { style: { display: 'block', width: '100%', position: 'relative', margin: '4px 0' } }, [
            h(View::Game::Card, text: card_text, border_color: train_border_color, click_action: train_click_handler),
            menu_dropdown,
          ].compact)
        end.compact

        if train_boxes.empty?
          return h(:div, { style: { fontSize: '0.75rem', color: '#666', fontStyle: 'italic', padding: '0.2rem' } },
                   'No matching same-owner trains available')
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'column', width: '100%', padding: '0.2rem 0', boxSizing: 'border-box' } }, train_boxes)
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
          h(View::Game::Card, text: train.name)
        end

        empty_count = [limit - owned_trains.size, 0].max
        empty_count.times do
          train_boxes << h(:div,
                           {
                             style: {
                               width: '42px',
                               height: '22px',
                               backgroundColor: 'transparent',
                               border: '1px dashed #999',
                               borderRadius: '3px',
                               margin: '2px',
                               boxSizing: 'border-box',
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
              base_revenue = routes_to_submit.any? ? routes_to_submit.sum(&:revenue) : 0
              storage_key = "rev_override_#{current_entity&.id}"
              current_revenue = Lib::Storage[storage_key] ? Lib::Storage[storage_key].to_i : base_revenue

              process_action(Engine::Action::RunRoutes.new(
                current_entity,
                routes: routes_to_submit,
                extra_revenue: @game.extra_revenue(current_entity, routes_to_submit) + (current_revenue - base_revenue),
                subsidy: @game.routes_subsidy(routes_to_submit)
              ))
            elsif label == 'Pay' && (available_actions.include?('dividend') || available_actions.include?('payout'))
              routes_to_submit = active_routes
              base_revenue = routes_to_submit.any? ? routes_to_submit.sum(&:revenue) : 0
              storage_key = "rev_override_#{current_entity&.id}"
              current_revenue = Lib::Storage[storage_key] ? Lib::Storage[storage_key].to_i : base_revenue
              extra_rev = current_revenue - base_revenue

              process_action(Engine::Action::Dividend.new(current_entity, kind: 'payout', extra_revenue: extra_rev))
            elsif label == 'Hold' && (available_actions.include?('dividend') || available_actions.include?('withhold'))
              routes_to_submit = active_routes
              base_revenue = routes_to_submit.any? ? routes_to_submit.sum(&:revenue) : 0
              storage_key = "rev_override_#{current_entity&.id}"
              current_revenue = Lib::Storage[storage_key] ? Lib::Storage[storage_key].to_i : base_revenue
              extra_rev = current_revenue - base_revenue

              process_action(Engine::Action::Dividend.new(current_entity, kind: 'withhold', extra_revenue: extra_rev))
            elsif label == 'Split' && (available_actions.include?('dividend') || available_actions.include?('half') || available_actions.include?('split'))
              routes_to_submit = active_routes
              base_revenue = routes_to_submit.any? ? routes_to_submit.sum(&:revenue) : 0
              storage_key = "rev_override_#{current_entity&.id}"
              current_revenue = Lib::Storage[storage_key] ? Lib::Storage[storage_key].to_i : base_revenue
              extra_rev = current_revenue - base_revenue

              process_action(Engine::Action::Dividend.new(current_entity, kind: 'half', extra_revenue: extra_rev))
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
