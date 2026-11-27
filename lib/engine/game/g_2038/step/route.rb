# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G2038
      module Step
        class Route < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          FINISH = 'finish'
          CANCEL = 'cancel'
          # §7.1x: collecting a transshipment credit is a "may," not automatic.
          TRANSSHIP = 'transship'
          FLYOVER = 'flyover_'
          SHORTCUT_EXPLORE = 'shortcut_explore_'
          SUBMIT_FLIGHT = 'submit_flight'
          FLIGHT_SEP = '~'
          UNDO_HEX = 'undo_hex'

          def description
            'Fly Spaceships'
          end

          # Intentionally empty -- suppresses Step::Base's generic pass log line.
          def log_pass(_entity); end

          def help
            ['Click a base to launch, then click adjacent hexes to fly. '\
             'While on a transshipment point, click to collect its credit '\
             '(only pays with an empty cargo hold). End route at a base '\
             'or transshipment point to collect payment.',
             # Non-breaking space, not a regular one -- plain '' collapses to zero height.
             ' ']
          end

          def setup
            @trace = []
            @cargo = []
            @ran_ships = []
            @explored_in_trace = false
            @mp_spent = 0
            @choices_memo = nil
            @round.laid_hexes = []
            @local_flight_log = []
            # Not @trace.size: finish_route can reset @trace to [] within
            # the same dispatch that just grew it (see maybe_auto_finish!),
            # which would make that hex's mark silently go unrecorded.
            @hexes_entered = 0
            @rollback = nil
            # Gates explore_hex!'s exploration-bonus payment so it can't
            # fire twice -- false while a flight is still a local preview.
            @committing = false
          end

          def round_state
            super.merge({ routes: [], extra_revenue: 0, laid_hexes: [] })
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.operator?
            return [] if @game.route_trains(entity).empty?

            ACTIONS
          end

          def choice_name
            nil
          end

          def choices
            @choices_memo ||= compute_choices
          end

          def available_hex(entity, hex)
            return false unless entity == current_entity
            return true unless @trace.empty?
            return true unless current_ship(entity)

            choices.key?(hex.id)
          end

          def entity_choices(_entity)
            {}
          end

          # Opt-in hook for View::Game::HexChoiceSelector.
          def hex_choices(entity, hex)
            return nil unless entity == current_entity

            if @trace.empty?
              return nil unless @rollback&.dig(:finished)
              return nil unless hex == undo_click_hex
              return { UNDO_HEX => undo_hex_label } if undoing_last_hex_reveals_tile?

              return nil
            end

            return current_hex_popup if hex == @trace.last
            return nil unless needs_exploration?(hex)

            neighbor = @trace.last.neighbors.value?(hex)
            explore_key = neighbor ? hex.id : "#{SHORTCUT_EXPLORE}#{hex.id}"
            flyover_key = neighbor ? "#{FLYOVER}#{hex.id}" : hex.id
            popup = {}
            popup[explore_key] = 'Explore' if choices.key?(explore_key)
            popup[flyover_key] = 'Skip' if choices.key?(flyover_key)
            popup.empty? ? nil : popup
          end

          def current_hex_popup
            matches = current_hex_action_choices
            return matches if matches.size > 1
            return matches if matches.key?(UNDO_HEX) && undoing_last_hex_reveals_tile?

            nil
          end

          def current_hex_action_choices
            matches = choices.select { |key, _label| key == TRANSSHIP }
            return matches unless undo_last_hex_available?(current_entity)

            matches.merge(UNDO_HEX => undo_hex_label)
          end

          def pass_description
            return 'Pass' if @trace.empty? && @rollback&.dig(:finished) != true
            return 'Cancel (⚠️ un-reveals tile)' if @rollback && !@rollback[:laid_hexes].empty?

            'Cancel'
          end

          # Opt-in hook for assets/app/view/game/actionable.rb.
          def local_choose?(entity, choice)
            choice = choice.to_s
            entity == current_entity && !choice.start_with?("#{SUBMIT_FLIGHT}:")
          end

          def local_choose!(entity, choice)
            @rollback ||= capture_rollback!
            hexes_entered_before = @hexes_entered
            log_index = @local_flight_log.size
            @local_flight_log << choice
            dispatch_choice!(entity, choice)
            @rollback[:hex_marks] << log_index if @hexes_entered > hexes_entered_before
          end

          def local_pass?(entity)
            entity == current_entity &&
              (!@trace.empty? || @rollback&.dig(:finished) == true)
          end

          def local_pass!(entity)
            rollback_local_flight!(entity)
          end

          def local_undo?(entity)
            local_pass?(entity)
          end

          # hex_marks[0] is always the launch hex, so size > 1 means a real
          # hex has been flown; below that there's nothing to step back to.
          def local_undo!(entity)
            return unless @rollback

            if @rollback[:hex_marks].size > 1
              undo_last_hex!(entity)
            else
              rollback_local_flight!(entity)
            end
          end

          # ShipSelector renders its own pass/cancel controls, grouped with
          # the rest of the ship controls, so this step's standalone
          # Pass/Cancel button is always suppressed.
          def suppress_standalone_pass?(_entity)
            true
          end

          def submit_flight_choice(entity)
            return nil unless entity == current_entity
            return nil unless @rollback&.dig(:finished)
            return nil if @local_flight_log.empty?

            "#{SUBMIT_FLIGHT}:#{@local_flight_log.join(FLIGHT_SEP)}"
          end

          def submit_ready?(entity)
            return false unless entity == current_entity
            return false if @rollback.nil?

            @rollback[:finished] || @trace.size > 1
          end

          def undo_last_hex_available?(entity)
            entity == current_entity && (@rollback&.dig(:hex_marks)&.size || 0) > 1
          end

          def undo_last_hex!(entity)
            return unless @rollback

            marks = @rollback[:hex_marks]
            return if marks.size <= 1

            replay_log = @local_flight_log[0...marks.last]

            rollback_local_flight!(entity)
            replay_log.each { |c| local_choose!(entity, c) }
          end

          def undo_click_hex
            return @trace.last unless @trace.empty?
            return nil unless @rollback&.dig(:finished)

            ship = @rollback[:finished_ship]
            @round.routes.find { |r| r.train == ship }&.hexes&.last
          end

          def undoing_last_hex_reveals_tile?
            return false unless @rollback

            last_explored = @rollback[:laid_hexes].last
            hex = undo_click_hex
            !!(last_explored && hex && last_explored[:hex_id] == hex.id)
          end

          def undo_hex_label
            undoing_last_hex_reveals_tile? ? 'Undo (⚠️)' : 'Undo'
          end

          def submit_button_label(entity)
            revenue =
              if @rollback&.dig(:finished)
                ship = @rollback[:finished_ship]
                @round.routes.find { |r| r.train == ship }&.revenue
              elsif @trace.size > 1 && (ship = current_ship(entity))
                @game.trace_revenue(entity, ship, @trace, @cargo)
              end
            revenue ? "Submit (#{@game.format_currency(revenue)})" : 'Submit'
          end

          # Mutating -- only call from a click handler, never from render.
          def finish_and_submit_choice(entity)
            local_choose!(entity, FINISH) if @trace.size > 1 && !@rollback&.dig(:finished)
            submit_flight_choice(entity)
          end

          def process_choose(action)
            entity = action.entity
            choice = action.choice

            return replay_submitted_flight!(entity, choice) if choice.to_s.start_with?("#{SUBMIT_FLIGHT}:")

            dispatch_choice!(entity, choice)
          end

          def dispatch_choice!(entity, choice)
            raise GameError, "Invalid route choice: #{choice}" unless choices.key?(choice)

            @choices_memo = nil

            if choice == FINISH
              finish_route(entity)
            elsif choice == CANCEL
              cancel_route
            elsif choice == UNDO_HEX || (@rollback&.dig(:finished) && choice == undo_click_hex&.id)
              undo_last_hex!(entity)
            elsif choice == TRANSSHIP
              pick_up_transshipment!(entity, @trace.last)
              finish_route(entity)
            elsif choice.start_with?(FLYOVER)
              move_to(entity, choice.delete_prefix(FLYOVER), explore: false)
            elsif choice.start_with?(SHORTCUT_EXPLORE)
              fly_shortcut_to!(entity, choice.delete_prefix(SHORTCUT_EXPLORE), explore_destination: true)
            elsif @trace.empty?
              launch_at(entity, choice)
            elsif choice == @trace.last.id
              resolve_current_hex_choice!(entity, choice)
            elsif @trace.last.neighbors.values.map(&:id).include?(choice)
              move_to(entity, choice, explore: true)
            else
              fly_shortcut_to!(entity, choice)
            end

            # Redundant with the reset above in most branches, but
            # resolve_current_hex_choice! can repopulate @choices_memo
            # from the pre-finish trace after finish_route has already run
            # -- leaving a stale cache that launch_at would silently accept.
            @choices_memo = nil
          end

          def resolve_current_hex_choice!(entity, choice)
            matches = current_hex_action_choices
            raise GameError, "Ambiguous choice at #{choice}" if matches.size != 1

            case matches.keys.first
            when TRANSSHIP
              pick_up_transshipment!(entity, @trace.last)
              finish_route(entity)
            when UNDO_HEX
              undo_last_hex!(entity)
            end
          end

          def process_pass(action)
            @choices_memo = nil

            if @trace.empty?
              log_pass(action.entity)
              pass!
            elsif @explored_in_trace
              raise GameError, 'Cannot cancel a route after exploring — finish the route instead'
            else
              cancel_route
            end
          end

          private

          def compute_choices
            entity = current_entity
            return {} unless entity

            if @rollback&.dig(:finished)
              hex = undo_click_hex
              return hex ? { hex.id => undo_hex_label, UNDO_HEX => undo_hex_label } : {}
            end

            ship = current_ship(entity)
            return {} unless ship

            return start_choices(entity, ship) if @trace.empty?

            result = neighbor_move_choices(entity, ship)
            result.merge!(shortcut_choices(entity, ship))
            transshipment_choice(entity, ship, result)
            alias_current_hex_action!(result)
            if @trace.size > 1
              revenue = @game.trace_revenue(entity, ship, @trace, @cargo)
              result[FINISH] = "End route (#{@game.format_currency(revenue)})"
            end
            result[CANCEL] = 'Cancel route' unless @explored_in_trace
            result
          end

          def available_ships(entity)
            @game.route_trains(entity).reject { |t| @ran_ships.include?(t) }
          end

          # finish_route moves its ship into @ran_ships immediately, so
          # without this check, a finished-but-unsubmitted flight would
          # lose focus to available_ships.first the moment it was the last
          # unrun ship -- even though it's still the one on screen.
          def current_ship(entity)
            return @rollback[:finished_ship] if @rollback&.dig(:finished_ship)

            available_ships(entity).first
          end

          def mp_left(entity, ship)
            @game.ship_distance(entity, ship) - @mp_spent
          end

          def neighbor_move_choices(entity, ship)
            result = {}
            @trace.last.neighbors.each_value do |hex|
              next if hex.empty

              if needs_exploration?(hex)
                if mp_left(entity, ship) >= 2
                  result[hex.id] = "Explore #{hex.id} (2 MP: 1 fly + 1 explore; #{mp_left(entity, ship) - 2} left)"
                end
                if mp_left(entity, ship) >= 1
                  result["#{FLYOVER}#{hex.id}"] =
                    "Skip #{hex.id} (1 MP; #{mp_left(entity, ship) - 1} left)"
                end
              elsif mp_left(entity, ship) >= 1
                result[hex.id] = "Move to #{hex.id} (1 MP; #{mp_left(entity, ship) - 1} left)"
              end
            end
            result
          end

          # Only the final hex of a shortcut offers Explore/Skip -- exploring
          # a pass-through hex is a real decision the shortcut can't make
          # on the player's behalf.
          def shortcut_choices(entity, ship)
            neighbor_ids = @trace.last.neighbors.values.map(&:id)
            shortcut_paths(entity, ship).each_with_object({}) do |(hex_id, entry), result|
              next if neighbor_ids.include?(hex_id)

              hops = entry[:path].size
              result[hex_id] = "Fly to #{hex_id} via shortest route (#{hops} hexes, no exploring)"

              hex = @game.hex_by_id(hex_id)
              next unless needs_exploration?(hex)
              next unless entry[:remaining] >= 1

              result["#{SHORTCUT_EXPLORE}#{hex_id}"] =
                "Fly to #{hex_id} via shortest route and explore (#{hops} hexes, 1 extra MP; "\
                "#{entry[:remaining] - 1} left)"
            end
          end

          def shortcut_paths(entity, ship)
            start = @trace.last
            mp = mp_left(entity, ship)
            plain = plain_shortest_paths(start)

            plain.each_with_object({}) do |(hex_id, path), result|
              next if path.size > mp

              result[hex_id] = { path: path, remaining: mp - path.size }
            end
          end

          def plain_shortest_paths(start)
            _dist, predecessor = @game.hex_bfs(start)

            predecessor.each_key.to_h do |id|
              path = []
              hex = @game.hex_by_id(id)
              while hex && hex.id != start.id
                path.unshift(hex)
                hex = predecessor[hex.id]
              end
              [id, path]
            end
          end

          def fly_shortcut_to!(entity, hex_id, explore_destination: false)
            entry = shortcut_paths(entity, current_ship(entity))[hex_id]
            raise GameError, "No shortcut route to #{hex_id}" unless entry

            path = entry[:path]
            @log << "#{entity.name} flies the shortcut route to #{hex_id} (#{path.size} hexes"\
                    "#{explore_destination ? ', exploring on arrival' : ''})"
            path.each_with_index { |hex, i| move_to(entity, hex.id, explore: explore_destination && i == path.size - 1) }
          end

          def needs_exploration?(hex)
            hex.tile.color == :blue && !@game.mine_state[hex.id]
          end

          def start_choices(entity, ship)
            entity.tokens.filter_map { |t| t.city&.hex }.uniq.to_h do |hex|
              [hex.id, "Launch #{ship_label(ship)} from #{hex.id}"]
            end
          end

          # "4/0", not "Probe" -- matches the row width of every other
          # ship-selector row.
          def ship_label(ship)
            ship.name == 'Probe' ? "#{ship.distance}/#{@game.cargo_holds_for_ship(ship)}" : ship.name
          end

          # The rules permit ending a flight at a transshipment point
          # without collecting -- never automatic.
          def transshipment_choice(_entity, ship, result)
            return unless @game.transshipment_hex?(@trace.last.id)
            return if cargo_full?(ship)

            value = @game.transshipment_value(@trace.last, ship)
            result[TRANSSHIP] = "Transshipment (#{@game.format_currency(value)})"
          end

          def cargo_full?(ship)
            @cargo.size >= @game.cargo_holds_for_ship(ship)
          end

          # hex.rb's click dispatch requires `choices.include?(@hex.id)` to
          # act on a hex at all -- aliased here so the current hex (never
          # its own neighbor) still has an entry for its own real action.
          def alias_current_hex_action!(result)
            result[UNDO_HEX] = undo_hex_label if undo_last_hex_available?(current_entity)

            matches = result.select { |key, _label| [TRANSSHIP, UNDO_HEX].include?(key) }
            return if matches.empty?

            result[@trace.last.id] ||= matches.values.first
          end

          def launch_at(_entity, hex_id)
            hex = @game.hex_by_id(hex_id)
            @trace << hex
            @hexes_entered += 1
            update_trace_highlight
          end

          def move_to(entity, hex_id, explore:)
            hex = @game.hex_by_id(hex_id)
            do_explore = explore && needs_exploration?(hex)
            @mp_spent += do_explore ? 2 : 1
            @trace << hex
            @hexes_entered += 1

            if do_explore
              @explored_in_trace = true
              explore_hex_tracked!(hex_id, entity)
            end

            update_trace_highlight
            maybe_auto_finish!(entity, current_ship(entity))
          end

          def maybe_auto_finish!(entity, ship)
            return unless @trace.size > 1
            return if ship.nil? || mp_left(entity, ship).positive?

            remaining = {}
            transshipment_choice(entity, ship, remaining)
            return unless remaining.empty?

            finish_route(entity)
          end

          def pick_up_transshipment!(entity, hex)
            return unless @game.transshipment_hex?(hex.id)

            ship = current_ship(entity)
            return if !ship || @cargo.size >= @game.cargo_holds_for_ship(ship)

            value = @game.transshipment_value(hex, ship)
            @cargo << { hex_id: hex.id, mine_idx: nil, ore: nil, value: value }
            @log << "#{entity.name} collects #{@game.format_currency(value)} at transshipment point #{hex.id}"
          end

          def finish_route(entity)
            ship = current_ship(entity)
            trace = @trace.dup
            revenue = @game.trace_revenue(entity, ship, trace, @cargo)

            if revenue.zero? && !@cargo.empty?
              @log << "#{entity.name}'s #{@cargo.size} #{@cargo.size == 1 ? 'load is' : 'loads are'} "\
                      'not delivered and lost'
            end

            if @rollback
              @rollback[:finished] = true
              @rollback[:finished_ship] = ship
            end

            route = Engine::Route.new(@game, @game.phase, ship, hexes: trace, revenue: revenue)
            @round.routes << route

            @log << "#{entity.name} runs #{ship_label(ship)} for #{@game.format_currency(revenue)} "\
                    "(#{@mp_spent}/#{@game.ship_distance(entity, ship)} MP): #{trace.map(&:id).join(' - ')}"

            @ran_ships << ship
            @trace = []
            @cargo = []
            @explored_in_trace = false
            @mp_spent = 0
            update_trace_highlight
          end

          def cancel_route
            @cargo = []
            @trace = []
            @explored_in_trace = false
            @mp_spent = 0
            update_trace_highlight
          end

          # Snapshotting rand_state (and restoring it verbatim) is enough
          # for a later real replay to draw identically to the discarded
          # preview -- no need to track which calls consumed it.
          def capture_rollback!
            {
              log_size: @log.size,
              rand: @game.rand_state,
              laid_hexes: [],
              mine_state_added: [],
              finished: false,
              finished_ship: nil,
              hex_marks: [],
            }
          end

          def rollback_local_flight!(_entity = nil)
            r = @rollback
            return unless r

            if r[:finished]
              ship = r[:finished_ship]
              @round.routes.pop
              @ran_ships.delete(ship)
            end

            r[:laid_hexes].reverse_each do |e|
              hex = @game.hex_by_id(e[:hex_id])
              @game.tiles << hex.tile
              hex.lay(e[:original_tile])
            end
            r[:mine_state_added].each { |hex_id| @game.mine_state.delete(hex_id) }

            @game.rand_state = r[:rand]
            @log.slice!(r[:log_size]..-1) if @log.size > r[:log_size]

            @trace = []
            @cargo = []
            @explored_in_trace = false
            @mp_spent = 0
            @local_flight_log = []
            @hexes_entered = 0
            @rollback = nil
            @choices_memo = nil
            update_trace_highlight
          end

          def explore_hex_tracked!(hex_id, entity)
            if @rollback
              hex = @game.hex_by_id(hex_id)
              @rollback[:laid_hexes] << { hex_id: hex_id, original_tile: hex.tile }
              @rollback[:mine_state_added] << hex_id
            end
            @game.explore_hex!(hex_id, entity, pay: @committing)
          end

          # Rolls back unconditionally rather than trusting that the
          # submitting browser's own state is already correct -- so the
          # submitting browser and a later reload run the identical path.
          def replay_submitted_flight!(entity, choice)
            _prefix, rest = choice.split(':', 2)
            sequence = rest.to_s.split(FLIGHT_SEP)
            raise GameError, 'Empty submitted flight' if sequence.empty?

            rollback_local_flight!(entity)
            @committing = true
            sequence.each { |c| dispatch_choice!(entity, c) }
          ensure
            @committing = false
          end

          def update_trace_highlight
            @round.laid_hexes = @trace.dup
          end
        end
      end
    end
  end
end
