# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'tiles'
require_relative '../base'

module Engine
  module Game
    module GFrost1831
      class Game < Game::Base
        include_meta(GFrost1831::Meta)
        include Entities
        include Map
        include Tiles

        CURRENCY_FORMAT_STR = '£%s'

        BANK_CASH = 9000

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        SELL_BUY_ORDER = :sell_buy

        EBUY_CAN_SELL_SHARES = false

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
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
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

        # Track when bank breaks so D train doesn't override it
        def end_now?(after)
          @bank_broken_trigger ||= true if after == :full_or && @bank.broken?

          super
        end

        def game_end_check_custom?
          @d_train_bought
        end

        # The game ends when the bank breaks.
        def game_end_check_values
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
              'Game ends at conclusion of the next full OR set'
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
            tokens_total = faction.tokens.size - 1 # 8 additional tokens
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

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
