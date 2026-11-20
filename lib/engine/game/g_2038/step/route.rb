# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G2038
      module Step
        # Spaceship routes are traced one hex at a time via the `choose` action:
        # each hex click (or choice button) fires Action::Choose with the hex id.
        # The trace lives in step state and is rebuilt identically on undo/replay.
        # Entering an unexplored blue hex reveals its pre-assigned tile
        # immediately, so the player sees what they found before flying on.
        class Route < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          FINISH = 'finish'
          CANCEL = 'cancel'
          # Collecting a transshipment credit is a "may," not an automatic
          # pickup (§7.1x) -- a ship may end its flight at a transshipment
          # point with an empty cargo hold without explicitly collecting,
          # same as it may keep flying past one instead.
          TRANSSHIP = 'transship'
          FLYOVER = 'flyover_'
          SHORTCUT_EXPLORE = 'shortcut_explore_'
          # The one real action a hand-flown route ever submits -- see
          # local_choose!/submit_flight_choice/replay_submitted_flight!.
          # A hand-flown flight can hit every choice type this step
          # supports (explore vs flyover, shortcuts, transship), so rather
          # than deriving a separate replay format, this just carries the
          # literal sequence of `choice` values the player clicked,
          # replayed through the exact same dispatch_choice! table that
          # built it.
          SUBMIT_FLIGHT = 'submit_flight'
          FLIGHT_SEP = '~'
          # A dedicated choice key for undo_last_hex! (see its comment) --
          # never a real hex id, so it can be dispatched unambiguously
          # whether it arrives via a hex-choice popup's own button or as
          # the sole aliased action on a directly-clicked hex.
          UNDO_HEX = 'undo_hex'

          def description
            'Fly Spaceships'
          end

          # Suppresses Step::Base's generic "<entity> passes fly
          # spaceships" log line -- every real route decision this step
          # makes is already logged with specifics (route submitted,
          # ship declared no route, etc.), so the generic pass
          # announcement is just noise on top of that.
          def log_pass(_entity); end

          def help
            ['Click a base to launch, then click adjacent hexes to fly. '\
             'While on a transshipment point, click to collect its credit '\
             '(only pays with an empty cargo hold). End route at a base '\
             'or transshipment point to collect payment.',
             # View::Game::Help renders each array element as its own line; a
             # trailing blank line adds breathing room before the ship list
             # renders below it. A plain '' would collapse to zero height, so
             # use a non-breaking space to force real line height.
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
            # The literal sequence of `choice` values clicked locally for
            # the ship currently being built (or just finished, awaiting
            # Submit) -- see local_choose!/SUBMIT_FLIGHT. Reset here each
            # round, and again by rollback_local_flight! once that flight
            # is submitted or discarded.
            @local_flight_log = []
            # Monotonic count of hexes appended to @trace (launch_at/
            # move_to), used by local_choose! instead of @trace.size to
            # detect "did this dispatch enter a new hex" -- @trace.size
            # alone misses a hex whose own arrival immediately auto-
            # finished the route (maybe_auto_finish! resets @trace to []
            # within the very same dispatch that just grew it), which
            # otherwise left that hex's mark never recorded and
            # undo_last_hex! silently rolling back one hex further than
            # intended.
            @hexes_entered = 0
            # Non-nil while a local, unsubmitted flight has mutated real
            # game state (hex tiles, log lines) -- everything needed to
            # precisely undo it, captured the moment local building
            # starts (see local_choose!/rollback_local_flight!). nil
            # whenever there's nothing pending: no local flight has
            # started, or the last one was submitted/discarded.
            @rollback = nil
            # True only while replaying an already-submitted flight for
            # real (live, right after the player clicks Submit, or later
            # on reload/for another client) -- gates the one-time-only
            # side effects a flight can't safely run twice: the
            # exploration bonus payment (Game#explore_hex!'s `pay:`) and
            # finish_route's auto-pass. False during ordinary local
            # building, so neither fires on a preview that might still be
            # discarded.
            @committing = false
          end

          def round_state
            super.merge({ routes: [], extra_revenue: 0, laid_hexes: [] })
          end

          # Always both choose (Submit/Cancel) and pass (end of turn, or
          # Cancel/Discard while a flight's in progress or pending) for as
          # long as it's this entity's turn -- never [] just because every
          # ship has flown. The corp's turn only actually ends once the
          # player explicitly passes.
          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.operator?
            # A company that owns no ships at all has nothing to confirm
            # here; skip straight past this step (and, since it'll earn
            # exactly $0, Dividend's own actions already auto-skips on
            # total_revenue.zero? too) rather than making the player
            # click Submit All Routes for a turn that could never have
            # had anything in it.
            return [] if @game.route_trains(entity).empty?

            ACTIONS
          end

          # nil -- suppresses the generic Choose panel's "X:" header
          # entirely (see assets/app/view/game/choose.rb, which already
          # treats a falsy choice_name as "no header").
          def choice_name
            nil
          end

          # Memoized: `available_hex` calls this once per hex on the map (a
          # full render pass), but the result only changes when this step's
          # state is mutated -- invalidated in `setup`/`process_choose`/
          # `process_pass`, the only places that happens.
          def choices
            @choices_memo ||= compute_choices
          end

          # Dims everything that isn't a company base (i.e. a legal starting
          # location) before launch, when it's actually useful to see which
          # of this entity's bases are valid to fly from.
          def available_hex(entity, hex)
            return false unless entity == current_entity
            return true unless @trace.empty?
            return true unless current_ship(entity)

            choices.key?(hex.id)
          end

          # No bottom-panel-only choices in this step currently (every
          # live choice has a map-click equivalent, see choices' own
          # comment) -- kept as its own opt-in hook anyway since the base
          # Step class already calls it.
          def entity_choices(_entity)
            {}
          end

          # Optional hook for the map view: when a hex needing a click-time
          # decision is clicked directly, offer a popup with the relevant
          # choices instead of dispatching a default immediately. Two
          # cases: a transshipment-collection-vs-undo decision on the hex
          # the ship is already sitting on, else an explore/flyover
          # decision -- for a direct neighbor (1 hop) or a shortcut
          # destination (2+ hops) alike; only the choice keys differ (see
          # shortcut_choices/compute_choices).
          def hex_choice_popup(entity, hex)
            return nil unless entity == current_entity

            if @trace.empty?
              # Nothing left flying -- the only thing a hex click can mean
              # here is undoing an already-finished, not-yet-submitted
              # route's last hex, and only a popup (forcing an explicit
              # confirm) when that would un-reveal a tile. Otherwise the
              # direct click already dispatches it (see compute_choices'
              # matching branch); no popup needed.
              return nil unless @rollback&.dig(:finished)
              return nil unless hex == undo_click_hex
              return { UNDO_HEX => undo_hex_label } if undoing_last_hex_reveals_tile?

              return nil
            end

            return current_hex_popup if hex == @trace.last

            neighbor = @trace.last.neighbors.value?(hex)
            explore_key = neighbor ? hex.id : "#{SHORTCUT_EXPLORE}#{hex.id}"
            flyover_key = neighbor ? "#{FLYOVER}#{hex.id}" : hex.id
            popup = {}
            popup[explore_key] = 'Explore' if choices.key?(explore_key)
            popup[flyover_key] = 'Skip' if choices.key?(flyover_key)
            popup.size > 1 ? popup : nil
          end

          # Mid-flight version of the same "force a popup if undo would
          # un-reveal a tile, otherwise let a single option dispatch
          # directly" rule hex_choice_popup's finished-route branch above
          # uses -- current_hex_action_choices already folds Undo in
          # alongside transship, so this only needs to decide *when* that
          # combined set needs a popup instead of a direct click.
          def current_hex_popup
            matches = current_hex_action_choices
            return matches if matches.size > 1
            return matches if matches.key?(UNDO_HEX) && undoing_last_hex_reveals_tile?

            nil
          end

          # The current hex's own action set: collecting a transshipment
          # credit (if this is one, with a free cargo hold) plus Undo (if
          # there's a previous hex to back up to) -- one combined pool so
          # alias_current_hex_action!/current_hex_popup/dispatch_choice! all
          # agree on what a click (or a popup button) on the ship's own
          # hex can mean.
          def current_hex_action_choices
            matches = choices.select { |key, _label| key == TRANSSHIP }
            return matches unless undo_last_hex_available?(current_entity)

            matches.merge(UNDO_HEX => undo_hex_label)
          end

          # "Submit All Routes ($X)" whenever nothing's locally pending.
          # With every route built client-side, ending the
          # corp's turn is now always an explicit confirmation, regardless
          # of whether every ship has flown or the player is choosing to
          # leave some unflown. The $ total is every route already
          # submitted this turn, plus a still-pending preview for the ship
          # currently on screen (folded in because process_pass now
          # accepts that preview rather than discarding it -- see there),
          # so the button always reports what will actually be submitted
          # if clicked right now.
          def pass_description
            return 'Pass' if @trace.empty? && @rollback&.dig(:finished) != true
            return 'Cancel (⚠️ un-reveals tile)' if @rollback && !@rollback[:laid_hexes].empty?

            'Cancel'
          end

          # Opt-in hook for assets/app/view/game/actionable.rb: every
          # ordinary Choose click while a route is being hand-flown runs
          # locally (no process_action, no network, no permanent action
          # history entry) until the whole flight is done and the player
          # explicitly hits Submit -- see SUBMIT_FLIGHT/local_choose!/
          # replay_submitted_flight!. The one thing that must still go
          # through the real pipeline, submitted immediately in its own
          # one and only click, is excluded: the self-contained
          # SUBMIT_FLIGHT string itself.
          def local_choose?(entity, choice)
            choice = choice.to_s
            entity == current_entity && !choice.start_with?("#{SUBMIT_FLIGHT}:")
          end

          # Runs one hop of a hand-flown route entirely locally: records
          # the literal choice for later replay (see submit_flight_choice)
          # and dispatches it through the same table a real action would
          # use, so the live preview and the eventual real replay can
          # never diverge in what they do for a given choice. Lazily
          # snapshots rollback state on the very first local choice since
          # the last submit/discard.
          def local_choose!(entity, choice)
            @rollback ||= capture_rollback!
            hexes_entered_before = @hexes_entered
            log_index = @local_flight_log.size
            @local_flight_log << choice
            dispatch_choice!(entity, choice)
            # A hex-mark records the log index of whichever choice caused
            # a new hex to be entered -- launch, an ordinary move, a
            # flyover, or a shortcut hop -- so undo_last_hex! can later
            # truncate the log to "everything before the most recent
            # hex" without having to reparse choice strings to tell moves
            # apart from choices that don't enter a hex at all. Compares
            # @hexes_entered (a monotonic counter), not @trace.size -- a
            # hex whose own arrival immediately auto-finishes the route
            # (maybe_auto_finish! resets @trace to [] within this same
            # dispatch) would otherwise look like no growth happened at
            # all, and its mark would never get recorded.
            @rollback[:hex_marks] << log_index if @hexes_entered > hexes_entered_before
          end

          # Opt-in hook mirroring local_choose? for Action::Pass: true
          # whenever there's local, unsubmitted flight state to throw
          # away (mid-flight, or finished but not yet submitted). False
          # once nothing's pending, so an ordinary end-of-turn Pass still
          # goes through as a real, recorded action exactly as before.
          def local_pass?(entity)
            entity == current_entity &&
              (!@trace.empty? || @rollback&.dig(:finished) == true)
          end

          def local_pass!(entity)
            rollback_local_flight!(entity)
          end

          # Opt-in hook for assets/app/view/game/actionable.rb: same
          # pending-local-state test as local_pass? (a hand-built route
          # has nothing real to undo until Submit -- see local_choose!'s
          # own comment) -- whenever it's true, the real Undo button/
          # ctrl+z targets this local state instead of reaching into the
          # real action log for the previous entity's last action.
          def local_undo?(entity)
            local_pass?(entity)
          end

          # One step back: the same single-hex rollback the in-place
          # "Undo (hex)" control already offers once at least one hex has
          # actually been flown (@rollback[:hex_marks].size > 1 -- the
          # first mark is always the launch hex itself, see
          # capture_rollback!/undo_last_hex!'s own comment). Before that
          # -- nothing flown yet, only a bare pilot assignment or a
          # freshly-selected ship tab -- there's no hex to step back from,
          # so this discards the local state outright instead (which,
          # with nothing flown, only ever means undoing that pilot
          # assignment).
          def local_undo!(entity)
            return unless @rollback

            if @rollback[:hex_marks].size > 1
              undo_last_hex!(entity)
            else
              rollback_local_flight!(entity)
            end
          end

          # Opt-in hook for assets/app/view/game/pass.rb: unconditionally
          # suppressed -- ShipSelector now renders its own equivalent
          # unconditionally (Clear Ship via local_pass!/
          # cancel_flight_button while something's pending, the real
          # Submit-All-Routes PassButton once nothing is), grouped with
          # the rest of the ship controls instead of appearing as a
          # separate standalone button elsewhere on the page. No `entity`
          # comparison needed: pass.rb only ever calls this when this step
          # is the round's own active_step, at which point its
          # `current_entity` and the round's are the same value by
          # construction (Route doesn't override active_entities/entities/
          # entity_index), so the comparison could never actually be
          # false.
          def suppress_standalone_pass?(_entity)
            true
          end

          # Public: the self-contained choice this ship's just-finished,
          # not-yet-submitted flight would submit.  This is nil until finish_route
          # has actually run locally (see FLIGHT_SEP/replay_submitted_flight!).
          def submit_flight_choice(entity)
            return nil unless entity == current_entity
            return nil unless @rollback&.dig(:finished)
            return nil if @local_flight_log.empty?

            "#{SUBMIT_FLIGHT}:#{@local_flight_log.join(FLIGHT_SEP)}"
          end

          # Public: whether ShipSelector's Submit button should be showing
          # right now.  Either the flight has already finished (running
          # out of MP auto-finishes it; so does a previous click of this
          # same button), or it's simply sitting on a hex where finishing
          # is currently a legal move.  Read-only -- safe to call on every
          # render, unlike finish_and_submit_choice below.
          def submit_ready?(entity)
            return false unless entity == current_entity
            return false if @rollback.nil?

            @rollback[:finished] || @trace.size > 1
          end

          # Public: whether undo_last_hex! has anything to undo -- at
          # least two hexes recorded (the launch plus one more), whether
          # the flight is still in progress or already finished but not
          # yet submitted. With only the launch hex on record there's
          # nothing meaningful to back up to short of discarding the
          # whole flight, which Cancel already covers.
          def undo_last_hex_available?(entity)
            entity == current_entity && (@rollback&.dig(:hex_marks)&.size || 0) > 1
          end

          # Public: undoes the most recently entered hex, leaving the
          # ship back at the hex before it, free to fly a different
          # direction from there. Implemented as a full rollback (the
          # exact same one Cancel/local_pass! uses) followed by replaying
          # every local choice up to (not including) the discarded hex's
          # own move -- see local_choose!'s hex_marks comment. Deliberately
          # not a second, narrower undo path: reusing rollback_local_flight!
          # wholesale means this can never drift out of sync with what a full
          # Cancel already knows how to reverse (explored tiles, the
          # deferred exploration bonus, pickups, PRNG state).
          def undo_last_hex!(entity)
            return unless @rollback

            marks = @rollback[:hex_marks]
            return if marks.size <= 1

            replay_log = @local_flight_log[0...marks.last]

            rollback_local_flight!(entity)
            replay_log.each { |c| local_choose!(entity, c) }
          end

          # Public: which hex a click means "undo the last hex" for --
          # the ship's current position while still flying, or (since
          # finish_route empties @trace) the endpoint of the route it
          # just flew, once finished but not yet submitted. nil once
          # nothing's pending at all. Shared by available_hex/
          # hex_choice_popup/compute_choices/dispatch_choice! so all four
          # always agree on the exact same hex.
          def undo_click_hex
            return @trace.last unless @trace.empty?
            return nil unless @rollback&.dig(:finished)

            ship = @rollback[:finished_ship]
            @round.routes.find { |r| r.train == ship }&.hexes&.last
          end

          # Public: whether undoing the last hex would take back an
          # exploration -- the deciding factor for whether a click needs
          # a confirmation popup first (see hex_choice_popup/current_hex_popup)
          # rather than acting immediately.
          def undoing_last_hex_reveals_tile?
            return false unless @rollback

            last_explored = @rollback[:laid_hexes].last
            hex = undo_click_hex
            !!(last_explored && hex && last_explored[:hex_id] == hex.id)
          end

          def undo_hex_label
            undoing_last_hex_reveals_tile? ? 'Undo (⚠️)' : 'Undo'
          end

          # Public: the Submit button's label -- the route's real,
          # already-computed revenue if it's already finished, or a live
          # preview of what finishing right now would earn otherwise.
          # Ending a route with MP still available looks identical to
          # running out of MP: same button, same label, same code,
          # regardless of which way the flight actually ends. Read-only.
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

          # Public: the Submit button's actual click handler. Finishes the
          # flight locally first if it hasn't already and then returns the
          # self-contained choice to submit for real -- so ending a route
          # with MP still left takes the exact same one-click as a route
          # that already auto-finished from running out of MP, instead of
          # a separate Finish click before Submit even appears. Mutating --
          # only call from a click handler, never from render (see submit_ready?/
          # submit_button_label for the read-only render-time checks).
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

          # The complete choose-action dispatch table -- shared by
          # process_choose (a real, recorded action: one hop of
          # replay_submitted_flight!'s loop, with @committing true) and
          # local_choose! (every live click while a route is still being
          # built locally and unsubmitted, @committing false). One
          # dispatch table for both guarantees a submitted flight replays
          # through exactly the logic that built it live, hop for hop.
          def dispatch_choice!(entity, choice)
            raise GameError, "Invalid route choice: #{choice}" unless choices.key?(choice)

            @choices_memo = nil

            if choice == FINISH
              finish_route(entity)
            elsif choice == CANCEL
              cancel_route
            elsif choice == UNDO_HEX || (@rollback&.dig(:finished) && choice == undo_click_hex&.id)
              # The second half of this condition is only reachable once
              # nothing else is offered (see compute_choices' finished-
              # flight branch) -- a direct click on an already-finished,
              # not-yet-submitted route's last hex, with nothing to un-
              # reveal (the popup already intercepted the case where
              # there was).
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

            # The @trace.last.id branch above (transshipment disambiguation)
            # calls `choices` mid-method, re-populating @choices_memo from
            # the *pre-finish* trace, then finish_route (right below it)
            # empties @trace without invalidating that cache again --
            # leaving the next ship's turn looking at a stale, mid-flight
            # choice list (still offering the just-finished hex as a
            # "choice", never the real launch hexes). Since launch_at
            # never validates its hex against the entity's own tokens,
            # that stale entry then gets silently accepted as a legitimate
            # launch point. Resetting here, unconditionally, after every
            # branch has run, guarantees the next `choices` call is always
            # freshly computed regardless of how many times something
            # upstream recomputed and cached it mid-dispatch.
            @choices_memo = nil
          end

          # Disambiguates a direct click on the flight's own current hex
          # (dispatch_choice!'s `choice == @trace.last.id` branch) --
          # transshipment pickup or an un-reveal (Undo), whichever the
          # popup actually offered there.
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

            # A flight that finished locally but hasn't been submitted yet
            # blocks starting (or switching to) another ship -- at most one
            # flight is ever pending discard/submit at a time, so there's
            # nothing to interleave (see local_choose!/rollback_local_flight!).
            # The one exception is undoing its own last hex -- clicking the
            # route's endpoint (or, if that would un-reveal a tile, the
            # popup's confirm button) is still offered.
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
            # Exploration reveals hidden information, so a route that has
            # explored is committed — it can be finished but not taken back.
            result[CANCEL] = 'Cancel route' unless @explored_in_trace
            result
          end

          def available_ships(entity)
            @game.route_trains(entity).reject { |t| @ran_ships.include?(t) }
          end

          # With multiple unrun ships, always the first by acquisition
          # order -- no player-facing picker in this PR (deferred to the
          # follow-up that adds the ship-selector tab UI); a corp with
          # several ships simply flies them one at a time in that order.
          #
          # A flight that finished locally but hasn't been submitted yet
          # always wins over that fallback, regardless of how many (or
          # how few) other ships remain unrun -- @rollback[:finished_ship]
          # is already in @ran_ships at this point (finish_route put it
          # there), so once it was the *last* unrun ship, available_ships
          # would otherwise narrow to size 1 and silently hand focus to
          # whatever ship comes next, even though the pending flight is
          # still what the player's looking at (its Submit/Cancel bar,
          # its route on the map).
          def current_ship(entity)
            return @rollback[:finished_ship] if @rollback&.dig(:finished_ship)

            available_ships(entity).first
          end

          def mp_left(entity, ship)
            @game.ship_distance(entity, ship) - @mp_spent
          end

          # Plain one-hop choices: every direct neighbor of the current
          # hex, either a Move (already explored) or an Explore/Skip pair
          # (not yet explored) -- pulled out of compute_choices so it
          # reads as its own named concern, the same way shortcut/pickup/
          # transshipment/refuel choices already are, rather than being
          # the one inline loop left sitting directly in the dispatch
          # method.
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

          # Flight shortcut: lets the player click a hex more than one hop
          # away and fly there by the shortest route, instead of clicking
          # every intermediate hex by hand. Pass-through hexes along the
          # way are always flyovers regardless of whether they've been
          # explored (1 MP, tile stays hidden) -- exploring one of those is
          # a real decision (reveals hidden information, costs an extra
          # MP) the shortcut can't make on the player's behalf. The FINAL
          # hex is different: that's exactly where a hand-flown route
          # would stop and decide whether to explore too, so it gets the
          # same Explore/Fly-over choice a direct neighbor would (see
          # hex_choice_popup), just at the shortcut's own MP cost. Adjacent
          # hexes are excluded here since the normal per-hex choice
          # already covers them.
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

          # Shortcut destinations, one entry per reachable hex 2+ hexes
          # away: {hex_id => {path: [hex, hex, ...], remaining: N}}.
          def shortcut_paths(entity, ship)
            start = @trace.last
            mp = mp_left(entity, ship)
            plain = plain_shortest_paths(start)

            plain.each_with_object({}) do |(hex_id, path), result|
              next if path.size > mp

              result[hex_id] = { path: path, remaining: mp - path.size }
            end
          end

          # Plain BFS shortest-hop-path tree from `start`, completely
          # ignoring refueling stations -- 1 MP per hop, unconstrained by
          # how much MP is actually available (shortcut_paths compares
          # against that separately). Built from Game#hex_bfs, a per-game
          # memoized cache of this exact walk (the hex-adjacency graph
          # never changes over a game) shared with Autorouter's own
          # identical need for it. Returns {hex_id => [hex, hex, ...]}, the
          # hops after `start`, for every hex on the (fully connected,
          # minus empty hexes) board.
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

          # Replays a shortcut path hop by hop via the normal move_to.
          # Every hop but the last is always explore: false -- every
          # pass-through hex is a flyover regardless of whether it's been
          # explored, exactly like a hand-clicked FLYOVER move, so any
          # unexplored hex passed through stays hidden. The final hex
          # honors `explore_destination` (see shortcut_choices/
          # process_choose's SHORTCUT_EXPLORE branch) -- same
          # explore-on-arrival choice a direct neighbor move gets, just
          # reached via the shortcut. Only the final hex (where control
          # returns to the player) offers a transshipment-collection
          # choice, same as any normal move ending there -- the whole
          # point of the shortcut is not stopping at every hex passed
          # through.
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

          # Every real spaceship's name already encodes its stats (e.g.
          # '3/2' = 3 MP, 2 cargo holds); the Probe doesn't follow that
          # convention, so spell its stats out alongside its name instead.
          def ship_label(ship)
            # Just "4/0", matching every other ship's plain movement/
            # cargo naming (see the class comment's naming convention) --
            # the leading "Probe" name made this one row visibly wider
            # than every other ship-selector row for no informational
            # gain, throwing off the row grid's column alignment.
            ship.name == 'Probe' ? "#{ship.distance}/#{@game.cargo_holds_for_ship(ship)}" : ship.name
          end

          # Never automatic (see pick_up_transshipment! above) -- offered
          # as a click choice on the current hex, since the rules permit
          # ending a flight at a transshipment point without collecting.
          def transshipment_choice(_entity, ship, result)
            return unless @game.transshipment_hex?(@trace.last.id)
            return if cargo_full?(ship)

            value = @game.transshipment_value(@trace.last, ship)
            result[TRANSSHIP] = "Transshipment (#{@game.format_currency(value)})"
          end

          def cargo_full?(ship)
            @cargo.size >= @game.cargo_holds_for_ship(ship)
          end

          # The current hex is never one of its own neighbors, so it never
          # gets a plain hex-id key from the loop above -- but hex.rb's
          # generic click dispatch only ever looks for a popup (or a direct
          # bare-hex-id action) when `choices.include?(@hex.id)` is already
          # true. Alias it here so clicking the ship's own hex can trigger
          # the one real action there. With exactly one action available
          # this value is what actually gets dispatched; with 2+ it's a
          # placeholder `hex_choice_popup` always intercepts ahead of.
          def alias_current_hex_action!(result)
            result[UNDO_HEX] = undo_hex_label if undo_last_hex_available?(current_entity)

            matches = result.select { |key, _label| [TRANSSHIP, UNDO_HEX].include?(key) }
            return if matches.empty?

            result[@trace.last.id] ||= matches.values.first
          end

          # Launching costs no MP -- the ship starts at its base, full tank.
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
              # Revealing the tile is itself a reveal of hidden
              # information, whether or not anything found there matters.
              @explored_in_trace = true
              explore_hex_tracked!(hex_id, entity)
            end

            update_trace_highlight
            maybe_auto_finish!(entity, current_ship(entity))
          end

          # Once MP is exhausted, there's nothing left to decide once any
          # pickup still available at the current hex is gone too --
          # auto-finish instead of making the player click "End route" for
          # a foregone conclusion, the same "no click for a choice that
          # isn't really one" principle already applied elsewhere (the SR
          # Done-button fix, ships auto-passing between each other). Skipped
          # while a tile-redraw choice is still pending (Lucky) -- that's a
          # real decision to resolve first, not a foregone conclusion; safe
          # to call repeatedly mid-shortcut-flight too, since MP only ever
          # reaches 0 at the true final hop of any reachable path (see
          # shortcut_paths). A pending refuel choice ALSO blocks this --
          # unlike a pickup, taking it doesn't end the flight, so stranding
          # the ship at 0 MP without offering it first would defeat the
          # entire point of letting refueling be deferred (§7.12).
          def maybe_auto_finish!(entity, ship)
            return unless @trace.size > 1
            return if ship.nil? || mp_left(entity, ship).positive?

            remaining = {}
            transshipment_choice(entity, ship, remaining)
            return unless remaining.empty?

            finish_route(entity)
          end

          # A transshipment point's printed value works like a mine with
          # unlimited availability (no "used" marker, any ship any number of
          # times), but -- unlike an ore pickup -- it's never automatic: the
          # rules permit a ship to end its flight at a transshipment point
          # without collecting there, so picking it up requires an explicit
          # click on the hex, same as any other mine (see
          # transshipment_choice/alias_current_hex_action!/process_choose's
          # TRANSSHIP branch below). Choosing to collect also ends the ship's
          # flight immediately -- unlike an ore pickup, which lets the ship
          # keep flying.
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
            # Only reachable when nothing was explored this trace (choices/pass
            # both guard). Transshipment credits (mine_idx: nil) have no mine
            # state to un-mark, so there's nothing to give back -- cargo is
            # simply discarded.
            @cargo = []
            @trace = []
            @explored_in_trace = false
            @mp_spent = 0
            update_trace_highlight
          end

          # Starting point for a fresh @rollback -- see local_choose!.
          # rand is a single LCG integer (Game::Base#rand/#initialize_seed),
          # so snapshotting it here and restoring it verbatim in
          # rollback_local_flight! is enough to make a later real replay
          # draw identically to whatever the discarded local preview
          # already showed (tile rotation, Lucky's second-draw borrow) --
          # no need to separately track which random calls happened.
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

          # Precisely undoes everything local_choose! has mutated for real
          # since the last submit/discard -- explored hexes/mine reveals,
          # the log tail, and (if the flight had already finished locally)
          # the route/ran-ships bookkeeping finish_route recorded. A no-op
          # when nothing's pending (@rollback nil) -- true both when the
          # player never started a local flight and, deliberately, at the
          # top of every real replay (see replay_submitted_flight!), so a
          # fresh reload with no local state to undo behaves identically
          # to the live browser that just submitted.
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
              # Puts the revealed mine tile back in the Tile Manifest's
              # pool -- explore_hex! removed it on the way in (see its own
              # comment); discarding this preview means it was never
              # really revealed at all.
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

          # Wraps Game#explore_hex! so a local, unsubmitted flight can be
          # rolled back precisely (see rollback_local_flight!) -- records
          # the hex's pre-explore tile so it can be re-laid, and that
          # @mine_state gained a fresh entry so it can be dropped. A no-op
          # tracking-wise during a real replay (@rollback is nil there --
          # see rollback_local_flight!'s comment): nothing will ever need
          # to undo a real, committed explore. `pay:` is deferred to
          # @committing -- see Game#explore_hex!'s own comment.
          def explore_hex_tracked!(hex_id, entity)
            if @rollback
              hex = @game.hex_by_id(hex_id)
              @rollback[:laid_hexes] << { hex_id: hex_id, original_tile: hex.tile }
              @rollback[:mine_state_added] << hex_id
            end
            @game.explore_hex!(hex_id, entity, pay: @committing)
          end

          # The real, recorded handler for SUBMIT_FLIGHT -- rolls back
          # whatever local preview already happened (a no-op on a fresh
          # reload, which never ran one), then replays the submitted
          # choice sequence hop by hop through the exact same
          # dispatch_choice! table local_choose! used, with @committing
          # true so the exploration bonus actually gets paid and
          # finish_route's auto-pass can actually end the turn. Rolling
          # back first (rather than trusting the live browser's
          # already-correct local state) means the browser that submitted
          # and a browser that later reloads from raw_actions run through
          # an identical code path -- no separate "already did this"
          # special case to keep in sync.
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
