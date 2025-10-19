# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapGotlandCustomization
        D_TILE_MAP = {
          'B9' => [3, 4, 4, 5, 5, 6],
          'D3' => [4, 4, 5, 0, 0, 1],
          'D7' => [3, 4, 5, 0, 1, 2],
        }.freeze

        B3_BASE_REVENUE_GREEN = 50
        B3_BASE_REVENUE_BROWN = 70
        DIFFICULTY_VALUES = {
          'easy' => 10,
          'normal' => 20,
          'hard' => 30,
          'very_hard' => 40,
        }.freeze

        CHOICES = {
          1 => 'Sell All Shares',
          2 => 'Sell 1 Share',
          3 => 'Status quo',
          4 => 'Buy 1 Share',
          5 => 'Buy 2 Shares',
          6 => 'Buy 3 Shares',
        }.freeze

        MARKET_1D_WITH_30B = [
          %w[30c
             40
             45
             50p
             55p
             60p
             65p
             70p
             80p
             90p
             100p
             110p
             120p
             135p
             150p
             165
             180
             200
             220
             245
             270
             300
             330
             360
             400
             440
             490
             540],
        ].freeze

        def map_gotland_setup
          @newly_floated_corporations = []
          rival.owner = rival
        end

        def map_gotland_constants
          redef_const(:CURRENCY_FORMAT_STR, '%s SEK')
          redef_const(:BANKRUPTCY_ENDS_GAME_AFTER, :one)
        end

        def map_gotland_game_companies
          []
        end

        def map_gotland_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:float_percent] = 40
            c[:coordinates] = %w[B5 B9 D11 B5 G2][idx]
            c[:city] = [1, nil, nil, 0, nil][idx]
            c[:shares] = [40, 20, 20, 20]
            c[:max_ownership_percent] = 100
            c[:tokens] = [0, -40, -100]
          end
          @corporation_float_order = corps.sort_by { rand }
          corps << {
            floatable: false,
            hide_shares: true,
            sym: 'RIVALS',
            name: 'Evil Pontus & Co',
            tokens: [],
            shares: [100],
            logo: 'System18/KKN',
            simple_logo: 'System18/KKN.alt',
            color: '#000000',
            text_color: '#ffffff',
          }
          corps << {
            floatable: false,
            hide_shares: true,
            sym: 'SJ',
            name: 'SJ',
            tokens: [],
            shares: [100],
            logo: 'System18/DGN',
            simple_logo: 'System18/DGN.alt',
            color: '#000000',
            text_color: '#ffffff',
          }
          corps
        end

        def map_gotland_game_cash
          { 1 => 180 }
        end

        def map_gotland_game_market
          self.class::MARKET_1D_WITH_30B
        end

        def map_gotland_close_corporation(corporation)
          corporation.set_cash(0, @bank)
          corporation.close!
          @log << "#{corporation.name} did not survive you lose"
          end_game!(:bankrupt)
        end

        def map_gotland_game_trains(trains)
          trains.delete(find_train(trains, 'D'))
          find_train(trains, '2')[:num] = 6
          find_train(trains, '3')[:num] = 5
          find_train(trains, '4')[:num] = 4
          find_train(trains, '5')[:num] = 3
          find_train(trains, '6')[:num] = 2
          find_train(trains, '8')[:num] = 8
          trains
        end

        def map_gotland_game_phases
          self.class::S18_INCCAP_PHASES
        end

        def map_gotland_game_cert_limit
          { 1 => 99 }
        end

        def map_gotland_game_capitalization
          :incremental
        end

        def map_gotland_game_tiles(tiles)
          tiles.merge!({
                         'SVD2' => {
                           'count' => 1,
                           'color' => 'green',
                           'code' => 'city=revenue:40,slots:1;path=a:2,b:_0;path=a:3,b:_0;label=D',
                         },
                         'SVD3' => {
                           'count' => 1,
                           'color' => 'green',
                           'code' => 'city=revenue:40,slots:1;path=a:1,b:_0;path=a:3,b:_0;label=D',
                         },
                         'SGV2' => {
                           'count' => 1,
                           'color' => 'green',
                           'code' => 'city=revenue:50,slots:1;city=revenue:50,slots:1;'\
                                     'path=a:0,b:_0;path=a:3,b:_0,track:narrow;'\
                                     'path=a:4,b:_1;path=a:3,b:_1,track:narrow;label=V',
                         },
                         'SVD4' => {
                           'count' => 1,
                           'color' => 'brown',
                           'code' => 'city=revenue:50,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;label=D',
                         },
                         'SGV3' => {
                           'count' => 1,
                           'color' => 'brown',
                           'code' => 'city=revenue:70,slots:1;city=revenue:70,slots:1;'\
                                     'path=a:0,b:_0;path=a:3,b:_0,track:narrow;'\
                                     'path=a:4,b:_1;path=a:3,b:_1,track:narrow;label=V',
                         },
                       })
        end

        def map_gotland_game_location_names
          {
            'B5' => 'Visby',
            'B9' => 'Klintehamn',
            'B11' => 'Hablingbo, Havdhem',
            'B13' => 'Burgsvik',
            'C8' => 'Tjuls, Stenstu',
            'C10' => 'Hemse',
            'D3' => 'Tingstäde',
            'D5' => 'Lokrume',
            'D7' => 'Roma',
            'D9' => 'Etelhem, Stånga',
            'D11' => 'Ronehamn',
            'E4' => 'Lärbro, Slite',
            'G2' => 'Fårösund',
          }
        end

        def d_tile(hex_id)
          dice_value = rand.to_i % 6
          rotation = D_TILE_MAP[hex_id][dice_value]
          @log << "D TILE: #{hex_id} Dice value: #{dice_value + 1}"
          "city=revenue:30,slots:1;path=a:#{rotation},b:_0;label=D"
        end

        # ----- Difficulty level -----
        def difficulty_level
          @difficulty_level
        end

        def assign_difficulty_level(level)
          @difficulty_level = level
          redef_const(:TILE_LAYS, [{ lay: true, upgrade: true, cost: difficulty_level_value }].freeze)
          reduce_float_costs(0)

          @green_value = B3_BASE_REVENUE_GREEN - difficulty_level_value
          @brown_value = B3_BASE_REVENUE_BROWN - difficulty_level_value
          # Update the B3 hex with the new values
          hex = hex_by_id('B3')
          hex.tile.offboards.first.revenue = { 'green' => @green_value, 'brown' => @brown_value }
        end

        def difficulty_level_value
          @difficulty_value ||= DIFFICULTY_VALUES[difficulty_level]
        end

        def map_hexes
          {
            white: {
              %w[B7 C4 C6 C12 E2 E6 E8 F3] => '',
              %w[B11 D9 E4] => 'town=revenue:0;town=revenue:0',
              %w[B13 D5 D11 G2] => 'city=revenue:10',
            },
            yellow: {
              %w[B5] => 'city=revenue:30,slots:1;city=revenue:30,slots:1;path=a:0,b:_0;path=a:4,b:_1;label=V',
              ['C10'] => 'city=revenue:0,slots:1;label=B',
              ['C8'] => 'city=revenue:0,slots:1;city=revenue:0,slots:1;label=OO',
              ['B9'] => d_tile('B9'),
              ['D3'] => d_tile('D3'),
              ['D7'] => d_tile('D7'),
            },
            red: {
              %w[B3] => 'offboard=revenue:green_50|brown_70,format:%d-X;path=a:0,b:_0,track:narrow',
            },
            blue: {
              %w[A12] => 'offboard=revenue:yellow_10|brown_20;path=a:5,b:_0',
              %w[C14 F5] => 'offboard=revenue:yellow_10|brown_20;path=a:2,b:_0',
              %w[D13] => 'offboard=revenue:yellow_10|brown_20;path=a:3,b:_0',
            },
            gray: {
              ['F1'] => 'path=a:0,b:5',
              ['G4'] => 'path=a:2,b:3',
            },
          }
        end

        def map_gotland_game_hexes
          map_hexes
        end

        def rival
          @rival ||= corporation_by_id('RIVALS')
        end

        def sj
          @sj ||= corporation_by_id('SJ')
        end

        def map_gotland_layout
          :flat
        end

        def map_gotland_stock_round
          GSystem18::Round::Stock.new(self, stock_steps)
        end

        def map_gotland_operating_steps
          [
            GSystem18::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            GSystem18::Step::Track,
            GSystem18::Step::Token,
            Engine::Step::Route,
            GSystem18::Step::Dividend,
            GSystem18::Step::BuyTrain,
          ]
        end

        def map_gotland_init_round
          # Start with difficulty selection if not already set
          return GSystem18::Round::DifficultySelection.new(self, [GSystem18::Step::DifficultySelection]) unless difficulty_level

          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter = 1
          stock_round
        end

        def reduce_float_costs(floated_corporation_index)
          order = @corporation_float_order
          if floated_corporation_index&.positive? && floated_corporation_index&.<(order.size)
            order = order[floated_corporation_index..-1] + order[0...floated_corporation_index]
          end
          count = 0
          order.each do |corp_hash|
            corp = corporation_by_id(corp_hash[:sym])
            next if corp.floated?

            ability = corp.all_abilities.find do |a|
              a.is_a?(Engine::Game::GSystem18::Gotland::FloatCost) && a.float_cost&.positive?
            end
            new_cost = difficulty_level_value * count
            count += 1
            if new_cost.zero?
              corp.remove_ability(ability) if ability
            else
              ability ||= Engine::Game::GSystem18::Gotland::FloatCost.new(type: 'float_cost', description: '', desc_detail: '',
                                                                          float_cost: new_cost)
              corp.add_ability(ability) unless corp.all_abilities.include?(ability)
              ability.float_cost = new_cost
              ability.description = "Float cost: #{new_cost}"
              ability.desc_detail = "This corporation requires #{new_cost} to float"
            end
          end
        end

        def map_gotland_can_par?(corporation, player)
          player_president_shares = corporations.count { |corp| corp.president?(player) }
          return false if player_president_shares >= 4

          # Super
          !corporation.ipoed
        end

        def map_gotland_float_corporation(corporation)
          player = corporation.owner

          ability = corporation.all_abilities.find do |a|
            a.is_a?(Engine::Game::GSystem18::Gotland::FloatCost) && a.float_cost && a.float_cost.positive?
          end
          if ability
            float_cost = ability.float_cost
            if player.cash < float_cost
              raise GameError,
                    "#{player.name} does not have enough cash to float #{corporation.name}. "
            end
            player.spend(float_cost, @bank)
            @log << "#{player.name} pays #{format_currency(float_cost)} to float #{corporation.name}"
            corporation.remove_ability(ability)
          end
          floated_index = @corporation_float_order.index { |c| c[:sym] == corporation.id }
          reduce_float_costs(floated_index)

          @log << "#{corporation.name} floats"

          # Track newly floated corporations for the current stock round
          track_newly_floated(corporation) if @round.is_a?(GSystem18::Round::Stock)

          return if %i[incremental none].include?(corporation.capitalization)

          @bank.spend(corporation.par_price.price * corporation.total_shares, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
        end

        # ----- Rival share randomizer -----
        def rival_share_randomizer
          @log << '-- Rival share randomizer --'
          dice_num = (rand.to_i % 6) + 1
          @log << "Rivals share random action: #{dice_num} - #{CHOICES[dice_num]}"
          case dice_num
          when 1
            handle_sell(rival, :all)
          when 2
            handle_sell(rival, 1)
          when 3
            @log << 'Rival passes'
          when 4, 5, 6
            handle_buy(rival, dice_num - 3)
          end
        end

        def handle_buy(rival, count)
          bundles = find_buyable_bundles(rival, count)
          return @log << 'No available shares to buy' if bundles.empty?

          bundles.each { |bundle| rival_buy_shares(bundle) }
        end

        def find_buyable_bundles(_entity, count)
          bundles = []
          corporations.select(&:floated?).sort_by { |corp| -(corp.share_price&.price || 0) }.each do |corp|
            break if bundles.size >= count

            share = corp.treasury_shares&.first || share_pool.shares_by_corporation[corp]&.first
            bundles << share.to_bundle if share
          end
          bundles
        end

        def rival_buy_shares(bundle)
          @log << "Rival buys one share from #{bundle.corporation.name}"
          share_pool.buy_shares(rival, bundle, exchange: true)
        end

        def handle_sell(rival, count)
          shares = collect_rival_shares(rival)
          return @log << 'Rival does not have any shares to sell' if shares.empty?

          shares_to_sell = count == :all ? shares : [find_lowest_value_share(shares)]
          rival_sell_shares(shares_to_sell)
        end

        def rival_sell_shares(shares)
          shares = [shares] unless shares.is_a?(Array)
          shares.group_by(&:corporation).each do |corp, corp_shares|
            @log << "Rival sells #{corp_shares.sum(&:percent)}% of #{corp.name}"
            corp_shares.each do |share|
              share_pool.transfer_shares(share.to_bundle, share_pool, allow_president_change: false)
            end
          end
        end

        def collect_rival_shares(rival)
          corporations.select(&:floated?).flat_map do |corp|
            rival.shares_by_corporation[corp] || []
          end
        end

        def find_lowest_value_share(shares)
          shares.min_by { |share| share.corporation.share_price&.price || 0 }
        end

        # ----- Nationalize -----
        def new_nationalization_round(round_num)
          GSystem18::Round::GotlandNationalization.new(self, [
              GSystem18::Step::GotlandNationalizeCorporation,
              ], round_num: round_num)
        end

        def nationalized?(entity)
          entity.type == :nationalized
        end

        def nationalize_requirement(market_value)
          case market_value
          when 0...59
            2
          when 60...90
            3
          when 100...150
            4
          else
            5
          end
        end

        def allow_nationalize?(corporation)
          dice_num = (rand.to_i % 6) + 1
          market_value = corporation.share_price&.price || 0
          can_nationalize = dice_num >= nationalize_requirement(market_value)
          @log << if can_nationalize
                    "Congratulation SJ are interesed to nationalize dice #{dice_num} " \
                      "need at least a #{nationalize_requirement(market_value)}"
                  else
                    "Sorry SJ is not interesed for the moment dice #{dice_num} " \
                      "need at least a #{nationalize_requirement(market_value)}"
                  end
          can_nationalize
        end

        def nationalize_corporation(corporation)
          market_value = corporation.share_price&.price || 0
          @log << "Nationalized #{corporation.name} receives #{format_currency(market_value)}"

          shares = @_shares.values.select { |share| share.corporation == corporation }

          corporation.share_holders.clear

          shares.each { |share| share.percent /= 2 }
          new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }

          shares.each { |share| corporation.share_holders[share.owner] += share.percent }

          new_shares.each do |share|
            add_new_share(share)
          end
          corporation.type = :nationalized

          bundle = ShareBundle.new(new_shares.take(1))
          @bank.spend(market_value, corporation)
          share_pool.buy_shares(sj, bundle, exchange: :free)
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def map_gotland_stock_finish_round
          # Check if any new corporations were floated during this stock round
          if @newly_floated_corporations.empty?
            # No new corporations floated, export trains equal to number of unfloated corporations
            unfloated_count = corporations.count { |c| !c.floated? && c.floatable }
            if unfloated_count.positive?
              log << 'No new corporations floated during stock round'
              log << "Exporting unfloated corporations count #{unfloated_count} train#{unfloated_count > 1 ? 's' : ''}"
              unfloated_count.times do
                depot.export! unless depot.upcoming.empty?
              end
            end
          end

          # Clear the tracking array for next stock round
          @newly_floated_corporations.clear
        end

        def track_newly_floated(corporation)
          @newly_floated_corporations << corporation
        end

        def map_gotland_next_round!
          @round =
            case @round
            when GSystem18::Round::DifficultySelection
              rival_share_randomizer
              new_stock_round
            when GSystem18::Round::GotlandNationalization
              @turn += 1
              or_set_finished
              rival_share_randomizer
              new_stock_round
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
                new_nationalization_round(@round.round_num)
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def map_gotland_can_dump?(entity, bundle)
          corporation = bundle.corporation
          return false if (corporation.share_holders[rival] || 0) > (corporation.share_holders[entity] - bundle.percent)

          bundle.can_dump?(entity)
        end
      end
    end
  end
end
