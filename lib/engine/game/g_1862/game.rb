# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../trainless_shares_half_value'
require_relative 'entities'
require_relative 'map'
require_relative 'round/parliament'
require_relative 'round/stock'
require_relative 'step/charter_auction'
require_relative 'step/buy_tokens'
require_relative 'step/forced_sales'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/home_upgrade'
require_relative 'step/option_share'
require_relative 'step/remove_tokens'
require_relative 'step/merge'
require_relative 'step/track'
require_relative 'step/token'
require_relative 'step/route'
require_relative 'step/dividend'
require_relative 'step/buy_train'
require_relative 'step/redeem_share'

module Engine
  module Game
    module G1862
      class Game < Game::Base
        include_meta(G1862::Meta)
        include Entities
        include Map
        include TrainlessSharesHalfValue

        attr_accessor :chartered, :base_tiles, :deferred_rust, :skip_round, :permits, :lner, :london_nodes

        register_colors(black: '#000000',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#ff0000',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '£%s'

        BANK_CASH = 15_000

        CERT_LIMIT = {
          2 => 25,
          3 => 18,
          4 => 13,
          5 => 11,
          6 => 10,
          7 => 9,
          8 => 8,
        }.freeze

        STARTING_CASH = {
          2 => 1200,
          3 => 800,
          4 => 600,
          5 => 480,
          6 => 400,
          7 => 345,
          8 => 300,
        }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[0c
             7i
             14i
             20i
             26i
             31i
             36i
             40
             44
             47
             50
             52
             54p
             56r
             58p
             60r
             62p
             65r
             68p
             71r
             74p
             78r
             82p
             86r
             90p
             95r
             100p
             105r
             110r
             116r
             122r
             128r
             134r
             142r
             150r
             158r
             166r
             174r
             182r
             191r
             200r
             210i
             220i
             232i
             245i
             260i
             275i
             292i
             310i
             330i
             350i
             375i
             400j
             430j
             460j
             495j
             530j
             570j
             610j
             655j
             700j
             750j
             800j
             850j
             900j
             950j
             1000e],
           ].freeze

        PHASES = [
          {
            name: 'A',
            train_limit: 3, # per type
            tiles: [:yellow],
            operating_rounds: 1,
            status: %w[three_per first_rev],
          },
          {
            name: 'B',
            on: 'B',
            train_limit: 3, # 3 type
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[three_per first_rev],
          },
          {
            name: 'C',
            on: 'C',
            train_limit: 3, # per type
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[three_per middle_rev],
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 3, # per type
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[three_per middle_rev],
          },
          {
            name: 'E',
            on: 'E',
            train_limit: 2, # per type
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[two_per last_rev],
          },
          {
            name: 'F',
            on: 'F',
            train_limit: 2, # per type
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[two_per last_rev],
          },
          {
            name: 'G',
            on: 'G',
            train_limit: 3, # across all types
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[three_total last_rev],
          },
          {
            name: 'H',
            on: 'H',
            train_limit: 3, # across all types
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[three_total last_rev],
          },
        ].freeze

        def game_trains
          [
            {
              name: 'A',
              distance: 99,
              price: 100,
              rusts_on: 'C',
              num: @optional_rules&.include?(:short_length) ? 6 : 7,
              no_local: true,
              variants: [
                {
                  name: '1F*',
                  distance: 1,
                  price: 100,
                  no_local: true,
                },
                {
                  name: '2L*',
                  distance: [{ 'nodes' => %w[city], 'pay' => 2, 'visit' => 2 },
                             { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                  price: 100,
                },
                {
                  name: '2E*',
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                             { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                  price: 100,
                },
              ],
            },
            {
              name: 'B',
              distance: 99,
              price: 200,
              rusts_on: 'E',
              num: @optional_rules&.include?(:short_length) ? 5 : 6,
              variants: [
                {
                  name: '2F',
                  distance: 2,
                  price: 200,
                },
                {
                  name: '2/3L',
                  distance: [{ 'nodes' => %w[city], 'pay' => 2, 'visit' => 3 },
                             { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                  price: 200,
                },
                {
                  name: '2/3E',
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 3 },
                             { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                  price: 200,
                },
              ],
            },
            {
              name: 'C',
              distance: 99,
              price: 280,
              rusts_on: 'F',
              num: @optional_rules&.include?(:long_length) ? 5 : 4,
              variants: [
                {
                  name: '3F',
                  distance: 3,
                  price: 280,
                },
                {
                  name: '3L',
                  distance: [{ 'nodes' => %w[city], 'pay' => 3, 'visit' => 3 },
                             { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                  price: 280,
                },
                {
                  name: '3E',
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                             { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                  price: 280,
                },
              ],
            },
            {
              name: 'D',
              distance: 99,
              price: 360,
              rusts_on: 'G',
              num: @optional_rules&.include?(:long_length) ? 4 : 3,
              variants: [
                {
                  name: '5F*',
                  distance: 5,
                  price: 360,
                },
                {
                  name: '4L*',
                  distance: [{ 'nodes' => %w[city], 'pay' => 4, 'visit' => 4 },
                             { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                  price: 360,
                },
                {
                  name: '4E*',
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                             { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                  price: 360,
                },
              ],
            },
            {
              name: 'E',
              distance: 99,
              price: 500,
              num: 3,
              variants: [
                {
                  name: '6F',
                  distance: 6,
                  price: 500,
                },
                {
                  name: '4/5L',
                  distance: [{ 'nodes' => %w[city], 'pay' => 4, 'visit' => 5 },
                             { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                  price: 500,
                },
                {
                  name: '4/5E',
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 5 },
                             { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                  price: 500,
                },
              ],
            },
            {
              name: 'F',
              distance: 99,
              price: 600,
              num: 2,
              variants: [
                {
                  name: '7F',
                  distance: 7,
                  price: 600,
                },
                {
                  name: '5L',
                  distance: [{ 'nodes' => %w[city], 'pay' => 5, 'visit' => 5 },
                             { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                  price: 600,
                },
                {
                  name: '5E',
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                             { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                  price: 600,
                },
              ],
            },
            {
              name: 'G',
              distance: 99,
              price: 700,
              num: 1,
              variants: [
                {
                  name: '8F',
                  distance: 8,
                  price: 700,
                },
                {
                  name: '5/6L',
                  distance: [{ 'nodes' => %w[city], 'pay' => 5, 'visit' => 6 },
                             { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                  price: 700,
                },
                {
                  name: '5/6E',
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 6 },
                             { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                  price: 700,
                },
              ],
            },
            {
              name: 'H',
              distance: 99,
              price: 800,
              num: 99,
              variants: [
                {
                  name: '9F',
                  distance: 9,
                  price: 800,
                },
                {
                  name: '6L',
                  distance: [{ 'nodes' => %w[city], 'pay' => 6, 'visit' => 6 },
                             { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                  price: 800,
                },
                {
                  name: '6E',
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                             { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                  price: 800,
                },
              ],
              events: [{ 'type' => 'lner_trigger' }],
            },
          ]
        end

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        HOME_TOKEN_TIMING = :operate
        SELL_AFTER = :round
        SELL_BUY_ORDER = :sell_buy
        PRESIDENT_SALES_TO_MARKET = true
        MARKET_SHARE_LIMIT = 100
        CERT_LIMIT_INCLUDES_PRIVATES = false

        TRACK_RESTRICTION = :semi_restrictive

        SOLD_OUT_INCREASE = false

        STOCKMARKET_COLORS = {
          par: :yellow,
          endgame: :orange,
          close: :gray,
          repar: :peach,
          ignore_one_sale: :olive,
          ignore_two_sales: :green,
          multiple_buy: :brown,
          unlimited: :orange,
          no_cert_limit: :yellow,
          liquidation: :red,
          acquisition: :yellow,
          safe_par: :white,
        }.freeze

        MARKET_TEXT = {
          par: 'Par values for chartered corporations',
          no_cert_limit: 'UNUSED',
          unlimited: 'UNUSED',
          multiple_buy: 'UNUSED',
          close: 'Corporation bankrupts',
          endgame: 'End game trigger',
          liquidation: 'UNUSED',
          repar: 'Par values for unchartered corporations',
          ignore_one_sale: 'Ignore first share sold when moving price (except president)',
          ignore_two_sales: 'Ignore first 2 shares sold when moving price (except president)',
        }.freeze

        # NOTE: that the definition of an "upgrade" is extended to include "N" tiles
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        GAME_END_CHECK = { stock_market: :current_or, bank: :full_or, custom: :full_or }.freeze
        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          bank: 'The bank runs out of money before LNER forms',
          custom: 'LNER forms before bank runs out of money'
        )

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'three_per' => ['3 per kind',
                          'Limit of 3 trains of each kind (Freight/Local/Express)'],
          'two_per' => ['2 per kind',
                        'Limit of 2 trains of each kind (Freight/Local/Express)'],
          'three_total' => ['3 total',
                            'Limit of 3 trains total'],
          'first_rev' => ['First offboard',
                          'First offboard/port value used for revenue'],
          'middle_rev' => ['Middle offboard',
                           'Middle offboard/port value used for revenue'],
          'last_rev' => ['Last offboard',
                         'Last offboard/port value used for revenue'],
        ).freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
           'lner_trigger' => ['LNER Trigger',
                              'LNER will form at end of OR set, game ends at end of following OR set'],
         ).freeze

        CHARTERED_TOKEN_COST = 60
        UNCHARTERED_TOKEN_COST = 40

        LONDON_TOKEN_HEXES = %w[
            B15
            D15
        ].freeze

        LONDON_HEXES = %w[
            A12
            A14
            B15
            C14
            D15
        ].freeze

        IPSWITCH_HEX = 'F11'
        HARWICH_HEX = 'F13'

        FREIGHT_BONUS = 20
        PORT_FREIGHT_BONUS = 30

        REAL_PHASE_TO_REV_PHASE = {
          'A' => :white,
          'B' => :white,
          'C' => :gray,
          'D' => :gray,
          'E' => :purple,
          'F' => :purple,
          'G' => :purple,
          'H' => :purple,
        }.freeze

        NORM_TOKENS = 7
        OPTIONAL_TOKENS = 8

        def max_tokens
          @max_tokens ||= @optional_rules&.include?(:eight_tokens) ? OPTIONAL_TOKENS : NORM_TOKENS
        end

        def init_companies(players)
          clist = super

          # create charter companies on the fly based on corporations
          game_corporations.map do |corp|
            description = "Parliamentary Obligation for #{corp[:name]}"
            name = "#{corp[:sym]} Obligation"

            clist << Company.new(sym: corp[:sym], name: name, value: 0, revenue: 0, desc: description)
          end

          clist
        end

        def setup
          @cached_freight_sets = nil
          @global_stops = nil
          @deferred_rust = []
          @merging = nil
          @london_nodes = LONDON_HEXES.map do |h|
            hex_by_id(h).tile.nodes.find { |n| n.offboard? && n.groups.include?('London') }
          end
        end

        def setup_preround
          @base_tiles = []
          @skip_round = {}
          @lner_triggered = nil
          @lner = nil

          # remove reservations (nice to have in starting map)
          @corporations.each { |corp| remove_reservation(corp) }

          @double_parliament = true

          # randomize order of corporations, then remove some based on player count
          @offer_order = @corporations.sort_by { rand }
          num_removed = case @players.size
                        when 8
                          2
                        when 7
                          3
                        else
                          4
                        end
          removed = @offer_order.take(num_removed)
          removed.each do |corp|
            @offer_order.delete(corp)
            @corporations.delete(corp)
            @companies.delete(@companies.find { |c| c.id == corp.id })

            @log << "Removing #{corp.name} from game"
          end

          # add markers for remaining companies
          @corporations.each { |corp| add_marker(corp) }

          @chartered = {}

          # randomize and distribute train permits
          permit_list = 6.times.flat_map { %i[freight express local] }
          permit_list.pop(2) if @players.size < 7
          permit_list.sort_by! { rand }
          @permits = Hash.new { |h, k| h[k] = [] }
          @original_permits = Hash.new { |h, k| h[k] = [] }
          @corporations.each_with_index { |corp, idx| @permits[corp] << permit_list[idx] }
          @corporations.each_with_index { |corp, idx| @original_permits[corp] << permit_list[idx] }

          # record what phases corp become available
          @starting_phase = {}
          @offer_order.each { |c| @starting_phase[c] = 'A' }
          @offer_order.reverse.take(8).each { |c| @starting_phase[c] = 'B' }
          @offer_order.reverse.take(4).each { |c| @starting_phase[c] = 'C' }

          @corporations.each { |c| convert_to_full!(c) }
        end

        def shares
          @corporations.flat_map(&:ipo_shares)
        end

        def remove_reservation(corporation)
          hex = @hexes.find { |h| h.id == corporation.coordinates } # hex_by_id doesn't work here
          hex.tile.cities.each do |city|
            city.reservations.delete(corporation) if city.reserved_by?(corporation)
          end
        end

        def add_marker(corporation)
          hex = @hexes.find { |h| h.id == corporation.coordinates } # hex_by_id doesn't work here
          return if hex.tile.icons.find(&:large) # don't add twice

          image = "1862/#{corporation.id}".upcase.delete('&')
          marker = Part::Icon.new(image, nil, true, nil, hex.tile.preprinted, large: true, owner: corporation)
          hex.tile.icons << marker
        end

        def remove_marker(corporation)
          hex = hex_by_id(corporation.coordinates)
          marker = hex.tile.icons.find(&:large)
          hex.tile.icons.delete(marker) if marker
        end

        def priority_deal_player
          players = @players.reject(&:bankrupt)

          if @round.is_a?(Engine::Game::G1862::Round::Stock)
            # We're in a stock round
            # priority deal card goes to the player who will go first if
            # everyone passes starting now.  last_to_act is nil before
            # anyone has gone, in which case the first player has PD.
            last_to_act = @round.last_to_act
            priority_idx = last_to_act ? (players.index(last_to_act) + 1) % players.size : 0
            players[priority_idx]
          else
            # We're in a parliament or operating round
            # The player list was already rotated when we
            # left a player-focused round to put the PD player first.
            players.first
          end
        end

        def share_prices
          repar_prices
        end

        def repar_prices
          @repar_prices ||= stock_market.market.first.select { |p| p.type == :repar || p.type == :par }
        end

        def ipoable_corporations
          ready_corporations.reject(&:ipoed)
        end

        def ready_corporations
          @offer_order.select { |corp| available_to_start?(corp) || corp.ipoed }
        end

        def available_to_start?(corporation)
          @phase.available?(@starting_phase[corporation]) && legal_to_start?(corporation)
        end

        def add_obligation(entity, corporation)
          charter = company_by_id(corporation.id)
          charter.owner = entity
          entity.companies << charter
          @log << "#{entity.name} is under obligation for #{corporation.name}"
          @chartered[corporation] = true
        end

        # called at end of stock round
        def enforce_obligations
          @next_priority ||= @players[@round.entity_index]
          @players.each do |player|
            remaining_fine = 0
            player.companies.dup.each do |company|
              corp = corporation_by_id(company.id)
              @log << "#{player.name} has missed obligation for #{corp.name}"
              new_fine = corp.par_price.price * 5
              @log << "#{player.name} is fined #{format_currency(new_fine)}"
              player.companies.delete(company)
              company.owner = nil
              @chartered.delete(corp)

              if player.cash >= new_fine
                @log << "#{player.name} pays #{format_currency(new_fine)}"
                player.spend(new_fine, @bank)
                restart_corporation!(corp)
                next
              elsif player.cash.positive?
                @log << "#{player.name} pays #{format_currency(player.cash)}"
                new_fine -= player.cash
                player.spend(player.cash, @bank)
              else
                @log << "#{player.name} has no cash to pay fine"
              end

              @log << "#{player.name} still owes #{format_currency(new_fine)} on #{corp.name} obligation"

              # sell shares of company until either debt is repaid, or out of those shares
              share_value = effective_price(corp)
              shares = player.shares_of(corp).sort_by(&:percent)
              share_revenue = 0
              while new_fine.positive? && !shares.empty?
                share = shares.shift
                sale_price = share.percent * share_value / 10
                new_fine -= sale_price
                share_revenue += sale_price
              end
              @log << "#{player.name} sells shares of #{corp.name} for #{format_currency(share_revenue)}"

              unless new_fine.positive?
                @bank.spend(-new_fine, player) unless new_fine.zero?
                restart_corporation!(corp)
                next
              end

              if player.shares.empty?
                @log << "#{player.name} has no more assets. Remainder of debt is forgiven."
                restart_corporation!(corp)
                next
              end

              @log << "#{player.name} still owes #{format_currency(new_fine)} on #{corp.name} obligation"
              remaining_fine += new_fine
              restart_corporation!(corp)
            end

            if remaining_fine.positive? && can_sell_any_shares?(player)
              @log << "-- #{player.name} owes #{format_currency(remaining_fine)} on all obligations and is required"\
                      ' to sell some or all assets --'
              @round.pending_forced_sales << {
                entity: player,
                amount: remaining_fine,
              }
            elsif remaining_fine.positive?
              @log << "#{player.name} has no more sellable assets. Remainder of debt is forgiven."
            end
          end
        end

        def can_sell_any_shares?(entity)
          @corporations.any? do |corporation|
            bundles = bundles_for_corporation(entity, corporation)
            bundles.any? { |bundle| can_dump_share?(entity, bundle) }
          end
        end

        def can_dump_share?(entity, bundle)
          corp = bundle.corporation
          return true if !bundle.presidents_share || bundle.percent >= corp.presidents_percent

          max_shares = corp.player_share_holders.reject { |p, _| p == entity }.values.max || 0
          return true if max_shares >= corp.presidents_percent

          diff = bundle.shares.sum(&:percent) - bundle.percent

          pool_shares = @share_pool.percent_of(corp) || 0
          pool_shares >= diff
        end

        def after_par(corporation)
          return if @chartered[corporation]

          # find closest chartered par
          corporation.original_par_price = find_valid_par_price(corporation.original_par_price.price)
        end

        def float_corporation(corporation)
          super
          charter = company_by_id(corporation.id)

          unless (entity = charter.owner)
            # unchartered company
            raise GameError, 'Player missing charter' if @chartered[corporation]

            @round.buy_tokens = corporation
            @log << "#{corporation.name} (#{acting_for_entity(corporation).name}) must buy tokens"
            @round.clear_cache!
            return
          end

          raise GameError, 'Player has charter in error' unless @chartered[corporation]

          # chartered company
          charter.owner = nil
          @log << "#{entity.name} has completed obligation for #{corporation.name}"
          entity.companies.delete(charter)

          # assumption: corp defaults to three tokens
          raise GameError, 'Wrong number of tokens for Chartered Company' if corporation.tokens.size != 3

          @log << "#{corporation.name} buys 3 tokens for #{format_currency(CHARTERED_TOKEN_COST * 3)}"
          corporation.spend(CHARTERED_TOKEN_COST * 3, @bank)
        end

        def convert_to_full!(corporation)
          corporation.capitalization = :full
          corporation.always_market_price = false
          corporation.ipo_owner = @bank
          corporation.share_holders.keys.each do |sh|
            next if sh == @bank

            sh.shares_by_corporation[corporation].dup.each { |share| transfer_share(share, @bank) }
          end
        end

        def convert_to_incremental!(corporation)
          corporation.capitalization = :incremental
          corporation.always_market_price = true
          corporation.ipo_owner = corporation
          corporation.share_holders.keys.each do |sh|
            next if sh == corporation

            corporation.share_holders[sh] = 0
            sh.shares_by_corporation[corporation].dup.each do |share|
              share.owner = corporation
              sh.shares_by_corporation[corporation].delete(share)
              corporation.shares_by_corporation[corporation] << share
              corporation.share_holders[corporation] += share.percent
            end
          end
        end

        def london_link?(entity)
          LONDON_TOKEN_HEXES.any? { |hexid| hex_by_id(hexid).tile.cities.any? { |c| c.tokened_by?(entity) } }
        end

        def purchase_tokens!(corporation, count)
          (count - 2).times { corporation.tokens << Token.new(corporation, price: 0) }
          corporation.spend((cost = UNCHARTERED_TOKEN_COST * count), @bank)
          @log << "#{corporation.name} buys #{count} tokens for #{format_currency(cost)}"
        end

        def place_home_token(corporation)
          # If a corp has laid it's first token assume it's their home token
          return if corporation.tokens.first&.used || corporation.receivership?

          hex = hex_by_id(corporation.coordinates)

          tile = hex.tile
          city = tile.cities.first # no OO tiles in 1862
          if city.tokenable?(corporation, free: true)
            # still a slot, use it
            token = corporation.find_token_by_type
            city.place_token(corporation, token)
            remove_marker(corporation)
            graph.clear
            @log << "#{corporation.name} places home token on #{hex.name}"
          elsif upgrade_tokenable?(hex)
            # wait for upgrade
            @log << "#{corporation.name} must upgrade #{hex.name} in order to place home token"
            @round.upgrade_before_token << corporation
            @round.clear_cache!
          else
            # displace existing token
            old_token = city.tokens.last
            old_token.remove!
            new_token = corporation.find_token_by_type
            city.exchange_token(new_token)
            remove_marker(corporation)
            graph.clear
            @log << "#{corporation.name} replaces #{old_token.corporation.name} token on #{hex.name} "\
                    'with home token'
          end
        end

        # Determine if an available legal upgrade for this hex has an additional slot
        # Do this without referencing graph
        #
        def upgrade_tokenable?(hex)
          from = hex.tile

          return false if from.color == :yellow && !@phase.tiles.include?(:green)
          return false if from.color == :green && (from.label.to_s != 'N' || !@phase.tiles.include?(:brown))
          return false if from.color == :brown

          from_exits = from.exits
          legal_exits = Engine::Tile::ALL_EDGES.select { |e| from.hex.neighbors[e] }
          @tiles.any? do |to|
            next unless Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)
            next unless upgrades_to_correct_label?(from, to)

            to_exits = to.exits
            Engine::Tile::ALL_EDGES.any? { |rot| exits_match?(to_exits, rot, from_exits, legal_exits) }
          end
        end

        def exits_match?(exits, rotation, from_exits, legal_exits)
          exits = exits.map { |e| (e + rotation) % 6 }
          from_exits.all? { |e| exits.include?(e) } && # every exit on old tile appears on new tile
            exits.all? { |e| legal_exits.include?(e) } # every exit on new tile is legal
        end

        # OK to start a corp if
        # - there still is a slot available, OR
        # - a legal upgrade has an additional slot
        def legal_to_start?(corporation)
          return false if @lner
          return true if corporation.tokens.first&.used

          hex = hex_by_id(corporation.coordinates)
          city = hex.tile.cities.first
          city.tokenable?(corporation, free: true) || upgrade_tokenable?(hex)
        end

        def base_tile_name(tile)
          return tile.name unless tile.name.include?('_')

          tile.name.slice(0..(tile.name.index('_') - 1))
        end

        def adding_town?(from, to)
          return false if from.towns.empty? || to.towns.empty?
          return false unless base_tile_name(from) == base_tile_name(to)

          to.towns.size == from.towns.size + 1
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if adding_town?(from, to)

          super
        end

        def upgrades_to_correct_label?(from, to)
          (from.label == to.label) ||
            (from.label.to_s == 'N' && to.label.to_s == 'I' && from.hex.id == IPSWITCH_HEX) ||
            (from.label.to_s == 'Y' && to.label.to_s == 'H' && from.hex.id == HARWICH_HEX)
        end

        def active_players
          players_ = @round.active_entities.map(&:player).compact

          players_.empty? ? acting_when_empty : players_
        end

        def acting_when_empty
          if (active_entity = @round && @round.active_entities[0])
            [acting_for_entity(active_entity)]
          else
            @players
          end
        end

        # find majority shareholder for receivership corp
        # breaking ties with closest to priority deal
        def acting_for_entity(entity)
          return entity if entity.player?
          return entity.owner if entity.owner&.player?

          @players.max_by { |h| h.shares_of(entity).sum(&:percent) }
        end

        def reorder_players(_order = nil, log_player_order: false)
          @players.rotate!(@players.index(@next_priority))
          @log << if log_player_order
                    "Priority order: #{@players.map(&:name).join(', ')}"
                  else
                    "#{@players.first.name} has priority deal"
                  end
        end

        def stock_round
          G1862::Round::Stock.new(self, [
            G1862::Step::BuyTokens,
            G1862::Step::ForcedSales,
            G1862::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G1862::Step::HomeUpgrade,
            G1862::Step::OptionShare,
            G1862::Step::RemoveTokens,
            G1862::Step::Merge,
            G1862::Step::Track,
            G1862::Step::Token,
            G1862::Step::Route,
            G1862::Step::Dividend,
            G1862::Step::BuyTrain,
            G1862::Step::RedeemShare,
            G1862::Step::Acquire,
          ], round_num: round_num)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: true)
        end

        def init_round
          @log << '-- Initial Parliament Round -- '
          new_parliament_round
        end

        def new_stock_round
          @next_priority = nil
          super
        end

        def new_parliament_round
          @log << "-- Parliament Round #{@turn} -- " unless @double_parliament
          G1862::Round::Parliament.new(self, [
            G1862::Step::CharterAuction,
          ])
        end

        def next_round!
          @skip_round.clear
          @round =
            case @round
            when G1862::Round::Parliament
              if @double_parliament
                @double_parliament = false
                clear_programmed_actions
                new_parliament_round
              else
                clear_programmed_actions
                new_stock_round
              end
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                if @lner_triggered
                  @lner_triggered = false
                  form_lner
                  new_stock_round
                else
                  new_parliament_round
                end
              end
            when init_round.class
              init_round_finished
              new_stock_round
            end
        end

        def form_lner
          @log << '-- LNER Formed --'

          @cert_limit = @players.map { |p| p.shares.sum(&:percent) }.max / 10
          @log << "-- Certificate limit is now #{@cert_limit} per player --"

          # move all IPO stock to market
          @corporations.each do |corp|
            if @chartered[corp] && !(ipo_shares = corp.ipo_shares).empty?
              ipo_shares.each { |s| transfer_share(s, @share_pool) }
              @log << "Moved #{ipo_shares.size} shares from #{corp.name} IPO to market"
            end
          end

          # remove any non-ipoed corps
          @corporations.reject(&:ipoed).dup.each { |c| remove_corporation!(c) }

          @lner = true
        end

        def event_lner_trigger!
          @lner_triggered = true
          @log << 'LNER will form at end of current OR set'
        end

        # overridden to change bank condition
        def game_end_check
          triggers = {
            bankrupt: bankruptcy_limit_reached?,
            bank: @bank.broken? && !@lner,
            stock_market: @stock_market.max_reached?,
            final_train: @depot.empty?,
            final_phase: @phase.phases.last == @phase.current,
            custom: custom_end_game_reached?,
          }.select { |_, t| t }

          %i[immediate current_round current_or full_or one_more_full_or_set].each do |after|
            triggers.keys.each do |reason|
              if game_end_check_values[reason] == after
                @final_turn ||= @turn + 1 if after == :one_more_full_or_set
                return [reason, after]
              end
            end
          end

          nil
        end

        def custom_end_game_reached?
          @lner
        end

        def enter_bankruptcy!(corp)
          @log << "#{corp.name} enters Bankruptcy"

          # compensate former owners of shares if share price is not zero
          share_value = effective_price(corp)
          corp.share_holders.keys.each do |share_holder|
            next unless share_holder.player?

            percent = share_holder.shares_of(corp).sum(&:percent)
            total = share_value * percent / 10
            if total.positive?
              @bank.spend(total, share_holder)
              @log << "#{share_holder.name} receives #{format_currency(total)} for shares"
            end
          end

          # move cash to bank
          corp.spend(corp.cash, @bank) if corp.cash.positive?

          # remove tokens from map
          corp.tokens.each(&:remove!)

          # make it available to restart
          restart_corporation!(corp)

          @skip_round[corp] = true

          # disable auto-actions if this was in a stock round
          clear_programmed_actions if @round.stock?
        end

        def status_array(corp)
          start_phase = @starting_phase[corp]
          status = []
          status << %w[Receivership bold] if corp.receivership?
          status << %w[Chartered bold] if @chartered[corp]
          status << ["Par: #{format_currency(corp.original_par_price.price)}"] if corp.ipoed
          status << ["Phase available: #{start_phase}"] if !@phase.available?(start_phase) && !corp.ipoed
          status << ['Cannot start'] if @phase.available?(start_phase) && !legal_to_start?(corp) && !corp.ipoed
          status << ["Permits: #{@permits[corp].map(&:to_s).join(',')}"]
          status
        end

        def sorted_corporations
          ipoed, others = corporations.partition(&:ipoed)
          ipoed.sort + others.sort.sort_by { |c| @starting_phase[c] }
        end

        def ipo_name(entity = nil)
          if entity&.capitalization == :incremental
            'Treasury'
          else
            'IPO'
          end
        end

        def bank_sort(corporations)
          corporations.sort.sort_by { |c| @starting_phase[c] }
        end

        def check_bankruptcy!(entity)
          return unless entity.corporation?

          enter_bankruptcy!(entity) if entity.share_price&.type == :close
        end

        def corporation_available?(entity)
          entity.corporation? && ready_corporations.include?(entity)
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] if entity.receivership?

          shares = @share_pool.shares_by_corporation[entity].take(1)
          return [] if shares.empty?

          [Engine::ShareBundle.new(shares)]
        end

        def selling_movement?(corporation)
          corporation.floated? && !@lner
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          corporation = bundle.corporation
          old_price = corporation.share_price
          president_selling = (bundle.owner == corporation.owner)

          @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
          num_shares = bundle.num_shares
          unless president_selling
            num_shares -= 1 if corporation.share_price.type == :ignore_one_sale
            num_shares -= 2 if corporation.share_price.type == :ignore_two_sales
          end
          num_shares.times { @stock_market.move_down(corporation) } if selling_movement?(corporation)
          log_share_price(corporation, old_price)
          check_bankruptcy!(corporation)
        end

        def train_type_by_name(name)
          case name
          when /F\**$/
            :freight
          when /L\**$/
            :local
          when /E\**$/
            :express
          end
        end

        def train_type(train)
          train_type_by_name(train.name)
        end

        def legal_route?(entity)
          @graph.route_info(entity)&.dig(:route_train_purchase)
        end

        def able_to_operate?(entity, _train, name)
          @permits[entity].include?(train_type_by_name(name))
        end

        def route_trains(entity)
          entity.runnable_trains.select { |t| @permits[entity].include?(train_type(t)) }
        end

        def get_token_cities(corporation)
          tokens = []
          hexes.each do |hex|
            hex.tile.cities.each do |city|
              next unless city.tokened_by?(corporation)

              tokens << city
            end
          end
          tokens
        end

        # at least one route must include home token
        def check_home_token(corporation, routes)
          tokens = get_token_cities(corporation)
          home_city = tokens.find { |c| c.hex == hex_by_id(corporation.coordinates) }
          found = false
          routes.each { |r| found ||= r.visited_stops.include?(home_city) } if home_city
          raise GameError, 'At least one route must include home token' unless found
        end

        def visit_route(ridx, intersects, visited)
          return if visited[ridx]

          visited[ridx] = true
          intersects[ridx].each { |i| visit_route(i, intersects, visited) }
        end

        # all routes must intersect each other
        def check_intersection(routes)
          actual_routes = routes.reject { |r| r.chains.empty? }

          # build a map of which routes intersect with each route
          intersects = Hash.new { |h, k| h[k] = [] }
          actual_routes.each_with_index do |r, ir|
            actual_routes.each_with_index do |s, is|
              next if ir == is

              intersects[ir] << is if (r.visited_stops & s.visited_stops).any?
            end
            intersects[ir].uniq!
          end

          # starting with the first route, make sure every route can be visited
          visited = {}
          visit_route(0, intersects, visited)

          raise GameError, 'Routes must intersect with each other' if visited.size != actual_routes.size
        end

        def mn_train?(train)
          return false if train_type(train) == :freight

          train.distance[0]['pay'] != train.distance[0]['visit']
        end

        def freight_revenue_stops(route, visits)
          route_set = freight_sets(route.routes).find { |set| set.include?(route) }
          freight_set_ends(route_set) & [visits.first, visits.last]
        end

        # returns list of combinations of stops
        def revenue_stop_options(route)
          visits = route.visited_stops

          if train_type(route.train) == :freight
            [freight_revenue_stops(route, visits)]
          else
            # OK, since local trains won't have offboards
            all_stops = visits.select { |n| n.city? || n.offboard? }
            stop_options = []
            length = [all_stops.size, route.train.distance[0]['pay']].min
            all_stops.combination(length) { |c| stop_options << c }
            stop_options = [[]] if stop_options.empty?
            stop_options
          end
        end

        def game_route_revenue(stop, phase, train)
          return 0 unless stop

          if stop.offboard?
            stop.revenue[REAL_PHASE_TO_REV_PHASE[phase.name]]
          else
            stop.route_revenue(phase, train)
          end
        end

        def stop_revenues(stops, route)
          stops.sum { |stop| game_route_revenue(stop, route.phase, route.train) }
        end

        # Brute force it. Theoretical max combos is 729, but realistic max is order of magnitude lower
        def global_optimize(routes)
          return [] if routes.empty?

          route_stops = routes.map { |r| revenue_stop_options(r) }
          possibilities = if routes.one?
                            route_stops[0].product
                          else
                            route_stops[0].product(*route_stops[1..-1])
                          end
          max_rev = -1
          max_stops = nil
          possibilities.each do |p|
            rev = stop_revenues(p.flatten.uniq, routes[0]) # any route will do here
            if rev > max_rev && rev.positive?
              max_rev = rev
              max_stops = p
            end
          end
          max_stops
        end

        def optimize_stops(route, _num_pay, _total_stops)
          return [] if route.routes.empty?

          @global_stops ||= global_optimize(route.routes)
          @global_stops[route.routes.index(route)]
        end

        def compute_local_stops(route, visits)
          if mn_train?(route.train)
            towns = visits.select(&:town?)
            optimize_stops(route) + towns
          else
            visits
          end
        end

        def compute_express_stops(route, visits)
          if mn_train?(route.train)
            optimize_stops(route)
          else
            visits.select { |n| n.city? || n.offboard? }
          end
        end

        def compute_stops(route)
          @cached_freight_sets = nil
          @global_stops = nil
          visits = route.visited_stops
          case train_type(route.train)
          when :local
            compute_local_stops(route, visits)
          when :express
            compute_express_stops(route, visits)
          else
            freight_revenue_stops(route, visits)
          end
        end

        # FIXME: take options into account
        def nonpermanent_freight?(train)
          train.distance < 6
        end

        # given a route, and a list of available stops,
        # recursively find a set of other routes that connect to it end-to-end
        # when faced with a branch, choose:
        # 1. the branch containing non-permanent trains, then
        # 2. the longest branch
        #
        def get_set_node(node, route, stops)
          return [] unless stops

          stops.delete(route)
          return [] if stops.empty? # no stops left, we're done

          routes = stops.keys.select { |r| stops[r].include?(node) }
          if routes.size == 1
            # no branching, continue recursing
            create_oneway_set(node, routes[0], [routes[0]], stops)
          elsif routes.size > 1
            # branching, recurse on all branches and pick
            branches = []
            routes.each do |r|
              new_stops = stops.dup
              branches << create_oneway_set(node, r, [], new_stops)
            end
            branch = if (nonperm_set = branches.find { |s| s.any? { |r| nonpermanent_freight?(r.train) } })
                       nonperm_set
                     else
                       branches.max_by(&:size)
                     end
            branch.each { |r| stops.delete(r) }
          else
            # no other routes match, we're done
            []
          end
        end

        def create_oneway_set(visited, route, set, stops)
          set << route
          end_a = stops[route].first
          end_b = stops[route].last
          set.concat(get_set_node(end_a, route, stops)) if end_a != visited
          set.concat(get_set_node(end_b, route, stops)) if end_b != visited
          set.compact.uniq
        end

        def create_set(route, set, stops)
          set << route
          end_a = stops[route].first
          end_b = stops[route].last
          set.concat(get_set_node(end_a, route, stops))
          set.concat(get_set_node(end_b, route, stops))
          set.compact.uniq
        end

        def freight_sets(routes)
          @cached_freight_sets ||= build_freight_sets(routes)
        end

        # return sets of end-to-end connected freight trains
        def build_freight_sets(routes)
          stops = {}
          routes.select { |r| train_type(r.train) == :freight && !r.chains.empty? }.each do |r|
            visits = r.visited_stops
            stops[r] = [visits.first, visits.last]
          end

          set_list = []
          # always start with non-perm trains
          if (first_nonperm = stops.keys.find { |r| nonpermanent_freight?(r.train) })
            set_list << create_set(first_nonperm, [], stops)
          end

          # continue to find sets
          set_list << create_set(stops.keys.first, [], stops) until stops.empty?
          set_list
        end

        # given a set of routes that connect end-to-end
        # find the start and stop
        def freight_set_ends(set)
          return [] unless set

          ends = []
          nodes = Hash.new { |h, k| h[k] = [] }
          set.each do |r|
            visits = r.visited_stops
            nodes[visits.first] << r
            nodes[visits.last] << r
          end
          nodes.keys.each { |n| ends << n if nodes[n].one? }
          raise GameError, 'Logic error: freight set with only one end' if ends.one?

          # if no ends, we have a loop: pick first node
          # FIXME: pick the highest revenue node? Pathological case.
          ends = [nodes.keys.first, nodes.keys.first] if ends.empty?
          ends
        end

        # Every non-permanent freight train needs to share it's start and/or end
        # with another non-permanent freight trains and one permanent freight
        # train if it exists
        def check_freight_intersections(routes)
          @cached_freight_sets = nil
          freight_sets = freight_sets(routes)
          # only one set can have non-perms
          if freight_sets.count { |set| set.any? { |r| nonpermanent_freight?(r.train) } } > 1
            raise GameError, 'All non-permanent freight trains need to connect end-to-end'
          end
          # if a set has non-perms, it either must have perms too, or be the only set
          if (nonperm_set = freight_sets.find { |set| set.any? { |r| nonpermanent_freight?(r.train) } }) &&
              nonperm_set.all? { |r| nonpermanent_freight?(r.train) } &&
              freight_sets.size > 1
            raise GameError, 'Non-permanent freight trains must connect to permanent trains'
          end
        end

        # Can reuse track between routes, but not within a route, so this method
        # doesn't check track reuse, but instead checks:
        # - home token requirement
        # - route intersection requirement
        # - freight track end-to-end requirements
        def check_overlap(routes)
          return if routes.empty?

          check_home_token(current_entity, routes)
          check_intersection(routes)
          check_freight_intersections(routes)
        end

        # This checks track reuse within a route
        def check_overlap_single(route)
          tracks = []

          route.paths.each do |path|
            a = path.a
            b = path.b

            tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
            tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?

            # check track between edges and towns not in center
            # (essentially, that town needs to act like an edge for this purpose)
            if b.edge? && a.town? && (nedge = a.tile.preferred_city_town_edges[a]) && nedge != b.num
              tracks << [path.hex, a, path.lanes[0][1]]
            end
            if a.edge? && b.town? && (nedge = b.tile.preferred_city_town_edges[b]) && nedge != a.num
              tracks << [path.hex, b, path.lanes[1][1]]
            end
          end

          tracks.group_by(&:itself).each do |k, v|
            raise GameError, "Route cannot reuse track on #{k[0].id}" if v.size > 1
          end
        end

        def route_distance(route)
          case train_type(route.train)
          when :local
            "#{route.visited_stops.count(&:city?)}+#{route.visited_stops.count(&:town?)}"
          when :express
            route.visited_stops.count { |n| n.city? || n.offboard? }
          else
            hex_route_distance(route)
          end
        end

        def london_hex?(stop)
          @london_nodes.include?(stop)
        end

        def check_london(visits)
          return if !london_hex?(visits.first) && !london_hex?(visits.last)

          raise GameError, 'Train cannot visit London w/o link' unless london_link?(current_entity)
        end

        def hex_route_distance(route)
          route.chains.sum do |conn|
            conn[:paths].each_cons(2).sum do |a, b|
              a.hex == b.hex ? 0 : 1
            end
          end
        end

        def check_distance(route, visits)
          raise GameError, 'Route cannot begin/end in a town' if visits.first.town? || visits.last.town?
          # could let super handle this, but this is a better error message
          raise GameError, 'Local train cannot visit an offboard' if train_type(route.train) == :local && visits.any?(&:offboard?)
          if (visits.first.tile.color == :red && visits.last.tile.color == :red) ||
            (visits.first.tile.color == :blue && visits.last.tile.color == :blue)
            raise GameError, 'Route cannot visit two red offboards or two ports'
          end

          check_london(visits)

          return super if train_type(route.train) != :freight
          return if route.train.distance >= (distance = hex_route_distance(route))

          raise GameError, "#{distance} is too many hexes for a #{route.train.name} train"
        end

        def check_other(route)
          check_overlap_single(route)
        end

        def stop_on_other_route?(this_route, stop)
          this_route.routes.each do |r|
            return false if r == this_route

            other_stops = r.stops
            return true if other_stops.include?(stop)
            return true unless (other_stops.flat_map(&:groups) & stop.groups).empty?
          end
          false
        end

        # adjust end of set of routes to neighbor node if end is an offboard
        # always returns hex of end
        def adjust_end(set, setend)
          return setend.hex unless setend.offboard?

          # find route in set that has this end
          end_route = set.find { |r| r.visited_stops.include?(setend) }
          # find chain in route that has this end
          end_chain = end_route.chains.find { |c| c[:nodes].include?(setend) }
          # return previous hex in chain
          end_chain[:hexes][0] == setend.hex ? end_chain[:hexes][1] : end_chain[:hexes][-2]
        end

        # from https://www.redblobgames.com/grids/hexagons
        def doubleheight_coordinates(hex)
          [hex.id[0].ord - 'A'.ord, hex.id[1..-1].to_i]
        end

        # given a freight route set, find number of intervening hexes
        # between ends. If an end is an offboard, calculate distance as if end
        # is last hex before offboard and add 1
        def hex_crow_distance(set, setend_a, setend_b)
          hex_a = adjust_end(set, setend_a)
          hex_b = adjust_end(set, setend_b)

          x_a, y_a = doubleheight_coordinates(hex_a)
          x_b, y_b = doubleheight_coordinates(hex_b)

          # from https://www.redblobgames.com/grids/hexagons#distances
          # this game essentially uses double-height coordinates
          dx = (x_a - x_b).abs
          dy = (y_a - y_b).abs
          distance = hex_a == hex_b ? -1 : [0, dx + [0, (dy - dx) / 2].max - 1].max

          # adjust for offboards
          distance += 1 if hex_a != setend_a.hex
          distance += 1 if hex_b != setend_b.hex

          [0, distance].max
        end

        def freight_bonus(set)
          if freight_set_ends(set).any? { |n| n.tile.color == :blue }
            PORT_FREIGHT_BONUS
          else
            FREIGHT_BONUS
          end
        end

        # freight trains only count set ends, but add in hex distance bonus - allocate to first train in set
        def freight_revenue(route, stops)
          return 0 if route.chains.empty?

          route_set = freight_sets(route.routes).find { |set| set.include?(route) }
          ends = (set_ends = freight_set_ends(route_set)) & stops
          rev = 0
          unless ends.empty?
            rev = ends.sum do |stop|
              stop_on_other_route?(route, stop) ? 0 : game_route_revenue(stop, route.phase, route.train)
            end
          end
          return rev unless route == route_set&.first

          rev + (hex_crow_distance(route_set, set_ends.first, set_ends.last) * freight_bonus(route_set))
        end

        # only count revenue locations once
        def revenue_for(route, stops)
          return freight_revenue(route, stops) if train_type(route.train) == :freight

          stops.sum do |stop|
            stop_on_other_route?(route, stop) ? 0 : game_route_revenue(stop, route.phase, route.train)
          end
        end

        def hex_on_other_route?(this_route, hex)
          this_route.routes.each do |r|
            return false if r == this_route
            next unless train_type(r.train) == :local

            return true if r.all_hexes.include?(hex)
          end
          false
        end

        def subsidy_for(route, _stops)
          return 0 unless train_type(route.train) == :local

          route.all_hexes.count { |h| !hex_on_other_route?(route, h) } * 10
        end

        def routes_subsidy(routes)
          routes.sum(&:subsidy)
        end

        # find which stop was left out of an M/N train route
        def missing_stop(route)
          @global_stops ||= global_optimize(route.routes)

          used_stops = @global_stops[route.routes.index(route)]
          all_stops = route.visited_stops.select { |n| n.city? || n.offboard? }
          (all_stops - used_stops).first if all_stops != used_stops
        end

        def revenue_str(route)
          if mn_train?(route.train)
            route.hexes.map do |h|
              if missing_stop(route)&.hex == h
                "[#{h.name}]"
              else
                h.name
              end
            end.join('-')
          else
            route.hexes.map(&:name).join('-')
          end
        end

        # routes from different trains are allowed to overlap
        def compute_other_paths(_routes, _route)
          []
        end

        def train_limit(entity)
          @phase.train_limit(entity) * (@phase.available?('G') ? 1 : 3)
        end

        def train_limit_by_type(entity)
          @phase.train_limit(entity)
        end

        def used_train_price(train)
          train.sym == @phase.name ? train.price : (train.price / 2).to_i
        end

        def info_train_name(train)
          train.sym + ': ' + train.names_to_prices.keys.reject { |n| n == train.sym }.join(', ')
        end

        def info_train_price(train)
          format_currency(train.names_to_prices.values[0])
        end

        def rust?(train, purchased_train)
          train.rusts_on == purchased_train.sym
        end

        def rust_trains!(train, _entity)
          rusted_trains = []
          owners = Hash.new(0)

          trains.each do |t|
            next if @deferred_rust.include?(t) || !t.name.include?('*') || t.rusts_on != train.sym

            @deferred_rust << t
          end

          trains.each do |t|
            next if t.rusted || @deferred_rust.include?(t)
            next unless rust?(t, train)

            rusted_trains << t.name
            owners[t.owner.name] += 1
            rust(t)
          end

          @crowded_corps = nil

          return unless rusted_trains.any?

          @log << "-- Event: #{rusted_trains.uniq.join(', ')} trains rust " \
                  "( #{owners.map { |c, t| "#{c} x#{t}" }.join(', ')}) --"
        end

        def highlight_token?(token)
          return false unless token
          return false unless token.corporation

          corporation = token.corporation
          corporation.tokens.find_index(token).zero?
        end

        def must_buy_train?(entity)
          entity.trains.empty?
        end

        # Sell treasury stock to raise money
        def raise_money!(entity, amount)
          num_shares = (amount.to_f / entity.share_price.price).ceil
          shares = entity.shares.take(num_shares)
          bundle = ShareBundle.new(shares)
          @share_pool.sell_shares(bundle)
          old_price = entity.share_price
          num_shares.times { @stock_market.move_down(entity) }
          log_share_price(entity, old_price)
          check_bankruptcy!(entity)
        end

        # Refinance via merger algorithm
        def refinance!(entity)
          start_merge(entity, entity, nil, :refinance)
        end

        def share_holder_list(originator, corps)
          plist = @players.rotate(@players.index(originator.owner)).select do |p|
            corps.any? do |c|
              !p.shares_of(c).empty?
            end
          end
          plist + [originator]
        end

        def effective_price(corporation)
          corporation.trains.empty? ? (corporation.share_price.price / 2).to_i : corporation.share_price.price
        end

        def find_valid_par_price(price)
          min_par = @stock_market.par_prices.min_by(&:price)
          return min_par if price < min_par.price # rules white space

          @stock_market.par_prices.max_by { |p| p.price <= price ? p.price : 0 }
        end

        def find_valid_share_price(price)
          # only works with 1D market
          @stock_market.market.first.max_by { |p| p.price <= price ? p.price : 0 }
        end

        def compute_merger_share_price(corp_a, corp_b)
          prices = [effective_price(corp_a), effective_price(corp_b)].sort
          find_valid_share_price(prices.first + (prices.last / 2.0))
        end

        # just a basic share move without payment or president change
        #
        def transfer_share(share, new_owner)
          corp = share.corporation
          corp.share_holders[share.owner] -= share.percent
          corp.share_holders[new_owner] += share.percent
          share.owner.shares_by_corporation[corp].delete(share)
          new_owner.shares_by_corporation[corp] << share
          share.owner = new_owner
        end

        def start_merge(originator, survivor, nonsurvivor, merge_type)
          corps = merge_type == :refinance ? [survivor] : [survivor, nonsurvivor]
          @merge_data = {
            originator: originator,
            type: merge_type,
            corps: corps,
            holders: share_holder_list(originator, corps),
            stage: nil,
            price: originator.share_price,
            skip: nil,
          }

          # 1. (M/A): Find new share price and par price
          if merge_type != :refinance
            old_price = survivor.share_price
            new_price = compute_merger_share_price(survivor, nonsurvivor)
            new_par_price = find_valid_par_price(new_price.price)
            @log << "New share price: #{format_currency(new_price.price)} "\
                    "(par: #{format_currency(new_par_price.price)})"
            @merge_data[:price] = new_price
            @merge_data[:par] = new_par_price
            old_price.corporations.delete(survivor)
            new_price.corporations << survivor
            survivor.share_price = new_price
            survivor.par_price = new_par_price
            survivor.original_par_price = new_par_price
          end

          # 2. move any chartered IPO shares to market
          corps.each do |corp|
            if @chartered[corp] && !(ipo_shares = corp.ipo_shares).empty?
              ipo_shares.each { |s| transfer_share(s, @share_pool) }
              @log << "Moved #{ipo_shares.size} shares from #{corp.name} IPO to market"
            end
          end

          # 3. move all treasury shares to originator
          corps.each do |corp|
            next if corp == originator

            corp.shares_of(corp).dup.each { |s| transfer_share(s, originator) }
          end

          # 4. return half of shares, possibly offer to redeem or sell options (half-shares)
          return if @merge_data[:holders].any? { |holder| return_half_and_swap(holder) }

          merge_post_shares # no need to ask player
        end

        # called by step after player makes choice about option
        def continue_merge_option(entity)
          remaining_holders = @merge_data[:holders][(@merge_data[:holders].index(entity) + 1)..-1]
          return if remaining_holders.any? { |holder| return_half_and_swap(holder) }

          merge_post_shares # no need to ask player
        end

        # always return survivor shares first and director's first within those
        def affected_shares(entity, corps)
          affected = entity.shares.select { |s| s.corporation == corps.first }.sort_by(&:percent).reverse
          affected.concat(entity.shares.select { |s| s.corporation == corps.last }.sort_by(&:percent).reverse) unless corps.one?
          affected
        end

        # reorder shares
        # 1. nonsurviving director cert
        # 2. nonsurviving plain certs
        # 3. surviving plain certs
        # 4. surviving director cert
        def reorder_shares(shares, corps)
          if corps.one?
            shares.select { |s| s.corporation == corps.first }.sort_by(&:percent)
          else
            shares.select { |s| s.corporation == corps.last }.sort_by(&:percent).reverse +
              shares.select { |s| s.corporation == corps.first }.sort_by(&:percent)
          end
        end

        # look for next entity that has needed share
        def find_donor_share(entity, corp, holders, percent)
          return @share_pool.shares_of(corp).find { |s| s.percent == percent } if entity.corporation?

          donors = [@share_pool] + holders[(holders.find_index(entity) + 1)..-1]

          donors.each do |holder|
            match = holder.shares_of(corp).find { |s| s.percent == percent }
            return match if match
          end
          nil
        end

        # called only once per entity
        def return_half_and_swap(entity)
          #
          # Deal with directors with less than 60% across affected corps
          #
          entity_shares = affected_shares(entity, @merge_data[:corps])
          pres_option_percent = nil
          odd_share = nil

          if entity_shares.any?(&:president) && entity_shares.sum(&:percent) < 60
            # we know entity is only director of one corp
            # try to swap director cert for 3 normal certs from market
            pres_share = entity_shares.find(&:president)
            swap_corp = pres_share.corporation
            market_plain_shares = affected_shares(@share_pool, @merge_data[:corps]).reject(&:president)

            if market_plain_shares.sum(&:percent) >= 30
              # market has enough shares: swap pres cert for 3 plain ones (of either corp)
              #
              market_plain_shares.take(3).each { |s| transfer_share(s, entity) }
              transfer_share(pres_share, @share_pool)
              entity_shares = affected_shares(entity, @merge_data[:corps]) # recalculate
              @log << "#{entity.name} swaps #{swap_corp.name} director's certificate for 3 shares"
            else
              # not enough in market: move non-president shares to market and mark as an option
              #
              pres_option_percent = entity_shares.sum(&:percent)
              odd_share = pres_share
              plain_shares = entity_shares.reject(&:president)
              plain_shares.each { |s| transfer_share(s, @share_pool) }
              @log << "#{entity.name} cannot return #{swap_corp.name} director's certificate to market. "\
                      "#{entity.name} moves #{plain_shares.size} normal shares to market and director's certificate "\
                      'will be used as an option certificate.'
            end
          end

          #
          # return half of remaining shares starting with nonsurviving company
          #
          unless pres_option_percent
            total_percent = entity_shares.sum(&:percent)
            return_percent = (total_percent / 20).to_i * 10
            reordered = reorder_shares(entity_shares, @merge_data[:corps])
            returned = 0
            while returned < return_percent
              share = reordered.shift
              returned += share.percent
              @log << "#{entity.name} returns a #{share.percent}% share of #{share.corporation.name} to the market"
              transfer_share(share, @share_pool)

              if share.president && share.corporation == @merge_data[:corps].first
                raise GameError, 'returning incorrect presidents share'
              end
            end
            odd_share = total_percent != return_percent * 2 && reordered.first
          end

          #
          # swap remaining nonsurvivor shares for survivor shares if possible
          # otherwise must sell
          #
          if @merge_data[:type] != :refinance && pres_option_percent && swap_corp == @merge_data[:corps].last

            # Handle president share option specially
            #
            # try to swap. If not possible, sell
            old_share = entity_shares.find(&:president)
            if (swap_share = find_donor_share(entity, @merge_data[:corps].first, @merge_data[:holders], 30))
              donor = swap_share.owner
              transfer_share(old_share, donor)
              transfer_share(swap_share, entity)
              odd_share = swap_share
              @log << "#{entity.name} swaps director's certificate with #{donor.name}"
            else
              price = case pres_option_percent
                      when 50
                        @merge_data[:price].price * 2.5
                      when 40
                        @merge_data[:price].price * 2
                      else
                        @merge_data[:price].price * 1.5
                      end.to_i
              transfer_share(old_share, @share_pool)
              @bank.spend(price, entity)
              @log << "#{entity.name} unable to trade for #{@merge_data[:corps].first.name} director certificate."
              @log << "#{entity.name} sells non-survivor director certificate option for #{format_currency(price)}"
              odd_share = nil
            end
          elsif @merge_data[:type] != :refinance && !pres_option_percent &&
            !(old_shares = reordered.reverse.select { |s| s.corporation == @merge_data[:corps].last }).empty?

            # normal shares and options
            #
            # try to swap. If not possible, sell
            #
            old_shares.each do |os|
              raise GameError, 'Found pres share when swapping' if os.percent != 10

              if (swap_share = find_donor_share(entity, @merge_data[:corps].first, @merge_data[:holders], 10))
                donor = swap_share.owner
                transfer_share(os, donor)
                transfer_share(swap_share, entity)
                @log << "#{entity.name} swaps a #{@merge_data[:corps].last.name} share for a "\
                        "#{@merge_data[:corps].first.name} share from #{donor.name}"
                odd_share = swap_share if os == odd_share
              else
                price = (os == odd_share ? @merge_data[:price].price / 2 : @merge_data[:price].price).to_i
                transfer_share(os, @share_pool)
                @bank.spend(price, entity)
                @log << "#{entity.name} unable to trade for #{@merge_data[:corps].first.name} share."
                if os == odd_share
                  @log << "#{entity.name} sells non-survivor option share for #{format_currency(price)}"
                  odd_share = nil
                else
                  @log << "#{entity.name} sells non-survivor share for #{format_currency(price)}"
                end
              end
            end
          end

          #
          # Deal with option (odd) share or option president cert
          #
          # if they can pay, will ask player
          #
          if odd_share
            if @merge_data[:type] != :refinance && odd_share.corporation == @merge_data[:corps].last
              raise GameError, "Odd share is of non-survivor #{odd_share.corporation}"
            end

            if pres_option_percent
              sell_price = (@merge_data[:corps].first.share_price.price * pres_option_percent / 20).to_i
              redeem_price = (@merge_data[:corps].first.share_price.price * (60 - pres_option_percent) / 20).to_i
              percent = pres_option_percent
            else
              sell_price = (@merge_data[:corps].first.share_price.price / 2).to_i
              redeem_price = sell_price
              percent = 10
            end

            # only ask if they can afford to buy
            #
            if @merge_data[:originator] == entity && @merge_data[:type] != :refinance
              # need to use combined cash for corps
              other = @merge_data[:corps].find { |c| c != entity }
              other.spend(other.cash, entity) if other.cash.positive?
            end
            if entity.cash >= redeem_price
              @round.pending_options << {
                entity: entity,
                share: odd_share,
                percent: percent,
                sell_price: sell_price,
                redeem_price: redeem_price,
              }
              return true
            end

            # otherwise, sell
            #
            @bank.spend(sell_price, entity)
            transfer_share(odd_share, @share_pool)
            @log << "#{entity.name} must sell #{percent}% option share for #{format_currency(sell_price)}"
          end
          false
        end

        def merge_sanity_check
          # 100% of non-survivor shares should be in market
          if @merge_data[:type] != :refinance && @share_pool.shares_of(@merge_data[:corps].last).sum(&:percent) != 100
            raise GameError, "market shares of #{@merge_data[:corps].last.name} not 100%"
          end
          # survivor shares should total 100%
          return unless @merge_data[:corps].first.share_holders.values.sum != 100

          raise GameError, "total shares of #{@merge_data[:corps].first.name} not 100%"
        end

        def transfer_pres_share(corporation, owner)
          return if owner.shares_of(corporation).any?(&:president)

          pres_share = corporation.presidents_share
          owner.shares_of(corporation).take(3).each { |s| transfer_share(s, pres_share.owner) }
          transfer_share(pres_share, owner)
        end

        def adjust_president(corporation, holders)
          old_owner = corporation.owner
          majority_holder = holders.reject(&:corporation?).max_by { |h| h.shares_of(corporation).sum(&:percent) }
          majority_amount = majority_holder.shares_of(corporation).sum(&:percent)

          if majority_amount >= 30 && old_owner == majority_holder
            @log << "#{old_owner.name} retains presidency of #{corporation.name}"
            transfer_pres_share(corporation, old_owner)
          elsif majority_amount >= 30
            @log << "#{majority_holder.name} becomes new president of #{corporation.name}"
            transfer_pres_share(corporation, majority_holder)
            corporation.owner = majority_holder
          else
            @log << "#{corporation.name} has no president and enters receivership"
            corporation.owner = @share_pool
          end
        end

        def move_assets(survivor, nonsurvivor)
          # stocks
          nonsurvivor.shares_of(survivor).dup.each { |s| transfer_share(s, survivor) }
          # cash
          nonsurvivor.spend(nonsurvivor.cash, survivor) if nonsurvivor.cash.positive?
          # trains
          nonsurvivor.trains.each { |t| t.owner = survivor }
          survivor.trains.concat(nonsurvivor.trains)
          nonsurvivor.trains.clear
          survivor.trains.each { |t| t.operated = false }
          # permits
          @permits[survivor].concat(@permits[nonsurvivor])
          @permits[survivor].uniq!
          @permits[nonsurvivor] = @original_permits[nonsurvivor].dup
          # charter flag (keeping survivor chartered appears to only be needed for solo game)
          if @chartered[survivor] && !@chartered[nonsurvivor]
            # no shares can be in IPO, but doing this for consistancy (non-chartered => incremental)
            survivor.capitalization = :incremental
            survivor.always_market_price = true
            survivor.ipo_owner = survivor
          end
          @chartered.delete(survivor) unless @chartered[nonsurvivor]
          @chartered.delete(nonsurvivor)
          @log << "Moved assets from #{nonsurvivor.name} to #{survivor.name}"
        end

        def adjust_round_entities(originator, survivor, nonsurvivor)
          s_index = @round.entities.find_index(survivor)
          ns_index = @round.entities.find_index(nonsurvivor)

          if originator == survivor && ns_index > s_index
            # Non-survivor hasn't run yet.
            # Remove it.
            @round.entities.delete(nonsurvivor)
          elsif originator == survivor && ns_index < s_index
            # Non-survivor has run.
            # Maker sure survivor ends turn
            @merge_data[:skip] = true
          elsif originator == nonsurvivor && ns_index > s_index
            # Survivor has run
            # make sure survivor ends turn
            @merge_data[:skip] = true
            # overwrite this spot with survivor
            @round.entities[ns_index] = survivor
          else
            # Survivor hasn't run
            # overwrite this spot with survivor
            @round.entities[ns_index] = survivor
            # delete old survivor spot
            @round.entities.delete_at(s_index)
          end
        end

        def merge_post_shares
          merge_sanity_check
          adjust_president(@merge_data[:corps].first, @merge_data[:holders])

          if @merge_data[:type] == :refinance
            @bank.spend((payment = @merge_data[:corps].first.original_par_price.price * 10), @merge_data[:corps].first)
            @log << "#{@merge_data[:corps].first.name} is reorganized and receives #{format_currency(payment)}"
            return
          end

          move_assets(@merge_data[:corps].first, @merge_data[:corps].last)
          adjust_round_entities(@merge_data[:originator], @merge_data[:corps].first, @merge_data[:corps].last)

          finish_merge unless move_tokens
        end

        def remove_colocated_tokens(survivor, nonsurvivor)
          @hexes.each do |hex|
            hex.tile.cities.each do |city|
              next if !(city.tokened_by?(survivor) && city.tokened_by?(nonsurvivor)) &&
                  !(city.tokened_by?(nonsurvivor) && london_link?(survivor) && LONDON_TOKEN_HEXES.include?(hex.id))

              token = city.tokens.find { |t| t&.corporation == nonsurvivor }
              token.destroy!
              @log << "Removed co-located #{nonsurvivor.name} token in #{hex.id} (#{hex.location_name})"
            end
          end
        end

        def merge_hex_list(corps)
          corps.first.placed_tokens.reject { |t| t.city.hex.id == corps.first.coordinates }.map { |t| t.city.hex } +
            corps.last.placed_tokens.map { |t| t.city.hex }
        end

        def move_tokens
          # first completely delete non-survivor tokens co-located with survivor tokens
          remove_colocated_tokens(@merge_data[:corps].first, @merge_data[:corps].last)

          s_placed = @merge_data[:corps].first.placed_tokens.size
          ns_placed = @merge_data[:corps].last.placed_tokens.size

          if s_placed + ns_placed > max_tokens
            # player needs to remove excess tokens
            @round.pending_removals << {
              survivor: @merge_data[:corps].first,
              nonsurvivor: @merge_data[:corps].last,
              count: (s_placed + ns_placed) - max_tokens,
              hexes: merge_hex_list(@merge_data[:corps]),
            }
            return true
          end
          nil
        end

        def swap_token(survivor, nonsurvivor, old_token)
          new_token = survivor.next_token
          city = old_token.city
          @log << "Replaced #{nonsurvivor.name} token in #{city.hex.id} with #{survivor.name} token"
          new_token.place(city)
          city.tokens[city.tokens.find_index(old_token)] = new_token
          nonsurvivor.tokens.delete(old_token)
        end

        def remove_corporation!(corporation)
          @log << "#{corporation.name} cannot be started and is removed from the game"

          remove_marker(corporation)

          corporation.share_holders.keys.each do |share_holder|
            share_holder.shares_by_corporation.delete(corporation)
          end

          @share_pool.shares_by_corporation.delete(corporation)
          corporation.share_price&.corporations&.delete(corporation)
          @corporations.delete(corporation)
        end

        def restart_corporation!(corporation)
          # un-IPO the corporation
          corporation.share_price&.corporations&.delete(corporation)
          corporation.share_price = nil
          corporation.par_price = nil
          corporation.ipoed = false
          corporation.unfloat!
          corporation.owner = nil

          # get back to 3 tokens
          corporation.tokens.clear
          3.times { |_t| corporation.tokens << Token.new(corporation, price: 0) }

          # remove trains
          corporation.trains.clear

          # put marker onto map
          add_marker(corporation)

          # remove charter flag
          @chartered.delete(corporation)

          # restore original permit
          @permits[corporation] = @original_permits[corporation].dup

          convert_to_full!(corporation)

          # re-sort shares
          @bank.shares_by_corporation[corporation].sort_by!(&:id)
        end

        def finish_merge
          survivor, nonsurvivor = @merge_data[:corps]
          s_placed = survivor.placed_tokens
          s_unplaced = survivor.unplaced_tokens
          ns_placed = nonsurvivor.placed_tokens
          ns_unplaced = nonsurvivor.unplaced_tokens

          num_placed = s_placed.size + ns_placed.size
          raise GameError, 'too many placed tokens' if num_placed > max_tokens

          num_unplaced = [max_tokens - num_placed, s_unplaced.size + ns_unplaced.size].min
          total = num_placed + num_unplaced

          # increase survivor tokens if needed
          (total - s_placed.size - s_unplaced.size).times { survivor.tokens << Token.new(survivor, price: 0) }

          # swap the tokens
          ns_placed.each { |t| swap_token(survivor, nonsurvivor, t) }

          # allow the nonsurvivor to restart later
          restart_corporation!(nonsurvivor)

          # finally done with Merge/Acquire step
          @round.active_step&.pass!

          # we mucked around with tokens, clear the graph
          @graph.clear

          # stop survivor from running after merge if
          # other corp already ran or this is an acquisition
          @skip_round[@merge_data[:corps].first] = true if @merge_data[:skip] || @merge_data[:type] == :acquisition
          @log << "#{@merge_data[:corps].first.name} will not run" if @merge_data[:skip] && @merge_data[:type] == :merge

          @merge_data.clear
          @log << 'Merge complete'
        end

        def separate_treasury?
          true
        end

        def decorate_marker(icon)
          return nil if !(corporation = icon.owner) || !icon.owner.corporation?

          color = available_to_start?(corporation) ? 'white' : 'black'
          shape = case @permits[corporation]&.first
                  when :local
                    :diamond
                  when :express
                    :circle
                  else
                    :hexagon
                  end
          { color: color, shape: shape }
        end
      end
    end
  end
end
