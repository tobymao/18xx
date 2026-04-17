# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'graph'
require_relative 'map'
require_relative 'entities'
require_relative 'round/draft'
require_relative 'round/operating'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/buy_train'
require_relative 'step/draft'
require_relative 'step/draft_vanderpluym'
require_relative 'step/dividend'
require_relative 'step/form_prussian'
require_relative 'step/merge_to_prussian'
require_relative 'step/special_token'
require_relative 'step/special_track'
require_relative 'step/token'
require_relative 'step/track'
require_relative '../../round/operating'
require_relative '../../round/stock'
require_relative '../../step/home_token'
require_relative 'minor'

module Engine
  module Game
    module G1835
      class Game < Game::Base
        include_meta(G1835::Meta)
        include G1835::Entities
        include G1835::Map

        # Enable player-to-player share purchases (nationalization)
        BUY_SHARE_FROM_OTHER_PLAYER = true

        # Minimum ownership percentage required to nationalize shares
        NATIONALIZATION_THRESHOLD = 55

        # Ownership threshold for certificate limit bonus
        CERT_LIMIT_BONUS_THRESHOLD = 80

        # Pre-Prussian companies that can merge into PR
        PRE_PRUSSIAN_MINORS = %w[M1 M3 M4 M5 M6].freeze
        PRE_PRUSSIAN_COMPANIES = %w[BB HB].freeze

        # Mapping of pre-Prussian entities to their reserved PR share indices
        # P2 (M2) gets the president's share (handled specially)
        # These indices correspond to the shares array in PR corporation definition
        PR_SHARE_MAPPING = {
          'M1' => 'PR_9',  # 5% share at index 9
          'M3' => 'PR_10', # 5% share at index 10
          'M4' => 'PR_3',  # 10% share at index 3
          'M5' => 'PR_11', # 5% share at index 11
          'M6' => 'PR_8',  # 5% share at index 8
          'BB' => 'PR_2',  # 10% share at index 2
          'HB' => 'PR_1',  # 10% share at index 1
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'pr_optional' => ['Optional PR Formation', 'PR formation becomes optional for M2 owner'],
          'pr_mandatory' => ['Mandatory PR Formation', 'PR must form immediately if not already formed'],
          'mergers_mandatory' => ['Mandatory Mergers', 'All pre-Prussian companies must merge into PR'],
        ).freeze

        register_colors(black: '#37383a',
                        seRed: '#f72d2d',
                        bePurple: '#2d0047',
                        peBlack: '#000',
                        beBlue: '#c3deeb',
                        heGreen: '#78c292',
                        oegray: '#6e6966',
                        weYellow: '#ebff45',
                        beBrown: '#54230e',
                        gray: '#6e6966',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '%sM'
        # game end current or, when the bank is empty
        GAME_END_CHECK = { bank: :current_or }.freeze
        # bankrupt is allowed, player leaves game
        BANKRUPTCY_ALLOWED = true

        BANK_CASH = 12_000
        PAR_PRICES = {
          'PR' => 154,
          'BY' => 92,
          'SX' => 88,
          'BA' => 84,
          'WT' => 84,
          'HE' => 84,
          'MS' => 80,
          'OL' => 80,
        }.freeze

        # Vanderpluym-Auktion variant: floor bid for each start-packet item.
        # Bids must be in increments of 5M and at least this value.
        VANDERPLUYM_MIN_BIDS = {
          'NF' => 80,
          'M1' => 80,
          'LD' => 155,
          'M2' => 170,
          'M3' => 80,
          'M4' => 130,
          'BYD' => 150,
          'BB' => 100,
          'HB' => 125,
          'M5' => 80,
          'M6' => 80,
          'OBB' => 95,
          'PB' => 120,
        }.freeze
        CERT_LIMIT = { 3 => 19, 4 => 15, 5 => 12, 6 => 11, 7 => 9 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 475, 5 => 390, 6 => 340, 7 => 310 }.freeze
        # money per initial share sold
        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        MARKET = [['',
                   '',
                   '',
                   '',
                   '132',
                   '148',
                   '166',
                   '186',
                   '208',
                   '232',
                   '258',
                   '286',
                   '316',
                   '348',
                   '382',
                   '418'],
                  ['',
                   '',
                   '98',
                   '108',
                   '120',
                   '134',
                   '150',
                   '168',
                   '188',
                   '210',
                   '234',
                   '260',
                   '288',
                   '318',
                   '350',
                   '384'],
                  %w[82
                     86
                     92p
                     100
                     110
                     122
                     136
                     152
                     170
                     190
                     212
                     236
                     262
                     290
                     320],
                  %w[78
                     84p
                     88p
                     94
                     102
                     112
                     124
                     138
                     154p
                     172
                     192
                     214],
                  %w[72 80p 86 90 96 104 114 126 140],
                  %w[64 74 82 88 92 98 106],
                  %w[54 66 76 84 90]].freeze

        PHASES = [
          {
            name: '1.1',
            on: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '1.2',
            on: '2+2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2.1',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.2',
            on: '3+3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.3',
            on: '4',
            train_limit: { Prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.4',
            on: '4+4',
            train_limit: { Prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3.1',
            on: '5',
            train_limit: { Prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            events: { close_companies: true },
          },
          {
            name: '3.2',
            on: '5+5',
            train_limit: { Prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.3',
            on: '6',
            train_limit: { Prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.4',
            on: '6+6',
            train_limit: { Prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 9 },
          {
            name: '2+2',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[town], 'pay' => 2, 'visit' => 2 }],
            price: 120,
            rusts_on: '4+4',
            num: 4,
          },
          { name: '3', distance: 3, price: 180, rusts_on: '6', num: 4 },
          {
            name: '3+3',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => %w[town], 'pay' => 3, 'visit' => 3 }],
            price: 270,
            rusts_on: '6+6',
            num: 3,
          },
          { name: '4', distance: 4, price: 360, num: 3, events: [{ 'type' => 'pr_optional' }] },
          {
            name: '4+4',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => %w[town], 'pay' => 4, 'visit' => 4 }],
            price: 440,
            num: 1,
            events: [{ 'type' => 'pr_mandatory' }],
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
            events: [{ 'type' => 'mergers_mandatory' }, { 'type' => 'close_companies' }],
          },
          {
            name: '5+5',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[town], 'pay' => 5, 'visit' => 5 }],
            price: 600,
            num: 1,
          },
          { name: '6', distance: 6, price: 600, num: 2 },
          {
            name: '6+6',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => %w[town], 'pay' => 6, 'visit' => 6 }],
            price: 720,
            num: 4,
          },
        ].freeze

        LAYOUT = :pointy

        SELL_MOVEMENT = :down_block
        SELL_AFTER = :operate

        HOME_TOKEN_TIMING = :float

        # When a tile with paths is laid over a multi-city no-path home hex (e.g. L6/BA),
        # the displaced token is re-placed by the owning corporation (not the current operator).
        TOKEN_PLACEMENT_ON_TILE_LAY_ENTITY = :owner

        attr_reader :pr_formed, :pr_formation_optional, :pr_formation_mandatory, :mergers_mandatory

        def option_clemens?
          @optional_rules&.include?(:clemens)
        end

        def option_vanderpluym?
          @optional_rules&.include?(:vanderpluym)
        end

        # Called by Step::Draft after each player turn during the Clemens first circuit.
        # When all N players have gone once (in the initial reversed order), the first
        # circuit is complete.  Step::Draft then flips entities back to normal order.
        def clemens_advance_first_circuit!
          return if @clemens_first_circuit_done

          @clemens_first_circuit_count += 1
          @clemens_first_circuit_done = true if @clemens_first_circuit_count >= @players.size
        end

        def clemens_first_circuit_done?
          @clemens_first_circuit_done
        end

        def setup
          @pr_formed = false
          @pr_formation_optional = false
          @pr_formation_mandatory = false
          @mergers_mandatory = false
          @draft_pending_capital = Hash.new(0)
          @announced_available = []
          # Clemens variant: track the first reversed circuit across draft rounds
          @clemens_first_circuit_done = false
          @clemens_first_circuit_count = 0

          # Mark the trailing 20% share of BA/HE/WT as last_cert so it can only
          # be purchased after all other IPO shares of that corporation are gone.
          %w[BA HE WT].each do |corp_id|
            corp = corporation_by_id(corp_id)
            corp.shares.find { |s| s.index == 7 }&.tap { |s| s.last_cert = true }
          end

          # Mark non-president 20% shares as double_cert so the UI shows 'd' next to
          # the share count for any player holding one (counts as 2 certificates).
          # President's shares are already distinguished by '*' in the display.
          corporations.each do |corp|
            corp.shares.each { |s| s.double_cert = true if s.percent == 20 && !s.president }
          end

          # BY and SX are available from the start; all others appear progressively.
          corporations.each do |corp|
            price = @stock_market.par_prices.find { |p| p.price == PAR_PRICES[corp.id] }
            next unless price

            if %w[BY SX].include?(corp.id)
              # These start on the stock market immediately
              @stock_market.set_par(corp, price)
              corp.ipoed = true
            else
              # Pre-set internal price fields without placing the stock market token.
              # The token appears when the president's share is first purchased (or PR forms).
              corp.share_price = price
              corp.par_price = price
              corp.original_par_price = price
            end
          end

          # Reserve PR shares for pre-Prussian companies
          setup_pr_reserved_shares
        end

        def init_minors
          game_minors.map { |minor| G1835::Minor.new(**minor) }
        end

        def setup_pr_reserved_shares
          pr = corporation_by_id('PR')
          return unless pr

          # Mark the appropriate shares as reserved for each pre-Prussian entity
          # The share indices map to specific reserved shares
          PR_SHARE_MAPPING.each_value do |share_id|
            share_index = share_id.split('_').last.to_i
            share = pr.shares[share_index] if share_index < pr.shares.size
            share.buyable = false if share
          end

          # Also reserve the president's share for P2 (M2)
          pr.presidents_share.buyable = false
        end

        # Accumulate capital owed to a corporation for free shares distributed during the draft.
        # Called by the Draft step each time it hands out a share with exchange: :free.
        # If the corporation is already floated (e.g. BY in Clemens/Vanderpluym after BYD is won),
        # pay the capital immediately; otherwise defer to float_corporation.
        def add_draft_capital(corporation, amount)
          if corporation.floated?
            @bank.spend(amount, corporation)
            @log << "#{corporation.name} receives #{format_currency(amount)} as share capital"
          else
            @draft_pending_capital[corporation] += amount
          end
        end

        # Event handlers for PR formation triggers
        def event_pr_optional!
          @log << "-- Event: #{EVENTS_TEXT['pr_optional'][1]} --"
          @pr_formation_optional = true
        end

        def event_pr_mandatory!
          @log << "-- Event: #{EVENTS_TEXT['pr_mandatory'][1]} --"
          @pr_formation_mandatory = true

          # If PR hasn't formed yet, it must form now
          form_prussian_railroad! unless @pr_formed
        end

        def event_mergers_mandatory!
          @log << "-- Event: #{EVENTS_TEXT['mergers_mandatory'][1]} --"
          @mergers_mandatory = true

          # Force all remaining pre-Prussian mergers
          force_remaining_mergers!
        end

        # Check if PR formation is currently allowed
        def pr_formation_allowed?
          @pr_formation_optional || @pr_formation_mandatory
        end

        # Check if mergers are currently allowed
        def mergers_allowed?
          @pr_formed && (@pr_formation_optional || @mergers_mandatory)
        end

        # Get the M2 minor (P2)
        def m2_minor
          @minors.find { |m| m.id == 'M2' }
        end

        # Get PR corporation
        def pr_corporation
          corporation_by_id('PR')
        end

        # Get pre-Prussian minors that haven't merged yet
        def unmerged_pre_prussian_minors
          PRE_PRUSSIAN_MINORS.map { |sym| @minors.find { |m| m.id == sym } }
                             .compact
                             .reject(&:closed?)
        end

        # Get pre-Prussian companies that haven't merged yet
        def unmerged_pre_prussian_companies
          PRE_PRUSSIAN_COMPANIES.map { |sym| company_by_id(sym) }
                                .compact
                                .reject(&:closed?)
        end

        # All pre-Prussian entities that can still merge
        def mergeable_pre_prussian_entities
          unmerged_pre_prussian_minors + unmerged_pre_prussian_companies
        end

        # Form the Prussian Railroad from M2
        def form_prussian_railroad!
          m2 = m2_minor
          return unless m2
          return if m2.closed?
          return if @pr_formed

          pr = pr_corporation
          owner = m2.owner

          @log << "-- #{m2.name} forms the Prussian Railroad! --"

          # Transfer president's share to M2 owner
          presidents_share = pr.presidents_share
          presidents_share.buyable = true
          @share_pool.transfer_shares(ShareBundle.new([presidents_share]), owner)

          @log << "#{owner.name} receives the president's share of #{pr.name}"

          # Set PR owner
          pr.owner = owner

          # Transfer cash from M2 to PR
          if m2.cash.positive?
            @log << "#{pr.name} receives #{format_currency(m2.cash)} from #{m2.name}'s treasury"
            m2.spend(m2.cash, pr)
          end

          # Transfer trains from M2 to PR
          unless m2.trains.empty?
            trains_str = m2.trains.map(&:name).join(', ')
            @log << "#{pr.name} receives train(s): #{trains_str}"
            m2.trains.dup.each { |t| buy_train(pr, t, :free) }
          end

          # Replace M2's token with PR token
          replace_minor_token(m2, pr)

          # Close M2
          close_corporation(m2, quiet: true)

          # Place PR on the stock market now that its unreserved shares are purchasable
          @stock_market.set_par(pr, pr.par_price) unless pr.share_price.corporations.include?(pr)
          pr.ipoed = true

          # Float PR
          pr.floatable = true
          pr.floated = true

          @pr_formed = true
        end

        # Merge a pre-Prussian entity into PR
        def merge_entity_to_prussian!(entity, operated_this_or: false)
          pr = pr_corporation
          return unless pr
          return unless @pr_formed

          # Get entity identifier - companies have sym, minors have id/name
          entity_id = entity.respond_to?(:sym) ? entity.sym : entity.id
          share_id = PR_SHARE_MAPPING[entity_id]
          return unless share_id

          share_index = share_id.split('_').last.to_i

          # Find the share by its index attribute, not array position
          # The shares array can shift after transfers, but share.index stays the same
          share = pr.shares.find { |s| s.index == share_index }
          return unless share

          owner = entity.owner
          @log << "-- #{entity.name} merges into #{pr.name} --"

          # Make share buyable and transfer to owner
          share.buyable = true
          @share_pool.transfer_shares(ShareBundle.new([share]), owner, allow_president_change: true)
          @log << "#{owner.name} receives a #{share.percent}% share of #{pr.name}"

          # Track if this share should not pay dividends this OR.
          # Store as fractional share units (share.percent / pr.share_percent) so that
          # 5% shares (= 0.5 units) are deducted correctly in num_paying_shares.
          if operated_this_or && @round.respond_to?(:non_paying_shares)
            @round.non_paying_shares[owner][pr] += share.percent.to_f / pr.share_percent
          end

          if entity.minor?
            # Transfer cash from minor to PR
            if entity.cash.positive?
              @log << "#{pr.name} receives #{format_currency(entity.cash)} from #{entity.name}'s treasury"
              entity.spend(entity.cash, pr)
            end

            # Transfer trains from minor to PR
            unless entity.trains.empty?
              if pr.trains.size >= train_limit(pr)
                @log << "#{entity.name}'s trains are discarded (#{pr.name} at train limit)"
                entity.trains.each { |t| @depot.reclaim_train(t) }
              else
                trains_str = entity.trains.map(&:name).join(', ')
                @log << "#{pr.name} receives train(s): #{trains_str}"
                entity.trains.dup.each { |t| buy_train(pr, t, :free) }
              end
            end

            # Replace token.
            # M5 (Berlin-Stettiner) is special: its Berlin token is removed rather than replaced
            # because Berlin already received a PR token when M2 formed the Prussian Railroad.
            if entity.id == 'M5'
              m5_token = entity.tokens.first
              if m5_token&.used
                hex_id = m5_token.city&.hex&.id
                @log << "#{entity.name}'s token at #{hex_id} is removed"
                m5_token.remove!
              end
            else
              replace_minor_token(entity, pr)
            end

            # Close the minor
            close_corporation(entity, quiet: true)
          else
            # It's a company - just close it
            entity.close!
          end

          graph.clear_graph_for(pr)
        end

        # Force all remaining pre-Prussian mergers
        def force_remaining_mergers!
          return unless @pr_formed

          mergeable_pre_prussian_entities.each do |entity|
            # Skip entities without player owners
            next unless entity.owner&.player?

            merge_entity_to_prussian!(entity, operated_this_or: false)
          end
        end

        # Replace a minor's token with a PR token
        def replace_minor_token(minor, pr)
          token = minor.tokens.first
          return unless token&.used

          new_token = Token.new(pr)
          pr.tokens << new_token
          token.swap!(new_token, check_tokenable: false)
          @log << "#{pr.name} receives token at #{new_token.city.hex.id}"
        end

        # Check if entity has operated this round
        def operated_this_round?(entity)
          entity.operating_history.include?([@turn, @round.round_num])
        end

        # Get player order for mergers, starting with the M2/PR director and going clockwise.
        def merger_player_order
          pr_owner = pr_corporation&.owner
          return @players unless pr_owner

          index = @players.index(pr_owner)
          return @players unless index

          @players.rotate(index)
        end

        def init_graph
          G1835::Graph.new(self)
        end

        def init_round
          @log << '-- Initial Draft Round --'
          new_draft_round
        end

        def new_draft_round
          if option_clemens?
            # Reversed order for the first circuit; normal order after that.
            G1835::Round::Draft.new(self, [G1835::Step::Draft],
                                    reverse_order: !@clemens_first_circuit_done)
          elsif option_vanderpluym?
            G1835::Round::Draft.new(self, [G1835::Step::DraftVanderpluym], reverse_order: false)
          else
            G1835::Round::Draft.new(self, [G1835::Step::Draft], reverse_order: false)
          end
        end

        def next_round!
          @round =
            case @round
            when G1835::Round::Draft
              set_draft_priority_deal
              if all_entities_drafted?
                # All purchased, move to stock round
                @log << '-- All entities purchased, starting stock round --'
                new_stock_round
              elsif operating_order.empty?
                # Draft incomplete and nothing to operate — skip the OR and return to draft
                @log << '-- Draft incomplete, nothing to operate, returning to draft round --'
                new_draft_round
              else
                # Draft incomplete but some entities can operate — run one OR then return to draft
                @log << '-- Draft incomplete, moving to operating round --'
                @operating_rounds = @phase.operating_rounds
                new_operating_round
              end
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                # Continue OR set
                or_round_finished
                new_operating_round(@round.round_num + 1)
              elsif all_entities_drafted?
                # Draft complete, normal flow
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              else
                # Return to draft round
                @log << '-- Returning to draft round --'
                new_draft_round
              end
            end
        end

        # Override to find any available city, not just cities.first.
        # Needed because M2 and M5 share hex E19 (Berlin, two city slots)
        # and M6 needs city index 2 on Hamburg (C11).
        def place_home_token(corporation)
          return unless corporation.next_token
          return if corporation.tokens.first&.used

          hex = hex_by_id(corporation.coordinates)
          return unless hex&.tile

          tile = hex.tile
          token = corporation.next_token

          # Honor corporation.city index when set (e.g. M6 at city 2 on Hamburg)
          preferred_city = corporation.city ? tile.cities[corporation.city] : nil

          city = if preferred_city&.tokenable?(corporation, tokens: token)
                   preferred_city
                 else
                   tile.cities.find { |c| c.reserved_by?(corporation) } ||
                     tile.cities.find { |c| c.tokenable?(corporation, tokens: token) }
                 end

          return unless city

          @log << "#{corporation.name} places a token on #{hex.name}"
          city.place_token(corporation, token)
        end

        # Called by share_pool when a corporation first reaches float_percent.
        # The base implementation only logs and transfers capital; it does NOT place a home token.
        # For HOME_TOKEN_TIMING = :float, ShareBuying#buy_shares calls maybe_place_home_token
        # AFTER share_pool.buy_shares, so tokens get placed in normal stock-round purchases.
        # However, when corporations float during the DRAFT (e.g. BY floats because BYD + OBB +
        # NF + PB are all drafted, distributing 50 % of BY's shares), the draft step calls
        # @game.share_pool.buy_shares directly, bypassing ShareBuying — so maybe_place_home_token
        # is never called.  Overriding float_corporation ensures the home token is placed regardless
        # of which code path caused the float.
        def float_corporation(corporation)
          # Pay any capital owed for shares distributed for free during the draft.
          # With CAPITALIZATION = :incremental, buy_shares pays the corporation per-share
          # as IPO sales happen, but draft shares use exchange: :free so nothing flows.
          # We accumulate the owed amount in @draft_pending_capital and settle it here.
          pending = @draft_pending_capital.delete(corporation).to_i
          if pending.positive?
            @bank.spend(pending, corporation)
            @log << "#{corporation.name} receives #{format_currency(pending)} as share capital"
          end
          super
          # PR's token comes from replace_minor_token (M2's token swap), not the normal path.
          place_home_token(corporation) unless corporation.id == 'PR'
          check_new_corp_availabilities
        end

        # Log an announcement when a corporation's shares first become available for purchase.
        # Called after each corporation float and after each IPO share purchase.
        # Also sets ipoed = true for BA/WT/HE/MS/OL so they appear as directly buyable
        # (solid outline) in the SR without going through a par-price dialog.
        def check_new_corp_availabilities
          %w[BA WT HE PR MS OL].each do |corp_id|
            next if @announced_available.include?(corp_id)

            corp = corporation_by_id(corp_id)
            next unless corporation_ipo_available?(corp)

            @announced_available << corp_id
            # Mark as ipoed so the UI shows it as a buyable corporation.
            # For BA/WT/HE/MS/OL: set_par is deferred until the president's share
            # is first purchased (process_buy_shares handles it).
            # For PR: place it on the stock market immediately — it has no president's
            # share purchase; players buy the 4 unreserved 10% shares directly.
            @stock_market.set_par(corp, corp.par_price) if corp_id == 'PR' && !corp.share_price.corporations.include?(corp)
            corp.ipoed = true

            msg = if corp_id == 'PR'
                    "#{corp.name} (#{corp_id}) shares are now available for purchase"
                  else
                    "#{corp.name} (#{corp_id}) president's share is now available for purchase"
                  end
            @log << "-- #{msg} --"
          end
        end

        def set_draft_priority_deal
          last_buyer = @round.last_to_act
          return unless last_buyer

          # Stock round starts with the player to the left of the last buyer
          next_idx = (@players.index(last_buyer) + 1) % @players.size
          @players.rotate!(next_idx)
          @log << "#{@players.first.name} has priority deal"
        end

        def all_entities_drafted?
          start_packet_entities.all? { |e| entity_drafted?(e) }
        end

        def start_packet_entities
          @start_packet_entities ||= begin
            entity_map = (companies + minors + corporations).to_h do |e|
              sym = e.respond_to?(:sym) ? e.sym : e.name
              [sym, e]
            end
            self.class::START_PACKET.map do |sym, _, _|
              entity = entity_map[sym]
              raise GameError, "START_PACKET references unknown entity: #{sym}" unless entity

              entity
            end
          end
        end

        def entity_drafted?(entity)
          return true if entity.respond_to?(:closed?) && entity.closed?

          if entity.corporation?
            # Corporation is drafted when a player owns the president's share
            entity.presidents_share.owner&.player?
          else
            entity.owner&.player?
          end
        end

        # Green city tiles 14 and 15 are terminal in 1835 — only labeled green tiles
        # (Y, HH, XX) upgrade to brown.
        GREEN_TERMINAL_TILES = %w[14 15].freeze

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return false if GREEN_TERMINAL_TILES.include?(from.name) && to.color == :brown

          # Yellow double-town tiles (two small towns) upgrade to green single-town tiles
          if from.color == :yellow && from.towns.size == 2
            return from.paths_are_subset_of?(to.paths) &&
              self.class::YELLOW_DOUBLE_TOWN_UPGRADES.include?(to.name)
          end

          super
        end

        def operating_round(round_num)
          G1835::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G1835::Step::FormPrussian,
            G1835::Step::MergeToPrussian,
            Engine::Step::HomeToken,
            G1835::Step::SpecialToken,
            G1835::Step::SpecialTrack,
            G1835::Step::Track,
            G1835::Step::Token,
            Engine::Step::Route,
            G1835::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1835::Step::BuyTrain,
          ], round_num: round_num)
        end

        # PR's home token at Berlin comes from swapping M2's token (via replace_minor_token),
        # not through the normal reservation system. Excluding PR prevents a tile-level
        # reservation at E19 from blocking M5's home token placement in Berlin's city 1.
        def reservation_corporations
          corporations.reject { |c| c.id == 'PR' }
        end

        # With no reservation, render_hex_reservation? for PR is moot, but keep it
        # as a safety net in case reservation logic changes.
        def render_hex_reservation?(corporation)
          corporation.id != 'PR'
        end

        # Cross-company train purchases are only allowed from phase 2.1 onwards.
        def can_buy_train_from_others?
          !@phase.name.start_with?('1')
        end

        # In phases 1.1 and 1.2 (before the first 3-train), major corporations may lay
        # two yellow tiles per operating turn. Minors always get the standard single lay.
        MAJOR_TWO_YELLOW_TILE_LAYS = [
          { lay: true, upgrade: false, cost: 0, cannot_reuse_same_hex: true },
          { lay: true, upgrade: false, cost: 0, cannot_reuse_same_hex: true },
        ].freeze

        def tile_lays(entity)
          return super if entity.minor?
          return MAJOR_TWO_YELLOW_TILE_LAYS if @phase.name.start_with?('1')

          super
        end

        # Private company powers (OBB tile, NF token, PB tile/token) are only exercisable
        # during a MAJOR corporation's operating turn.  Corporation#player walks the ownership
        # chain, so a minor's owner-player matches the ability player just like a major's
        # president does — without this guard the minor director could incorrectly use OBB/NF/PB.
        def ability_right_time?(ability, time, on_phase, passive_ok, strict_time)
          return false if ability.when?('owning_player_or_turn') &&
                          @round.operating? &&
                          @round.current_operator&.minor?

          super
        end

        # PR does not float via share sales — it forms when M2 merges.
        # Override the default "X% to float" label on the charter.
        def float_str(entity)
          return 'Floats when M2 converts' if entity.id == 'PR'

          super
        end

        # In 1835, several labeled tiles merge cities when upgrading to brown:
        #   green XX (two-city)  → brown X  (merged single city)
        #   green HH (Hamburg, 3-city) → brown H (tile 221, two-city with internal link)
        # The label changes are intentional; the base engine's label equality check
        # would otherwise block them.
        def upgrades_to_correct_label?(from, to)
          from_label = from.label&.to_s
          to_label   = to.label&.to_s
          return true if from_label == 'XX' && to_label == 'X'
          return true if from_label == 'HH' && to_label == 'H'

          super
        end

        HAMBURG_HEX = 'C11'
        HAMBURG_FERRY_PENALTY = 10

        # Hamburg (tile H, brown) has two cities connected by a ferry across the Elbe.
        # A train that crosses from one bank to the other uses the ferry and pays a
        # M10 penalty, but the hex still counts as only ONE stop.
        # Crossing is detected by the Hamburg hex appearing twice in visited_stops
        # (once for each bank city).  When that happens we suppress one city from
        # both the revenue sum and the distance count.
        def hamburg_ferry_used?(route)
          route.visited_stops.count { |s| s.hex.name == HAMBURG_HEX } > 1
        end

        # Return stops with the second Hamburg city removed when the ferry is used.
        def dedup_hamburg_stops(stops)
          seen = false
          stops.reject do |s|
            next false unless s.hex.name == HAMBURG_HEX

            if seen
              true  # remove second occurrence
            else
              seen = true
              false # keep first occurrence
            end
          end
        end

        def revenue_for(route, stops)
          return super unless hamburg_ferry_used?(route)

          super(route, dedup_hamburg_stops(stops)) - HAMBURG_FERRY_PENALTY
        end

        def revenue_str(route)
          str = super
          str += " [-#{HAMBURG_FERRY_PENALTY} ferry]" if hamburg_ferry_used?(route)
          str
        end

        def check_distance(route, visits, train = nil)
          visits = dedup_hamburg_stops(visits) if hamburg_ferry_used?(route)
          super
        end

        # Show "M+N" for plus trains (e.g. "2+2") instead of the raw stop sum.
        def route_distance_str(route)
          train = route.train
          return super unless train.distance.is_a?(Array)

          main = route.visited_stops.count { |s| %w[city offboard].include?(s.type) }
          towns = route.visited_stops.count { |s| s.type == 'town' }
          "#{main}+#{towns}"
        end

        # For player-owned companies (NF, PB) exercising token abilities during a major
        # corporation's operating turn, the token comes from that corporation's pool.
        # Called by SpecialToken#process_place_token to determine which corp places the token.
        def token_owner(entity)
          if entity&.company? && entity.owner&.player?
            operator = current_entity
            return operator if operator && !operator.minor?
          end
          super
        end

        # Override base payout_companies — pay each open private's fixed income to its owner.
        # Called by Engine::Round::Operating#setup at the start of each OR.
        def payout_companies
          @companies.each do |company|
            next if company.closed?
            next unless company.owner&.player?
            next unless company.revenue.positive?

            @bank.spend(company.revenue, company.owner)
            @log << "#{company.owner.name} receives #{format_currency(company.revenue)} from #{company.name}"
          end
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1835::Step::FormPrussian,
            G1835::Step::MergeToPrussian,
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            G1835::Step::SpecialTrack,
            G1835::Step::BuySellParShares,
          ])
        end

        # Share group availability: controls which corporations' IPO shares can be purchased
        # BY and SX are always available; others unlock progressively.
        def corporation_ipo_available?(corporation)
          case corporation.id
          when 'BA'
            # Available when BY and SX IPO shares are fully subscribed
            ipo_empty?(corporation_by_id('BY')) && ipo_empty?(corporation_by_id('SX'))
          when 'WT'
            # Available when BA has floated
            corporation_by_id('BA')&.floated? || false
          when 'HE'
            # Available when WT has floated
            corporation_by_id('WT')&.floated? || false
          when 'PR'
            # PR's purchasable shares (indices 4-7) available after BA director is sold
            ba = corporation_by_id('BA')
            ba&.presidents_share&.owner&.player? || false
          when 'MS'
            # Available when BA, WT, and HE IPO shares are all fully subscribed
            ipo_empty?(corporation_by_id('BA')) &&
              ipo_empty?(corporation_by_id('WT')) &&
              ipo_empty?(corporation_by_id('HE'))
          when 'OL'
            # Available when MS has floated
            corporation_by_id('MS')&.floated? || false
          else # corporation is either BY or SX, and thus available from the start
            true
          end
        end

        def ipo_empty?(corp)
          return true unless corp

          corp.ipo_shares.empty?
        end

        # Show purchase price on undrafted minor cards in the draft display
        def status_str(entity)
          return "Cost: #{format_currency(entity.value)}" if entity.minor? && !entity.floated? && entity.value

          nil
        end

        # Nationalization: player can only buy shares from another player if they own >= 55% of the corporation
        def can_gain_from_player?(entity, bundle)
          return false unless entity.player?

          corporation = bundle.corporation
          entity.percent_of(corporation) >= self.class::NATIONALIZATION_THRESHOLD
        end

        # Check and close private companies whose closing conditions have been met.
        # Called after every operating round action.
        def check_company_closings
          check_obb_closing
          check_nf_closing
          check_pb_closing
        end

        # OBB closes when yellow tiles exist on both M15 and M17 (regardless of who laid them).
        def check_obb_closing
          obb = company_by_id('OBB')
          return if obb.closed?
          return if hex_by_id('M15').tile.color == :white || hex_by_id('M17').tile.color == :white

          @log << "#{obb.name} closes"
          obb.close!
        end

        # NF closes when its token ability has been used, or when both cities in L14 are tokened.
        def check_nf_closing
          nf = company_by_id('NF')
          return if nf.closed?

          token_used = nf.all_abilities.none? { |a| a.type == :token }
          l14_full = hex_by_id('L14').tile.cities.all? { |city| city.tokens.count(&:itself) >= city.slots }
          return if !token_used && !l14_full

          @log << "#{nf.name} closes"
          nf.close!
        end

        # PB closes when BOTH its tile lay (teleport) AND its token ability have been used,
        # or when L6 has a tile and all token slots in L6 are filled.
        def check_pb_closing
          pb = company_by_id('PB')
          return if pb.closed?
          return if hex_by_id('L6').tile.color == :white

          teleport_used = pb.all_abilities.none? { |a| a.type == :teleport }
          token_used = pb.all_abilities.none? { |a| a.type == :token }
          l6_full = hex_by_id('L6').tile.cities.all? { |city| city.tokens.count(&:itself) >= city.slots }
          return if !(teleport_used && token_used) && !l6_full

          @log << "#{pb.name} closes"
          pb.close!
        end

        # No corporation in G1835 uses the par action. BY and SX are pre-placed on
        # the stock market at setup (ipoed from start). BA/WT/HE/MS/OL get ipoed=true
        # when their group becomes available (check_new_corp_availabilities) and are
        # then started via a normal buy_shares of the president's share.
        def can_par?(_corporation, _parrer)
          false
        end

        # Minors count as one certificate each against the owner's limit.
        def num_certs(entity)
          super + @minors.count { |m| m.owner == entity }
        end

        # Certificate limit with bonus for 80% ownership
        # Players get +1 to their certificate limit for each corporation they own >= 80% of
        def cert_limit(entity = nil)
          return @cert_limit unless entity&.player?

          bonus = @corporations.count do |corp|
            corp.ipoed && entity.percent_of(corp) >= self.class::CERT_LIMIT_BONUS_THRESHOLD
          end

          @cert_limit + bonus
        end
      end
    end
  end
end
