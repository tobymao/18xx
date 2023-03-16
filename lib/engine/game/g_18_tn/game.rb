# frozen_string_literal: true

require_relative 'meta'
require_relative 'share_pool'
require_relative '../base'
require_relative '../company_price_50_to_150_percent'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18TN
      class Game < Game::Base
        include_meta(G18TN::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 8000

        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 10 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[60
             70
             80
             90
             100
             110
             120
             130
             150
             170
             190
             210
             230
             250
             275
             300e],
          %w[55
             60
             70
             80
             90p
             100
             110
             120
             130
             150
             170
             190
             210
             230
             250],
          %w[50
             55
             60
             70p
             80p
             90
             100
             110
             120
             130
             150
             170],
          %w[45y 50y 55 65p 75p 80 90 100],
          %w[40o 45y 50y 60 70 75 80],
          %w[35o 40o 45y 55y 65y],
          %w[25o 30o 40o 50y 60y],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: %w[can_buy_companies_from_other_players
                       can_buy_companies_operation_round_one
                       limited_train_buy],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            status: %w[can_buy_companies_from_other_players
                       can_buy_companies
                       limited_train_buy],
            operating_rounds: 2,
          },
          {
            name: '3½',
            on: "3'",
            train_limit: 4,
            tiles: %i[yellow green],
            status: %w[can_buy_companies_from_other_players
                       can_buy_companies
                       limited_train_buy],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            status: %w[can_buy_companies_from_other_players can_buy_companies],
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
            name: '6½',
            on: "6'",
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 5 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 3 },
                  {
                    name: "3'",
                    distance: 3,
                    price: 180,
                    rusts_on: '6',
                    num: 2,
                    events: [{ 'type' => 'civil_war' }],
                  },
                  { name: '4', distance: 4, price: 300, obsolete_on: "6'", num: 3 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 2,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  { name: '6', distance: 6, price: 600, num: 1 },
                  { name: "6'", distance: 6, price: 600, num: 1 },
                  { name: '8', distance: 8, price: 700, num: 7 }].freeze

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_companies_operation_round_one' =>
            ['Can Buy Companies OR 1', 'Corporations can buy companies for face value in OR 1'],
        ).merge(
          'can_buy_companies_from_other_players' =>
            ['Interplayer Company Buy', 'Companies can be bought between players']
        ).merge(
          Engine::Step::SingleDepotTrainBuy::STATUS_TEXT
        ).freeze

        # Two lays or one upgrade
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        STANDARD_YELLOW_CITY_TILES = %w[5 6 57].freeze
        GREEN_CITY_TILES = %w[14 15 619].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'civil_war' => ['Civil War', 'Companies with trains lose revenue of one train its next OR']
        ).freeze

        include CompanyPrice50To150Percent

        def setup
          setup_company_price_50_to_150_percent

          # Illinois Central has a 30% presidency share
          ic = @corporations.find { |c| c.id == 'IC' }
          presidents_share = ic.shares_by_corporation[ic].first
          presidents_share.percent = 30
          final_share = ic.shares_by_corporation[ic].last
          @share_pool.transfer_shares(final_share.to_bundle, @bank)

          @brown_p_tile ||= @tiles.find { |t| t.name == '170' }
          @green_nashville_tile ||= @tiles.find { |t| t.name == 'TN2' }
        end

        def status_str(corp)
          return unless corp.id == 'IC'

          "#{corp.presidents_percent}% President's Share"
        end

        def operating_round(round_num)
          # For OR 1, set company buy price to face value only
          if @turn == 1
            @companies.each do |company|
              company.min_price = company.value
              company.max_price = company.value
            end
          end

          # After OR 1, the company buy price is changed to 50%-150%
          setup_company_price_50_to_150_percent if @turn == 2 && round_num == 1

          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::SpecialTrack,
            G18TN::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18TN::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::SingleDepotTrainBuy,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::BuySellParShares,
          ])
        end

        def routes_revenue(routes)
          total_revenue = super

          corporation = routes.first&.corporation

          return total_revenue if !abilities(corporation, :civil_war) || routes.size < corporation.trains.size

          # The train with the lowest revenue loses the income due to the war effort
          total_revenue - routes.map(&:revenue).min
        end

        def init_share_pool
          G18TN::SharePool.new(self)
        end

        def purchasable_companies(entity = nil)
          candidates = @companies.select do |company|
            company.owner&.player? && company.owner != entity
          end

          candidates.reject! { |c| @round.company_sellers.value?(c.owner) } if allowed_to_buy_during_operation_round_one?
          candidates
        end

        def allowed_to_buy_during_operation_round_one?
          @turn == 1 &&
            @round.is_a?(Round::Operating) &&
            @phase.status.include?('can_buy_companies_operation_round_one')
        end

        def event_civil_war!
          @log << '-- Event: Civil War! --'

          # Corporations that are active and own trains does get a Civil War token.
          # The current entity might not have any, but the 3' train it bought that
          # triggered the Civil War will be part of the trains for it.
          # There is a possibility that the trains will not have a valid route but
          # that is handled in the route code.
          corps = @corporations.select do |c|
            (c == current_entity) || (c.floated? && c.trains.any?)
          end

          corps.each do |corp|
            corp.add_ability(Engine::Ability::Base.new(
              type: :civil_war,
              description: 'Civil War! (One time effect)',
              count: 1,
            ))
          end

          @log << "#{corps.map(&:name).sort.join(', ')} each receive a Civil War token which affects their next OR"
        end

        def lnr
          @lnr ||= company_by_id('LNR')
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super

          return upgrades unless tile_manifest

          # Tile manifest for yellow standard cities should show N tile (TN1) as an option
          upgrades |= [@green_nashville_tile] if green_nashville_upgrade?(tile)

          # Tile manifest for green cities should show P tile as an option
          upgrades |= [@brown_p_tile] if @brown_p_tile && GREEN_CITY_TILES.include?(tile.name)

          upgrades
        end

        def green_nashville_upgrade?(tile)
          @green_nashville_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)
        end
      end
    end
  end
end
