# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/results_overlay'

module View
  module Game
    class CommandColumn < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :game, store: true
      needs :routes, store: true, default: []
      needs :last_routed_action_id, store: true, default: nil
      needs :last_entity, store: true, default: nil
      needs :cmd_router_running, store: true, default: false

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

        # Ask the Round instead of the Step to capture global actions like take_loan
        actions = if current_entity && @game.round.respond_to?(:actions_for)
                    begin
                      @game.round.actions_for(current_entity)
                    rescue NotImplementedError, StandardError
                      []
                    end
                  else
                    []
                  end

        # # puts '--- DEBUG ACTIONS ---'
        # puts "Entity ID: #{current_entity&.id}"
        # puts "Entity Type: #{current_entity.class.name}"
        # puts "Step Class: #{step.class.name}"
        # puts "Raw Actions: #{actions.inspect}"

        phase = :waiting
        if actions.include?('lay_tile') then phase = :build_track
        elsif actions.include?('place_token') then phase = :place_token
        elsif actions.include?('run_routes') then phase = :run_routes
        elsif actions.include?('dividend') || actions.include?('payout') || actions.include?('withhold') || actions.include?('half') || actions.include?('split') then phase = :dividend
        elsif actions.include?('buy_train') then phase = :buy_train
        elsif actions.include?('discard_train') then phase = :discard_train
        elsif actions.include?('choose') then phase = :choose
        elsif actions.include?('merge')
          phase = step && step.class.name.split('::').last == 'Acquire' ? :acquisition : :merge
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

        base_revenue = 0
        if active_routes.any? && !@cmd_router_running
          active_routes.each do |r|
            base_revenue += r.revenue if r.chains.any?
          rescue Engine::GameError, StandardError
            # Suppress evaluation crashes while the graph is computing
          end
        end
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

        if @game.finished
          upper_content << h(:div,
                             { style: { fontSize: '1.5rem', fontWeight: 'bold', textAlign: 'center', margin: '2rem 0 1rem 0' } }, 'End of Game')
          upper_content << h(:button, {
                               style: {
                                 width: '100%',
                                 padding: '0.75rem',
                                 fontSize: '1.2rem',
                                 backgroundColor: '#28a745',
                                 color: 'white',
                                 border: 'none',
                                 borderRadius: '4px',
                                 cursor: 'pointer',
                                 fontWeight: 'bold',
                               },
                               on: {
                                 click: lambda {
                                   Lib::Storage['show_results_overlay'] = true
                                   update
                                 },
                               },
                             }, 'Show Results')

          upper_content << h(ResultsOverlay, game: @game) if Lib::Storage['show_results_overlay']
        else

          unless @game.round.operating?
            round_name_str = @game.round.class.respond_to?(:round_name) ? @game.round.class.round_name : @game.round.class.name.split('::').last
            upper_content << h(:div, { style: { padding: '1.5rem 1rem 0.5rem', textAlign: 'center', color: '#333' } }, [
              h(:div, { style: { fontSize: '1.5rem', fontWeight: 'bold', textTransform: 'uppercase' } },
                "#{round_name_str} Round"),
              h(:div, { style: { fontSize: '1.2rem', marginTop: '0.2rem', fontWeight: 'normal' } },
                current_entity&.name || ''),
            ])
          end

          if current_entity
            if @game.round.operating?
              logo_src = begin
                setting_for(:simple_logos, @game) ? current_entity.simple_logo : current_entity.logo
              rescue StandardError
                nil
              end

              header_elements = []

              header_elements << h(:div, { style: { fontSize: '4rem' } }, company_logo)
              if player_name && !player_name.empty?
                header_elements << h(:div, { style: { fontSize: '2.5rem' } },
                                     player_name)
              end

              header_elements << h(:div, { style: { fontSize: '0.8rem', textTransform: 'uppercase', marginTop: '1px' } },
                                   phase.to_s.tr('_', ' '))

              upper_content << h(:div,
                                 { style: { backgroundColor: bg_color, color: text_color, padding: '0.2rem', textAlign: 'center', fontWeight: 'bold', border: '1px solid #999', marginBottom: '0.2rem', fontSize: '0.75rem' } }, header_elements)

              mauve_box_children = [
                 h(:div, { style: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #b886b8', paddingBottom: '0.2rem' } }, [
                   h(:div, { style: { fontSize: '0.8rem', fontWeight: 'bold' } }, 'Cash'),
                   h(:div, { style: { fontSize: '1.2rem', fontWeight: 'bold' } }, treasury.to_s),
                 ]),
                 h(:div, { style: { textAlign: 'center' } }, [
                   h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold', marginBottom: '2px' } },
                     'Owned Trains'),
                   render_owned_trains(current_entity, phase),
                 ]),
                 h(:div, { style: { textAlign: 'center' } }, [
                   h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold', marginBottom: '2px' } },
                     'Tokens'),
                   render_company_tokens(current_entity),
                 ]),
              ]

              if @game.respond_to?(:total_loans) && @game.total_loans&.nonzero?
                mauve_box_children << h(:div, { style: { textAlign: 'center' } }, [
                  h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold', marginBottom: '2px' } },
                    'Loans'),
                  render_loan_dots(current_entity),
                ])
              end

              upper_content << h(:div,
                                 { style: { border: '1px solid #999', borderTop: "4px solid #{bg_color}", padding: '0.4rem', marginBottom: '0.4rem', backgroundColor: '#dda0dd', borderRadius: '4px', display: 'flex', flexDirection: 'column', gap: '0.4rem', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' } }, mauve_box_children)
            else
              # COMPACT PLAYER HEADER FOR NON-ORs
              upper_content << h(:div, { style: { backgroundColor: bg_color, color: text_color, padding: '0.5rem', textAlign: 'center', fontWeight: 'bold', marginBottom: '0.4rem', borderRadius: '4px', border: '1px solid #999' } }, [
                h(:div, { style: { fontSize: '1rem', marginTop: '0.2rem' } }, "Cash: #{@game.format_currency(treasury)}"),
              ])
            end
          end

          unless @game.round.stock?

            # ACTION BLOCKS - NOW ACCESSIBLE IN ALL ROUND TYPES!

            upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
              render_phase_box('Lay Tile', phase == :build_track, actions.include?('pass') ? ['Skip'] : [], actions, current_entity, nil, bg_color, text_color),
            ])
            upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
              render_phase_box('Place Token', phase == :place_token, ['Skip'], actions, current_entity, nil, bg_color, text_color),
            ])

            revenue_overlay = if %i[run_routes dividend].include?(phase)
                                if @cmd_router_running
                                  h(:div, { style: { padding: '0.5rem', textAlign: 'center', color: '#666', fontStyle: 'italic', fontSize: '0.85rem' } },
                                    '🔄 Computing optimal network tracks...')
                                else
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
                              end

            if phase == :run_routes
              upper_content << render_phase_box('Run Routes', true, ["Submit #{formatted_revenue}"], actions, current_entity,
                                                revenue_overlay, bg_color, text_color)

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

              upper_content << render_phase_box('Dividend', true, div_buttons, actions, current_entity, revenue_overlay, bg_color,
                                                text_color)
            else
              options = step.respond_to?(:dividend_options) ? step.dividend_options(current_entity).map(&:to_s) : []
              div_buttons = []
              div_buttons << 'Pay' if actions.include?('payout') || options.include?('payout') || actions.include?('dividend')
              if actions.include?('withhold') || options.include?('withhold') || actions.include?('dividend')
                div_buttons << 'Hold'
              end
              div_buttons << 'Split' if actions.include?('half') || options.include?('half') || actions.include?('dividend')

              upper_content << render_phase_box('Revenue', false, div_buttons, actions, current_entity, nil, bg_color,
                                                text_color)
            end

            buyable_list = phase == :buy_train ? render_buyable_trains(step, current_entity) : h(:div)
            upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
              render_phase_box('Buy Trains', phase == :buy_train, ['Done Buying'], actions, current_entity, buyable_list, bg_color, text_color),
            ])

            if phase == :discard_train
              upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
                render_phase_box('Discard Train', true, [], actions, current_entity, h(:div), bg_color, text_color),
              ])
            end

            allow_private_buy = actions.include?('buy_company') || (@game.phase.status.include?('can_buy_companies') && current_entity&.corporation?)
            buyable_company_list = allow_private_buy ? render_buyable_companies(step, current_entity) : h(:div)
            upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
              render_phase_box('Buy Private Company', allow_private_buy, actions.include?('pass') ? ['Skip'] : [], actions, current_entity, buyable_company_list, bg_color, text_color),
            ])

            if phase == :choose
              choice_title = step.respond_to?(:choice_name) ? step.choice_name : 'Choose Action'
              choice_list = render_choices(step, current_entity, bg_color, text_color)
              upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
                render_phase_box(choice_title, true, [], actions, current_entity, choice_list, bg_color, text_color),
              ])
            end

            if phase == :merge
              merge_list = render_mergeable_companies(step, current_entity)
              upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
                render_phase_box('Merge', true, actions.include?('pass') ? ['Skip'] : [], actions, current_entity, merge_list, bg_color, text_color),
              ])
            elsif phase == :acquisition
              acquire_list = render_acquirable_companies(step, current_entity)
              target = step.respond_to?(:auctioning_corporation) ? step.auctioning_corporation : nil
              target_name = target ? " #{target.name}" : ''
              upper_content << h(:div, { style: { marginBottom: '0.4rem' } }, [
                render_phase_box("Acquire#{target_name}", true, actions.include?('pass') ? ['Skip'] : [], actions, current_entity, acquire_list, bg_color, text_color),
              ])
            end

            upper_content << h(Abilities)
            standard_actions = %w[lay_tile place_token run_routes dividend payout withhold half split
                                  buy_train pass buy_company merge choose]

            system_actions = %w[end_game bankrupt]
            special_actions = actions - standard_actions - system_actions
            if special_actions.any?
              special_buttons = special_actions.map do |action|
                action_class = begin
                  Engine::Action.const_get(action.split('_').map(&:capitalize).join)
                rescue NameError
                  nil
                end

                next unless action_class

                required_args = action_class.const_defined?(:REQUIRED_ARGS) ? action_class::REQUIRED_ARGS : []
                is_loan_action = %w[take_loan payoff_loan].include?(action)

                label = action.split('_').map(&:capitalize).join(' ')

                if required_args.empty? || is_loan_action
                  click_action = lambda do
                    if is_loan_action
                      loan_pool = if action == 'payoff_loan'
                                    current_entity.respond_to?(:loans) ? current_entity.loans : []
                                  else
                                    (@game.respond_to?(:loans) ? @game.loans : [])
                                  end
                      process_action(action_class.new(current_entity, loan: loan_pool[0])) if loan_pool[0]
                    else
                      process_action(action_class.new(current_entity))
                    end
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

                elsif required_args.include?(:corporation) || required_args.include?(:company)
                  # Scaffold to repeat the "Target Selection" pattern dynamically for unknown special actions
                  targets = if step.respond_to?(:available_targets)
                              step.available_targets(current_entity) || []
                            elsif step.respond_to?(:corporations)
                              step.corporations || []
                            elsif step.respond_to?(:companies)
                              step.companies || []
                            else
                              []
                            end

                  if targets.any?
                    target_buttons = targets.map do |target|
                      click_action = lambda do
                        kwargs = {}
                        kwargs[:corporation] = target if required_args.include?(:corporation)
                        kwargs[:company] = target if required_args.include?(:company)
                        process_action(action_class.new(current_entity, **kwargs))
                      end
                      h(:button, {
                          style: {
                            width: '100%',
                            padding: '0.2rem',
                            marginTop: '0.1rem',
                            fontSize: '0.75rem',
                            cursor: 'pointer',
                            backgroundColor: '#e0f7fa',
                            border: '1px solid #17a2b8',
                            borderRadius: '3px',
                          },
                          on: { click: click_action },
                        }, "#{label} #{target.name}")
                    end

                    h(:div, { style: { border: '1px solid #17a2b8', padding: '0.3rem', marginTop: '0.2rem', borderRadius: '4px', backgroundColor: '#ffffff' } }, [
                      h(:div, { style: { fontSize: '0.8rem', fontWeight: 'bold', color: '#0056b3', marginBottom: '0.2rem' } },
                        label),
                      *target_buttons,
                    ])
                  else
                    # Fallback if no targets could be resolved dynamically
                    h(:div, { style: { border: '1px solid #17a2b8', padding: '0.3rem', marginTop: '0.2rem', borderRadius: '4px', backgroundColor: '#e0f7fa', textAlign: 'center' } }, [
                      h(:div, { style: { fontSize: '0.8rem', fontWeight: 'bold', color: '#0056b3' } }, label),
                      h(:div, { style: { fontSize: '0.7rem', color: '#666', fontStyle: 'italic' } },
                        '(Select target on map)'),
                    ])
                  end

                else
                  # Action requires arguments like :hex or :share that we cannot easily list in a column right now
                  h(:div, { style: { border: '1px solid #17a2b8', padding: '0.3rem', marginTop: '0.2rem', borderRadius: '4px', backgroundColor: '#e0f7fa', textAlign: 'center' } }, [
                    h(:div, { style: { fontSize: '0.8rem', fontWeight: 'bold', color: '#0056b3' } }, label),
                    h(:div, { style: { fontSize: '0.7rem', color: '#666', fontStyle: 'italic' } },
                      '(Interact via map/market)'),
                    h(:div, { style: { fontSize: '0.65rem', color: '#888' } },
                      "Args: #{required_args.join(', ')}"),
                  ])
                end
              end.compact

              upper_content << h(:div, { style: { border: '2px solid #007bff', padding: '0.4rem', backgroundColor: '#e2e3e5', textAlign: 'center', marginBottom: '0.4rem', borderRadius: '4px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' } }, [
                          h(:div, { style: { fontSize: '0.8rem', fontWeight: 'bold', color: '#1b1e21', marginBottom: '0.2rem' } },
                            '5. Special Actions'),
                          *special_buttons,
                                  ])
            end
          end
        end

        # AUTOMATED REVENUE PATH ROUTER WITH ASYNC TIMING GATE
        current_action_id = @game.raw_actions.size
        if phase == :run_routes && @last_routed_action_id != current_action_id
          store(:last_routed_action_id, current_action_id, skip: true)
          store(:cmd_router_running, true, skip: false)

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
                path_timeout: 10_000,
                route_timeout: 10_000,
                callback: lambda do |computed_routes|
                            store(:routes, computed_routes, skip: true)
                            store(:cmd_router_running, false)
                          end
              )
            rescue StandardError => e
              store(:cmd_router_running, false)
              `console.warn('AutoRouter skipped layout matching: ' + e)`
            end
            `}, 100);`
          }.call
        end

        h(:div, { style: { display: 'flex', flexDirection: 'column', height: '100%', maxHeight: '100%', overflow: 'hidden', padding: '0.4rem', backgroundColor: '#e0e0e0', boxSizing: 'border-box', position: 'relative' } }, [
                      h(:div,
                        { style: { position: 'absolute', top: '0.2rem', left: '0.2rem', right: '0.2rem', bottom: '0.2rem', overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '0.1rem' } }, upper_content),
                  ])
      end

      def render_owned_trains(current_entity, phase = nil)
        return h(:div) unless current_entity&.respond_to?(:trains)

        owned_trains = current_entity.trains
        limit = begin
          @game.phase.train_limit(current_entity)
        rescue StandardError
          owned_trains.size
        end
        limit = owned_trains.size if limit < owned_trains.size

        train_boxes = owned_trains.map do |train|
          if phase == :discard_train
            click_handler = lambda do
              process_action(Engine::Action::DiscardTrain.new(current_entity, train: train))
            end
            h(:div,
              { attrs: { class: 'game-card clickable' }, style: { border: '2px solid red', cursor: 'pointer' }, on: { click: click_handler } }, train.name)
          else
            h(:div, { attrs: { class: 'game-card' } }, train.name)
          end
        end

        empty_count = [limit - owned_trains.size, 0].max
        empty_count.times do
          train_boxes << h(:div,
                           {
                             style: {
                               width: '3.5rem',
                               height: '1.45rem',
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

        token_icons = unplaced_tokens.map do |token|
          style = {
            width: '26px',
            height: '26px',
            borderRadius: '50%',
            boxSizing: 'border-box',
            display: 'inline-block',
            border: '1px solid #333',
          }

          icon_el = if logo_src
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

          formatted_price = @game.format_currency(token.price)
          h(:div, { style: { display: 'inline-flex', alignItems: 'center', margin: '2px' } }, [
            icon_el,
            h(:span, { style: { fontSize: '0.75rem', marginLeft: '4px', fontWeight: 'bold', color: '#000000' } },
              "(#{formatted_price})"),
          ])
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'row', justifyContent: 'center', flexWrap: 'wrap', padding: '0.1rem 0' } }, token_icons)
      end

      def render_loan_dots(entity)
        return h(:div, '') unless entity && entity.respond_to?(:loans) && @game.respond_to?(:maximum_loans)

        loans_taken = entity.loans.size
        max_loans = @game.maximum_loans(entity)
        interest_owed = @game.respond_to?(:interest_owed) ? @game.interest_owed(entity) : 0

        dots = []
        loans_taken.times do
          dots << h(:span,
                    {
                      style: {
                        display: 'inline-block',
                        width: '8px',
                        height: '8px',
                        backgroundColor: '#dc3545',
                        borderRadius: '50%',
                        margin: '0 2px',
                        verticalAlign: 'middle',
                      },
                    })
        end
        [max_loans - loans_taken, 0].max.times do
          dots << h(:span,
                    {
                      style: {
                        display: 'inline-block',
                        width: '8px',
                        height: '8px',
                        border: '1px solid #dc3545',
                        borderRadius: '50%',
                        margin: '0 2px',
                        verticalAlign: 'middle',
                        boxSizing: 'border-box',
                      },
                    })
        end

        dots << h(:span, { style: { marginLeft: '4px', fontSize: '0.75rem', fontWeight: 'bold', verticalAlign: 'middle' } },
                  "(#{interest_owed})")

        h(:div, { style: { display: 'flex', alignItems: 'center', justifyContent: 'center' } }, dots)
      end

      def render_buyable_companies(step, current_entity)
        companies = []
        if step.respond_to?(:buyable_companies)
          companies = step.buyable_companies(current_entity)
        elsif step.respond_to?(:companies)
          companies = step.companies
        elsif @game.respond_to?(:companies)
          companies = @game.companies.select do |c|
            step.respond_to?(:can_buy_company?) ? step.can_buy_company?(current_entity, c) : !c.owned_by?(current_entity)
          end
        end

        if companies.nil? || companies.empty?
          return h(:div, { style: { fontSize: '0.75rem', color: '#666', fontStyle: 'italic', padding: '0.2rem' } },
                   'No companies available')
        end

        company_boxes = companies.map do |c|
          owner_name = c.owner&.name || 'Bank'
          next nil if c.owner == current_entity

          # Restrict buyable list to only show privates owned by the operating corporation's president
          if current_entity.respond_to?(:corporation?) && current_entity.corporation? && (c.owner != current_entity.owner)
            next nil
          end

          min_price = if step.respond_to?(:min_price)
                        step.min_price(c)
                      else
                        (c.respond_to?(:min_price) ? c.min_price : 1)
                      end
          max_price = if step.respond_to?(:max_price)
                        step.max_price(current_entity, c)
                      else
                        (c.respond_to?(:max_price) ? c.max_price : current_entity.cash)
                      end

          menu_storage_key = "cmd_buy_company_menu_#{c.id}"
          price_storage_key = "cmd_buy_company_price_#{c.id}"

          company_click_handler = lambda {
            Lib::Storage[menu_storage_key] = true
            Lib::Storage[price_storage_key] = min_price
            update
          }

          if Lib::Storage[menu_storage_key]
            menu_title = "Buy #{c.name} from #{owner_name} (#{min_price}-#{max_price}):"

            confirm_handler = lambda {
              price_value = Lib::Storage[price_storage_key].to_i
              price_value = min_price if price_value < min_price
              price_value = max_price if price_value > max_price

              Lib::Storage[menu_storage_key] = nil
              Lib::Storage[price_storage_key] = nil
              process_action(Engine::Action::BuyCompany.new(
                current_entity,
                company: c,
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
                                  position: 'fixed',
                                  top: '50%',
                                  left: '50%',
                                  transform: 'translate(-50%, -50%)',
                                  backgroundColor: '#ffffff',
                                  border: '2px solid #333333',
                                  borderRadius: '8px',
                                  padding: '1.5rem',
                                  zIndex: '10000',
                                  boxShadow: '0px 10px 30px rgba(0,0,0,0.5)',
                                  color: '#000000',
                                  minWidth: '250px',
                                  textAlign: 'center',
                                },
                              }, [
              h(:div, { style: { fontSize: '0.85rem', fontWeight: 'bold', marginBottom: '0.8rem', whiteSpace: 'nowrap' } },
                menu_title),
              h(:input, {
                  key: price_storage_key,
                  style: {
                    display: 'block',
                    width: '100%',
                    marginBottom: '0.8rem',
                    boxSizing: 'border-box',
                    padding: '5px 8px',
                    fontSize: '1rem',
                  },
                  props: {
                    value: Lib::Storage[price_storage_key] || min_price.to_s,
                  },
                  attrs: {
                    type: 'number',
                    min: min_price.to_s,
                    max: max_price.to_s,
                  },
                  on: {
                    input: lambda { |event|
                      Lib::Storage[price_storage_key] = `#{event}.target.value`
                      update
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

          card_text = "#{c.name} (#{owner_name})"

          card_props = {
            attrs: { class: 'game-card clickable' },
            style: { border: '2px solid #ff8c00', width: 'auto', padding: '0 8px' },
            on: { click: company_click_handler },
          }

          h(:div, { style: { display: 'block', width: '100%', position: 'relative', margin: '4px 0' } }, [
            h(:div, card_props, card_text),
            menu_dropdown,
          ].compact)
        end.compact

        h(:div,
          { style: { display: 'flex', flexDirection: 'column', width: '100%', padding: '0.2rem 0', boxSizing: 'border-box' } }, company_boxes)
      end

      def render_choices(step, current_entity, bg_color, text_color)
        return h(:div) unless step.respond_to?(:choices)

        choices = step.choices
        # 1837 handles choices inconsistently (Hashes for Minor, Arrays for Coal). Standardize to Hash.
        choice_list = choices.is_a?(Hash) ? choices : choices.to_h { |c| [c, c] }

        choice_boxes = choice_list.map do |engine_val, label_val|
          click_action = lambda do
            process_action(Engine::Action::Choose.new(
              current_entity,
              choice: engine_val
            ))
          end

          is_pass = %w[pass decline].include?(engine_val.to_s.downcase)
          btn_bg = is_pass ? '#e0e0e0' : bg_color
          btn_text = is_pass ? '#000000' : text_color

          h(:button, {
              style: {
                display: 'block',
                width: '100%',
                marginBottom: '0.2rem',
                cursor: 'pointer',
                fontSize: '0.8rem',
                fontWeight: 'bold',
                padding: '0.3rem',
                backgroundColor: btn_bg,
                color: btn_text,
                border: '1px solid #333',
                borderRadius: '3px',
              },
              on: { click: click_action },
            }, label_val)
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'column', width: '100%', padding: '0.2rem 0', boxSizing: 'border-box' } }, choice_boxes)
      end

      def render_mergeable_companies(step, current_entity)
        return h(:div) unless step.respond_to?(:mergeable)

        targets = step.mergeable(current_entity).select { |c| c.owner == current_entity.owner }

        if targets.empty?
          return h(:div, { style: { fontSize: '0.75rem', color: '#666', fontStyle: 'italic', padding: '0.2rem' } },
                   'No valid companies to merge with')
        end

        target_boxes = targets.map do |target|
          merge_handler = lambda do
            process_action(Engine::Action::Merge.new(
              current_entity,
              corporation: target
            ))
          end

          h(:button, {
              style: {
                display: 'block',
                width: '100%',
                marginBottom: '0.2rem',
                cursor: 'pointer',
                fontSize: '0.8rem',
                fontWeight: 'bold',
                padding: '0.3rem',
                backgroundColor: target.color || '#e0e0e0',
                color: target.text_color || '#000000',
                border: '1px solid #333',
                borderRadius: '3px',
              },
              on: { click: merge_handler },
            }, "Merge with #{target.name}")
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'column', width: '100%', padding: '0.2rem 0', boxSizing: 'border-box' } }, target_boxes)
      end

      def render_acquirable_companies(step, current_entity)
        target = step.respond_to?(:auctioning_corporation) ? step.auctioning_corporation : nil
        return h(:div) unless target

        buyers = step.respond_to?(:mergeable) ? step.mergeable(target) : []

        if buyers.empty?
          return h(:div, { style: { fontSize: '0.75rem', color: '#666', fontStyle: 'italic', padding: '0.2rem' } },
                   'No eligible companies to acquire with')
        end

        target_boxes = buyers.map do |buyer|
          acquire_handler = lambda do
            process_action(Engine::Action::Merge.new(
              current_entity,
              corporation: buyer
            ))
          end

          h(:button, {
              style: {
                display: 'block',
                width: '100%',
                marginBottom: '0.2rem',
                cursor: 'pointer',
                fontSize: '0.8rem',
                fontWeight: 'bold',
                padding: '0.3rem',
                backgroundColor: buyer.color || '#e0e0e0',
                color: buyer.text_color || '#000000',
                border: '1px solid #333',
                borderRadius: '3px',
              },
              on: { click: acquire_handler },
            }, "Buy with #{buyer.name}")
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'column', width: '100%', padding: '0.2rem 0', boxSizing: 'border-box' } }, target_boxes)
      end

      def render_mergeable_companies(step, current_entity)
        return h(:div) unless step.respond_to?(:mergeable)

        targets = step.mergeable(current_entity).select { |c| c.owner == current_entity.owner }

        if targets.empty?
          return h(:div, { style: { fontSize: '0.75rem', color: '#666', fontStyle: 'italic', padding: '0.2rem' } },
                   'No valid companies to merge with')
        end

        target_boxes = targets.map do |target|
          merge_handler = lambda do
            process_action(Engine::Action::Merge.new(
              current_entity,
              corporation: target
            ))
          end

          h(:button, {
              style: {
                display: 'block',
                width: '100%',
                marginBottom: '0.2rem',
                cursor: 'pointer',
                fontSize: '0.8rem',
                fontWeight: 'bold',
                padding: '0.3rem',
                backgroundColor: target.color || '#e0e0e0',
                color: target.text_color || '#000000',
                border: '1px solid #333',
                borderRadius: '3px',
              },
              on: { click: merge_handler },
            }, "Merge with #{target.name}")
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'column', width: '100%', padding: '0.2rem 0', boxSizing: 'border-box' } }, target_boxes)
      end

      def render_acquirable_companies(step, current_entity)
        target = step.respond_to?(:auctioning_corporation) ? step.auctioning_corporation : nil
        return h(:div) unless target

        buyers = step.respond_to?(:mergeable) ? step.mergeable(target) : []

        if buyers.empty?
          return h(:div, { style: { fontSize: '0.75rem', color: '#666', fontStyle: 'italic', padding: '0.2rem' } },
                   'No eligible companies to acquire with')
        end

        target_boxes = buyers.map do |buyer|
          acquire_handler = lambda do
            process_action(Engine::Action::Merge.new(
              current_entity,
              corporation: buyer
            ))
          end

          h(:button, {
              style: {
                display: 'block',
                width: '100%',
                marginBottom: '0.2rem',
                cursor: 'pointer',
                fontSize: '0.8rem',
                fontWeight: 'bold',
                padding: '0.3rem',
                backgroundColor: buyer.color || '#e0e0e0',
                color: buyer.text_color || '#000000',
                border: '1px solid #333',
                borderRadius: '3px',
              },
              on: { click: acquire_handler },
            }, "Buy with #{buyer.name}")
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'column', width: '100%', padding: '0.2rem 0', boxSizing: 'border-box' } }, target_boxes)
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
          next nil unless owner_entity

          is_corp = owner_entity.respond_to?(:owner)
          is_bank = !is_corp

          # Filter out trains that already belong to the active company
          next nil if current_entity && owner_entity == current_entity

          # Only show corporate trains if they belong to a company with the same owner
          if is_corp
            owned_by_same_player = active_p && owner_entity.owner == active_p
            next nil unless owned_by_same_player
          end

          is_adjustable_price = is_corp
          train_border_color = '#00cc00'

          owner_key = owner_entity.respond_to?(:id) ? owner_entity.id : 'depot'
          menu_storage_key = "cmd_buy_train_menu_#{owner_key}_#{t.id}"
          price_storage_key = "cmd_buy_train_price_#{owner_key}_#{t.id}"

          train_click_handler = lambda {
            if is_adjustable_price
              Lib::Storage[menu_storage_key] = true
              Lib::Storage[price_storage_key] = current_entity.cash
              update
            else
              process_action(Engine::Action::BuyTrain.new(
                current_entity,
                train: t,
                price: t.price
              ))
            end
          }

          menu_dropdown = nil
          if is_adjustable_price && Lib::Storage[menu_storage_key]
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
                  key: price_storage_key,
                  style: {
                    display: 'block',
                    width: '100%',
                    marginBottom: '0.4rem',
                    boxSizing: 'border-box',
                    padding: '3px 6px',
                    fontSize: '0.85rem',
                  },
                  props: {
                    value: Lib::Storage[price_storage_key] || '1',
                  },
                  attrs: {
                    type: 'number',
                    min: '1',
                  },
                  on: {
                    input: lambda { |event|
                      Lib::Storage[price_storage_key] = `#{event}.target.value`
                      update
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

          card_element = h(:div,
                           { attrs: { class: 'game-card clickable' }, style: { border: "2px solid #{train_border_color}" } }, t.name)

          source_name = is_bank ? 'Bank' : owner_entity.name
          info_string = is_adjustable_price ? "from #{source_name}" : "from #{source_name} (#{@game.format_currency(t.price)})"

          info_text = h(:span, { style: { marginLeft: '0.5rem', fontSize: '0.85rem', color: '#111' } }, info_string)

          clickable_container = h(:div, {
                                    style: { display: 'flex', alignItems: 'center', cursor: 'pointer' },
                                    on: { click: train_click_handler },
                                  }, [card_element, info_text])

          h(:div, { style: { display: 'block', width: '100%', position: 'relative', margin: '4px 0' } }, [
            clickable_container,
            menu_dropdown,
          ].compact)
        end.compact

        if train_boxes.empty?
          return h(:div, { style: { fontSize: '0.75rem', color: '#666', fontStyle: 'italic', padding: '0.2rem' } },
                   'No buyable trains available')
        end

        h(:div,
          { style: { display: 'flex', flexDirection: 'column', width: '100%', padding: '0.2rem 0', boxSizing: 'border-box' } }, train_boxes)
      end

      def render_phase_box(title, is_active, button_labels, available_actions, current_entity, custom_overlay, entity_bg_color = '#4169e1', _entity_text_color = '#ffffff')
        effectively_active = is_active && !(@cmd_router_running && title == 'Run Routes')
        box_bg = effectively_active ? '#ffffff' : '#f5f5f5'
        box_border = effectively_active ? "2px solid #{entity_bg_color}" : '1px solid #cccccc'
        title_color = effectively_active ? '#000000' : '#888888'

        buttons = button_labels.map do |label|
          click_action = lambda do
            next unless effectively_active

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
                extra_revenue: @game.extra_revenue(current_entity,
                                                   routes_to_submit) + (current_revenue - base_revenue),
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

          attrs = { disabled: !effectively_active }
          attrs[:id] = 'submit' if label.start_with?('Submit')

          btn_bg = effectively_active ? '#4169e1' : '#e0e0e0'
          btn_text = effectively_active ? '#ffffff' : '#a0a0a0'
          btn_border = effectively_active ? 'none' : '1px solid #cccccc'

          h(:button,
            { style: { width: '100%', padding: '0.3rem', marginTop: '0.2rem', fontSize: '0.75rem', backgroundColor: btn_bg, color: btn_text, border: btn_border, borderRadius: '3px', cursor: effectively_active ? 'pointer' : 'not-allowed', fontWeight: 'bold' }, attrs: attrs, on: { click: click_action } }, label)
        end
        h(:div, { style: { border: box_border, padding: '0.4rem', backgroundColor: box_bg, textAlign: 'center', borderRadius: '4px', boxShadow: effectively_active ? '0 1px 3px rgba(0,0,0,0.1)' : 'none' } }, [
                h(:div, { style: { fontSize: '0.75rem', fontWeight: 'bold', color: title_color, marginBottom: '0.2rem' } }, title),
                custom_overlay, *buttons
            ].compact)
      end
    end
  end
end
