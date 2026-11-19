# frozen_string_literal: true

require_relative '../g_1846/game'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../company_price_up_to_face'
require_relative '../base'

module Engine
  module Game
    module G1833NE
      class Game < Game::Base
        include_meta(G1833NE::Meta)
        include Entities
        include Map
        include CompanyPriceUpToFace

        attr_accessor :last_action, :lowell_merchants_company_activated

        BANK_CASH = 10_000
        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 400 }.freeze

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :float
        MUST_SELL_IN_BLOCKS = true
        POOL_SHARE_DROP = :left_block
        SELL_AFTER = :p_any_operate
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :left_block_pres

        EBUY_FROM_OTHERS = :never
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        MUST_BUY_TRAIN = :always
        TILE_COST = 20

        SHERBROOKE_HEX = 'F5'

        VARIABLE_START = :variable_start
        TAKEOVER_STATUS = 'takeovers'
        TAKEOVERS_FROM_PHASE = 'II'
        TAKEOVER_TRAIN_PHASE = 'IV'
        UNTRACKED_HOME_COST = 80
        TRACKED_HOME_COST = 120
        TRACKED_HOME_MIN_PRICE = 60

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          TAKEOVER_STATUS => [
            'Takeovers',
            'Variable Start railroads may be launched, and corporations may take over other corporations',
          ],
        ).freeze

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        GAME_END_CHECK = {
          bankrupt: :immediate,
          bank: :full_or,
          all_closed: :immediate,
          final_train: :one_more_full_or_set,
        }.freeze

        CERT_LIMIT = {
          3 => { 14 => 35, 13 => 33, 12 => 30, 11 => 28, 10 => 26, 9 => 24, 8 => 22, 7 => 19, 6 => 16, 5 => 14 },
          4 => { 14 => 26, 13 => 25, 12 => 23, 11 => 21, 10 => 20, 9 => 18, 8 => 16, 7 => 14, 6 => 12, 5 => 10 },
          5 => { 14 => 21, 13 => 20, 12 => 18, 11 => 17, 10 => 16, 9 => 14, 8 => 13, 7 => 11, 6 => 10, 5 => 8 },
        }.freeze

        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

        MARKET = [
          %w[0c 10 20 30 40p 50p 60p 70p 80p 90p 100p 112p 124p 137p 150p
             165 180 195 212 230 250 270 295 320 345 375 405 440 475 510 550 590 630 680 730],
           ].freeze

        PHASES = [
          {
            name: 'I',
            train_limit: 3,
            takeover_train_limit: 3,
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: 'II',
            train_limit: 3,
            takeover_train_limit: 3,
            on: '3/5',
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: 'III',
            on: '4/7',
            train_limit: 3,
            takeover_train_limit: 2,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: 'IV',
            on: '6/9',
            train_limit: 2,
            takeover_train_limit: 1,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: 'V',
            on: '7+3',
            train_limit: 2,
            takeover_train_limit: 1,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 75,
            num: 8,
            obsolete_on: '4/7',
            rusts_on: '6/9',
            variants: [
              {
                name: '2+1',
                distance: [{ 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                           { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
                price: 100,
              },
            ],
          },
          {
            name: '3/5',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 5 }],
            price: 180,
            num: 5,
            obsolete_on: '6/9',
            rusts_on: '7+3',
            variants: [
              {
                name: '2+2',
                distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
                price: 140,
              },
            ],
          },
          {
            name: '4/7',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 7 }],
            price: 320,
            num: 6,
            obsolete_on: '7+3',
            variants: [
              {
                name: '3+3',
                distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
                price: 230,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6/9',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 9 }],
            price: 750,
            num: 3,
            variants: [
              {
                name: '5+3',
                distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 }],
                price: 640,
              },
            ],
            events: [
              { 'type' => 'remove_bonuses' },
              { 'type' => 'remove_reservations' },
            ],
          },
          {
            name: '7+3',
            distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => %w[city offboard town], 'pay' => 7, 'visit' => 7 }],
            price: 950,
            num: 15,
          },
        ].freeze

        def num_trains(train)
          return takeover_game? ? 5 : 3 if train[:name] == takeover_train_name

          train[:num]
        end

        def setup
          setup_company_price_up_to_face

          @last_action = nil
          @lowell_merchants_company_activated = false
          @takeovers_by = Hash.new(0)
        end

        def game_corporations
          return self.class::CORPORATIONS if takeover_game?

          self.class::CORPORATIONS.reject { |corporation| corporation[:type].to_sym == self.class::VARIABLE_START }
        end

        def game_phases
          return self.class::PHASES unless takeover_game?

          takeovers_from = self.class::PHASES.index { |phase| phase[:name] == self.class::TAKEOVERS_FROM_PHASE }
          self.class::PHASES.map.with_index do |phase, index|
            status = Array(phase[:status])
            status += [self.class::TAKEOVER_STATUS] if index >= takeovers_from
            phase.merge(train_limit: phase[:takeover_train_limit], status: status)
          end
        end

        def train_limit(entity)
          super + @takeovers_by[entity]
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1833NE::Step::WaterfallAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1833NE::Step::HomeToken,
            Engine::Step::Assign,
            G1846::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @round_num = round_num
          G1833NE::Round::Operating.new(self, [
            G1846::Step::Bankrupt,
            Engine::Step::Assign,
            Engine::Step::SpecialToken,
            G1833NE::Step::SpecialTrack,
            G1833NE::Step::BuyCompany,
            G1846::Step::IssueShares,
            G1833NE::Step::TrackAndToken,
            Engine::Step::Route,
            G1846::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1833NE::Step::BuyTrain,
            [G1833NE::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def takeover_round
          G1833NE::Round::Takeover.new(self, [
            Engine::Step::DiscardTrain,
            G1833NE::Step::RedeemTakeoverShares,
            G1833NE::Step::TakeoverConsent,
            G1833NE::Step::TakeoverCorporation,
          ])
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              remove_lowell_merchants_ability! if @lowell_merchants_company_activated
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              elsif takeovers_allowed?
                or_round_finished
                or_set_finished
                new_takeover_round
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when G1833NE::Round::Takeover
              @turn += 1
              new_stock_round
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def new_takeover_round
          @log << '-- Takeover Round -- '
          takeover_round
        end

        def operating_order
          corporations = @corporations.select(&:floated?)
          if @turn == 1 && (@round_num || 1) == 1
            corporations.sort_by! do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          else
            corporations.sort!
          end
        end

        def upgrade_cost(tile, hex, entity, spender)
          [self.class::TILE_COST, super].max
        end

        def show_map_legend?
          true
        end

        def map_legend(font_color, yellow, green, brown, _gray, *_extra_colors)
          [
            # table-wide props
            {
              style: {
                margin: '0.5rem 0 0.5rem 0',
                border: '1px solid',
                borderCollapse: 'collapse',
              },
            },
            # header
            [
              { text: 'Interconnection bonuses', props: { style: { border: '1px solid', textAlign: 'center' } } },
              {
                text: 'I',
                props: {
                  style: {
                    border: '1px solid',
                    color: 'black',
                    background: "linear-gradient(135deg, #{yellow} 50%, #{green} 50%)",
                  },
                },
              },
              {
                text: 'III',
                props: {
                  style: {
                    border: '1px solid',
                    color: 'black',
                    background: "linear-gradient(135deg, #98ff98 50%, #{brown} 50%)",
                  },
                },
              },
              {
                text: 'V',
                props: {
                  style: {
                    border: '1px solid',
                    color: 'black',
                    backgroundColor: 'gray',
                  },
                },
              },
              { text: 'Direct bonuses', props: { style: { border: '1px solid', textAlign: 'center' } } },
              {
                text: 'I',
                props: {
                  style: {
                    border: '1px solid',
                    color: 'black',
                    background: "linear-gradient(135deg, #{yellow} 50%, #{green} 50%)",
                  },
                },
              },
              {
                text: 'III',
                props: {
                  style: {
                    border: '1px solid',
                    color: 'black',
                    background: "linear-gradient(135deg, #98ff98 50%, #{brown} 50%)",
                  },
                },
              },
              {
                text: 'V',
                props: {
                  style: {
                    border: '1px solid',
                    color: 'black',
                    backgroundColor: 'gray',
                  },
                },
              },
            ],
            # body
            [
              {
                text: 'Montreal to Portland',
                props: { style: { border: "1px solid #{font_color}" } },
              },
              { text: '30', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '60', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '40', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              {
                text: 'Montreal ending at New Haven or Norwich',
                props: { style: { border: "1px solid #{font_color}" } },
              },
              { text: '-', props: { style: { border: '1px solid', textAlign: 'center' } } },
              { text: '50', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '80', props: { style: { border: '1px solid',  textAlign: 'center' } } },
            ],
            [
              {
                text: 'Montreal to Boston',
                props: { style: { border: "1px solid #{font_color}" } },
              },
              { text: '70', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '90', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '-', props: { style: { border: '1px solid', textAlign: 'center' } } },
              {
                text: 'Montreal/Ogdensburg and Boston',
                props: { style: { border: "1px solid #{font_color}" } },
              },
              { text: '50', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '60', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '-', props: { style: { border: '1px solid', textAlign: 'center' } } },
            ],
            [
              {
                text: 'Ogdensburg to Boston',
                props: { style: { border: "1px solid #{font_color}" } },
              },
              { text: '40', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '70', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '-', props: { style: { border: '1px solid', textAlign: 'center' } } },
              {
                text: 'New York and Boston',
                props: { style: { border: "1px solid #{font_color}" } },
              },
              { text: '- ', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '60', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '80', props: { style: { border: '1px solid',  textAlign: 'center' } } },
            ],
            [
              {
                text: 'Albany/Troy to Boston',
                props: { style: { border: "1px solid #{font_color}" } },
              },
              { text: '50', props: { style: { border: '1px solid', textAlign: 'center' } } },
              { text: '-', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '-', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              {
                text: 'Albany/Troy and Boston',
                props: { style: { border: "1px solid #{font_color}" } },
              },
              { text: '50', props: { style: { border: '1px solid', textAlign: 'center' } } },
              { text: '-', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '-', props: { style: { border: '1px solid',  textAlign: 'center' } } },
            ],
            [
              {
                text: 'Portland to Montreal',
                props: { style: { border: "1px solid #{font_color}" } },
              },
              { text: '30', props: { style: { border: '1px solid', textAlign: 'center' } } },
              { text: '60', props: { style: { border: '1px solid',  textAlign: 'center' } } },
              { text: '40', props: { style: { border: '1px solid',  textAlign: 'center' } } },
            ],
            [
              {
                text: 'Boston to Montreal',
                props: { style: { border: "1px solid #{font_color}" } },
              },
              { text: '30', props: { style: { border: '1px solid', textAlign: 'center' } } },
              { text: '50', props: { style: { border: '1px solid', textAlign: 'center' } } },
              { text: '-', props: { style: { border: '1px solid', textAlign: 'center' } } },
            ],
          ]
        end

        def sellable_bundles(player, corporation)
          return [] if corporation.receivership?

          super
        end

        def buying_power(entity, **)
          entity.cash + (issuable_shares(entity).map(&:price).max || 0)
        end

        def total_emr_buying_power(player, corporation)
          emergency = (issuable = emergency_issuable_cash(corporation)).zero?
          corporation.cash + issuable + liquidity(player, emergency: emergency)
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G1846::Step::IssueShares) }.active?

          num_shares = entity.num_player_shares - entity.num_market_shares
          bundles = bundles_for_corporation(entity, entity)
          share_price = stock_market.find_share_price(entity, :left).price

          bundles
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| bundle.num_shares > num_shares }
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G1846::Step::IssueShares) }.active?

          share_price = stock_market.find_share_price(entity, :right).price

          bundles_for_corporation(share_pool, entity)
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| entity.cash < bundle.price }
        end

        def emergency_issuable_bundles(corp)
          return [] if corp.trains.any?
          return [] if @round.emergency_issued
          return [] unless (train = @depot.min_depot_train)

          min_train_price, max_train_price = train.variants.map { |_, v| v[:price] }.minmax
          return [] if corp.cash >= max_train_price

          bundles = bundles_for_corporation(corp, corp)

          num_issuable_shares = corp.num_player_shares - corp.num_market_shares
          bundles.reject! { |bundle| bundle.num_shares > num_issuable_shares }

          bundles.each do |bundle|
            directions = [:left] * (1 + bundle.num_shares)
            bundle.share_price = stock_market.find_share_price(corp, directions).price
          end

          # cannot issue shares that generate no money
          bundles.reject! { |b| b.price.zero? }

          bundles.sort_by!(&:price)

          # Cannot issue more shares than needed to buy the train from the bank
          # (but may buy either variant)
          train_buying_bundles = bundles.select { |b| (corp.cash + b.price) >= min_train_price }
          if train_buying_bundles.any?
            bundles = train_buying_bundles

            index = bundles.find_index { |b| (corp.cash + b.price) >= max_train_price }
            return bundles.take(index + 1) if index

            return bundles
          end

          # if a train cannot be afforded, issue all possible shares
          biggest_bundle = bundles.max_by(&:num_shares)
          return [biggest_bundle] if biggest_bundle

          []
        end

        def takeover_game?
          @takeover_game ||= @optional_rules&.include?(:takeover_game)
        end

        def takeovers_allowed?
          @phase.status.include?(self.class::TAKEOVER_STATUS)
        end

        def variable_start?(corporation)
          corporation.type == self.class::VARIABLE_START
        end

        def can_par?(corporation, parrer)
          return false if variable_start?(corporation) && !takeovers_allowed?

          super
        end

        def status_array(corporation)
          return unless variable_start?(corporation)

          status = [['Variable Start Corp', 'bold']]
          status << ["Phase available: #{self.class::TAKEOVERS_FROM_PHASE}"] unless takeovers_allowed?
          status
        end

        def home_token_locations(corporation)
          hexes.select { |hex| hex.tile.cities.any? { |city| variable_start_home?(corporation, city) } }
        end

        def variable_start_home?(corporation, city)
          city.hex.id != self.class::SHERBROOKE_HEX &&
            city.tokenable?(corporation, free: true) &&
            !home_of_available_corporation?(city) &&
            (untracked_hex?(city.hex) || corporation.par_price.price >= self.class::TRACKED_HOME_MIN_PRICE)
        end

        def home_of_available_corporation?(city)
          @corporations.any? do |corporation|
            !corporation.ipoed && corporation.coordinates == city.hex.id && (corporation.city || 0) == city.index
          end
        end

        def untracked_hex?(hex)
          hex.tile.color == :gray || hex.tile.paths.empty?
        end

        def variable_start_home_cost(hex)
          untracked_hex?(hex) ? self.class::UNTRACKED_HOME_COST : self.class::TRACKED_HOME_COST
        end

        def vulnerable?(corporation)
          corporation.trains.all?(&:obsolete)
        end

        def can_attempt_takeover?(corporation)
          corporation.floated? && !corporation.receivership? && !vulnerable?(corporation)
        end

        def takeover_candidates(acquirer)
          return [] if !takeovers_allowed? || !can_attempt_takeover?(acquirer)

          targets = @corporations.select do |target|
            target != acquirer && target.floated? && can_redeem_takeover_shares?(acquirer, target)
          end
          return [] if targets.empty?

          nodes = graph.connected_nodes(acquirer)
          targets.select { |target| target.placed_tokens.any? { |token| nodes[token.city] } }
        end

        def takeover_holdings(target)
          (@players + [@share_pool]).filter_map do |holder|
            shares = holder.num_shares_of(target)
            [holder, shares] if shares.positive?
          end
        end

        def takeover_unissued_shares(acquirer)
          acquirer.shares_of(acquirer).reject(&:president)
        end

        def takeover_swap_capacity(acquirer, holder)
          limit = holder == @share_pool ? market_share_limit(acquirer) : acquirer.max_ownership_percent
          [((limit - holder.percent_of(acquirer)).to_f / acquirer.share_percent).floor, 0].max
        end

        def takeover_swap_caps(acquirer, target)
          takeover_holdings(target).map { |holder, shares| [shares, takeover_swap_capacity(acquirer, holder)].min }
        end

        def takeover_swaps_needed(acquirer, target)
          price = target.share_price.price
          shortfall = (takeover_holdings(target).sum(&:last) * price) - acquirer.cash
          return 0 unless shortfall.positive?

          (shortfall.to_f / price).ceil
        end

        def can_redeem_takeover_shares?(acquirer, target)
          available = [takeover_swap_caps(acquirer, target).sum, takeover_unissued_shares(acquirer).size].min
          takeover_swaps_needed(acquirer, target) <= available
        end

        def takeover_swap_range(acquirer, target, index, swapped)
          caps = takeover_swap_caps(acquirer, target)
          later = caps[(index + 1)..].sum
          min = [takeover_swaps_needed(acquirer, target) - swapped - later, 0].max
          max = [caps[index], takeover_unissued_shares(acquirer).size - swapped].min
          (min..max)
        end

        def takeover_consenter(acquirer, target)
          return if vulnerable?(target)

          president = target.owner
          president if president&.player? && president != acquirer.owner
        end

        def take_over!(acquirer, target, swaps)
          @log << "-- #{acquirer.name} takes over #{target.name} --"
          redeem_takeover_shares!(acquirer, target, swaps)
          adjust_takeover_share_price!(acquirer, target)
          transfer_takeover_tokens!(acquirer, target)
          @takeovers_by[acquirer] += 1
          transfer_takeover_assets!(acquirer, target)
          remove_takeover_train! if @takeovers_by.values.sum.odd?
          close_corporation(target)
          @log << "#{acquirer.name}'s train limit is now #{train_limit(acquirer)}"
          @log << "The certificate limit is now #{cert_limit}"
        end

        def redeem_takeover_shares!(acquirer, target, swaps)
          price = target.share_price.price
          unissued = takeover_unissued_shares(acquirer)
          takeover_holdings(target).each_with_index do |(holder, shares), index|
            swapped = swaps[index]
            unless swapped.zero?
              @share_pool.transfer_shares(ShareBundle.new(unissued.shift(swapped)), holder, allow_president_change: false)
            end
            cash = (shares - swapped) * price
            acquirer.spend(cash, holder == @share_pool ? @bank : holder) if cash.positive?
            @log << "#{acquirer.name} redeems #{holder.name}'s #{shares} #{target.name} share(s) "\
                    "for #{swapped} #{acquirer.name} share(s) and #{format_currency(cash)}"
          end
          update_takeover_presidency!(acquirer)
        end

        def update_takeover_presidency!(corporation)
          previous = corporation.owner
          holdings = @share_pool.presidency_check_shares(corporation)
          max = holdings.values.max
          return if holdings[previous] == max

          president = holdings.select { |_, percent| percent == max }.keys
                        .min_by { |player| @share_pool.distance(previous, player) }
          @share_pool.change_president(corporation.presidents_share, previous, president, previous)
          corporation.owner = president
          @log << "#{president.name} becomes the president of #{corporation.name}"
        end

        def adjust_takeover_share_price!(acquirer, target)
          target_price = target.share_price.price
          acquirer_price = acquirer.share_price.price
          return if target_price == acquirer_price

          old_price = acquirer.share_price
          if target_price < acquirer_price
            @stock_market.move_left(acquirer)
          else
            @stock_market.move_right(acquirer)
          end
          log_share_price(acquirer, old_price)
        end

        def transfer_takeover_tokens!(acquirer, target)
          target.placed_tokens.each do |token|
            city = token.city
            if city.tokened_by?(acquirer)
              token.remove!
              @log << "#{target.name}'s token in #{city.hex.name} is discarded"
            else
              replacement = Engine::Token.new(acquirer)
              acquirer.tokens << replacement
              token.swap!(replacement, check_tokenable: false)
              @log << "#{acquirer.name} replaces #{target.name}'s token in #{city.hex.name}"
            end
          end
          transfer_takeover_reservations!(acquirer, target)
          graph.clear
        end

        def transfer_takeover_reservations!(acquirer, target)
          hexes.each do |hex|
            hex.tile.cities.each do |city|
              next unless (index = city.reservations.index(target))

              held = city.tokened_by?(acquirer) || city.reserved_by?(acquirer)
              city.reservations[index] = held ? nil : acquirer
            end
            next unless hex.tile.reservations.delete(target)

            hex.tile.reservations << acquirer unless hex.tile.reserved_by?(acquirer)
          end
        end

        def transfer_takeover_assets!(acquirer, target)
          if target.cash.positive?
            @log << "#{acquirer.name} receives #{format_currency(target.cash)} from #{target.name}'s treasury"
            target.spend(target.cash, acquirer)
          end
          %i[trains companies].each do |assets|
            transferred = transfer(assets, target, acquirer)
            next if transferred.empty?

            @log << "#{acquirer.name} receives #{target.name}'s #{assets}: #{transferred.map(&:name).join(', ')}"
          end
        end

        def takeover_train_name
          @takeover_train_name ||= self.class::PHASES.find { |phase| phase[:name] == self.class::TAKEOVER_TRAIN_PHASE }[:on]
        end

        def remove_takeover_train!
          return unless (train = @depot.upcoming.find { |t| t.sym == takeover_train_name })

          @depot.remove_train(train)
          @log << "An unsold #{train.name} train is removed from the game"
        end

        def lowell_merchants_company
          @lowell_merchants_company ||= company_by_id('P2')
        end

        def activate_lowell_merchants_company!
          @lowell_merchants_company_activated = true
        end

        def remove_lowell_merchants_ability!
          corp = lowell_merchants_company.owner
          ability = corp.all_abilities.find { |a| a.type == :tile_discount }

          corp.remove_ability(ability)
          if hex_by_id('G20').tile.color == :white
            @log << "#{corp.name} forfeits #{lowell_merchants_company.name}'s ability to lay a tile in G20 for free."
          end

          @lowell_merchants_company_activated = false
        end
      end
    end
  end
end
