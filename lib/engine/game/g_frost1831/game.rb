# frozen_string_literal: true

require_relative 'diamond_trains'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'parliament_movement'
require_relative 'stock_market'
require_relative 'round/stock'
require_relative 'round/voting'
require_relative 'step/buy_cert'
require_relative 'step/buy_company'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/buy_train'
require_relative 'step/choose_factions'
require_relative 'step/choose_influence'
require_relative 'step/choose_priority_faction'
require_relative 'step/dividend'
require_relative 'step/faction_dividend'
require_relative 'step/home_token'
require_relative 'step/intervention'
require_relative 'step/turmoil'
require_relative 'step/pre_turmoil_influence'
require_relative 'step/discard_train'
require_relative 'step/route'
require_relative 'step/special_choose'
require_relative 'step/special_track'
require_relative 'step/token'
require_relative 'step/track'
require_relative 'step/vote'
require_relative 'tiles'
require_relative '../base'

module Engine
  module Game
    module GFrost1831
      class Game < Game::Base
        include_meta(GFrost1831::Meta)
        include DiamondTrains
        include Entities
        include Map
        include Tiles

        # Stub hex for faction tokens that aren't placed yet — displays as "5◆" on the card
        FactionHexStub = Struct.new(:name)
        FACTION_TOKEN_HEX = FactionHexStub.new('5◆').freeze

        CURRENCY_FORMAT_STR = '£%s'

        BANK_CASH = 9000

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        SELL_BUY_ORDER = :sell_buy

        HOME_TOKEN_TIMING = :operate

        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: :not_if_upgraded, upgrade: false },
        ].freeze

        GAME_END_CHECK = { bank: :full_or, custom: :one_more_full_or_set }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'First D train is purchased'
        )

        GAME_END_REASONS_TIMING_TEXT = Base::GAME_END_REASONS_TIMING_TEXT.merge(
          one_more_full_or_set: 'Finish current OR, then 1 more full set (SR + Voting + ORs)'
        )

        EBUY_CAN_SELL_SHARES = false
        EBUY_OWNER_MUST_HELP = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = false

        # Rusted/discarded trains are removed from the game, not sent to bank pool
        DISCARDED_TRAINS = :remove

        CERT_LIMIT = {
          2 => { 8 => 31, 7 => 27, 6 => 25, 5 => 22 },
          3 => { 8 => 25, 7 => 22, 6 => 20, 5 => 18 },
          4 => { 8 => 22, 7 => 20, 6 => 18, 5 => 16 },
          5 => { 8 => 19, 7 => 17, 6 => 15, 5 => 14 },
        }.freeze

        MARKET = [
          %w[_ _B!d _B!d _B!d _B!d _B!d _B!d _B!d _B!d _B!d _B!d _B!d _B!d _],
          %w[_c!n 70y 80 90 100p 110 120 140 160 190 220 250 300K _B!l],
          %w[_c!n 60y 70 80 90p 100 110 130 150 180 210 240K],
          %w[_c!n 50y 60 70 80p 90 100 120 140 170 200K],
          %w[_c!n 40y 50 60 70p 80 90 110 130 160K],
          %w[_c!n 30y 40 50 60p 70 80 100 120K],
          %w[_c!n 20y 30 40 50 60 70 80K],
          %w[_c!n 10y 20 30 40 50 60K],
          %w[_c!n _c!n],
          %w[70r 80r 100r 120r 140r 160r 190r 220r 250r!n],
        ].freeze

        FACTION_ROW = 9

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          close: :orange,
          pays_bonus: :purple,
          pays_unique_bonus: :blue,
          repar: :gray,
        ).freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par: 'Initial Offering (£60–£100)',
          close: 'Intervention Zone — corporation is eliminated',
          pays_bonus: 'Influence Zone — grants Influence',
          pays_unique_bonus: 'Influence — first to arrive',
          no_cert_limit: 'Shares do not count towards cert limit, may hold >60%',
          repar: 'Faction Values in Parliament',
        ).freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies parliament_opens],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies turmoil],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['blizzard'],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['turmoil'],
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: ['turmoil'],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 8,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 5,
            events: [{ 'type' => 'parliament_opens' }],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 4,
            events: [{ 'type' => 'turmoil' }],
          },
          {
            name: '5',
            distance: 5,
            price: 530,
            num: 3,
            events: [{ 'type' => 'blizzard' }, { 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 2,
            events: [{ 'type' => 'turmoil' }],
          },
          {
            name: 'D',
            distance: 999,
            price: 1100,
            num: 'unlimited',
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300, '4◆' => 300, '5◆' => 300, '6◆' => 300 },
            events: [{ 'type' => 'turmoil' }],
          },
        ].freeze

        TRAIN_NAMES = {
          '2' => 'Hope',
          '3' => 'Long John',
          '4' => 'Ice Breaker',
          '5' => 'The Queen',
          '6' => 'Nightmare',
          'D' => 'Silver Bullet',
          '2◆' => 'Hope ◆',
          '3◆' => 'Long John ◆',
          '4◆' => 'Ice Breaker ◆',
          '5◆' => 'The Queen ◆',
          '6◆' => 'Nightmare ◆',
          'D◆' => 'Silver Bullet ◆',
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'parliament_opens' => ['Parliament Opens', 'Factions become available in the next Stock Round'],
          'turmoil' => ['Turmoil', 'Political turmoil — consequences depend on Parliament state'],
          'blizzard' => ['Blizzard', 'Yellow tiles on marked hexes are removed; isolated stations are eliminated'],
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'parliament_opens' => ['Parliament Opens', 'Factions are available for purchase'],
          'turmoil' => ['Turmoil', 'Political turmoil triggered'],
          'blizzard' => ['Blizzard', 'Blizzard event active — marked yellow tiles removed'],
        ).freeze

        # Override to display thematic train names (e.g. "2 (Hope)")
        def trains_str(corporation)
          return [''] if corporation.type == :faction

          super
        end

        def info_train_name(train)
          name = train.names_to_prices.keys.join(', ')
          base_name = train.name.delete('◆').strip
          thematic = self.class::TRAIN_NAMES[base_name]
          thematic ? "#{name} (#{thematic})" : name
        end

        # Override to add extra 3-train if variant is active
        def num_trains(train)
          return train[:num] + 1 if train[:name] == '3' && extra_train?

          super
        end

        def buy_train(operator, train, price = nil)
          first_d = train.name == 'D' && !@d_train_bought
          from_depot = train.owner == @depot

          # D train grants influence BEFORE events fire (per manual 10.4.5.4)
          # Only when purchased from the depot (bank), not from other corporations
          if train.name == 'D' && from_depot && @corporation_factions[operator.id]
            @d_train_influence_pending = operator
          end

          super

          # Grant influence after super but event_turmoil! will wait for it
          if @d_train_influence_pending == operator
            grant_influence_for_d_purchase(operator)
            # If no influence choice needed (single faction), turmoil was deferred
            execute_deferred_turmoil! unless @pending_influence_choice
          end

          # First D purchased triggers game end only for legacy :d_train_endgame games
          # BUT only if bank hasn't already broken (bank trigger takes priority if it happened first).
          # Only legacy games flagged with :d_train_endgame end on the first D train;
          # all new games end only when the bank breaks.
          if first_d && !@bank_broken_trigger && d_train_endgame?
            @d_train_bought = true
            # Truncate remaining ORs - go to SR after current OR ends
            @operating_rounds = @round.round_num if @round.is_a?(Engine::Round::Operating)
            # Set final turn: current turn + 1 (we'll do one more full SR + Voting + ORs)
            # This needs to be set here, before game_end_check is called again, to lock in the correct turn
            @final_turn ||= @turn + 1
            @log << "-- First D train purchased — game will end at conclusion of OR #{@final_turn}.#{@phase.operating_rounds} --"
          end
        end

        # Track when bank breaks so D train doesn't override it
        def end_now?(after)
          if after == :full_or && @bank.broken?
            @bank_broken_trigger ||= true
          end

          super
        end

        def game_end_check_custom?
          @d_train_bought
        end

        # By default the game ends only when the bank breaks. Only legacy games
        # flagged with :d_train_endgame keep the custom (first D train) trigger.
        def game_end_check_values
          return self.class::GAME_END_CHECK if d_train_endgame?

          { bank: :full_or }
        end

        def game_ending_description
          reason, after = game_end_check
          return unless after

          if @d_train_bought && @final_turn
            "Game ends at conclusion of OR #{@final_turn}.#{@phase.operating_rounds}"
          elsif reason == :bank
            if @round.is_a?(Engine::Round::Operating)
              "Game ends at conclusion of OR #{@turn}.#{operating_rounds}"
            else
              "Game ends at conclusion of the next full OR set"
            end
          end
        end

        def end_game!(game_end_reason)
          return if @finished

          # Skip final maintenance if game was manually ended
          if game_end_reason == :manually_ended
            @finished = true
            @game_end_reason = game_end_reason
            @manually_ended = true
            store_player_info
            return
          end

          # If we're resuming after pre-turmoil window, skip the turmoil part
          unless @end_game_turmoil_done
            @log << '-- Final Maintenance --'
            @end_game_reason = game_end_reason

            # 1. Final Turmoil (may pause for influence window)
            event_turmoil!

            # If turmoil paused for influence window, return and wait
            return if @pre_turmoil_window

            @end_game_turmoil_done = true
          end

          continue_end_game!
        end

        def continue_end_game!
          # 2. Move all Influence from corp cards to respective factions (no limits)
          @corporations.select { |c| c.type != :faction && !c.closed? }.each do |corp|
            influence = @corporation_influence[corp.id] || {}
            influence.each do |faction_sym, count|
              next unless count.positive?

              @faction_influence[faction_sym] += count
              @log << "#{corp.name} transfers #{count} Influence to #{faction_display_name(faction_sym)}"
            end
            @corporation_influence[corp.id] = {}
          end

          # 3. Influence exchange: every 4 Influence → faction value +1 (move right, max 250)
          @corporations.select { |c| c.type == :faction }.each do |faction|
            total_influence = (@faction_influence[faction.id] || 0).to_i
            moves = (total_influence.to_f / 4).floor

            # Calculate how many tokens are available to lose
            tokens_total = faction.tokens.size - 1  # 8 additional tokens
            tokens_used = faction.share_price&.coordinates&.[](1) || 0
            tokens_available = [tokens_total - tokens_used, 0].max

            # Actual moves is limited by available tokens and max price (250)
            actual_moves = 0
            moves.times do
              break if faction.share_price&.price && faction.share_price.price >= 250
              break if tokens_available <= actual_moves

              @stock_market.move_right(faction)
              actual_moves += 1
            end

            # Keep par_price synced so the UI shows the correct price everywhere
            faction.par_price = faction.share_price

            # Log the result
            faction_full_name = faction_display_name(faction.id)
            if actual_moves.positive?
              tokens_word = actual_moves == 1 ? 'token' : 'tokens'
              @log << "#{faction_full_name} has #{total_influence} Influence and lost #{actual_moves} #{tokens_word}. "\
                      "#{faction.name}'s value increases to #{format_currency(faction.share_price.price)}"
            elsif moves.positive?
              # Wanted to move but couldn't (already at max or no tokens)
              @log << "#{faction_full_name} has #{total_influence} Influence and lost no tokens. "\
                      "#{faction.name}'s value already is #{format_currency(faction.share_price.price)}"
            else
              # No moves earned
              @log << "#{faction_full_name} has #{total_influence} Influence (no token loss)"
            end
          end

          # Call the base class end_game! to finalize
          @finished = true
          @game_end_reason = @end_game_reason
          store_player_info
          @round_counter += 1
          scores = result.map { |id, value| "#{@players.find { |p| p.id == id.to_i }&.name} (#{format_currency(value)})" }
          @log << "-- Game over: #{scores.join(', ')} --"
        end

        def grant_influence_for_d_purchase(corporation)
          factions = @corporation_factions[corporation.id] || []
          available = factions.select { |f| within_influence_limit?(corporation, f) }

          if available.empty?
            @log << "#{corporation.name} cannot receive influence (both factions at limit — cube discarded)"
            return
          end

          if available.size == 1
            @log << "#{corporation.name} gains 1 Influence (D train purchase)"
            queue_influence_choice(corporation, available, reason: 'D train purchase')
          else
            @log << "#{corporation.name} gains 1 Influence (D train purchase) — choose faction"
            queue_influence_choice(corporation, available, reason: 'D train purchase')
          end
        end

        def within_influence_limit?(corporation, faction_sym)
          current = @corporation_influence[corporation.id]&.dig(faction_sym) || 0
          limit = corporation_influence_limit
          current < limit
        end

        def queue_influence_choice(corporation, factions, reason: nil)
          @pending_influence_queue ||= []
          @pending_influence_queue << {
            corporation: corporation,
            entity: corporation.owner,
            factions: factions,
            reason: reason,
          }
          # Set pending_influence_choice to the first item in queue
          @pending_influence_choice = @pending_influence_queue.first
          @round.clear_cache! if @round
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            GFrost1831::Step::BuyCert,
          ])
        end

        def stock_round
          GFrost1831::Round::Stock.new(self, [
            GFrost1831::Step::PreTurmoilInfluence,
            GFrost1831::Step::Intervention,
            GFrost1831::Step::DiscardTrain,
            Engine::Step::Exchange,
            GFrost1831::Step::ChooseFactions,
            GFrost1831::Step::HomeToken,
            GFrost1831::Step::SpecialChoose,
            Engine::Step::SpecialTrack,
            GFrost1831::Step::ChooseInfluence,
            GFrost1831::Step::BuySellParShares,
            GFrost1831::Step::ChoosePriorityFaction,
          ])
        end

        def clear_graph
          super
          @no_blocking_graph&.clear
        end

        def clear_graph_for_entity(entity)
          # Clear both graphs to ensure no stale cache when tokens are placed
          @graph&.clear
          @no_blocking_graph&.clear
        end

        # Override to treat home hexes as connected for corps laying first tile
        # Without this, legal_tile_rotation? fails because hex_neighbors returns nil
        # for corps that haven't laid track yet (home hex not in connected_hexes)
        def init_graph
          Graph.new(self, home_as_token: true)
        end

        # Expose reorder_players publicly for use by Stock round
        def reorder_players(order = nil, log_player_order: false, silent: false)
          super
        end

        def operating_round(round_num)
          # Clear OR priority choice at start of each OR
          clear_or_priority_choice!

          # Trigger OR priority choice if needed
          if needs_or_priority_choice?
            priority_player = players.reject(&:bankrupt).first
            trigger_or_priority_choice!(priority_player)
          end

          Engine::Round::Operating.new(self, [
            GFrost1831::Step::ChoosePriorityFaction,
            GFrost1831::Step::PreTurmoilInfluence,
            GFrost1831::Step::Turmoil,
            GFrost1831::Step::Intervention,
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            GFrost1831::Step::HomeToken,
            GFrost1831::Step::ChooseInfluence,
            GFrost1831::Step::SpecialChoose,
            GFrost1831::Step::SpecialTrack,
            GFrost1831::Step::BuyCompany,
            GFrost1831::Step::Track,
            GFrost1831::Step::Token,
            GFrost1831::Step::FactionDividend,
            GFrost1831::Step::Route,
            GFrost1831::Step::Dividend,
            GFrost1831::Step::DiscardTrain,
            GFrost1831::Step::BuyTrain,
            GFrost1831::Step::SpecialTrack,
            [GFrost1831::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_round_finished
          last_winner = @round.active_step&.instance_variable_get(:@last_winner)
          if last_winner
            winner_idx = @players.index(last_winner)
            @players.rotate!(winner_idx + 1)
          end
        end

        def init_cert_limit
          player_count = @players.size
          cert_limit = self.class::CERT_LIMIT[player_count]
          return cert_limit unless cert_limit.is_a?(Hash)

          # Count corporations in play (excludes closed corps and factions)
          corps_in_play = @corporations.count { |c| !c.closed? && c.type != :faction }
          cert_limit.reject { |k, _| k.to_i < corps_in_play }
                    .min_by(&:first)&.last || cert_limit.values.last
        end

        def num_certs(entity)
          certs = entity.shares.sum do |s|
            s.corporation.counts_for_limit && s.counts_for_limit ? s.cert_size : 0
          end
          # FAV and INF are internal game mechanics and do not count toward cert limit.
          # Everything else (private companies, intervention cards) counts normally.
          company_certs = entity.companies.count { |c| !%w[FAV INF].include?(c.sym) }
          certs + company_certs
        end

        def par_prices(_corp = nil)
          stock_market.par_prices
        end

        def init_stock_market
          GFrost1831::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                      multiple_buy_types: self.class::MULTIPLE_BUY_TYPES,
                                      sold_out_top_row_movement: self.class::SOLD_OUT_TOP_ROW_MOVEMENT)
        end

        def game_corporations
          self.class::CORPORATIONS + self.class::FACTIONS
        end

        # Display order: factions in Arena order, then corporations by market value
        def sorted_corporations
          factions = all_factions_arena_order
          corps = @corporations.select { |c| c.type != :faction }

          # Separate into: floated, IPO'd but not floated, no IPO
          floated_corps, not_floated = corps.partition(&:floated?)
          ipoed_corps, no_ipo_corps = not_floated.partition(&:ipoed)

          factions + floated_corps.sort + ipoed_corps.sort + no_ipo_corps
        end

        # Factions operate BEFORE corporations in Arena order, then corps by market value
        def operating_order
          factions = faction_operating_order
          corps = @corporations.select { |c| c.floated? && c.type != :faction }.sort
          factions + corps
        end

        # Founded factions in Arena order for OR
        def faction_operating_order
          return [] unless parliament_open?

          factions_or_order.select { |f| f.floated? }
        end

        # Insert Voting Round between SR and OR (from Phase 3 onwards)
        def next_round!
          @round =
            case @round
            when GFrost1831::Round::Stock
              @operating_rounds = @phase.operating_rounds
              # reorder_players is now called in Stock::finish_round
              # before priority faction choice trigger
              if parliament_open? && faction_voting_order.any?
                new_voting_round
              else
                new_operating_round
              end
            when GFrost1831::Round::Voting
              # Unlock all regulations for next voting round
              @regulations.each { |_, reg| reg.delete(:locked) }
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def new_voting_round
          @log << "-- Voting Round #{@turn} --"
          start_voting_round
          GFrost1831::Round::Voting.new(self, [
            GFrost1831::Step::SpecialChoose,
            GFrost1831::Step::Vote,
          ])
        end

        def after_end_of_operating_turn(operator)
          remove_favor_from_operator(operator)
        end

        def new_operating_round(round_num = 1)
          @favor_used_this_or = Hash.new(0)
          super
        end

        def can_par?(corporation, _player)
          return false if corporation.ipoed
          # Factions cannot be parred — they are bought at fixed price
          return false if corporation.type == :faction

          true
        end

        # Factions cannot buy private companies
        def purchasable_companies(entity = nil)
          return [] if entity.is_a?(Engine::Corporation) && entity.type == :faction

          super
        end

        # Hide FAVOR and INF companies from card displays
        def companies_sort(companies)
          companies.reject { |c| %w[FAV INF].include?(c.sym) }
        end

        # During voting round, only show the Use Influence (INF) ability.
        # All other private company abilities are irrelevant during voting.
        # During favor mode, show only INF (so player can use influence before confirming favor).
        # INF ability only shows to the player who owns it (not during other players' turns).
        # PAF (Affiliate) only shows after parliament opens (factions available).
        def entity_can_use_company?(entity, company)
          # INF is player-owned and should only be usable by its owner
          if company.sym == 'INF'
            current_player = if @round.is_a?(GFrost1831::Round::Voting)
                               current_voting_president
                             elsif @round.is_a?(Engine::Round::Operating)
                               @round.current_entity&.player
                             else
                               @round.current_entity
                             end
            return false unless current_player == company.owner
          end

          # PAF (Affiliate) only available after parliament opens
          return false if company.sym == 'PAF' && !parliament_open?

          if @round.is_a?(GFrost1831::Round::Voting)
            return company.sym == 'INF'
          end

          if @round.respond_to?(:favor_mode) && @round.favor_mode
            return company.sym == 'INF'
          end

          super
        end

        # Show factions before corporations in the Entities tab (bank row)
        def bank_sort(corporations)
          factions, corps = corporations.partition { |c| c.type == :faction }
          factions.sort_by(&:name) + corps.sort_by(&:name)
        end

        # R2: Upgrade cost depends on regulation (ONLY for actual upgrades, not yellow lays)
        def upgrade_cost(tile, hex, entity, spender)
          return super if entity&.type == :faction

          # For yellow lays: use base engine cost (includes mountain terrain)
          # R1 flat cost is added separately by tile_cost_with_discount
          return super if tile.color == :white

          # For actual upgrades (yellow→green, green→brown, etc.)
          base_cost = super

          r2_position = regulation_value('R2')
          upgrade_extra = case r2_position
                          when 0 then 0
                          when 1
                            tile.cities.empty? && tile.towns.empty? ? 20 : 0
                          when 2 then 20
                          else 0
                          end

          base_cost + upgrade_extra
        end

        # R1: Cost for laying yellow tiles (per tile, not cumulative)
        def tile_cost_with_discount(tile, hex, entity, spender, cost)
          return cost if entity&.type == :faction
          return cost unless tile.color == :yellow # R1 only for yellow tile lays

          # cost already includes terrain (mountain) from upgrade_cost
          # R1 adds a flat cost per yellow tile based on regulation and which tile this is
          r1_position = regulation_value('R1')
          num_laid = @round.respond_to?(:num_laid_track) ? @round.num_laid_track : 0

          r1_cost = case r1_position
                    when 0 then 0 # Loose: £0 per tile
                    when 1 # Normal: 1st=£0, 2nd=£20
                      num_laid >= 1 ? 20 : 0
                    when 2 then 20 # Tight: £20 per tile
                    else 0
                    end

          cost + r1_cost
        end

        # Factions don't run routes
        def can_run_route?(entity)
          return false if entity.type == :faction

          super
        end

        # Override: don't auto-close during favor preview. Outside favor, trigger intervention manually.
        def close_corporations_in_close_cell!
          # During favor mode, never trigger
          return if @round&.respond_to?(:favor_mode) && @round.favor_mode

          # Don't re-trigger if intervention already pending
          return if @pending_intervention

          # Outside favor: check and trigger intervention
          return unless stock_market.has_close_cell

          @corporations.each do |corp|
            next if corp.closed? || corp.type == :faction
            next unless corp.share_price&.type == :close

            trigger_intervention(corp)
            break # Only one intervention at a time
          end
        end

        def action_processed(action)
          super

          # If intervention was triggered, clear round cache so Intervention step becomes active
          return unless @pending_intervention
          return unless @round

          @round.clear_cache!
        end

        def trigger_intervention(corporation)
          @log << "-- #{corporation.name} enters Intervention Zone! --"

          corp_factions = corporation_factions(corporation)
          opposing = FACTION_SYMS.reject { |f| corp_factions.include?(f) }
          opposing_corps = opposing.map { |sym| @corporations.find { |c| c.id == sym } }.compact

          opposing_founded = opposing_corps.select { |f| f.floated? }

          # === 12.2.1 Certificate Transfer ===
          opposing_founded.each do |faction|
            @log << "#{faction.name} receives 1 certificate of #{corporation.name}"
            @faction_certificates ||= Hash.new(0)
            @faction_certificates[faction.id] ||= []
            @faction_certificates[faction.id] << corporation.id
          end

          # === 12.2.2 Certificates Compensated ===
          par_value = corporation.original_par_price&.price || corporation.par_price&.price || 0
          president = corporation.owner

          corporation.player_share_holders.each do |player, percent|
            next if player == president
            next unless percent.positive?

            shares_count = (percent / 10.0).floor  # 10% shares
            compensation = shares_count * par_value
            next unless compensation.positive?

            paid_from_corp = [corporation.cash, compensation].min
            corporation.spend(paid_from_corp, player) if paid_from_corp.positive?

            remainder = compensation - paid_from_corp
            if remainder.positive?
              paid_from_president = [president.cash, remainder].min
              president.spend(paid_from_president, player) if paid_from_president.positive?

              debt = remainder - paid_from_president
              if debt.positive?
                # President takes on debt from bank
                @bank.spend(debt, player)
                president.debt += debt
                @log << "#{president.name} takes on #{format_currency(debt)} loan"
              end
            end

            @log << "#{player.name} receives #{format_currency(compensation)} compensation for #{corporation.name} shares"
          end

          # === 12.2.3 Station Replacement ===
          stations = corporation.tokens.select(&:used)

          if stations.empty? || opposing_founded.empty?
            # No stations or no founded opposing factions — skip
            finalize_intervention(corporation)
          elsif needs_station_choice?(corporation, stations, opposing_founded)
            # Need player input — set pending intervention
            @pending_intervention = corporation
            @intervention_data = {
              corporation: corporation,
              opposing: opposing_founded,
              stations: stations,
              assigned: {},
            }
          else
            # Auto-assign stations (no choice needed)
            auto_assign_stations(corporation, stations, opposing_founded)
            finalize_intervention(corporation)
          end
        end

        attr_reader :pending_intervention, :intervention_data

        def intervention_station_choices
          return {} unless @intervention_data

          data = @intervention_data
          stations = data[:stations].reject { |t| data[:assigned].key?(t) }
          opposing = data[:opposing].reject { |f| data[:assigned].values.include?(f) }

          choices = {}

          stations.each do |token|
            hex = token.hex
            next unless hex

            hex_name = hex.name
            opposing.each do |faction|
              next unless faction_can_receive_station?(faction, token)

              choices["#{hex_name}:#{faction.id}"] = "#{hex_name} → #{faction.name}"
            end
          end

          choices
        end

        def process_intervention_choice(choice)
          return unless @intervention_data

          data = @intervention_data

          hex_name, faction_id = choice.split(':')
          faction = @corporations.find { |c| c.id == faction_id }
          token = data[:stations].find { |t| !data[:assigned].key?(t) && t.hex&.name == hex_name }

          return unless faction && token

          # Replace station with faction base
          place_intervention_base(data[:corporation], token, faction)
          data[:assigned][token] = faction

          # Check if intervention is complete
          remaining_stations = data[:stations].reject { |t| data[:assigned].key?(t) }
          remaining_factions = data[:opposing].reject { |f| data[:assigned].values.include?(f) }

          if remaining_factions.empty?
            # All factions assigned — done
            finalize_intervention(data[:corporation])
          elsif remaining_factions.size == 1
            # 1 faction left — check if she has exactly 1 eligible station
            eligible = remaining_stations.select { |t| faction_can_receive_station?(remaining_factions.first, t) }
            if eligible.size <= 1
              # Auto-assign (or nothing if no eligible station)
              if eligible.size == 1
                place_intervention_base(data[:corporation], eligible.first, remaining_factions.first)
                data[:assigned][eligible.first] = remaining_factions.first
              end
              finalize_intervention(data[:corporation])
            end
            # else: more than 1 eligible — player must click another hex
          end
        end

        def finalize_intervention(corporation)
          @pending_intervention = nil
          @intervention_data = nil

          # === 12.2.4 Reduction in cert limit ===
          president = corporation.owner
          if president
            # Intervention cards: 1 for 4-5 players, 2 for 2-3 players
            cards = @players.size <= 3 ? 2 : 1
            @player_intervention_cards ||= Hash.new(0)
            @player_intervention_cards[president.id] += cards

            cards.times do |_i|
              card = Engine::Company.new(
                sym: "INT(#{corporation.id})",
                name: 'Intervention Card',
                value: 0,
                revenue: 0,
                desc: "Intervention penalty for #{corporation.name}. Cannot be sold. Does not close in Phase 5.",
                color: nil,
                abilities: [{ type: 'no_buy' }, { type: 'close', on_phase: 'never' }],
              )
              card.owner = president
              president.companies << card
              @companies << card
            end
            update_cache(:companies)
            @log << "#{president.name} receives #{cards} Intervention Card(s)"
          end

          # === 12.2.5 Corporation Eliminated ===
          @corporation_influence.delete(corporation.id)
          @corporation_factions.delete(corporation.id)
          @favors_used.delete(corporation.id)

          @log << "#{corporation.name} is eliminated from the game"
          close_corporation(corporation, quiet: true)
          on_corporation_eliminated(corporation)
        end

        # Override to protect FAV and INF companies from being closed with corporation
        def close_corporation(corporation, quiet: false)
          # Remove FAV from the corporation before closing (so it doesn't get closed with it)
          if @favor_company && corporation.companies.include?(@favor_company)
            corporation.companies.delete(@favor_company)
            @favor_company.owner = nil
          end

          # Remove INF from the corporation's president if they own it
          # (INF is player-owned, not corp-owned, so this shouldn't happen, but just in case)

          super
        end

        # From the second corporation eliminated (Blizzard or Intervention),
        # the cheapest available train in the depot is removed from the game
        # and can trigger a phase change (section 10.4.5.5).
        def on_corporation_eliminated(_corporation)
          @corporations_eliminated_count += 1
          return unless @corporations_eliminated_count >= 2

          train = @depot.min_depot_train
          return unless train

          train_name = train.name
          remove_train(train)
          @log << "-- #{train_name} train removed from the game (#{@corporations_eliminated_count}th+ corporation eliminated) --"
          @phase.buying_train!(nil, train, @depot)
        end

        def faction_can_receive_station?(faction, token)
          # Faction must be founded
          return false unless faction.floated?

          # Faction must have available markers (check via market position)
          tokens_total = faction.tokens.size - 1  # 8 additional tokens (excluding base)
          tokens_used = faction.share_price&.coordinates&.[](1) || 0
          return false unless tokens_total - tokens_used > 0

          # Faction can't have base in same city already
          hex = token.hex
          return false unless hex

          city = hex.tile.cities.first
          return false unless city
          return false if city.tokens.any? { |t| t&.corporation == faction }

          true
        end

        private

        # Use constraint propagation to determine if assignment is deterministic
        # Returns nil if ambiguous (player choice needed), or assignment hash if deterministic
        def compute_deterministic_assignment(stations, opposing)
          return {} if stations.empty? || opposing.empty?

          # Build eligibility map: station -> list of factions that can receive it
          eligibility = {}
          stations.each do |token|
            eligible_factions = opposing.select { |f| faction_can_receive_station?(f, token) }
            eligibility[token] = eligible_factions
          end

          # Filter to stations that have at least 1 eligible faction
          eligibility.reject! { |_token, factions| factions.empty? }
          return {} if eligibility.empty?

          # Special case: if there's only 1 station with multiple eligible factions, player must choose
          if eligibility.size == 1
            token, factions = eligibility.first
            return nil if factions.size > 1 # Ambiguous - player chooses which faction gets this station
          end

          # Constraint propagation: repeatedly assign where only 1 option exists
          assignment = {}
          assigned_factions = []

          changed = true
          while changed
            changed = false

            # Check stations with exactly 1 eligible faction
            eligibility.each do |token, factions|
              next if assignment.key?(token)

              remaining = factions - assigned_factions
              if remaining.size == 1
                faction = remaining.first
                assignment[token] = faction
                assigned_factions << faction
                changed = true
              elsif remaining.empty?
                # No faction can receive this station - skip it
                assignment[token] = nil
                changed = true
              end
            end

            # Check factions that can only go to 1 station
            # BUT only if that station doesn't have other unassigned factions competing for it
            (opposing - assigned_factions).each do |faction|
              possible_stations = eligibility.keys.reject { |t| assignment.key?(t) }.select do |token|
                eligibility[token].include?(faction)
              end

              next unless possible_stations.size == 1

              token = possible_stations.first
              # Check if other factions also need this same station
              other_factions_needing_this = (opposing - assigned_factions - [faction]).select do |other|
                other_possible = eligibility.keys.reject { |t| assignment.key?(t) }.select do |t|
                  eligibility[t].include?(other)
                end
                other_possible == [token] # Other faction ALSO only has this station
              end

              # Only auto-assign if no other faction is competing for this exact station
              if other_factions_needing_this.empty?
                assignment[token] = faction
                assigned_factions << faction
                changed = true
              end
            end
          end

          # Check if all eligible stations are assigned
          unassigned = eligibility.keys.reject { |t| assignment.key?(t) }
          return nil unless unassigned.empty? # Still ambiguous, need player choice

          assignment
        end

        def needs_station_choice?(corporation, stations, opposing)
          return false if stations.empty?
          return false if opposing.empty?

          # Build eligibility map to check if any station can be replaced
          eligibility = {}
          stations.each do |token|
            eligible_factions = opposing.select { |f| faction_can_receive_station?(f, token) }
            eligibility[token] = eligible_factions unless eligible_factions.empty?
          end

          # If no station can be replaced, no choice needed
          return false if eligibility.empty?

          # Always require player confirmation for station replacement
          # This gives visibility to the player about what will happen
          # and allows them to reconsider before confirming the intervention consequences
          true
        end

        def auto_assign_stations(corporation, stations, opposing)
          assignment = compute_deterministic_assignment(stations, opposing)
          return unless assignment

          assignment.each do |token, faction|
            next unless faction # Skip stations with no eligible faction

            place_intervention_base(corporation, token, faction)
          end
        end

        def place_intervention_base(corporation, corp_token, faction)
          hex = corp_token.hex
          city = corp_token.city

          # Permanently remove corporation token from the game
          corp_token.destroy!

          # Place faction base
          faction_token = faction.tokens.find { |t| !t.used }
          if faction_token
            city.place_token(faction, faction_token, check_tokenable: false)
            # Increment faction's market position to track token usage
            # (same as when giving a favor - move_right increments the column counter)
            @stock_market.move_right(faction)
            faction.par_price = faction.share_price
            @log << "#{faction.name} places base on #{hex.name} (replacing #{corporation.name})"
          end
        end

        public

        NL_HEX = 'D7'
        NORTH_HEXES = %w[A2 B1].freeze
        SOUTH_HEXES = %w[D15].freeze
        EAST_HEXES = %w[M2 O14].freeze

        def revenue_for(route, stops)
          revenue = super

          hexes = stops.map { |s| s.hex.id }
          has_nl = hexes.include?(NL_HEX)

          # Bonus: N + NL + S = +£50
          if has_nl && (hexes & NORTH_HEXES).any? && (hexes & SOUTH_HEXES).any?
            revenue += 50
          end

          # Bonus: NL + L (East) = +£70 per L hex
          if has_nl
            l_count = (hexes & EAST_HEXES).size
            revenue += 70 * l_count
          end

          revenue
        end

        def revenue_str(route)
          str = super

          hexes = route.stops.map { |s| s.hex.id }
          has_nl = hexes.include?(NL_HEX)

          str += ' + S-NL-N(+50)' if has_nl && (hexes & NORTH_HEXES).any? && (hexes & SOUTH_HEXES).any?
          l_count = (hexes & EAST_HEXES).size
          str += " + NL-L(+#{70 * l_count})" if has_nl && l_count.positive?

          str
        end

        def must_buy_train?(entity)
          return false if entity.type == :faction

          super
        end

        # Frost 1831: trains discarded due to phase limit are removed from the game,
        # not sent to the bank pool.
        def discard_train(train)
          train.owner&.trains&.delete(train)
          train.owner = nil
          train.rusted = true
          trains.delete(train)
          @crowded_corps = nil
          @log << "#{train.name} is removed from the game (phase limit)"
        end

        def check_other(route)
          # Use ordered_hexes which collapses consecutive duplicates (same hex visited
          # by adjacent paths). A hex appearing more than once non-consecutively means
          # the route re-enters that hex from a different direction — not allowed.
          hexes = route.ordered_hexes
          raise GameError, 'Route cannot re-enter a hex' if hexes.size != hexes.uniq.size
        end

        # Factions don't participate in end-of-SR share price movements
        def sold_out_increase?(corporation)
          return false if corporation.type == :faction

          super
        end

        # Faction shares return to IPO (Parliament), not to the market pool
        def sold_shares_destination(corporation)
          return :corporation if corporation.type == :faction

          super
        end

        # Factions don't participate in pool-share price drops either
        def num_market_shares(corporation)
          return 0 if corporation.type == :faction

          corporation.num_market_shares
        end

        # Factions have a dynamic share price based on the value ruler (market row)
        def faction_share_price(faction)
          faction.share_price&.price || 70
        end

        def extra_game_tabs
          [{ title: 'P|arliament', anchor: 'parliament', klass: View::Game::GFrost1831::Parliament, key: 'p' }]
        end

        # Round views for Frost: the operating and stock rounds add the influence
        # chooser, the faction cost table and the intervention map; favor and voting
        # are Frost-only rounds with no generic equivalent.
        def round_view_class(key)
          case key
          when :operating then View::Game::GFrost1831::Round::Operating
          when :stock then View::Game::GFrost1831::Round::Stock
          when :favor then View::Game::GFrost1831::Round::Favor
          when :voting then View::Game::GFrost1831::Round::Voting
          end
        end

        def ipo_name(entity = nil)
          return 'Parliament' if entity&.type == :faction

          'IPO'
        end

        def event_parliament_opens!
          @log << "-- Event: New London's Parliament opens! --"
          @log << 'Factions now available for purchase in the next Stock Round.'
          @parliament_open = true

          # Par factions on the dedicated faction row in the market
          faction_start_price = stock_market.market[FACTION_ROW].find { |p| p&.price == 70 }
          @corporations.select { |c| c.type == :faction }.each do |faction|
            faction.ipoed = true
            faction.par_price = faction_start_price
            faction.share_price = faction_start_price
            faction_start_price.corporations << faction
          end

          # Give each regular corporation a "Favor" ability (appears in Abilities during OR)
          @corporations.select { |c| c.type != :faction && c.floated? }.each do |corp|
            grant_favor_ability(corp)
          end
        end

        # Create a single global "Favor" company that enables the favor ability for all corps
        def grant_favor_ability(_corporation)
          return if @favor_company

          @favor_company = Engine::Company.new(
            sym: 'FAV',
            name: 'Favor',
            value: 0,
            revenue: 0,
            desc: 'Request Faction Favor: receive £100, lose market value.',
            color: nil,
            abilities: [
              {
                type: 'choose_ability',
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
                choices: %w[request_favor],
              },
              { type: 'no_buy' },
              { type: 'close', on_phase: 'never' },
            ],
          )
          # Assign to no one initially — will be assigned during OR
          @companies << @favor_company
          update_cache(:companies)
        end

        # Create favor company at start of corporation's turn, remove at end
        attr_reader :favor_company

        # Create hidden INF company for Use Influence ability
        def create_influence_company
          return if @influence_company

          @influence_company = Engine::Company.new(
            sym: 'INF',
            name: 'Use Influence',
            value: 0,
            revenue: 0,
            desc: 'Allocates 1 Influence to a Corporation or Faction where the player is President.',
            color: nil,
            abilities: [
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'any',
                choices: %w[allocate_influence],
              },
              { type: 'no_buy' },
              { type: 'close', on_phase: 'never' },
            ],
          )
          @companies << @influence_company
          update_cache(:companies)
        end

        attr_reader :influence_company

        def assign_favor_to_current_operator(entity)
          return unless @favor_company
          return if entity.type == :faction
          return unless can_request_favor?(entity)

          # Resurrect FAV if it was accidentally closed (e.g., corporation closed with FAV assigned)
          @favor_company.instance_variable_set(:@closed, false) if @favor_company.closed?

          @favor_company.owner = entity
          entity.companies << @favor_company unless entity.companies.include?(@favor_company)
        end

        # Called at end of each corp's OR turn
        def remove_favor_from_operator(entity)
          return unless @favor_company
          return unless entity
          return if entity.type == :faction

          entity.companies&.delete(@favor_company)
          @favor_company.owner = nil
        end

        def event_turmoil!
          @log << '-- Event: Turmoil! --'

          # If D train influence is pending, defer turmoil until influence is allocated
          # (per manual 10.4.5.4: influence placement occurs before events)
          if @d_train_influence_pending
            @log << 'D train influence must be allocated before Turmoil consequences.'
            @deferred_turmoil = true
            return
          end

          # Check if any player has influence they can use
          players_with_influence = @players.select { |p| player_influence(p).positive? }

          if players_with_influence.any?
            @log << 'Players with Influence may allocate before consequences are calculated.'
            @pre_turmoil_window = {
              players_remaining: players_with_influence.dup,
            }
            return
          end

          # No players with influence, execute turmoil immediately
          execute_turmoil_consequences!
        end

        def execute_deferred_turmoil!
          return unless @deferred_turmoil

          @deferred_turmoil = nil
          @d_train_influence_pending = nil

          # Check if any player has influence they can use
          players_with_influence = @players.select { |p| player_influence(p).positive? }

          if players_with_influence.any?
            @log << 'Players with Influence may allocate before consequences are calculated.'
            @pre_turmoil_window = {
              players_remaining: players_with_influence.dup,
            }
            return
          end

          # No players with influence, execute turmoil immediately
          execute_turmoil_consequences!
        end

        def execute_pending_turmoil!
          @pre_turmoil_window = nil
          execute_turmoil_consequences!

          # If this was final turmoil during end_game, continue with end game
          if @end_game_reason && !@finished
            @end_game_turmoil_done = true
            continue_end_game!
          end
        end

        def execute_turmoil_consequences!
          gov_sym = governing_faction_sym
          unless gov_sym
            @log << 'Government is neutral — no consequences.'
            return
          end

          # Protected Factions mode removed - all factions participate regardless of opened status

          opp_sym = OPPOSITES[gov_sym]
          level = ParliamentMovement.polarization_level(*@government_marker)

          @log << "Government: #{faction_display_name(gov_sym)} (Level #{level})"
          @log << "Opposition: #{faction_display_name(opp_sym)}"

          gov_supporter = principal_supporter(gov_sym)
          opp_supporter = principal_supporter(opp_sym)

          # === GOVERNMENT consequences ===
          # Level 1: Principal Supporter +1→ on market
          if level >= 1 && gov_supporter
            @log << "#{gov_supporter.name} (Government supporter) gains market value"
            old = gov_supporter.share_price
            @stock_market.move_right(gov_supporter)
            log_share_price(gov_supporter, old)
          end

          # Level 2: Faction +1 influence + Supporter +1 influence (governing slot)
          if level >= 2
            limit = faction_influence_limit
            if @faction_influence[gov_sym] < limit
              @faction_influence[gov_sym] += 1
              @log << "#{faction_display_name(gov_sym)} gains 1 Influence in Parliament"
            else
              @log << "#{faction_display_name(gov_sym)} at Parliament limit — Influence not gained"
            end

            if gov_supporter
              corp_limit = corporation_influence_limit
              current = @corporation_influence[gov_supporter.id]&.dig(gov_sym) || 0
              if current < corp_limit
                @corporation_influence[gov_supporter.id] ||= {}
                @corporation_influence[gov_supporter.id][gov_sym] ||= 0
                @corporation_influence[gov_supporter.id][gov_sym] += 1
                @log << "#{gov_supporter.name} gains 1 Influence (#{faction_display_name(gov_sym)})"
              else
                @log << "#{gov_supporter.name} at corp card limit for #{faction_display_name(gov_sym)} — Influence not gained"
              end
            end
          end

          # Level 3: Supporter receives Favor from Governing Faction (no market penalty)
          if level >= 3 && gov_supporter
            gov_faction = @corporations.find { |c| c.id == gov_sym }
            if gov_faction && gov_faction.cash >= 100
              gov_faction.spend(100, gov_supporter)
              @log << "#{gov_supporter.name} receives Favor (#{format_currency(100)}) from #{gov_faction.name} (no market penalty)"
              # Track favor received by corporation (counts toward 5/5 limit)
              @favors_used[gov_supporter.id] += 1
              # Move faction value up (if it has markers to move)
              # In turmoil, favor is given even without markers, but faction value still moves
              # only if there are markers (normal behavior of move_right)
              old_faction_price = gov_faction.share_price
              @stock_market.move_right(gov_faction)
              if gov_faction.share_price != old_faction_price
                @log << "#{gov_faction.name}'s value increases to #{format_currency(gov_faction.share_price.price)}"
              end
            else
              @log << "#{faction_display_name(gov_sym)} cannot grant Favor (insufficient treasury)"
            end
          end

          # === OPPOSITION consequences ===
          # Level 1: Principal Supporter -1← on market
          if level >= 1 && opp_supporter
            @log << "#{opp_supporter.name} (Opposition supporter) loses market value"
            old = opp_supporter.share_price
            @stock_market.move_left(opp_supporter)
            log_share_price(opp_supporter, old)
          end

          # Level 2: Faction -1 influence + Supporter -1 influence (opposition slot)
          if level >= 2
            if @faction_influence[opp_sym] > 0
              @faction_influence[opp_sym] -= 1
              @log << "#{faction_display_name(opp_sym)} loses 1 Influence from Parliament"
            else
              @log << "#{faction_display_name(opp_sym)} has no Influence in Parliament — no loss"
            end

            if opp_supporter
              current = @corporation_influence[opp_supporter.id]&.dig(opp_sym) || 0
              if current.positive?
                @corporation_influence[opp_supporter.id][opp_sym] -= 1
                @log << "#{opp_supporter.name} loses 1 Influence (#{faction_display_name(opp_sym)})"
              else
                @log << "#{opp_supporter.name} has no Influence for #{faction_display_name(opp_sym)} — no loss"
              end
            end
          end

          # Level 3: Supporter loses 1 station → replaced by Governing Faction base
          if level >= 3 && opp_supporter
            turmoil_station_loss(opp_supporter, gov_sym)
          end
        end

        # Turmoil level 3 opposition: station loss
        def turmoil_station_loss(corporation, gov_faction_sym)
          gov_faction = @corporations.find { |c| c.id == gov_faction_sym }

          # Must have 2+ stations
          stations = corporation.tokens.select(&:used)
          if stations.size < 2
            @log << "#{corporation.name} has only #{stations.size} station(s) — no loss"
            return
          end

          # Governing faction must have available markers (check via market position)
          tokens_total = gov_faction.tokens.size - 1
          tokens_used = gov_faction.share_price&.coordinates&.[](1) || 0
          unless gov_faction && (tokens_total - tokens_used) > 0
            @log << "#{faction_display_name(gov_faction_sym)} has no available markers — no station loss"
            return
          end

          # Filter to stations where governing faction doesn't already have a base
          eligible = stations.select do |token|
            # Use the token's actual city, not the hex's first city. Hexes with
            # multiple cities would otherwise resolve to the wrong city.
            city = token.city
            next false unless city
            next false if city.tokens.any? { |t| t&.corporation == gov_faction }

            true
          end

          if eligible.empty?
            @log << "#{faction_display_name(gov_faction_sym)} already has bases in all #{corporation.name}'s cities — no loss"
            return
          end

          if eligible.size == 1
            # Auto-resolve
            place_turmoil_base(corporation, eligible.first, gov_faction)
          else
            # Need player input — queue pending turmoil choice
            @pending_turmoil = {
              corporation: corporation,
              gov_faction: gov_faction,
              eligible_stations: eligible,
            }
          end
        end

        def place_turmoil_base(corporation, corp_token, faction)
          hex = corp_token.hex
          # Capture the exact city the corp token occupies before destroying it.
          # On multi-city hexes this must not fall back to the hex's first city.
          city = corp_token.city

          # Permanently remove corporation token from the game
          corp_token.destroy!

          # Place faction base — skip the base token (index 0), use additional markers
          faction_token = faction.tokens[1..].find { |t| !t.used }
          if faction_token && city
            city.place_token(faction, faction_token, check_tokenable: false)
            # Faction value increases when a marker is placed (removed from parliament pool)
            @stock_market.move_right(faction)
            faction.par_price = faction.share_price
            @log << "#{faction.name} replaces #{corporation.name}'s station on #{hex.name} (Turmoil)"
            @log << "#{faction.name}'s value increases to #{format_currency(faction.share_price.price)}"
          end
        end

        attr_reader :pending_turmoil, :faction_certificates, :pre_turmoil_window

        def clear_pending_turmoil!
          @pending_turmoil = nil
        end

        # Tiles that survive a blizzard: green and above. White (unbuilt) and
        # yellow tiles inside the blizzard zone lose their stations.
        BLIZZARD_SURVIVING_COLORS = %i[green brown gray].freeze

        def event_blizzard!
          @log << '-- Event: Blizzard! --'

          affected_hexes = @hexes.select { |hex| hex.tile.icons.any? { |i| i.name == 'blizzard' } }

          removed_tiles = []
          destroyed_tokens = []

          affected_hexes.each do |hex|
            tile = hex.tile

            # Inside the blizzard zone a station only survives if it sits on a
            # green (or higher) tile. Tokens on unbuilt (white) or yellow tiles
            # are destroyed. At the first 5-train no brown/gray tiles exist yet,
            # so in practice this means white and yellow are wiped.
            next if BLIZZARD_SURVIVING_COLORS.include?(tile.color)

            # Collect tokens to destroy before any downgrade removes them.
            tokens_to_destroy = []
            tile.cities.each do |city|
              city.tokens.each do |token|
                next unless token

                tokens_to_destroy << token
                destroyed_tokens << "#{token.corporation.name} (#{hex.name})"
              end
            end

            # Only yellow tiles have track to remove; white/base tiles stay as
            # they are (there is no built tile to downgrade).
            if tile.color == :yellow
              removed_tiles << hex.name
              hex.lay_downgrade(hex.original_tile)

              # Return the yellow tile to stock
              @tiles << tile

              # Remove influence cubes from restored tile if already collected
              if @influence_cubes_collected.include?(hex.id)
                hex.tile.icons.reject! { |icon| icon.name == 'influence_cube' }
              end
            end

            # Permanently remove tokens from the game
            tokens_to_destroy.each(&:destroy!)
          end

          # Remove blizzard icons from all affected hexes
          affected_hexes.each do |hex|
            hex.tile.icons.reject! { |i| i.name == 'blizzard' }
          end

          @log << "Tiles removed: #{removed_tiles.join(', ')}" if removed_tiles.any?
          @log << "Stations/bases destroyed: #{destroyed_tokens.join(', ')}" if destroyed_tokens.any?

          # Check if any corporation lost ALL stations → close it.
          # Corps start with 3 tokens. If tokens.size < 3 and none are used,
          # it means the corp had placed tokens that were destroyed.
          eliminated = @corporations.select do |c|
            next false if c.type == :faction || c.closed? || !c.floated?
            next false if c.tokens.any?(&:used)

            c.tokens.size < 3
          end

          # Resolve the eliminations atomically. close_corporation calls
          # force_next_entity! for the currently-operating corp, which would
          # advance the operating turn (logging "X operates ...") in the middle
          # of the Blizzard. Close the active corporation LAST so the whole
          # Blizzard (token loss, train removal, other closures) resolves before
          # the turn moves on.
          active = @round&.respond_to?(:current_entity) ? @round.current_entity : nil
          inactive, still_active = eliminated.partition { |c| c != active }

          inactive.each do |corp|
            @log << "#{corp.name} has no remaining stations — corporation is eliminated!"
            close_corporation(corp, quiet: true)
            on_corporation_eliminated(corp)
          end

          # The currently-operating corp cannot be closed inline: close_corporation
          # calls force_next_entity! for the active corp, which would advance the
          # operating turn (logging "X operates ...") before the remaining train
          # events (e.g. close_companies) have run. Run its elimination side effect
          # now (train removal) but defer the actual close/turn-advance until all
          # train events finish (see flush_pending_eliminations!).
          still_active.each do |corp|
            @log << "#{corp.name} has no remaining stations — corporation is eliminated!"
            on_corporation_eliminated(corp)
            @pending_eliminations << corp
          end
        end

        # Close any corporations whose elimination was deferred because they were
        # the operating entity. Called after all train events have run so the
        # turn only advances once the whole 5-train resolution is complete.
        def flush_pending_eliminations!
          return if @pending_eliminations.empty?

          @pending_eliminations.each { |corp| close_corporation(corp, quiet: true) }
          @pending_eliminations = []
        end

        def parliament_open?
          @parliament_open || false
        end

        def parliamentary_intervention?
          @optional_rules&.include?(:parliamentary_intervention)
        end

        def tight_government?
          @optional_rules&.include?(:tight_government)
        end

        def extra_train?
          @optional_rules&.include?(:extra_train)
        end

        # Legacy flag: games created before the endgame change still end on the
        # first D train purchase. New games are never given this flag, so they
        # end only when the bank breaks.
        def d_train_endgame?
          @optional_rules&.include?(:d_train_endgame)
        end

        # Legacy flag: games created before this change auto-pick the 2nd
        # supported faction when only one option is left. New games always
        # require the player to make the 2nd choice manually.
        def auto_second_faction?
          @optional_rules&.include?(:auto_second_faction)
        end

        # === Faction Support Cards & Influence Cubes ===

        OPPOSITES = {
          'TEC' => 'GUA',
          'GUA' => 'TEC',
          'EXP' => 'LOR',
          'LOR' => 'EXP',
        }.freeze

        FACTION_SYMS = %w[TEC GUA EXP LOR].freeze

        FACTION_RESERVED_CITIES = %w[F3 G8 K14 M8].freeze

        def setup
          super

          @no_blocking_graph = Graph.new(self, no_blocking: true)

          # 2 cards per faction per set; new set released after 4 corps float
          @faction_support_pool = FACTION_SYMS.flat_map { |f| [f, f] }
          @faction_support_reserve = FACTION_SYMS.flat_map { |f| [f, f] }
          @corporations_floated_count = 0

          @corporation_influence = {}
          @faction_influence = Hash.new(0)
          @corporation_factions = {}
          @pending_faction_choices = []
          @player_influence = Hash.new(0)
          @pending_influence_choice = nil
          @pending_influence_queue = []
          @influence_cubes_collected = []

          @government_marker = [3, 4] # Center (neutral)

          @parliament_open = false
          @d_train_bought = false

          @pending_intervention = nil
          @intervention_data = nil
          @pre_turmoil_window = nil
          @end_game_turmoil_done = false
          @end_game_reason = nil
          @deferred_turmoil = nil
          @d_train_influence_pending = nil
          
          @player_intervention_cards = Hash.new(0)
          @faction_certificates = Hash.new { |h, k| h[k] = [] }

          @favors_used = Hash.new(0)
          @favor_used_this_or = Hash.new(0)
          @corporations_eliminated_count = 0
          @pending_eliminations = []

          # Create hidden INF company (Use Influence) — not in auction
          create_influence_company

          # Regulations start at Normal (1) or Tight (2) if variant active
          starting_position = tight_government? ? 2 : 1
          @regulations = {
            'R1' => { name: 'Track Laying', position: starting_position },
            'R2' => { name: 'Track Upgrade', position: starting_position },
            'R3' => { name: 'Corporation Limit', position: starting_position },
            'R4' => { name: 'Favor', position: starting_position },
          }

          # Apply R3 limits immediately if starting at Tight
          apply_r3_limits if tight_government?

          @voting_phase = nil
          @voting_rounds_remaining = 0
          @voting_proposer_index = 0
          @current_voting_regulation_id = nil
          @chosen_priority_faction = nil # Set by priority player when government is neutral (for VR)
          @pending_priority_faction_choice = false
          @priority_faction_chooser = nil
          # Separate OR priority choice (reset each OR)
          @chosen_or_priority_faction = nil
          @pending_or_priority_choice = false
          @or_priority_chooser = nil

          # Give each faction its £500 treasury (per setup rules)
          # Also set unplaced tokens to show "5◆" via hex stub
          @corporations.select { |c| c.type == :faction }.each do |faction|
            @bank.spend(500, faction)
            faction.tokens[1..].each do |token|
              next if token.used

              token.hex = FACTION_TOKEN_HEX
            end
          end
        end

        attr_reader :pending_faction_choices

        attr_reader :government_marker

        attr_reader :pending_influence_choice

        def after_lay_tile(hex, tile, entity)
          # Check if hex has NL route icon — grants influence cube only if
          # the placed tile actually connects the future path (route A to B)
          return unless hex.tile.icons.any? { |icon| icon.name == 'influence_cube' }

          future_edges = influence_cube_edges(hex.id)
          return unless future_edges

          edge_a, edge_b = future_edges
          connected = edges_connected?(tile, edge_a, edge_b)
          return unless connected

          hex.tile.icons.reject! { |icon| icon.name == 'influence_cube' }
          @influence_cubes_collected << hex.id

          corporation = entity.corporation? ? entity : entity.owner
          return unless corporation&.corporation?

          # Factions: cube goes directly to Parliament
          if corporation.type == :faction
            limit = faction_influence_limit
            if @faction_influence[corporation.id] < limit
              @faction_influence[corporation.id] += 1
              @log << "#{corporation.name} gains 1 Influence in Parliament from NL route (#{hex.name})"
              move_government(corporation.id)
            else
              @log << "#{corporation.name} at Parliament limit — Influence from NL route not gained"
            end
            return
          end

          factions = corporation_factions(corporation)
          return if factions.empty?

          @log << "#{corporation.name} collects Influence from NL route (#{hex.name})"

          available = factions.select { |f| within_influence_limit?(corporation, f) }
          if available.empty?
            @log << "#{corporation.name} cannot receive influence (both factions at limit — cube discarded)"
            return
          end

          queue_influence_choice(corporation, available, reason: "NL route (#{hex.name})")
        end

        # NL route future path edges per hex (extracted from map definition)
        # 34 hexes total with influence_cube icon
        NL_ROUTE_EDGES = {
          'A4' => [0, 3], 'A6' => [5, 3], 'B7' => [2, 4],
          'C6' => [1, 5], 'C8' => [0, 5], 'C10' => [0, 3],
          'C12' => [3, 5], 'D9' => [2, 3], 'D13' => [0, 2],
          'E2' => [0, 4], 'E4' => [0, 3], 'E6' => [1, 3],
          'F1' => [1, 5], 'F7' => [0, 4], 'F9' => [0, 3],
          'F11' => [3, 5], 'G6' => [1, 5], 'G12' => [2, 5],
          'H7' => [2, 4], 'H13' => [2, 5], 'I4' => [0, 2],
          'I14' => [2, 4], 'J5' => [1, 5], 'J13' => [1, 4],
          'K6' => [2, 4], 'K12' => [1, 5], 'L3' => [4, 5],
          'L5' => [1, 5], 'L13' => [0, 2], 'M4' => [2, 5],
          'M14' => [1, 4], 'N5' => [0, 2], 'N7' => [2, 3],
          'N13' => [1, 5],
        }.freeze

        def influence_cube_edges(hex_id)
          NL_ROUTE_EDGES[hex_id]
        end

        # Check if two edges are connected through the tile's path/node network
        def edges_connected?(tile, edge_a, edge_b)
          # For simple tiles (single path with both edges): direct check
          tile.paths.each do |path|
            return true if path.exits.include?(edge_a) && path.exits.include?(edge_b)
          end

          # For tiles with nodes (towns/cities): check if both edges reach the same node
          tile.nodes.each do |node|
            node_edges = node.paths.flat_map(&:exits)
            return true if node_edges.include?(edge_a) && node_edges.include?(edge_b)
          end

          false
        end

        def resolve_influence_choice(faction_sym)
          return unless @pending_influence_choice

          corporation = @pending_influence_choice[:corporation]
          was_d_train = @pending_influence_choice[:reason] == 'D train purchase'
          apply_faction_influence(corporation, faction_sym)

          # Remove processed item from queue and set next one
          @pending_influence_queue ||= []
          @pending_influence_queue.shift
          @pending_influence_choice = @pending_influence_queue.first

          # If this was D train influence, execute deferred turmoil
          execute_deferred_turmoil! if was_d_train && @deferred_turmoil
        end

        def move_government(faction_sym)
          row, col = @government_marker
          result = ParliamentMovement.move(row, col, faction_sym)

          if result.nil?
            @log << "Government marker cannot move from (#{row},#{col}) toward #{faction_display_name(faction_sym)}"
            return
          end

          new_row, new_col = result
          if new_row == row && new_col == col
            @log << "Government marker already at maximum for #{faction_display_name(faction_sym)}"
            return
          end

          @government_marker = [new_row, new_col]
          @log << "Government marker moves toward #{faction_display_name(faction_sym)}"

          # Clear priority faction choice if government is no longer neutral
          clear_priority_faction_choice! unless government_neutral?
        end

        def float_corporation(corporation)
          super

          # Sync ownership limit for the corp's initial market position
          update_ownership_limit_for(corporation)

          president = corporation.owner

          # Always queue faction choice for the president
          # First choice is NEVER automatic (order matters for government marker movement)
          # Second choice can be auto-selected if only one option remains
          @pending_faction_choices << {
            corporation: corporation,
            entity: president,
            step: :first,
            first_choice: nil,
          }
        end

        def after_buy_company(player, company, price)
          # Don't call super during auction (it needs companies_pending_par from Stock Round)
          # Handle abilities manually during auction
          if @round.is_a?(Engine::Round::Auction)
            # P5 (Old Guard): grants 1 share of OE
            if company.sym == 'POG'
              abilities(company, :shares) do |ability|
                ability.shares.each do |share|
                  share_pool.buy_shares(player, share, exchange: :free) unless share.president
                end
              end
            end
          else
            super
          end

          # P3 (Convoy): grants 1 influence cube to the player + hidden INF company
          if company.sym == 'PCO'
            @player_influence[player.id] += 1
            @log << "#{player.name} receives 1 Influence from #{company.name}"

            # Give the hidden INF company to the player
            if @influence_company && !@influence_company.closed?
              @influence_company.owner = player
              player.companies << @influence_company unless player.companies.include?(@influence_company)
            end
          end
        end

        def player_influence(player)
          @player_influence[player.id] || 0
        end

        def player_influence_spend(player)
          @player_influence[player.id] -= 1
        end

        def add_corporation_influence(corporation, faction_sym)
          @corporation_influence[corporation.id] ||= {}
          @corporation_influence[corporation.id][faction_sym] ||= 0
          @corporation_influence[corporation.id][faction_sym] += 1
        end

        def player_card_rows(player)
          cubes = player_influence(player)
          return nil unless cubes.positive?

          ['Influence', cubes.to_s]
        end

        def faction_support_available
          @faction_support_pool.uniq
        end

        def faction_support_remaining(faction_sym)
          @faction_support_pool.count(faction_sym)
        end

        def faction_support_available_for_second(first_choice)
          opposite = OPPOSITES[first_choice]
          remaining = @faction_support_pool.reject { |f| f == first_choice }
          remaining.reject { |f| f == opposite }.uniq
        end

        def consume_faction_support(faction_sym)
          idx = @faction_support_pool.index(faction_sym)
          @faction_support_pool.delete_at(idx) if idx
        end

        def on_corporation_floated(corporation, factions)
          # Record which factions this corp supports (cubes already applied per-choice)
          @corporation_factions[corporation.id] = factions

          @corporations_floated_count += 1

          # After 4 corps float, release new set of cards
          if @corporations_floated_count == 4
            @faction_support_pool = @faction_support_reserve.dup
          end

          @log << "#{corporation.name} now supports #{factions.map { |f| faction_display_name(f) }.join(' and ')}"
        end

        def apply_faction_influence(corporation, faction_sym)
          @corporation_factions[corporation.id] ||= []
          @corporation_factions[corporation.id] << faction_sym unless @corporation_factions[corporation.id].include?(faction_sym)

          @corporation_influence[corporation.id] ||= {}
          @corporation_influence[corporation.id][faction_sym] ||= 0

          corp_limit = corporation_influence_limit
          current_on_corp = @corporation_influence[corporation.id][faction_sym]
          if current_on_corp >= corp_limit
            @log << "#{corporation.name} has reached the limit of #{corp_limit} Influence for #{faction_display_name(faction_sym)} (cube discarded)"
            return
          end

          @corporation_influence[corporation.id][faction_sym] += 1

          faction_influence_gain(faction_sym)
          move_government(faction_sym)
        end

        def corporation_factions(corporation)
          @corporation_factions[corporation.id] || []
        end

        def corporation_influence(corporation)
          @corporation_influence[corporation.id] || {}
        end

        # Returns the corporation (non-faction) that is the principal supporter of a faction.
        # Principal supporter = most influence cubes allocated to that faction.
        # Tiebreak: highest market value.
        def principal_supporter(faction_sym)
          # Only corps that support this faction are candidates
          corps = @corporations.select do |c|
            c.type != :faction && !c.closed? && c.floated? &&
              (@corporation_factions[c.id] || []).include?(faction_sym)
          end
          return nil if corps.empty?

          # Sort by operating order for tiebreak
          corps.sort_by! { |c| operating_order.index(c) || 999 }

          # Corp with most influence for this faction; first in operating order wins ties
          corps.max_by do |c|
            cubes = @corporation_influence[c.id]&.dig(faction_sym) || 0
            order_priority = corps.size - (corps.index(c) || 0)
            [cubes, order_priority]
          end
        end

        def faction_influence(faction_sym)
          @faction_influence[faction_sym] || 0
        end

        def corporation_influence_for(corporation, faction_sym)
          @corporation_influence[corporation.id]&.dig(faction_sym) || 0
        end

        def faction_influence_gain(faction_sym)
          limit = faction_influence_limit
          if @faction_influence[faction_sym] >= limit
            @log << "#{faction_display_name(faction_sym)} has reached the limit of #{limit} Influence in Parliament (Influence discarted)"
            return
          end
          @faction_influence[faction_sym] += 1
        end

        def faction_influence_lose(faction_sym)
          @faction_influence[faction_sym] = [@faction_influence[faction_sym] - 1, 0].max
        end

        def available_faction_cities(faction = nil)
          # Without faction arg: return reserved cities for initial base placement (founding)
          unless faction
            return FACTION_RESERVED_CITIES.select do |hex_id|
              hex = hex_by_id(hex_id)
              city = hex.tile.cities.first
              city && city.tokens.none? { |t| t&.corporation&.type == :faction }
            end
          end

          # With faction arg: additional bases during OR
          # Any city connected to existing bases with available slots
          # Excluded: NL, GJ, cities where this faction already has a base
          excluded_hexes = %w[D7 M6] # NL and GJ hex IDs
          existing_bases = faction.tokens.select(&:used).map(&:hex)

          return [] if existing_bases.empty?

          eligible = []
          @hexes.each do |hex|
            next if excluded_hexes.include?(hex.id)

            cities = hex.tile.cities
            next if cities.empty?
            next unless cities.any? { |c| c.available_slots.positive? }

            # Faction can't have more than 1 base in the same hex — check ALL
            # cities on the hex, not just the first (multi-city OO/NL tiles).
            next if cities.any? { |c| c.tokens.any? { |t| t&.corporation == faction } }

            # Must be connected to one of the faction's existing bases
            next unless connected_to_faction_base?(faction, hex, existing_bases)

            eligible << hex.id
          end

          eligible
        end

        def connected_to_faction_base?(faction, target_hex, existing_bases)
          # Check if target_hex is reachable from any of the faction's bases via track
          existing_bases.any? do |base_hex|
            reachable_hexes(base_hex, faction).include?(target_hex)
          end
        end

        def reachable_hexes(start_hex, entity)
          # BFS from start_hex following connected track
          visited = []
          queue = [start_hex]

          while (current = queue.shift)
            next if visited.include?(current)

            visited << current

            # Find all hexes connected via paths from current hex
            current.tile.paths.each do |path|
              path.exits.each do |edge|
                neighbor = current.neighbors[edge]
                next unless neighbor
                next if visited.include?(neighbor)

                # Check if the neighbor connects back (has a path entry from this edge)
                opposite_edge = (edge + 3) % 6
                connected = neighbor.tile.paths.any? { |p| p.exits.include?(opposite_edge) }
                next unless connected

                # Check if passage through current city is blocked
                blocked = false
                current.tile.cities.each do |city|
                  next if city.tokens.any? { |t| t&.corporation == entity }

                  blocked = true if city.available_slots.zero? && current != start_hex
                end

                queue << neighbor unless blocked
              end
            end
          end

          visited
        end

        def place_faction_base(faction, hex_id)
          hex = hex_by_id(hex_id)
          city = hex.tile.cities.first
          token = faction.tokens.find { |t| !t.used }
          return unless token && city

          city.place_token(faction, token)
          # Remove the faction_base icon (visual marker no longer needed)
          hex.tile.icons.reject! { |icon| icon.name == 'faction_base' }
          @log << "#{faction.name} places base on #{hex_id} (#{hex.location_name})"
        end

        def faction_influence_limit
          case @phase.name
          when '2', '3' then 6
          when '4' then 6
          when '5', '6' then 8
          when 'D' then 10
          else 6
          end
        end

        # Limit of cubes per faction on a corporation's card
        def corporation_influence_limit
          case @phase.name
          when '2' then 3
          when '3', '4' then 4
          when '5', '6', 'D' then 5
          else 3
          end
        end

        # Factions have 9 tokens total (1 base + 8 additional).
        # Tokens used = market column position (each move_right consumes 1).
        # Corporations use the default logic.
        def count_available_tokens(corporation)
          if corporation.type == :faction
            tokens_total = corporation.tokens.size  # 9 total (1 base + 8)
            tokens_used = corporation.share_price&.coordinates&.[](1) || 0
            [tokens_total - tokens_used, 0].max
          else
            super
          end
        end

        def token_string(corporation)
          if corporation.type == :faction
            tokens_total = corporation.tokens.size  # 9 total
            # market column tracks bases placed via favor/intervention
            # +1 for home base if faction has floated
            market_tokens = corporation.share_price&.coordinates&.[](1) || 0
            home_base = corporation.floated? ? 1 : 0
            tokens_used = market_tokens + home_base
            tokens_available = [tokens_total - tokens_used, 0].max
            "#{tokens_available}/#{tokens_total}"
          else
            super
          end
        end

        def status_array(corporation)
          if corporation.type == :faction
            inf = faction_influence(corporation.id)
            limit = faction_influence_limit
            # Each move_right consumes 1 token from the parliament pool.
            # +1 for home base if faction has floated
            tokens_total = corporation.tokens.size  # 9 total (1 base + 8)
            market_tokens = corporation.share_price&.coordinates&.[](1) || 0
            home_base = corporation.floated? ? 1 : 0
            tokens_used = market_tokens + home_base
            tokens_available = [tokens_total - tokens_used, 0].max
            certs = @faction_certificates[corporation.id]&.size || 0
            rows = [
              ["Influence: #{inf}/#{limit}", ''],
              ["Tokens: #{tokens_available}/#{tokens_total}", ''],
            ]
            rows << ["Certificates: #{certs}", ''] if certs.positive?
            return rows
          end

          factions = corporation_factions(corporation)
          return unless factions.any?

          influence = corporation_influence(corporation)
          limit = corporation_influence_limit
          rows = factions.map do |f|
            name = faction_display_name(f)
            count = influence[f] || 0
            ["#{name}: #{count}/#{limit}", '']
          end

          # Show favors used by this corp (may exceed 5 if forced train purchase)
          used = @favors_used[corporation.id] || 0
          rows << ["Favors: #{used}/#{MAX_FAVORS_PER_GAME}", ''] if used.positive?

          rows
        end

        def faction_display_name(sym)
          case sym
          when 'TEC' then 'Technicians'
          when 'GUA' then 'Guardians'
          when 'EXP' then 'Expansionists'
          when 'LOR' then 'Lords'
          else sym
          end
        end

        FACTION_SYMS_DISPLAY = %w[TEC LOR GUA EXP].freeze

        def spreadsheet_extra_headers
          # Favors column first, then faction columns
          headers = [{ title: 'Favors', sort_key: :extra_favors }]
          headers + FACTION_SYMS_DISPLAY.map { |sym| { title: sym, sort_key: :"extra_#{sym}" } }
        end

        def spreadsheet_extra_sort_value(corporation, sort_key)
          if sort_key == :extra_favors
            # Sort by favors: factions by remaining, corps by used
            if corporation.type == :faction
              # Factions: sort by remaining favors (5 - used), desc
              5
            else
              # Corps: sort by favors used, desc
              @favors_used[corporation.id] || 0
            end
          else
            faction_sym = sort_key.to_s.sub('extra_', '')

            # Faction itself always sorts first
            return [2, 999, 0] if corporation.id == faction_sym

            op_order = operating_order.index(corporation) || 999
            supported = (@corporation_factions[corporation.id] || []).include?(faction_sym)
            influence = @corporation_influence.dig(corporation.id, faction_sym) || 0

            if supported
              # Supporters: sorted by influence desc, then game order
              [1, influence, -op_order]
            else
              # Non-supporters: last, sorted by game order
              [0, -op_order, 0]
            end
          end
        end

        def spreadsheet_extra_data(corporation)
          if corporation.type == :faction
            # For factions: Favors remaining = cash / 100 (each favor costs £100)
            favors_remaining = corporation.cash / 100
            favors_data = ["#{favors_remaining}/5"]
            # Influence columns
            parl_limit = faction_influence_limit
            faction_data = FACTION_SYMS_DISPLAY.map do |sym|
              if corporation.id == sym
                "#{@faction_influence[sym]}/#{parl_limit}"
              else
                ''
              end
            end
            favors_data + faction_data
          else
            # For corporations: Favors used (always show, even if 0)
            used = @favors_used[corporation.id] || 0
            favors_data = ["#{used}/#{MAX_FAVORS_PER_GAME}"]
            # Influence columns
            corp_limit = corporation_influence_limit
            supported = @corporation_factions[corporation.id] || []
            faction_data = FACTION_SYMS_DISPLAY.map do |sym|
              val = @corporation_influence.dig(corporation.id, sym) || 0
              (val.positive? || supported.include?(sym)) ? "#{val}/#{corp_limit}" : ''
            end
            favors_data + faction_data
          end
        end

        def phase_extra_headers
          ['◆ Corp Limit', '◆ Faction Limit']
        end

        def phase_extra_data(phase)
          corp_limit = case phase[:name]
                       when '2' then 3
                       when '3', '4' then 4
                       when '5', '6', 'D' then 5
                       else 3
                       end

          parl_limit = case phase[:name]
                       when '2', '3', '4' then 6
                       when '5', '6' then 8
                       when 'D' then 10
                       else 6
                       end

          [corp_limit.to_s, parl_limit.to_s]
        end

        # Override: when a corporation moves into the Influence Zone (row 0, pays_bonus cells),
        # it gains 1 Influence Cube and bounces back to the previous position.
        # The purple row is never a resting place for corporations.
        def sold_out_stock_movement(corporation)
          prev = corporation.share_price
          @stock_market.move_up(corporation)
          check_influence_zone(corporation, prev)
        end

        # After any share price change, check if corp landed in influence zone
        def log_share_price(entity, from, steps = nil, log_steps: false)
          # Factions never move on the stock market via normal mechanisms
          if entity.type == :faction
            return
          end

          to = entity.share_price

          # Check if corp ended up in influence zone (pays_bonus with price 0)
          # This catches dividend movements (move_right into 0B at end of row)
          if to && to != from && to.type == :pays_bonus && entity.type != :faction
            check_influence_zone(entity, from)
            # After bounce-back, entity is back at `from` — no price change to log
            return
          end

          # Check blue cell (pays_unique_bonus) — first to arrive gets cube (corp stays there)
          if to && to != from && to.types.include?(:pays_unique_bonus) && entity.type != :faction
            @claimed_influence_cells ||= []
            cell_key = to.coordinates.join(',')
            unless @claimed_influence_cells.include?(cell_key)
              @log << "#{entity.name} is first to reach #{format_currency(to.price)} — gains 1 Influence"
              grant_market_influence(entity)
              @claimed_influence_cells << cell_key
              @stock_market.consume_unique_bonus(to)
            end
          end

          # Keep ownership limit in sync when corp enters/exits no_cert_limit (K) zone
          update_ownership_limit_for(entity) if to != from

          super
        end

        # Check if corporation is in the influence zone and bounce back.
        # Influence zone = any cell with type :pays_bonus (price 0, purple).
        # This includes all of row 0 and the rightmost cell of row 1.
        def check_influence_zone(corporation, previous_price)
          current = corporation.share_price
          return unless current&.type == :pays_bonus
          return if corporation.type == :faction

          # Bounce back to previous position
          current.corporations.delete(corporation)
          corporation.share_price = previous_price
          previous_price.corporations << corporation unless previous_price.corporations.include?(corporation)

          @log << "#{corporation.name} reaches Influence Zone (sold out) — gains 1 Influence"
          @log << "#{corporation.name}'s share price returns to #{format_currency(previous_price.price)}"

          grant_market_influence(corporation)
        end

        def grant_market_influence(corporation)
          factions = corporation_factions(corporation)
          return if factions.empty?

          available = factions.select { |f| within_influence_limit?(corporation, f) }
          if available.empty?
            @log << "#{corporation.name} cannot receive influence (both factions at limit — cube discarded)"
            return
          end

          queue_influence_choice(corporation, available, reason: 'market influence zone')
        end

        # === Voting Round ===

        attr_reader :regulations, :voting_phase, :current_voting_regulation_id

        REGULATION_LABELS = { 0 => 'Loose', 1 => 'Normal', 2 => 'Tight' }.freeze

        def faction_voting_order
          # Founded factions with president, in Arena order (Government → clockwise)
          all_factions_arena_order.select { |f| f.floated? && f.owner }
        end

        def start_voting_round
          @voting_rounds_remaining = faction_voting_order.size
          @voting_proposer_index = 0
          @voting_phase = :propose
          @current_voting_regulation_id = nil
          @voting_passed_consecutive = []
          @voting_voter_index = 0

          # Log skipped factions (no president / not founded) in Arena order
          all_factions_arena_order.each do |faction|
            next if faction.floated? && faction.owner # eligible — don't skip

            if !faction.floated?
              @log << "#{faction.name} is not founded and passes"
            elsif !faction.owner
              @log << "#{faction.name} has no president and passes"
            end
          end
        end

        # All 4 factions in Arena order (Government → clockwise: TEC > LOR > GUA > EXP)
        # This is the fixed clockwise order starting from government position
        ARENA_CLOCKWISE_ORDER = %w[TEC LOR GUA EXP].freeze

        def all_factions_arena_order
          # Determine governing faction from government_marker position
          governing_sym = governing_faction_sym
          order = if governing_sym
                    # Rotate to start with governing faction
                    idx = ARENA_CLOCKWISE_ORDER.index(governing_sym) || 0
                    ARENA_CLOCKWISE_ORDER.rotate(idx)
                  elsif @chosen_priority_faction
                    # Neutral but priority player has chosen (for VR)
                    idx = ARENA_CLOCKWISE_ORDER.index(@chosen_priority_faction) || 0
                    ARENA_CLOCKWISE_ORDER.rotate(idx)
                  else
                    # Neutral and no choice yet: use default order
                    ARENA_CLOCKWISE_ORDER
                  end

          order.map { |sym| @corporations.find { |c| c.id == sym } }.compact
        end

        # Faction order specifically for Operating Round
        # Uses OR-specific choice if available, otherwise falls back to VR choice
        def factions_or_order
          governing_sym = governing_faction_sym
          order = if governing_sym
                    idx = ARENA_CLOCKWISE_ORDER.index(governing_sym) || 0
                    ARENA_CLOCKWISE_ORDER.rotate(idx)
                  elsif @chosen_or_priority_faction
                    # OR-specific choice takes precedence
                    idx = ARENA_CLOCKWISE_ORDER.index(@chosen_or_priority_faction) || 0
                    ARENA_CLOCKWISE_ORDER.rotate(idx)
                  elsif @chosen_priority_faction
                    # Fall back to VR choice
                    idx = ARENA_CLOCKWISE_ORDER.index(@chosen_priority_faction) || 0
                    ARENA_CLOCKWISE_ORDER.rotate(idx)
                  else
                    ARENA_CLOCKWISE_ORDER
                  end

          order.map { |sym| @corporations.find { |c| c.id == sym } }.compact
        end

        def government_neutral?
          row, col = @government_marker
          [3, 4].include?(row) && [3, 4].include?(col)
        end

        def needs_priority_faction_choice?
          # This is called during SR to check if choice is needed
          # Don't activate during SR - only when explicitly triggered at end
          false
        end

        def pending_priority_faction_choice
          @pending_priority_faction_choice
        end

        def trigger_priority_faction_choice!(player)
          @pending_priority_faction_choice = true
          @priority_faction_chooser = player
        end

        def priority_faction_chooser
          @priority_faction_chooser
        end

        def floated_factions
          @corporations.select { |c| c.type == :faction && c.floated? }
        end

        def set_priority_faction!(faction_sym)
          @chosen_priority_faction = faction_sym
          @log << "#{@priority_faction_chooser.name} chooses #{faction_display_name(faction_sym)} as priority faction for Voting Round"
          @pending_priority_faction_choice = false
          @priority_faction_chooser = nil
        end

        def clear_priority_faction_choice!
          @chosen_priority_faction = nil
        end

        # OR priority choice methods
        def pending_or_priority_choice
          @pending_or_priority_choice
        end

        def or_priority_chooser
          @or_priority_chooser
        end

        def trigger_or_priority_choice!(player)
          @pending_or_priority_choice = true
          @or_priority_chooser = player
        end

        def set_or_priority_faction!(faction_sym)
          @chosen_or_priority_faction = faction_sym
          @log << "#{@or_priority_chooser.name} chooses #{faction_display_name(faction_sym)} as first faction for Operating Round"
          @pending_or_priority_choice = false
          @or_priority_chooser = nil

          # Reorder entities in the current round to reflect the new order
          reorder_or_entities!
        end

        def reorder_or_entities!
          return unless @round.is_a?(Engine::Round::Operating)

          # Recalculate operating order and update round entities
          @round.entities = operating_order
          @round.entity_index = 0
        end

        def clear_or_priority_choice!
          @chosen_or_priority_faction = nil
        end

        def needs_or_priority_choice?
          return false unless government_neutral?
          return false unless parliament_open?

          floated_factions.size >= 2
        end

        def governing_faction_sym
          row, col = @government_marker
          # Center (3,3), (3,4), (4,3), (4,4) = neutral
          return nil if [3, 4].include?(row) && [3, 4].include?(col)

          # Determine which quadrant the marker is in
          # Top-left = TEC (rows 0-3, cols 0-3 exclusive of center)
          # Top-right = LOR (rows 0-3, cols 4-7)
          # Bottom-left = EXP (rows 4-7, cols 0-3)
          # Bottom-right = GUA (rows 4-7, cols 4-7)
          if row < 4 && col < 4
            'TEC'
          elsif row < 4 && col >= 4
            'LOR'
          elsif row >= 4 && col < 4
            'EXP'
          else
            'GUA'
          end
        end

        def current_voting_president
          return nil if voting_finished?

          if @voting_phase == :propose
            # Proposer is the faction at proposer_index
            faction = current_proposer_faction
            faction&.owner
          else
            # Current voter in the rotation
            current_voter_president
          end
        end

        def current_voting_faction
          return nil if voting_finished?

          if @voting_phase == :propose
            current_proposer_faction
          else
            voting_rotation[@voting_voter_index % voting_rotation.size]
          end
        end

        def current_voting_regulation
          return unless @current_voting_regulation_id

          @regulations[@current_voting_regulation_id]
        end

        def voting_finished?
          @voting_rounds_remaining.nil? || @voting_rounds_remaining <= 0
        end

        def available_regulations
          @regulations.reject { |_id, reg| reg[:locked] }
        end

        # Proposer picks criterion and gets a free vote (no cube cost)
        def propose_regulation(entity, reg_id, direction)
          reg = @regulations[reg_id]
          raise GameError, 'Invalid regulation' unless reg
          raise GameError, 'Regulation is locked' if reg[:locked]

          faction = current_proposer_faction
          from_label = REGULATION_LABELS[reg[:position]]
          move_regulation(reg_id, direction)
          @log << "#{entity.name} (#{faction.name}) votes #{reg_id}. #{reg[:name]}: "\
                  "#{from_label} -> #{REGULATION_LABELS[reg[:position]]}"

          # Move to vote phase, start with next voter after proposer
          @voting_phase = :vote
          @voting_voter_index = 1 # Skip proposer (index 0 in rotation is proposer)
          @voting_passed_consecutive = []
        end

        def select_voting_criterion(reg_id)
          reg = @regulations[reg_id]
          raise GameError, 'Invalid regulation' unless reg
          raise GameError, 'Regulation is locked' if reg[:locked]

          faction = current_proposer_faction
          @log << "#{faction.owner.name} (#{faction.name}) chooses #{reg_id}. #{reg[:name]}"

          @current_voting_regulation_id = reg_id
          @voting_phase = :propose_direction
        end

        def proposer_passes
          # Proposer skips — permanently loses their turn to propose
          # Move to next proposer or end voting if all have passed
          @voting_rounds_remaining -= 1
          return if voting_finished?

          @voting_proposer_index = (@voting_proposer_index + 1) % faction_voting_order.size
          @voting_phase = :propose
          @current_voting_regulation_id = nil
          @voting_passed_consecutive = []
          @voting_voter_index = 0
        end

        # A voter spends 1 cube and moves the regulation
        def cast_vote(entity, _reg_id, direction)
          faction = current_voting_faction
          raise GameError, 'No faction found for voter' unless faction

          faction_sym = faction.id
          if faction_influence(faction_sym) <= 0
            raise GameError, "#{faction.name} has no Influence"
          end

          faction_influence_lose(faction_sym)
          reg = @regulations[@current_voting_regulation_id]
          from_label = REGULATION_LABELS[reg[:position]]
          move_regulation(@current_voting_regulation_id, direction)

          @log << "#{entity.name} (#{faction.name}) votes #{@current_voting_regulation_id}. #{reg[:name]}: "\
                  "#{from_label} -> #{REGULATION_LABELS[reg[:position]]} (spends 1 Influence)"

          # Reset consecutive passes (someone voted)
          @voting_passed_consecutive = []
          advance_voter
        end

        # A voter passes
        def voting_pass(entity)
          @voting_passed_consecutive << entity

          # Check if all voters have passed consecutively
          if @voting_passed_consecutive.size >= voting_rotation.size
            # All passed — lock criterion and move to next proposer
            lock_current_and_advance
          else
            advance_voter
          end
        end

        def voting_entity_faction(entity)
          faction_voting_order.find { |f| f.owner == entity }
        end

        def lock_current_and_advance
          if @current_voting_regulation_id
            reg = @regulations[@current_voting_regulation_id]
            reg[:locked] = true
            @log << "#{reg[:name]} locked at #{REGULATION_LABELS[reg[:position]]}"
          end
          @voting_rounds_remaining -= 1
          return if voting_finished?

          @voting_proposer_index = (@voting_proposer_index + 1) % faction_voting_order.size
          @voting_phase = :propose
          @current_voting_regulation_id = nil
          @voting_passed_consecutive = []
          @voting_voter_index = 0
        end

        def regulation_value(reg_id)
          @regulations[reg_id][:position]
        end

        # === Faction Favors ===

        MAX_FAVORS_PER_GAME = 5

        def can_request_favor?(corporation)
          return false if corporation.type == :faction
          return false unless available_favor_factions(corporation).any?

          # Check if corporation is forced to buy train but can't afford
          forced_train_purchase = must_buy_train?(corporation) && corporation.cash < cheapest_depot_train_price

          # Normal limit check: max 5 favors per game, UNLESS forced to buy train
          # Per rules: forced train purchase can exceed the 5-favor limit (6/5, 7/5, etc.)
          unless forced_train_purchase
            return false if @favors_used[corporation.id] >= MAX_FAVORS_PER_GAME
          end

          # First favor of the OR: always available
          return true if @favor_used_this_or[corporation.id] < 1

          # After 1+ favor this OR: only available if must buy train and can't afford
          forced_train_purchase
        end

        def available_favor_factions(corporation)
          @corporations.select do |f|
            next false unless f.type == :faction
            next false unless f.cash >= 100
            # Use market position to check token availability (same logic as status_array).
            # Each move_right (favor, base, turmoil) consumes 1 token from the pool.
            tokens_total = f.tokens.size - 1
            tokens_used = f.share_price&.coordinates&.[](1) || 0
            next false unless tokens_total - tokens_used > 0

            true
          end
        end

        def favor_market_penalty(_corporation, _faction, with_influence_to)
          r4 = regulation_value('R4')

          # Spending an influence cube costs the same regardless of which faction
          # it comes from; only paying without a cube is more expensive.
          if with_influence_to
            case r4
            when 0 then 2
            when 1 then 2
            when 2 then 3
            else 2
            end
          else
            case r4
            when 0 then 3
            when 1 then 4
            when 2 then 4
            else 4
            end
          end
        end

        def execute_favor(corporation, faction, with_influence_to, silent: false)
          faction.spend(100, corporation)
          @log << "#{corporation.name} receives Favor (#{format_currency(100)}) from #{faction.name}" unless silent

          # Move influence from corp card to faction parliament
          if with_influence_to
            @corporation_influence[corporation.id] ||= {}
            if (@corporation_influence[corporation.id][with_influence_to] || 0).positive?
              @corporation_influence[corporation.id][with_influence_to] -= 1
              limit = faction_influence_limit
              if @faction_influence[faction.id] < limit
                @faction_influence[faction.id] += 1
                @log << "#{corporation.name} sends Influence from #{with_influence_to} to #{faction.id}" unless silent
              else
                @log << "#{corporation.name} sends Influence (#{faction.name} at limit, Influence returned)" unless silent
              end
            end
          end

          old_faction_price = faction.share_price
          @stock_market.move_right(faction)
          faction.par_price = faction.share_price
          @log << "#{faction.name}'s value increases to #{format_currency(faction.share_price.price)}" unless silent

          penalty = favor_market_penalty(corporation, faction, with_influence_to)
          old_price = corporation.share_price
          penalty.times do
            coords = @stock_market.left(corporation, corporation.share_price.coordinates)
            @stock_market.move(corporation, coords, force: true)
          end
          log_share_price(corporation, old_price) unless silent

          @favors_used[corporation.id] += 1
          @favor_used_this_or[corporation.id] += 1
        end

        # How many favors this corp has used this OR
        def favors_used_this_or(corporation)
          @favor_used_this_or[corporation.id]
        end

        # Is this corp in forced favor mode? (2nd+ favor, must buy train but can't afford cheapest)
        def forced_favor?(corporation)
          @favor_used_this_or[corporation.id] >= 1 && must_buy_train?(corporation) &&
            corporation.cash < cheapest_depot_train_price
        end

        # Once a trainless corp requests its 2nd favor this OR it is in forced
        # purchase: it may only buy a train from the depot (bank pool), never
        # from another player's corporation.
        def depot_only_train_purchase?(corporation)
          return false unless corporation.corporation? && corporation.type != :faction

          must_buy_train?(corporation) && @favor_used_this_or[corporation.id] >= 2
        end

        def cheapest_depot_train_price
          @depot.min_depot_train&.price || 0
        end

        # Undo a previously applied favor (for preview mode)
        def undo_favor(corporation, undo_data)
          return unless undo_data

          (undo_data[:move_left] || 0).times { @stock_market.move_right(corporation) }
          (undo_data[:move_down] || 0).times { @stock_market.move_up(corporation) }

          faction = undo_data[:faction]
          corporation.spend(100, faction) if faction
          @stock_market.move_left(faction) if faction

          if undo_data[:from_faction]
            if undo_data[:cube_added_to_parliament]
              @faction_influence[faction.id] = [@faction_influence[faction.id] - 1, 0].max
            end
            @corporation_influence[corporation.id] ||= {}
            @corporation_influence[corporation.id][undo_data[:from_faction]] ||= 0
            @corporation_influence[corporation.id][undo_data[:from_faction]] += 1
          end

          @favors_used[corporation.id] = [@favors_used[corporation.id] - 1, 0].max
          @favor_used_this_or[corporation.id] = [@favor_used_this_or[corporation.id] - 1, 0].max
        end

        # Execute favor silently and return undo data
        def execute_favor_with_undo(corporation, faction, with_influence_to)
          old_price = corporation.share_price
          old_price_value = old_price.price
          old_coords = old_price.coordinates.dup
          old_faction_influence = @faction_influence[faction.id]

          execute_favor(corporation, faction, with_influence_to, silent: true)

          influence_added = @faction_influence[faction.id] > old_faction_influence

          new_coords = corporation.share_price.coordinates
          move_left = old_coords[1] - new_coords[1]
          move_down = new_coords[0] - old_coords[0]

          {
            faction: faction,
            from_faction: with_influence_to,
            to_faction: faction.id,
            move_left: [move_left, 0].max,
            move_down: [move_down, 0].max,
            old_price_value: old_price_value,
            cube_added_to_parliament: influence_added,
          }
        end

        private

        def current_proposer_faction
          order = faction_voting_order
          return nil if order.empty?

          order[@voting_proposer_index % order.size]
        end

        def voting_rotation
          # Rotation starts with proposer, then clockwise (next factions in order)
          order = faction_voting_order
          return [] if order.empty?

          start = @voting_proposer_index % order.size
          order.rotate(start)
        end

        def current_voter_president
          rotation = voting_rotation
          return nil if rotation.empty?

          faction = rotation[@voting_voter_index % rotation.size]
          faction&.owner
        end

        def advance_voter
          @voting_voter_index = (@voting_voter_index + 1) % voting_rotation.size
        end

        def move_regulation(reg_id, direction)
          reg = @regulations[reg_id]
          case direction
          when :up
            reg[:position] = [reg[:position] + 1, 2].min
          when :down
            reg[:position] = [reg[:position] - 1, 0].max
          end

          # Apply R3 effects immediately
          apply_r3_limits if reg_id == 'R3'
        end

        def apply_r3_limits
          new_limit = case regulation_value('R3')
                      when 0 then 70 # Loose
                      when 1 then 60 # Normal
                      when 2 then 50 # Tight
                      else 60
                      end

          @corporations.each do |corp|
            next if corp.type == :faction

            if corp.share_price&.type == :no_cert_limit
              # Corps in the no_cert_limit zone (K cells) are exempt from R3 ownership limits
              corp.max_ownership_percent = 100
            else
              corp.max_ownership_percent = new_limit
            end
          end
        end

        # When a corp moves to/from a no_cert_limit (K) cell, update its ownership limit.
        # Called after any share price change via log_share_price.
        def update_ownership_limit_for(corporation)
          return if corporation.type == :faction

          if corporation.share_price&.type == :no_cert_limit
            corporation.max_ownership_percent = 100
          else
            r3_limit = case regulation_value('R3')
                       when 0 then 70
                       when 1 then 60
                       when 2 then 50
                       else 60
                       end
            corporation.max_ownership_percent = r3_limit
          end
        end

        public

        def faction_action_cost_chart
          [
            ['Action', 'Influence Cost'],
            ['Lay yellow tile (plain)', '1'],
            ['Lay yellow tile (mountain £50)', '2'],
            ['Lay yellow tile (mountain £80)', '3'],
            ['Upgrade to green', '2'],
            ['Upgrade to brown', '3'],
            ['Upgrade to gray', '4'],
            ['Place a base', '5'],
          ]
        end

        def price_movement_chart
          # Hide during favor mode
          return [['', '']] if @round&.respond_to?(:favor_mode) && @round.favor_mode

          [
            ['Action', 'Share Price Change'],
            ['Dividend ≥ market value', '1 →'],
            ['Dividend < market value (but > 0)', 'No change'],
            ['Dividend withheld (£0)', '1 ←'],
            ['Each share sold by player', '1 ↓'],
            ['Sold out at end of SR', '1 ↑'],
            ['Turmoil — Government supporter', '1 →'],
            ['Turmoil — Opposition supporter', '1 ←'],
            ['', ''],
            ['Favor (R4)', 'Loose / Normal / Tight'],
            ['Same faction Influence sent', '2← / 2← / 3←'],
            ['Different faction Influence sent', '2← / 3← / 4←'],
            ['No Influence sent', '3← / 4← / 4←'],
          ]
        end
      end
    end
  end
end
