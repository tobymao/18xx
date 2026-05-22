# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative 'entities'
require_relative '../../round/operating'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G1835
      class Game < Game::Base
        attr_accessor :draft_finished, :pr_can_form
        attr_reader :preussen_may_float

        include_meta(G1835::Meta)
        include CitiesPlusTownsRouteDistanceStr
        include G1835::Entities
        include G1835::Map

        CURRENCY_FORMAT_STR = '%sM'
        # game end current or, when the bank is empty
        GAME_END_CHECK = { bank: :current_or }.freeze
        # bankrupt is allowed, player leaves game
        BANKRUPTCY_ALLOWED = true

        BANK_CASH = 120_000
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
        CERT_LIMIT = { 3 => 19, 4 => 15, 5 => 12, 6 => 11, 7 => 9 }.freeze

        STARTING_CASH = { 3 => 6000, 4 => 475, 5 => 390, 6 => 340, 7 => 310 }.freeze
        # money per initial share sold
        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false
        BUY_SHARE_FROM_OTHER_PLAYER = true

        TOKEN_PLACEMENT_ON_TILE_LAY_ENTITY = :owner

        MARKET = [['', '', '', ''] + %w[132 148 166 186 208 232 258 286 316 348 382 418],
                  ['', ''] + %w[98 108 120 134 150 168 188 210 234 260 288 318 350 384],
                  %w[82 86 92p 100 110 122 136 152 170 190 212 236 262 290 320],
                  %w[78 84p 88p 94 102 112 124 138 154p 172 192 214], %w[72 80p 86 90 96 104 114 126 140],
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
            train_limit: { major: 4, minor: 2 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.3',
            on: '4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.4',
            on: '4+4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3.1',
            on: '5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            events: { close_companies: true },
          },
          {
            name: '3.2',
            on: '5+5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.3',
            on: '6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.4',
            on: '6+6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        def self.plus_train_distance(distance)
          [{ 'nodes' => ['town'], 'pay' => distance, 'visit' => distance },
           { 'nodes' => %w[city offboard town], 'pay' => distance, 'visit' => distance }]
        end

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 9 },
                  { name: '2+2', distance: plus_train_distance(2), price: 120, rusts_on: '4+4', num: 4,
                    events: [{ 'type' => 'pr_can_form' }], },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 4,
                    events: [{ 'type' => 'pr_formation' }]},
                  { name: '3+3', distance: plus_train_distance(3), price: 270, rusts_on: '6+6', num: 3 },
                  { name: '4', distance: 4, price: 360, num: 3 },
                  { name: '4+4', distance: plus_train_distance(4), price: 440, num: 1 },
                  { name: '5', distance: 5, price: 500, num: 2 },
                  { name: '5+5', distance: plus_train_distance(5), price: 600, num: 1 },
                  { name: '6', distance: 6, price: 600, num: 2 },
                  { name: '6+6', distance: plus_train_distance(6), price: 720, num: 4 }].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'buy_across' => ['Buy Across', 'Trains can be bought between companies'],
          'pr_can_form' => ['Optional Preußen Formation', 'Preußen can choose to form now or at beginning of SR/OR'],
          'pr_formation' => ['Preußen Formation', 'Preußen forms immediately'],

          ).freeze

        LAYOUT = :pointy

        SELL_MOVEMENT = :down_block

        HOME_TOKEN_TIMING = :float

        CORPORATION_BLOCKS = [%w[BY SX], %w[BA WT HE PR], %w[MS OL]].freeze

        def setup
          # Reserve Preußen shares to be exchanged for Vorpreußen and Privates
          # Reserving the president share would be correct here, but that would make can_buy and process_buy_shares
          # really complicated. Instead, the president share can be bought and will be swapped for a 10% share
          # once PR floats.
          corporation_by_id('PR').shares.last(8).each { |s| s.buyable = false }

          @corporations.each do |corp|
            corp.shares.reject(&:president).each { |share| share.double_cert = (share.percent == 20) }
          end

          @draft_finished = false
          @draft_round_num = 1
          @preussen_may_float = false

          @corporations.select { |corp| corp.type == :major }.each do |corp|
            @stock_market.set_par(corp, @stock_market.par_prices.find { |share_price| share_price.price == PAR_PRICES[corp.id] })
          end

          corporation_by_id('BY').ipoed = true
          corporation_by_id('SX').ipoed = true

          @corporation_blocks = CORPORATION_BLOCKS.map { |block| block.map { |c| corporation_by_id(c) } }

          @prussian_companies = %w[HA HB].map{ |id| company_by_id(id) }
        end

        def company_header(company)
          return 'MINOR' if '123456'.include?(company.sym)
          return 'SHARE' if company.sym == 'BY_D'

          'PRIVATE COMPANY'
        end

        def init_round
          G1835::Round::Draft.new(self,
                                  [G1835::Step::Draft])
        end

        def new_draft_round
          G1835::Round::Draft.new(self,
                                  [G1835::Step::Draft],)
        end

        def next_round!
          return super if @draft_finished

          clear_programmed_actions
          @round =
            case @round
            when G1835::Round::Draft
              reorder_players
              new_operating_round(@draft_round_num)
            when Engine::Round::Operating
              @draft_round_num += 1
              new_draft_round
            end
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G1835::Step::MinorExchange,
            Engine::Step::SpecialTrack,
            G1835::Step::SpecialToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1835::Step::BuyTrain,
          ], round_num: round_num)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1835::Step::MinorExchange,
            G1835::Step::BuySellParShares,
          ])
        end


        def bundles_for_corporation(share_holder, corporation, shares: nil)
          return super if share_holder.player? && corporation.type == :major
          []
        end

        def maybe_ipo_next_block(corporation)
          block = @corporation_blocks.find { |corporation_block| corporation_block.include?(corporation) }
          all_in_block_sold = block.all? { |corp| corp.shares.select(&:buyable).empty? }
          return unless all_in_block_sold
          return if block == @corporation_blocks.last

          next_block = @corporation_blocks[@corporation_blocks.index(block) + 1]
          @log << 'All shares of the current block have been sold.'\
                  " The next block is now available, starting with #{next_block.first.name}"
          next_block.each { |corp_to_ipo| corp_to_ipo.ipoed = true }
        end

        def cert_limit(player = nil)
          return @cert_limit unless player

          @cert_limit + @corporations.count { |corporation| corporation.type == :major && player.percent_of(corporation) >= 80 }
        end

        def corporation_available?(corp)
          return !corporation_by_id('BA').shares.first&.president if corp == corporation_by_id('PR')

          block = @corporation_blocks.find { |corporation_block| corporation_block.include?(corp) }
          index_in_block = block.index(corp)
          return true if index_in_block.zero?

          block[index_in_block - 1].floated?
        end

        def can_par?(_corporation, _parrer)
          false
        end

        def sorted_corporations
          ipoed, others = corporations.partition(&:ipoed)
          floated, not_floated = ipoed.partition(&:floated)
          floated.sort + not_floated + others
        end

        def revenue_for(route, stops)
          super + (hamburg_ferry?(route) ? -10 : 0)
        end

        def revenue_str(route)
          str = super
          str += " (#{format_currency(-10)} Hamburg ferry)" if hamburg_ferry?(route)
          str
        end

        def hamburg_hex
          @hamburg_hex ||= hex_by_id('C11')
        end

        def hamburg_ferry?(route)
          return false unless hamburg_hex.tile.color == :brown
          return false unless route.hexes.include?(hamburg_hex)

          north_edge_used = route.paths.any? { |path| path.tile.hex == hamburg_hex && [2, 3, 4].intersect?(path.exits) }
          south_edge_used = route.paths.any? { |path| path.tile.hex == hamburg_hex && [0, 1, 5].intersect?(path.exits) }
          north_edge_used && south_edge_used
        end

        def event_pr_can_form!
          @log << "-- Event: #{EVENTS_TEXT['pr_can_form'][1]} --"
          @pr_can_form = true
        end

        def event_pr_formation!
          return if minor_by_id("2").closed?

          @log << "-- Event: #{EVENTS_TEXT['pr_formation'][1]} --"
          national = corporation_by_id('PR')
          form_national_railway!(national)
        end

        def event_close_companies!
          @prussian_companies.reject(&:closed).each do |company|
            owner = company.owner
            exchange_prussian_share(true, corporation_by_id('PR'), 10, owner)
          end
          super
        end


        def exchange_target(entity)
          return corporation_by_id('PR') if entity.type == :minor
          return corporation_by_id('PR') if @prussian_companies.include?(entity)

          nil
        end

        def form_national_railway!(national)
          @log << "#{national.id} forms"
          national.floatable = true
          national.floated = true

          #ipo_cash = (10 - national.num_ipo_reserved_shares) * national.par_price.price
          #@bank.spend(ipo_cash, national)
          #@log << "#{national.name} receives #{format_currency(ipo_cash)}"

          merge_minor!(minor_by_id('2'), national, allow_president_change: false)

          set_national_president!(national)
        end

        def merge_minor!(minor, corporation, allow_president_change: true)
          @log << "#{minor.name} merges into #{corporation.name}"

          owner = minor.owner

          exchange_share_percentage = %w[2 4].include?(minor.id) ? 10 : 5

          exchange_prussian_share(allow_president_change, corporation, exchange_share_percentage, owner)

          if minor.cash.positive?
            @log << "#{corporation.name} receives #{format_currency(minor.cash)} from #{minor.name}'s treasury"
            minor.spend(minor.cash, corporation)
          end

          unless minor.trains.empty?
            trains_str = "#{minor.trains.map(&:name).join(', ')} train#{minor.trains.size > 1 ? 's' : ''}"
            @log << "#{corporation.name} receives #{trains_str}"
            #@round.merged_trains[corporation].concat(minor.trains)
            minor.trains.dup.each { |t| buy_train(corporation, t, :free) }
          end

          # Preußen already has a token in Berlin and the rules forbid having more than one token per hex
          unless minor.id == '5'
            token = minor.tokens.first
            new_token = Token.new(corporation)
            corporation.tokens << new_token

            token.swap!(new_token, check_tokenable: false)

            @log << "#{corporation.name} receives token (#{new_token.used ? new_token.city.hex.id : 'charter'})"
          end

          #close_corporation(minor, quiet: true)
          minors.delete(minor)
          minor.close!
          # TODO: remove token of minor 5

          graph.clear_graph_for(corporation)
        end

        def close_minor!(minor)
          minor.tokens.each(&:remove!)
          minor.close!
        end

        def set_national_president!(national)
          current_president = national.owner || national

          # president determined by most shares, then current president
          president_factors = national.player_share_holders.to_h do |player, percent|
            [[percent, player == current_president ? 1 : 0], player]
          end
          president = president_factors[president_factors.keys.max]
          return unless current_president != president

          @log << "#{president.name} becomes the president of #{national.name}"
          @share_pool.change_president(national.presidents_share, current_president, president)
          national.owner = president
        end

        private

        def exchange_prussian_share(allow_president_change, corporation, exchange_share_percentage, owner)
          @log << "#{owner.name} receives a #{exchange_share_percentage}% share of #{corporation.name}"
          exchange_share = corporation.reserved_shares.find { |share| share.percent == exchange_share_percentage }
          exchange_share.buyable = true
          @share_pool.transfer_shares(ShareBundle.new(exchange_share), owner, allow_president_change: allow_president_change)
        end
      end
    end
  end
end
