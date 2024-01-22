# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative '../g_1870'
require_relative '../g_1850'
require_relative 'entities'

module Engine
  module Game
    module G1832
      class Game < Game::Base
        include_meta(G1832::Meta)
        include Entities
        include Map

        attr_accessor :sell_queue, :reissued, :coal_token_counter, :coal_company_sold_or_closed

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 12_000

        CERT_LIMIT = {
          2 => { '10' => 28, '9' => 24, '8' => 21, '7' => 17, '6' => 14 },
          3 => { '10' => 20, '9' => 17, '8' => 15, '7' => 12, '6' => 10 },
          4 => { '10' => 16, '9' => 14, '8' => 12, '7' => 10, '6' => 8 },
          5 => { '10' => 13, '9' => 11, '8' => 9, '7' => 8, '6' => 6 },
          6 => { '10' => 11, '9' => 9, '8' => 8, '7' => 6, '6' => 5 },
          7 => { '10' => 9, '9' => 7, '8' => 6, '7' => 5, '6' => 4 },
        }.freeze

        STARTING_CASH = { 2 => 1050, 3 => 700, 4 => 525, 5 => 420, 6 => 350, 7 => 300 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true
        CORPORATION_CLASS = G1832::Corporation

        MARKET = [
          %w[64y 68 72 76 82 90 100p 110 120 140 160 180 200 225 250 275 300 325 350 375 400],
          %w[60y 64y 68 72 76 82 90p 100 110 120 140 160 180 200 225 250 275 300 325 350 375],
          %w[55y 60y 64y 68 72 76 82p 90 100 110 120 140 160 180 200 225 250i 275i 300i 325i 350i],
          %w[50o 55y 60y 64y 68 72 76p 82 90 100 110 120 140 160i 180i 200i 225i 250i 275i 300i 325i],
          %w[40b 50o 55y 60y 64 68 72p 76 82 90 100 110i 120i 140i 160i 180i],
          %w[30b 40o 50o 55y 60y 64 68p 72 76 82 90i 100i 110i],
          %w[20b 30b 40o 50o 55y 60y 64 68 72 76i 82i],
          %w[10b 20b 30b 40o 50y 55y 60y 64 68i 72i],
          %w[0c 10b 20b 30b 40o 50y 55y 60i 64i],
          %w[0c 0c 10b 20b 30b 40o 50y],
          %w[0c 0c 0c 10b 20b 30b 40o],
        ].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: %w[can_buy_companies],
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
                    name: '8',
                    on: '8',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '10',
                    on: '10',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '12',
                    on: '12',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 7 },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
            events: [{ 'type' => 'companies_buyable' }],
          },
          { name: '4', distance: 4, price: 300, rusts_on: '8', num: 4 },
          {
            name: '5',
            distance: 5,
            price: 450,
            rusts_on: '12',
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 3,
            events: [{ 'type' => 'remove_tokens' }],
          },
          {
            name: '8',
            distance: 8,
            price: 800,
            num: 3,
            events: [{ 'type' => 'remove_key_west_token' }],
          },
          { name: '10', distance: 10, price: 950, num: 2 },
          { name: '12', distance: 12, price: 1100, num: 99 },
        ].freeze

        EBUY_OTHER_VALUE = false

        CLOSED_CORP_TRAINS_REMOVED = false

        CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT = true
        IPO_RESERVED_NAME = 'Treasury'

        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0, cannot_reuse_same_hex: true },
                     { lay: :not_if_upgraded, upgrade: false, cost: 0 }].freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(unlimited: :green, par: :white,
                                                            ignore_one_sale: :red).freeze

        MULTIPLE_BUY_ONLY_FROM_MARKET = true

        BOOMTOWN_HEXES = %w[D8 F14 G9 G9 H6 L14].freeze

        ASSIGNMENT_TOKENS = {
          'boomtown' => '/icons/1832/boomtown_token.svg',
          'P2' => '/icons/1846/sc_token.svg',
          'P3' => '/icons/1832/cotton_token.svg',
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'companies_buyable' => ['Companies become buyable', 'All companies may now be bought in by corporation'],
          'remove_tokens' => ['Remove Tokens', 'Remove private company tokens'],
          'remove_key_west_token' => ['Remove Key West Token', 'FECR loses the Key West']
        ).freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          ignore_one_sale: 'Can only enter when 2 shares sold at the same time'
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_companies_from_other_players' => ['Interplayer Company Buy',
                                                     'Companies can be bought between players',
                                                     'The West Virginia Coalfields private company can be bought in for '\
                                                     'up to face value from the owning player'],
        ).merge(
          'companies_buyable' => ['Companies become buyable', 'All companies may now be bought in by corporation'],
        )

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            Engine::Step::WaterfallAuction,
          ])
        end

        def stock_round
          G1870::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1870::Step::BuySellParShares,
            G1850::Step::PriceProtection,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G1832::Step::BuyCompany,
            G1870::Step::Assign,
            G1870::Step::SpecialTrack,
            G1832::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1870::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1870::Step::BuyTrain,
            [G1832::Step::BuyCompany, { blocks: true }],
            G1850::Step::PriceProtection,
          ], round_num: round_num)
        end

        def init_stock_market
          G1870::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def ipo_reserved_name(_entity = nil)
          'Treasury'
        end

        def setup
          @sell_queue = []
          @reissued = {}
          @coal_token_counter = 5

          coal_company.max_price = coal_company.value

          @sharp_city ||= @all_tiles.find { |t| t.name == '5' }
          @gentle_city ||= @all_tiles.find { |t| t.name == '6' }
          @straight_city ||= @all_tiles.find { |t| t.name == '57' }

          @tile_141 ||= @all_tiles.find { |t| t.name == '141' }
          @tile_142 ||= @all_tiles.find { |t| t.name == '142' }
          @tile_143 ||= @all_tiles.find { |t| t.name == '143' }
          @tile_144 ||= @all_tiles.find { |t| t.name == '144' }
        end

        def event_companies_buyable!
          coal_company.max_price = 2 * coal_company.value
        end

        def event_close_companies!
          @log << '-- Event: Private companies close --'
          company.close!

          @coal_company_sold_or_closed = true
        end

        def event_close_remaining_companies!
          @log << '-- Event: All remaining private companies close --'
          @companies.each(&:close!)
        end

        # can't run to or through the West Virginia Coalfied hex (B14) without a coal token
        def check_distance(route, visits, _train = nil)
          return super if visits.none? { |v| v.hex == coal_hex } || route.train.owner.coal_token

          raise GameError, 'Corporation must own coal token to enter West Virginia Coalfields'
        end

        def event_remove_tokens!
          removals = Hash.new { |h, k| h[k] = {} }

          @corporations.each do |corp|
            corp.assignments.dup.each do |company, _|
              if ASSIGNMENT_TOKENS[company]
                removals[company][:corporation] = corp.name
                corp.remove_assignment!(company)
              end
            end
          end

          @hexes.each do |hex|
            hex.assignments.dup.each do |company, _|
              if ASSIGNMENT_TOKENS[company]
                removals[company][:hex] = hex.name
                hex.remove_assignment!(company)
              end
            end
          end

          removals.each do |company, removal|
            hex = removal[:hex]
            corp = removal[:corporation]
            @log << "-- Event: #{corp}'s #{company_by_id(company).name} token removed from #{hex} --"
          end
        end

        def port_company
          @port_company ||= company_by_id('P2')
        end

        def cotton_company
          @cotton_company ||= company_by_id('P3')
        end

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def coal_company
          @coal_company ||= company_by_id('P5')
        end

        def coal_hex
          @coal_hex ||= hex_by_id('B14')
        end

        def revenue_for(route, stops)
          revenue = super

          cotton = 'P2'
          revenue += 10 if route.corporation.assigned?(cotton) && stops.any? { |stop| stop.hex.assigned?(cotton) }

          revenue += (route.corporation.assigned?('P3') ? 20 : 10) if stops.any? { |stop| stop.hex.assigned?('P3') }

          revenue
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          @sell_queue << [bundle, bundle.corporation.owner]

          @share_pool.sell_shares(bundle)
        end

        def num_certs(entity)
          entity.shares.sum do |s|
            next 0 unless s.corporation.counts_for_limit
            next 0 unless s.counts_for_limit
            # Don't count shares that have been sold and will go to yellow unless protected
            next 0 if @sell_queue.any? do |bundle, _|
              bundle.corporation == s.corporation &&
                !stock_market.find_share_price(s.corporation, Array.new(bundle.num_shares, :down)).counts_for_limit
            end

            s.cert_size
          end + entity.companies.size
        end

        def legal_tile_rotation?(_entity, _hex, _tile)
          true
        end

        def purchasable_companies(entity = nil)
          entity ||= current_entity
          return super unless @phase.name == '2'

          coal_company
        end

        def after_sell_company(buyer, company, _price, _seller)
          return unless company == coal_company

          buyer.coal_token = true
          @coal_token_counter -= 1
          @coal_company_sold_or_closed = true
          log << "#{buyer.name} receives Coal token. #{@coal_token_counter} Coal tokens left in the game."
          log << '-- Corporations can now buy Coal tokens --'
        end

        def status_array(corporation)
          return unless corporation.coal_token

          ['Coal Token']
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super
          return upgrades unless tile_manifest

          upgrades |= [@sharp_city, @tile_141, @tile_142, @tile_143] if tile.name == '3' && tile.assigned?('boomtown')
          upgrades |= [@straight_city, @tile_141, @tile_142] if tile.name == '4' && tile.assigned?('boomtown')

          if tile.name == '58' && tile.assigned?('boomtown')
            upgrades |= [@gentle_city, @tile_141, @tile_142, @tile_143, @tile_144]
          end

          upgrades
        end

        def reissued?(corporation)
          @reissued[corporation]
        end

        def graph_skip_paths(entity)
          return nil if entity.coal_token

          @skip_paths ||= {}

          return @skip_paths unless @skip_paths.empty?

          coal_hex.tile.paths.each do |path|
            @skip_paths[path] = true
          end

          @skip_paths
        end

        # 1828 system code
        # def create_system(corporations)
        #   return nil unless corporations.size == 2

        #   system_data = CORPORATIONS.find { |c| c[:sym] == corporations.first.id }.dup
        #   system_data[:sym] = corporations.map(&:name).join('-')
        #   system_data[:tokens] = []
        #   system_data[:abilities] = []
        #   system_data[:corporations] = corporations
        #   system = init_system(@stock_market, system_data)

        #   @corporations << system
        #   @_corporations[system.id] = system
        #   system.shares.each { |share| @_shares[share.id] = share }

        #   corporations.each { |corporation| transfer_assets_to_system(corporation, system) }

        #   # Order tokens for better visual
        #   max_price = system.tokens.max_by(&:price).price + 1
        #   system.tokens.sort_by! { |t| (t.used ? -max_price : max_price) + t.price }

        #   place_system_blocking_tokens(system)

        #   # Make sure the system will not own two coal markers
        #   if coal_markers(system).size > 1
        #     remove_coal_marker(system)
        #     add_coal_marker_to_va_coalfields
        #     @log << "#{system.name} cannot have two coal markers, returning one to Virginia Coalfields"
        #   end

        #   @stock_market.set_par(system, system_market_price(corporations))
        #   system.ipoed = true

        #   system
        # end

        # def transfer_assets_to_system(corporation, system)
        #   corporation.spend(corporation.cash, system) if corporation.cash.positive?

        #   # Transfer tokens
        #   used, unused = corporation.tokens.partition(&:used)
        #   used.each do |t|
        #     new_token = Engine::Token.new(system, price: t.price)
        #     system.tokens << new_token
        #     t.swap!(new_token, check_tokenable: false)
        #   end
        #   unused.sort_by(&:price).each { |t| system.tokens << Engine::Token.new(system, price: t.price) }
        #   corporation.tokens.clear

        #   # Transfer companies
        #   corporation.companies.each do |company|
        #     company.owner = system
        #     system.companies << company
        #   end
        #   corporation.companies.clear

        #   # Transfer abilities
        #   corporation.all_abilities.dup.each do |ability|
        #     corporation.remove_ability(ability)
        #     system.add_ability(ability)
        #   end

        #   # Create shell and transfer
        #   shell = G1828::Shell.new(corporation.name, system)
        #   system.shells << shell
        #   corporation.trains.dup.each do |train|
        #     buy_train(system, train, :free)
        #     shell.trains << train
        #   end
        # end
      end
    end
  end
end
