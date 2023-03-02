# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G18CZ
      class Game < Game::Base
        include_meta(G18CZ::Meta)
        include StubsAreRestricted
        include Map
        include Entities

        register_colors(brightGreen: '#c2ce33',
                        beige: '#e5d19e',
                        lightBlue: '#1EA2D6',
                        mintGreen: '#B1CEC7',
                        yellow: '#ffe600',
                        lightRed: '#F3B1B3')

        CURRENCY_FORMAT_STR = '%s K'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 14, 3 => 14, 4 => 12, 5 => 10, 6 => 9 }.freeze

        STARTING_CASH = { 2 => 280, 3 => 380, 4 => 300, 5 => 250, 6 => 210 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TRACK_RESTRICTION = :permissive

        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_block
        MARKET_SHARE_LIMIT = 1000 # notionally unlimited shares in market

        MUST_BUY_TRAIN = :always

        HOME_TOKEN_TIMING = :operate
        LIMIT_TOKENS_AFTER_MERGER = 999
        NEXT_SR_PLAYER_ORDER = :most_cash

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false # if ebuying from depot, must buy cheapest train
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        EBUY_CAN_SELL_SHARES = false # player cannot sell shares

        AVAILABLE_CORP_COLOR = '#c6e9af'

        SHOW_SHARE_PERCENT_OWNERSHIP = true # allow corporation cards to show percentage ownership breakdown for players

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :red,
          par_2: :green,
          par_overlap: :blue
        ).freeze

        PAR_RANGE = {
          small: [50, 55, 60, 65, 70],
          medium: [60, 70, 80, 90, 100],
          large: [90, 100, 110, 120],
        }.freeze

        MARKET_TEXT = {
          par: 'Small Corporation Par',
          par_overlap: 'Medium Corporation Par',
          par_2: 'Large Corporation Par',
        }.freeze

        COMPANY_VALUES = [40, 45, 50, 55, 60, 65, 70, 75, 80, 90, 100, 110, 120].freeze

        OR_SETS = [1, 1, 1, 1, 2, 2, 2, 3].freeze

        GAME_END_REASONS_TEXT = Base::EVENTS_TEXT.merge(
          custom: 'End of Game',
        ).freeze

        GAME_END_REASONS_TIMING_TEXT = Base::EVENTS_TEXT.merge(
          full_or: 'Ends after the last OR set',
        ).freeze

        GAME_END_CHECK = { custom: :full_or }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'medium_corps_available' => ['Medium Corps Available',
                                       '5-share corps ATE, BN, BTE, KFN, NWB are available to start'],
          'large_corps_available' => ['Large Corps Available',
                                      '10-share corps By, kk, Sx, Pr, Ug are available to start']
        ).freeze

        TRAINS_FOR_CORPORATIONS = {
          '2a' => :small,
          '2b' => :small,
          '3c' => :small,
          '3d' => :small,
          '4e' => :small,
          '4f' => :small,
          '5g' => :small,
          '5h' => :small,
          '5i' => :small,
          '5j' => :small,
          '2+2b' => :medium,
          '2+2c' => :medium,
          '3+3d' => :medium,
          '3+3e' => :medium,
          '4+4f' => :medium,
          '4+4g' => :medium,
          '5+5h' => :medium,
          '5+5i' => :medium,
          '5+5j' => :medium,
          '3Ed' => :large,
          '3Ee' => :large,
          '4Ef' => :large,
          '4Eg' => :large,
          '5Eh' => :large,
          '6Ei' => :large,
          '8Ej' => :large,
        }.freeze

        COMPANY_REVENUE_TO_TYPE = {
          5 => 'Small',
          10 => 'Medium',
          20 => 'Large',
        }.freeze

        TWO_PLAYER_CORP_TO_REMOVE = %w[OFE MW KFN PR Ug].freeze
        TWO_PLAYER_COMPANIES_TO_REMOVE = {
          5 => 40,
          10 => 55,
          20 => 70,
        }.freeze

        TILE_RESERVATION_BLOCKS_OTHERS = :always

        TWO_PLAYER_HEXES_TO_REMOVE = %w[A22 B19 B21 B23 B25 C22 C24 C26 C28 D21 D23 D25 D27 D29 E20 E22 E24 E26
                                        E28 F21 F23 F25 F27 G20 G22 G24 G26 G28 H21 H23 H25 I20 I22 I24].freeze

        attr_accessor :rusted_variants

        def setup
          @or = 0
          @operating_rounds = 1
          @last_or = OR_SETS.size
          @recently_floated = []
          @rusted_variants = []
          @vaclavs_corporations = []

          unless multiplayer?
            @vaclav = Player.new(-1, 'Vaclav')
            @corporations = @corporations.reject { |item| TWO_PLAYER_CORP_TO_REMOVE.include?(item.name) }

            @corporations.select { |item| item.type == :large }.each { |item| item.max_ownership_percent = 70 }

            @players << @vaclav
          end

          # Only small companies are available until later phases
          @corporations, @future_corporations = @corporations.partition { |corporation| corporation.type == :small }
          @corporations.each { |corp| corp.reservation_color = self.class::AVAILABLE_CORP_COLOR }
          new_corporation_for_vaclav(:small) unless multiplayer?

          block_lay_for_purple_tiles
          init_player_debts
        end

        def new_corporation_for_vaclav(size)
          possible_corporations = @corporations.select { |corporation| corporation.type == size }
          index = rand % possible_corporations.size
          new_corporation = possible_corporations[index]

          new_corporation.ipoed = true
          new_corporation.owner = @vaclav
          new_corporation.tokens.each { |item| item.price = 0 }
          @recently_floated << new_corporation
          @vaclavs_corporations << new_corporation

          par_value = PAR_RANGE[new_corporation.type].first
          price = @stock_market.par_prices.find { |p| p.price == par_value }
          @stock_market.set_par(new_corporation, price)

          index = 0
          until new_corporation.floated?
            bundle = new_corporation.ipo_shares[index].to_bundle
            @share_pool.transfer_shares(bundle, @vaclav)
            index += 1
          end

          @log << "Vaclav receives new corporation #{new_corporation.name}"
          new_train_for_vaclav(new_corporation)
        end

        def new_train_for_vaclav(corporation)
          corporation.trains.each do |item|
            remove_train(item)
            item.owner = nil
          end
          train = @depot.upcoming.first
          variant = train.variants.values.find { |item| train_of_size?(item, corporation.type) }
          train.variant = variant[:name]
          source = train.owner
          remove_train(train)
          train.owner = corporation
          corporation.trains << train

          @phase.buying_train!(corporation, train, source)

          @log << "#{corporation.name} receives a new #{train.name} train"
        end

        def init_companies(players)
          companies = super
          companies = companies.reject { |item| item.value >= TWO_PLAYER_COMPANIES_TO_REMOVE[item.revenue] } unless multiplayer?
          companies
        end

        def active_players
          active = super
          return active if multiplayer? || active != [@vaclav]

          case active_step
          when G18CZ::Step::Track
            [player_for_track(current_entity)]
          when G18CZ::Step::Token
            [player_for_token(current_entity)]
          else
            players_without_vaclav
          end
        end

        def valid_actors(action)
          return super if multiplayer?

          action.entity.player == @vaclav ? active_players : super
        end

        def player_for_track(corporation)
          corporation.type == :medium ? players_without_vaclav[1] : players_without_vaclav[0]
        end

        def player_for_token(corporation)
          corporation.type == :medium ? players_without_vaclav[0] : players_without_vaclav[1]
        end

        def optional_hexes
          return game_hexes if multiplayer?

          new_hexes = {}
          game_hexes.keys.each do |color|
            new_map = game_hexes[color].transform_keys do |coords|
              coords - TWO_PLAYER_HEXES_TO_REMOVE
            end.to_h
            new_hexes[color] = new_map
          end
          new_hexes
        end

        def multiplayer?
          @multiplayer ||= @players.count { |item| item != @vaclav } > 2
        end

        def init_round
          G18CZ::Round::Draft.new(self,
                                  [G18CZ::Step::Draft],
                                  snake_order: true)
        end

        def stock_round
          G18CZ::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18CZ::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G18CZ::Round::Operating.new(self, [
            G18CZ::Step::HomeTrack,
            G18CZ::Step::SellCompanyAndSpecialTrack,
            G18CZ::Step::HomeToken,
            G18CZ::Step::ReduceTokens,
            G18CZ::Step::BuyCompany,
            G18CZ::Step::Track,
            G18CZ::Step::Token,
            Engine::Step::Route,
            G18CZ::Step::Dividend,
            G18CZ::Step::UpgradeOrDiscardTrain,
            G18CZ::Step::BuyCorporation,
            Engine::Step::DiscardTrain,
            G18CZ::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: :flip)
        end

        def init_player_debts
          @player_debts = @players.to_h { |player| [player.id, { debt: 0, penalty_interest: 0 }] }
        end

        def new_operating_round(round_num = 1)
          @or += 1
          @companies.each do |company|
            company.value = COMPANY_VALUES[@or - 1]
            company.min_price = 1
            company.max_price = company.value
          end

          super
        end

        def custom_end_game_reached?
          @turn == @last_or
        end

        def timeline
          @timeline = [
            'At the end of each set of ORs the next available train will be exported
           (removed, triggering phase change as if purchased)',
          ]
          @timeline.append("Game ends after OR #{OR_SETS.size}.#{OR_SETS.last}")
          @timeline.append("Current value of each private company is #{COMPANY_VALUES[[0, @or - 1].max]}")
          @timeline.append("Next set of Operating Rounds will have #{OR_SETS[@turn - 1]} ORs")
        end

        def able_to_operate?(entity, _train, name)
          TRAINS_FOR_CORPORATIONS[name] == entity.type
        end

        def par_prices(corp)
          par_nodes = stock_market.par_prices
          available_par_prices = PAR_RANGE[corp.type]
          par_nodes.select { |par_node| available_par_prices.include?(par_node.price) }
        end

        def event_medium_corps_available!
          medium_corps, @future_corporations = @future_corporations.partition do |corporation|
            corporation.type == :medium
          end
          medium_corps.each { |corp| corp.reservation_color = self.class::AVAILABLE_CORP_COLOR }
          @corporations.concat(medium_corps)
          @log << '-- Medium corporations now available --'

          new_corporation_for_vaclav(:medium) unless multiplayer?
        end

        def event_large_corps_available!
          @corporations.concat(@future_corporations)
          @future_corporations.clear
          @log << '-- Large corporations now available --'

          new_corporation_for_vaclav(:large) unless multiplayer?
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          @log << "#{corporation.name} floats"

          return if corporation.capitalization == :incremental

          @bank.spend(corporation.original_par_price.price * corporation.total_shares, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
        end

        def or_set_finished
          if multiplayer?
            depot.export!
          else
            # cloning is needed because vaclavs corporation changes when a new train triggers a new corporation
            @vaclavs_corporations.clone.each do |item|
              new_train_for_vaclav(item)
            end
          end
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              reorder_players(log_player_order: true)
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                @operating_rounds = OR_SETS[@turn - 1]
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players(:least_cash, log_player_order: true)
              clear_programmed_actions
              new_stock_round
            end
        end

        def tile_lays(entity)
          return super unless @recently_floated.include?(entity)

          floated_tile_lay = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
          floated_tile_lay.unshift({ lay: true, upgrade: true }) if entity.type == :large
          floated_tile_lay
        end

        def corporation_size(entity)
          # For display purposes is a corporation small, medium or large
          entity.type
        end

        def corporation_size_name(entity)
          entity.type[0].capitalize
        end

        def status_str(corp)
          train_type = case corp.type
                       when :small
                         'Normal '
                       when :medium
                         'Plus-'
                       else
                         'E-'
                       end
          "#{corp.type.capitalize} / #{train_type}Trains"
        end

        def status_array(corporation)
          return if !@vaclavs_corporations.include?(corporation) || !@round.current_entity&.player?

          ["Track: #{player_for_track(corporation).name}", "Token: #{player_for_token(corporation).name}"]
        end

        def block_lay_for_purple_tiles
          @tiles.each do |tile|
            tile.blocks_lay = true if purple_tile?(tile)
          end
        end

        def purple_tile?(tile)
          tile.name.end_with?('p')
        end

        def must_buy_train?(entity)
          !depot.depot_trains.empty? &&
          (entity.trains.empty? ||
            (entity.type == :medium && entity.trains.none? { |item| train_of_size?(item, :medium) }) ||
            (entity.type == :large && entity.trains.none? { |item| train_of_size?(item, :large) }))
        end

        def train_of_size?(item, size)
          name = if item.is_a?(Hash)
                   item[:name]
                 else
                   item.name
                 end

          TRAINS_FOR_CORPORATIONS[name] == size
        end

        def variant_is_rusted?(item)
          name = if item.is_a?(Hash)
                   item[:name]
                 else
                   item.name
                 end
          @rusted_variants.include?(name)
        end

        def home_token_locations(corporation)
          coordinates = COORDINATES_FOR_LARGE_CORPORATION[corporation.id]
          hexes.select { |hex| coordinates.include?(hex.coordinates) }
        end

        def place_home_token(corporation)
          return unless corporation.next_token # 1882
          # If a corp has laid it's first token assume it's their home token
          return if corporation.tokens.first&.used

          if corporation.coordinates.is_a?(Array)
            @log << "#{corporation.name} (#{corporation.owner.name}) must choose tile for home location"

            hexes = corporation.coordinates.map { |item| hex_by_id(item) }

            @round.pending_tracks << {
              entity: corporation,
              hexes: hexes,
            }

            @round.clear_cache!
          else
            hex = hex_by_id(corporation.coordinates)

            tile = hex&.tile

            if corporation.id == 'ATE'
              @log << "#{corporation.name} must choose city for home token"

              @round.pending_tokens << {
                entity: corporation,
                hexes: [hex],
                token: corporation.find_token_by_type,
              }

              @round.clear_cache!
              return
            end

            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
            token = corporation.find_token_by_type
            return unless city.tokenable?(corporation, tokens: token)

            @log << "#{corporation.name} places a token on #{hex.name}"
            city.place_token(corporation, token)
          end
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          return true if from.color == :white && to.color == :red

          return false unless from.paths_are_subset_of?(to.paths)

          if purple_tile?(to) && from.towns.size == 2 && !to.towns.empty? && from.color == :yellow && to.color == :green
            return true
          end

          super
        end

        def potential_tiles(corporation)
          tiles.select { |tile| tile.label&.to_s == corporation.name }
        end

        def rust?(train, purchased_train)
          train_symbols = if !purchased_train&.owner&.corporation?
                            purchased_train.variants.values.map do |item|
                              item[:name]
                            end
                          else
                            [purchased_train.name]
                          end
          !(train.rusts_on & train_symbols).empty?
        end

        def rust_trains!(train, entity)
          rusted_trains = []
          owners = Hash.new(0)
          # entity is nil when a train is exported. Then all trains are rusting
          train_symbol_to_compare = entity.nil? ? train.variants.values.map { |item| item[:name] } : [train.name]

          trains.each do |t|
            next if t.rusted
            next if t.rusts_on.nil? || t.rusts_on.none?
            next unless rust?(t, train)

            rusted_trains << t.name
            owners[t.owner.name] += 1 if t.owner
            rust(t)
          end

          all_varians = trains.flat_map do |item|
            item.variants.values
          end

          all_rusted_variants = all_varians.select do |item|
            item[:rusts_on] && !(item[:rusts_on] & train_symbol_to_compare).empty?
          end

          all_rusted_names = all_rusted_variants.map { |item| item[:name] }.uniq

          new_rusted = all_rusted_names - @rusted_variants
          return if new_rusted.none?

          @rusted_variants.concat(new_rusted)
          message = "Event: #{new_rusted.uniq.join(', ')} trains rust"
          message += " ( #{owners.map { |c, t| "#{c} x#{t}" }.join(', ')})" unless owners.none?

          @log << "-- #{message} --"
        end

        def revenue_for(route, stops)
          if route.corporation.type == :large
            number_of_stops = route.train.distance[0][:pay]
            all_stops = stops.map do |stop|
              stop.route_revenue(route.phase, route.train)
            end.sort.reverse.take(number_of_stops)
            revenue = all_stops.sum
            revenue += 50 if stops.any? { |stop| stop.tile.label.to_s == route.corporation.id }
            return revenue
          end
          stops.sum { |stop| stop.route_revenue(route.phase, route.train) }
        end

        def revenue_str(route)
          str = super
          str += " + #{route.corporation.name} bonus" if route.stops.any? do |stop|
                                                           stop.tile.label.to_s == route.corporation.id
                                                         end
          str
        end

        def increase_debt(player, amount)
          entity = @player_debts[player.id]
          entity[:debt] += amount
          entity[:penalty_interest] += amount
        end

        def reset_debt(player)
          entity = @player_debts[player.id]
          entity[:debt] = 0
        end

        def debt(player)
          @player_debts[player.id][:debt]
        end

        def penalty_interest(player)
          @player_debts[player.id][:penalty_interest]
        end

        def player_debt(player)
          debt(player)
        end

        def player_interest(player)
          penalty_interest(player)
        end

        def player_value(player)
          player.value - debt(player) - penalty_interest(player)
        end

        def result_players
          @players.reject { |p| p == @vaclav }
        end

        def liquidity(player, emergency: false)
          return player.cash if emergency

          super
        end

        def ability_blocking_step
          @round.steps.find do |step|
            # currently, abilities only care about Tracker, the is_a? check could
            # be expanded to a list of possible classes/modules when needed
            step.is_a?(Engine::Step::Track) && !step.passed? && step.blocks?
          end
        end

        def ability_usable?(ability)
          case ability
          when Ability::TileLay
            ability.count&.positive?
          else
            true
          end
        end

        def new_token_price
          100
        end

        def route_trains(entity)
          runnable = super

          runnable.select { |item| train_of_size?(item, entity.type) }
        end

        def show_progress_bar?
          true
        end

        def progress_information
          [
            { type: :PRE },
            { type: :SR },
            { type: :OR, value: '40', name: '1.1', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '45', name: '2.1', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '50', name: '3.1', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '55', name: '4.1', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '60', name: '5.1' },
            { type: :OR, value: '65', name: '5.2', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '70', name: '6.1' },
            { type: :OR, value: '75', name: '6.2', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '80', name: '7.1' },
            { type: :OR, value: '90', name: '7.2', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '100', name: '8.1' },
            { type: :OR, value: '110', name: '8.2' },
            { type: :OR, value: '120', name: '8.3' },
            { type: :End },
          ]
        end

        def route_distance(route)
          return super if train_of_size?(route.train, :small)

          n_cities = route.stops.count { |n| n.city? || n.offboard? }

          return n_cities if train_of_size?(route.train, :large)

          n_towns = route.stops.count(&:town?)
          max_towns = route.train.distance.find { |d| d['nodes'] == ['town'] }['pay']
          towns_as_cities = [0, n_towns - max_towns].max
          "#{n_cities + towns_as_cities}+#{n_towns - towns_as_cities}"
        end

        def can_par?(corporation, parrer)
          super && debt(parrer).zero?
        end

        def corporation_of_vaclav?(corporation)
          @vaclavs_corporations.include?(corporation)
        end

        def player_of_index(index)
          players_without_vaclav[index]
        end

        def players_without_vaclav
          exclude_vaclav(@players)
        end

        def exclude_vaclav(entities)
          entities.reject { |item| item == @vaclav }
        end

        def track_action_processed(entity)
          @recently_floated.delete(entity)
        end

        def next_sr_position(entity)
          player_order = @round.current_entity&.player? ? [] : players_without_vaclav
          player_order.index(entity)
        end

        # extra cash available if the corporation sells a company to the bank
        def potential_company_cash(entity)
          if @phase.status.include?('can_buy_companies') && entity.corporation?
            @companies.reduce(0) do |memo, company|
              memo +
                if company.owned_by_player? && entity.cash.positive?
                  company.value - 1
                elsif company.owner == entity
                  company.value
                else
                  0
                end
            end
          else
            0
          end
        end

        def token_buying_power(entity)
          buying_power(entity) + potential_company_cash(entity)
        end

        def reorder_players(order = nil, log_player_order: false)
          return super if multiplayer?

          order ||= next_sr_player_order
          case order
          when :most_cash
            current_order = @players.dup.reverse
            @players = players_without_vaclav.sort_by { |p| [p.cash, current_order.index(p)] }.reverse
          when :least_cash
            current_order = @players.dup
            @players = players_without_vaclav.sort_by { |p| [p.cash, current_order.index(p)] }
          end
          @players << @vaclav
          @log << if log_player_order
                    "Priority order: #{players_without_vaclav.map(&:name).join(', ')}"
                  else
                    "#{@players.first.name} has priority deal"
                  end
        end

        def company_size(company)
          COMPANY_REVENUE_TO_TYPE[company.revenue]
        end

        def company_size_str(company)
          COMPANY_REVENUE_TO_TYPE[company.revenue][0]
        end

        def company_sale_price(company)
          company.value
        end

        def maximum_share_price_change(entity)
          position = entity.share_price.coordinates.last
          return 2 if position.odd? # movement on the top row is capped only by the market's end

          MARKET[0].size - 2 - position
        end

        def remove_ate_reservation
          hex = hex_by_id('B9')
          hex.tile.reservations.clear
        end
      end
    end
  end
end
