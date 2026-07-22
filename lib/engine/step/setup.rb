# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    # Non-blocking meta step, present in every round via Round::Base::DEFAULT_STEPS,
    # that applies Action::Setup god-moves directly to the game state. It mirrors
    # Step::Message / Step::Program: always active, never blocking, so it processes
    # `setup` actions regardless of which game step is currently blocking.
    #
    # A `setup` action carries any subset of directive fields; #process_setup applies
    # them in a fixed order (see below). Each handler no-ops on empty input, so a
    # single action can set as much or as little of the position as desired.
    #
    # Known limitations (by design or deferred):
    # - `advance` lands only at clean round boundaries (start of a SR/OR); arbitrary
    #   mid-round positions are not supported.
    # - Prototype titles may not tolerate advancing into operation (e.g. 1871 has a
    #   pre-existing Stock->Operating bug in its own next_round!).
    # - Deliberately "illegal" states (over cert limit, negative bank, unconnected
    #   track/tokens) are allowed -- this is a god-move editor, not a rules referee.
    # - Tile lays skip the IMPASSABLE_HEX_COLORS neighbor fixup done by Step::Tracker.
    class Setup < Base
      ACTIONS = %w[setup].freeze

      # Safety cap on round transitions when advancing to a target boundary.
      MAX_ADVANCE_ROUNDS = 500

      def actions(entity)
        return [] unless entity.player?

        ACTIONS
      end

      def process_setup(action)
        process_cash(action.cash)
        process_phase(action.phase)
        process_rust(action.rust)
        process_par(action.par)
        process_loans(action.loans)
        process_market(action.market)
        process_shares(action.shares)
        process_trains(action.trains)
        process_tiles(action.tiles)
        process_remove_tiles(action.remove_tiles)
        process_tokens(action.tokens)
        process_companies(action.companies)
        process_extensions(action.extensions)
        process_advance(action.advance)
      end

      def blocks?
        false
      end

      def skip!; end

      def pass!; end

      def unpass!; end

      private

      def process_cash(cash)
        cash.each do |id, amount|
          next if id == 'bank'

          entity = cash_target(id)
          entity.set_cash(amount, @game.bank)
          @log << "-- Setup: #{entity.name} cash set to #{@game.format_currency(amount)} --"
        end

        # Set the bank last so entity transfers above don't disturb it.
        return unless cash.key?('bank')

        @game.bank.send(:cash=, cash['bank'])
        @log << "-- Setup: bank cash set to #{@game.format_currency(cash['bank'])} --"
      end

      def process_loans(loans)
        return if loans.empty?
        raise GameError, "Setup: #{@game.class.title} does not support loans" unless @game.respond_to?(:take_loan)

        loans.each do |h|
          corporation = corporation!(h['corporation'])
          count = h['count'] || 1
          count.times { @game.take_loan(corporation, @game.loans.last) }
          @log << "-- Setup: #{corporation.name} took #{count} loan(s) --"
        end
      end

      def process_phase(target)
        return if target.nil? || target.to_s.empty?

        target = target.to_s
        names = @game.phase.phases.map { |p| p[:name] }
        target_index = names.index(target) || raise(GameError, "Setup: unknown phase '#{target}'")
        if target_index < names.index(@game.phase.name)
          raise GameError, "Setup: phase '#{target}' is before the current phase '#{@game.phase.name}'"
        end

        @game.phase.next! until @game.phase.name == target
        @log << "-- Setup: advanced to phase #{target} --"
      end

      def process_trains(trains)
        trains.each do |h|
          corporation = corporation!(h['corporation'])
          train = depot_train!(h['train'])

          @game.buy_train(corporation, train, :free)
          @game.phase.buying_train!(corporation, train, @game.depot) if h['phase_effects']
          @log << "-- Setup: #{corporation.name} given a #{train.name} train --"
        end
      end

      # Retire every un-rusted train of each named type across the game (corp
      # rosters + depot), e.g. rust the 2s and 3s after advancing the phase.
      def process_rust(rust)
        rust.each do |name|
          retired = @game.trains.select { |t| t.name == name && !t.rusted }
          next if retired.empty?

          retired.each { |t| @game.rust(t) }
          @game.instance_variable_set(:@crowded_corps, nil)
          @log << "-- Setup: rusted #{retired.size} #{name} train(s) --"
        end
      end

      def process_par(par)
        par.each do |h|
          corporation = corporation!(h['corporation'])
          share_price = par_price!(corporation, h['price'])

          @game.stock_market.set_par(corporation, share_price)
          corporation.ipoed = true
          assign_president(corporation, h['president']) if h['president']
          @game.after_par(corporation)
          @log << "-- Setup: #{corporation.name} par'd at #{@game.format_currency(share_price.price)} --"
        end
      end

      def process_market(market)
        market.each do |h|
          corporation = corporation!(h['corporation'])
          raise GameError, "Setup: #{corporation.name} must be par'd before it can be moved" unless corporation.share_price

          @game.stock_market.move(corporation, h['coordinates'], force: true)
          @log << "-- Setup: #{corporation.name} moved to #{@game.format_currency(corporation.share_price.price)} --"
        end
      end

      def process_shares(shares)
        shares.each do |grant|
          corporation = corporation!(grant['corporation'])
          percent = grant['percent']
          # 'player' may be a player id or 'market' (into the share pool).
          target = grant['player'] == 'market' ? @game.share_pool : player!(grant['player'])

          bundle = Engine::ShareBundle.new(take_ipo_shares(corporation, percent))
          @game.share_pool.transfer_shares(bundle, target, allow_president_change: false)
          @log << "-- Setup: #{target.name} granted #{percent}% of #{corporation.name} --"
        end
      end

      # Minimal god-lay mirroring Step::Tracker#lay_tile without the legality checks:
      # rotate -> update inventory -> swap onto hex -> invalidate the routing graph.
      def process_tiles(tiles)
        tiles.each do |h|
          hex = hex!(h['hex'])
          tile = available_tile!(h['tile'])
          old_tile = hex.tile

          tile.rotate!(h['rotation'] || 0)
          @game.update_tile_lists(tile, old_tile)
          hex.lay(tile)
          @game.clear_graph

          @log << "-- Setup: laid tile #{tile.name} on #{hex.id} (rotation #{tile.rotation}) --"
        end
      end

      # Revert each hex to its original (preprinted) tile, returning the laid tile to
      # the pool. Mirrors hex.lay_downgrade (used by 1837's remove-Italy event).
      def process_remove_tiles(remove_tiles)
        remove_tiles.each do |hex_id|
          hex = hex!(hex_id)
          next if hex.tile == hex.original_tile

          laid = hex.tile
          hex.lay_downgrade(hex.original_tile)
          @game.tiles << laid unless laid.preprinted
          @game.clear_graph
          @log << "-- Setup: removed tile from #{hex.id} --"
        end
      end

      def process_tokens(tokens)
        tokens.each do |h|
          corporation = corporation!(h['corporation'])

          if h['home']
            @game.place_home_token(corporation)
            @log << "-- Setup: placed #{corporation.name} home token --"
            next
          end

          hex = hex!(h['hex'])
          city = hex.tile.cities[h['city'] || 0]
          raise GameError, "Setup: #{hex.id} has no city #{h['city'] || 0}" unless city

          token = corporation.next_token
          raise GameError, "Setup: #{corporation.name} has no available token" unless token

          city.place_token(corporation, token, free: true, check_tokenable: false)
          @log << "-- Setup: placed #{corporation.name} token on #{hex.id} --"
        end
      end

      # Hand each game-specific directive to the game (override
      # Game::Base#process_setup_extension in a g_<title> module).
      def process_extensions(extensions)
        extensions.each { |key, payload| @game.process_setup_extension(self, key, payload) }
      end

      def process_companies(companies)
        companies.each do |h|
          company = company!(h['company'])

          if h['close']
            remove_from_auction(company)
            company.close!
            @log << "-- Setup: #{company.name} closed --"
            next
          end

          new_owner = corp_or_player!(h['owner'])
          company.owner&.companies&.delete(company)
          company.owner = new_owner
          new_owner.companies << company
          remove_from_auction(company)
          @log << "-- Setup: #{company.name} assigned to #{new_owner.name} --"
        end
      end

      # Walk the game's own round state machine (init/auction -> SR -> OR -> ...) until
      # the requested boundary is reached, so a preset resumes at a clean round start
      # instead of mid opening-auction. Uses transition_to_next_round! (the same hook
      # the engine uses between rounds), which respects per-game next_round! overrides.
      def process_advance(advance)
        return if advance.nil? || advance.empty?

        guard = 0
        until advance_target_reached?(advance)
          if @game.finished || (guard += 1) > MAX_ADVANCE_ROUNDS
            raise GameError, "Setup: could not advance to #{advance_description(advance)}"
          end

          @game.transition_to_next_round!
        end

        apply_player_order(advance)
        @log << "-- Setup: advanced to #{@game.round.name} --"
      end

      # Set the priority deal / player rotation. `player_order` gives the exact
      # order (priority is first); `priority` just moves one player to the front.
      # At the start of a round, entity 0 = @players.first, so this fixes who acts
      # first and who holds priority deal -- game-agnostic (bypasses the per-game
      # NEXT_SR_PLAYER_ORDER rule the empty advance rounds would otherwise apply).
      def apply_player_order(advance)
        order =
          if (list = advance['player_order'])
            list.map { |id| player!(id) }
          elsif (pid = advance['priority'])
            priority = player!(pid)
            [priority, *@game.players.reject { |p| p == priority }]
          end
        return unless order

        @game.instance_variable_set(:@players, order)
        round = @game.round
        round.entities = round.select_entities
        round.entity_index = 0
        round.at_start = true
      end

      def advance_target_reached?(advance)
        round = @game.round
        case advance['round']
        when 'stock'
          round.is_a?(Engine::Round::Stock) && matches_turn?(advance)
        when 'operating'
          round.is_a?(Engine::Round::Operating) && matches_turn?(advance) &&
            (advance['round_num'].nil? || round.round_num == advance['round_num'])
        else
          raise GameError, "Setup: unknown advance round '#{advance['round']}' (use 'stock' or 'operating')"
        end
      end

      def matches_turn?(advance)
        advance['turn'].nil? || @game.turn == advance['turn']
      end

      def advance_description(advance)
        [advance['round'], advance['turn'] && "turn #{advance['turn']}",
         advance['round_num'] && "OR #{advance['round_num']}"].compact.join(' ')
      end

      # If a private is assigned during the initial auction, the auction step still
      # lists it as available (it tracks its own `companies` pool). Drop it there so
      # it doesn't linger in the auction. No-op outside an auction.
      def remove_from_auction(company)
        step = @game.round.active_step
        return unless step.respond_to?(:companies)

        pool = step.companies
        pool.delete(company) if pool.is_a?(Array) && pool.include?(company)
      end

      # --- entity lookup helpers (shared by all directive handlers) ---

      def cash_target(id)
        @game.corporation_by_id(id) || find_player(id) ||
          raise(GameError, "Setup: unknown cash target '#{id}'")
      end

      # The id lookups below are public so game setup extensions can reuse them
      # via the step passed to Game::Base#process_setup_extension.
      public

      def player!(id)
        find_player(id) || raise(GameError, "Setup: unknown player '#{id}'")
      end

      # Player ids are integers, but JSON object keys (and some fields) arrive as
      # strings, so coerce a numeric string id before giving up.
      def find_player(id)
        @game.player_by_id(id) ||
          (id.is_a?(String) && id.match?(/\A-?\d+\z/) ? @game.player_by_id(id.to_i) : nil)
      end

      def corporation!(id)
        @game.corporation_by_id(id) || raise(GameError, "Setup: unknown corporation '#{id}'")
      end

      def company!(id)
        @game.company_by_id(id) || raise(GameError, "Setup: unknown company '#{id}'")
      end

      def hex!(id)
        @game.hex_by_id(id) || raise(GameError, "Setup: unknown hex '#{id}'")
      end

      # An unlaid tile of the given name from the available pool (laid tiles are
      # removed from @game.tiles by update_tile_lists, so pool tiles have no hex).
      def available_tile!(name)
        @game.tiles.find { |t| t.name == name } ||
          raise(GameError, "Setup: no unlaid '#{name}' tile available")
      end

      # A private company can be owned by a player (integer id) or a corporation (string id).
      def corp_or_player!(id)
        @game.corporation_by_id(id) || find_player(id) ||
          raise(GameError, "Setup: unknown owner '#{id}'")
      end

      private

      def depot_train!(name)
        @game.depot.upcoming.find { |t| t.name == name } ||
          raise(GameError, "Setup: no '#{name}' train available in the depot")
      end

      def par_price!(corporation, price)
        @game.stock_market.par_prices.find { |sp| sp.price == price } ||
          raise(GameError, "Setup: no par price #{price} available for #{corporation.name}")
      end

      # Give the president's certificate to a player; transfer_shares assigns the
      # presidency (corporation.owner) via its normal majority check.
      def assign_president(corporation, player_id)
        player = player!(player_id)
        president_share = corporation.ipo_shares.find(&:president)
        raise GameError, "Setup: no president's share available for #{corporation.name}" unless president_share

        @game.share_pool.transfer_shares(president_share.to_bundle, player, allow_president_change: true)
      end

      # Pull enough non-president IPO shares to total `percent`.
      def take_ipo_shares(corporation, percent)
        remaining = percent
        shares = []
        corporation.ipo_shares.reject(&:president).each do |share|
          break unless remaining.positive?
          next if share.percent > remaining

          shares << share
          remaining -= share.percent
        end
        raise GameError, "Setup: cannot assemble #{percent}% of #{corporation.name} from IPO" unless remaining.zero?

        shares
      end
    end
  end
end
