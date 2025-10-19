# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'player_info'
require_relative '../base'
require_relative '../company_price_50_to_150_percent'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G18MS
      class Game < Game::Base
        include_meta(G18MS::Meta)
        include CitiesPlusTownsRouteDistanceStr
        include Entities
        include Map

        attr_accessor :chattanooga_reached

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 10_000

        CERT_LIMIT = { 2 => 20, 3 => 14, 4 => 10 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 625, 4 => 525 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        FIRST_OR_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

        MARKET = [
          %w[65y
             70
             75
             80
             90p
             100
             110
             130
             150
             170
             200
             230
             265
             300],
          %w[60y
             65y
             70p
             75p
             80p
             90
             100
             110
             130
             150
             170
             200
             230
             265],
          %w[50y 60y 65y 70 75 80 90 100 110 130 150],
          %w[45y 50y 60y 65y 70 75 80],
          %w[40y 45y 50y 60y],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 3,
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['can_buy_companies_operation_round_one'],
          },
          {
            name: '3',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '6',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: 'D',
            train_limit: 3,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 80,
            salvage: 20,
            num: 5,
          },
          {
            name: '3+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 180,
            salvage: 30,
            num: 4,
          },
          {
            name: '4+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 300,
            salvage: 60,
            num: 3,
          },
          { name: '5', distance: 5, price: 500, num: 2 },
          {
            name: '6',
            distance: 6,
            price: 550,
            num: 2,
            events: [{ 'type' => 'close_companies' }, { 'type' => 'remove_tokens' }],
          },
          {
            name: '2D',
            distance: 2,
            multiplier: 2,
            price: 500,
            num: 4,
            available_on: '6',
            variants: [
              {
                name: '4D',
                price: 750,
                multiplier: 2,
                available_on: '6',
                distance: 4,
              },
            ],
          },
          {
            name: '5D',
            multiplier: 2,
            distance: 5,
            price: 850,
            num: 1,
            available_on: '6',
          },
        ].freeze

        # Game will end after 10 ORs (or 11 in case of optional rule)
        GAME_END_CHECK = { fixed_round: :current_or }.freeze

        BANKRUPTCY_ALLOWED = false

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false # Emergency buy can buy any available trains
        EBUY_PRES_SWAP = false # Do not allow presidental swap during emergency buy
        EBUY_SELL_MORE_THAN_NEEDED = true # Allow to sell extra to force buy a more expensive train

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_companies_operation_round_one' =>
            ['Can Buy Companies OR 1', 'Corporations can buy AGS/BS companies for face value in OR 1'],
        ).freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_tokens' => ['Remove Tokens', 'New Orleans route bonus removed']
        ).freeze

        COMPANY_1_AND_2 = %w[AGS BS].freeze

        def chattanooga_hex
          @chattanooga_hex ||= @hexes.find { |h| h.name == 'B12' }
        end

        include CompanyPrice50To150Percent

        def setup
          @chattanooga_reached = false
          setup_company_price_50_to_150_percent

          @mobile_city_brown ||= @tiles.find { |t| t.name == 'X31b' }
          @gray_tile ||= @tiles.find { |t| t.name == '446' }
          @recently_floated = []

          # The last 2+ train will be used as free train for a private
          # Store it in the company in the meantime
          neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            tokens: [],
          )
          neutral.owner = @bank
          @free_train = train_by_id('2+-4')
          @free_train.buyable = false
          buy_train(neutral, @free_train, :free)

          @or = 0
          @last_or = @optional_rules&.include?(:or_11) ? 11 : 10
          @three_or_round = false
        end

        def timeline
          @timeline ||= [
            'At the start of OR 2, phase 3 starts.',
            'After OR 4, all 2+ trains are rusted. Trains salvaged for $20 each.',
            'After OR 6, all 3+ trains are rusted. Trains salvaged for $30 each.',
            'After OR 8, all 4+ trains are rusted. Trains salvaged for $60 each.',
            "Game ends after OR #{@last_or}!",
          ].freeze
          @timeline
        end

        def new_operating_round(round_num = 1)
          @or += 1
          # For OR 1, set company buy price to face value only
          if @or == 1
            @companies.each do |company|
              company.min_price = company.value
              company.max_price = company.value
            end
          end

          # When OR2 is to start setup company prices and switch to green phase
          if @or == 2
            setup_company_price_50_to_150_percent
            @phase.next!
          end

          # Need to take new loan if in debt after SR
          if round_num == 1
            @players.each do |p|
              next unless p.cash.negative?

              debt = -p.cash
              interest = (debt / 2.0).ceil
              p.spend(interest, @bank, check_cash: false)
              @log << "#{p.name} has to borrow another #{format_currency(interest)} as being in debt at end of SR"
            end
          end

          # In case of 11 ORs, the last set will be 3 ORs
          if @or == 9 && @optional_rules&.include?(:or_11)
            @operating_rounds = 3
            @three_or_round = true
          end

          super
        end

        def round_description(name, _round_num = nil)
          case name
          when 'Stock'
            super
          when 'Draft'
            name
          else # 'Operating'
            message = ''
            message += ' - Change to Phase 3 after OR 1' if @or == 1
            message += ' - 2+ trains rust after OR 4' if @or <= 4
            message += ' - 3+ trains rust after OR 6' if @or > 4 && @or <= 6
            message += ' - 4+ trains rust after OR 8' if @or > 6 && @or <= 8
            message += " - Game end after OR #{@last_or}" if @or > 8
            "#{name} Round #{@or} (of #{@last_or})#{message}"
          end
        end

        def store_player_info
          @players.each do |p|
            p.history << G18MS::PlayerInfo.new(@round.class.short_name, turn, @round.round_num, player_value(p))
          end
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Exchange,
            G18MS::Step::SpecialTrack,
            G18MS::Step::SpecialToken,
            G18MS::Step::BuyCompany,
            G18MS::Step::Track,
            G18MS::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::SpecialBuyTrain,
            G18MS::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::BuySellParShares,
          ])
        end

        def init_round
          Round::Draft.new(self, [G18MS::Step::SimpleDraft], reverse_order: true)
        end

        def priority_deal_player
          return @players.first if @round.is_a?(Round::Draft)

          super
        end

        def or_round_finished
          @recently_floated = []

          # In case we get phase change during the last OR set we ensure we have 3 ORs
          @operating_rounds = 3 if @three_or_round
        end

        def or_set_finished
          case @turn
          when 3 then rust_all('2+', 20)
          when 4 then rust_all('3+', 30)
          when 5 then rust_all('4+', 60)
          end
        end

        def or_description_short(turn, round)
          (((turn - 1) * 2) + round).to_s
        end

        # Game will end directly after the end of OR 10
        def game_end_check_fixed_round?
          @or == @last_or
        end

        def purchasable_companies(entity = nil)
          entity ||= current_entity
          return [] if entity.company?

          # Only companies owned by the president may be bought
          # Allow MC to be bought only before OR 3.1 and there is room for a 2+ train
          companies = super.select { |c| c.owned_by?(entity.player) }
          companies.reject! { |c| c.id == 'MC' && (@turn >= 3 || entity.trains.size == train_limit(entity)) }

          return companies unless @phase.status.include?('can_buy_companies_operation_round_one')

          return [] if @turn > 1

          companies.select do |company|
            COMPANY_1_AND_2.include?(company.id)
          end
        end

        def revenue_for(route, stops)
          super + hex_bonus_amount(route, stops)
        end

        def revenue_str(route)
          str = super

          str += ' + New Orleans' if hex_bonus_amount(route, route.stops).positive?

          str
        end

        def routes_revenue(routes)
          return 0 if routes.empty?

          if @round.round_num == 2
            routes.first.corporation.trains.each do |t|
              next unless t.name == "#{@turn}+"

              # Trains that are going to be salvaged at the end of this OR
              # cannot be sold when they have been run
              t.buyable = false unless @optional_rules&.include?(:allow_buy_rusting)
            end
          end

          super
        end

        def event_remove_tokens!
          @corporations.each do |corporation|
            abilities(corporation, :hexes_bonus) do |a|
              bonus_hex = @hexes.find { |h| a.hexes.include?(h.name) }
              hex_name = bonus_hex.name
              corporation.remove_ability(a)

              @log << "Route bonus is removed from #{get_location_name(hex_name)} (#{hex_name})"
            end
          end
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super

          return upgrades unless tile_manifest

          # Tile manifest for tile 15 should show brown Mobile City as a potential upgrade
          upgrades |= [@mobile_city_brown] if @mobile_city_brown && tile.name == '15'

          # Tile manifest for tile 63 should show 446 as a potential upgrade
          upgrades |= [@gray_tile] if @gray_tile && tile.name == '63'

          upgrades
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end

        def tile_lays(entity)
          return super unless @recently_floated.include?(entity)

          FIRST_OR_TILE_LAYS
        end

        def add_free_train_and_close_company(corporation, company)
          @free_train.buyable = true
          buy_train(corporation, @free_train, :free)
          @free_train.buyable = false
          company.close!
          @log << "#{corporation.name} exchanges #{company.name} for a free non sellable #{@free_train.name} train"
        end

        def get_location_name(hex_name)
          @hexes.find { |h| h.name == hex_name }.location_name
        end

        def remove_icons(hex_to_clear)
          @hexes
            .select { |hex| hex_to_clear == hex.name }
            .each { |hex| hex.tile.icons = [] }
        end

        def president_assisted_buy(corporation, train, price)
          # Can only assist if corporation cannot afford the train, but can pay at least 50%.
          # Corporation also need to own at least one train, and the train need to be permanent.
          if corporation.trains.size.positive? &&
            !train.name.include?('+') &&
            corporation.cash >= price / 2 &&
            price > corporation.cash

            fee = 50
            president_assist = price - corporation.cash
            return [president_assist, fee] unless corporation.player.cash < president_assist + fee
          end

          super
        end

        def show_progress_bar?
          true
        end

        def progress_information
          base_progress = [
            { type: :PRE },
            { type: :SR },
            { type: :OR, name: '1' },
            { type: :OR, name: '2' },
            { type: :SR },
            { type: :OR, name: '3' },
            { type: :OR, name: '4', exportAfter: true, exportAfterValue: '2+' },
            { type: :SR },
            { type: :OR, name: '5' },
            { type: :OR, name: '6', exportAfter: true, exportAfterValue: '3+' },
            { type: :SR },
            { type: :OR, name: '7' },
            { type: :OR, name: '8', exportAfter: true, exportAfterValue: '4+' },
            { type: :SR },
            { type: :OR, name: '9' },
            { type: :OR, name: '10' },
          ]

          base_progress << { type: :OR, name: '11' } if @optional_rules&.include?(:or_11)
          base_progress << { type: :End }
        end

        private

        def rust_all(train, salvage)
          rusted_trains = trains.select { |t| !t.rusted && t.name == train }
          return if rusted_trains.empty?

          owners = Hash.new(0)
          rusted_trains.each do |t|
            if t.owner.corporation? && t.owner.full_name != 'Neutral'
              @bank.spend(salvage, t.owner)
              owners[t.owner.name] += 1
            end
            rust(t)
          end

          @log << "-- Event: #{rusted_trains.map(&:name).uniq} trains rust " \
                  "( #{owners.map { |c, t| "#{c} x#{t}" }.join(', ')}) --"
          @log << "Corporations salvage #{format_currency(salvage)} from each rusted train"
        end

        def hex_bonus_amount(route, stops)
          hex_bonus_amount = 0
          abilities(route.corporation, :hexes_bonus) do |ability|
            hex_bonus_amount += ability.amount if stops.any? { |s| ability.hexes.include?(s.hex.id) }
          end

          hex_bonus_amount
        end
      end
    end
  end
end
