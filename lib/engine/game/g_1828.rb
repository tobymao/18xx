# frozen_string_literal: true

require_relative '../config/game/g_1828'
require_relative 'base'
require_relative '../g_1828/stock_market'
require_relative '../g_1828/system'
require_relative '../g_1828/shell'

module Engine
  module Game
    class G1828 < Base
      register_colors(hanBlue: '#446CCF',
                      steelBlue: '#4682B4',
                      brick: '#9C661F',
                      powderBlue: '#B0E0E6',
                      khaki: '#F0E68C',
                      darkGoldenrod: '#B8860B',
                      yellowGreen: '#9ACD32',
                      gray70: '#B3B3B3',
                      khakiDark: '#BDB76B',
                      thistle: '#D8BFD8',
                      lightCoral: '#F08080',
                      tan: '#D2B48C',
                      gray50: '#7F7F7F',
                      cinnabarGreen: '#61B329',
                      tomato: '#FF6347',
                      plum: '#DDA0DD',
                      lightGoldenrod: '#EEDD82')

      load_from_json(Config::Game::G1828::JSON)

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'North East, USA'
      GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1828.Games#rules'
      GAME_IMPLEMENTER = 'Chris Rericha based on 1828 by J C Lawrence'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1828.Games'

      MULTIPLE_BUY_TYPES = %i[unlimited].freeze

      MUST_BID_INCREMENT_MULTIPLE = true
      MIN_BID_INCREMENT = 5

      HOME_TOKEN_TIMING = :operate

      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_round, custom: :one_more_full_or_set }.freeze

      SELL_BUY_ORDER = :sell_buy_sell

      NEXT_SR_PLAYER_ORDER = :first_to_pass

      MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Yellow Phase Par',
                                            par_1: 'Green Phase Par',
                                            par_2: 'Blue Phase Par',
                                            par_3: 'Brown Phase Par',
                                            unlimited: 'Corporation shares can be held above 60%, ' \
                                                       'President may buy two shares at a time')

      STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :yellow,
                                                          par_1: :green,
                                                          par_2: :blue,
                                                          par_3: :brown,
                                                          unlimited: :gray,
                                                          endgame: :red)

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'green_par' => ['Green phase pars',
                        '$86 and $94 par prices are now available'],
        'blue_par' => ['Blue phase pars',
                       '$105 par price is now available'],
        'brown_par' => ['Brown phase pars',
                        '$120 par price is now available'],
        'remove_corporations' => ['Non-parred corporations removed',
                                  'All non-parred corporations are removed. Blocking tokens placed in home stations']
      ).freeze

      VA_COALFIELDS_HEX = 'K11'
      VA_TUNNEL_HEX = 'K13'
      COAL_MARKER_ICON = 'coal'
      COAL_MARKER_COST = 120

      def self.title
        '1828.Games'
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::CompanyPendingPar,
          Step::G1828::WaterfallAuction,
        ])
      end

      def stock_round
        Round::G1828::Stock.new(self, [
          Step::G1828::DiscardTrain,
          Step::G1828::RemoveTokens,
          Step::G1828::Merger,
          Step::G1828::Exchange,
          Step::G1828::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::G1828::Exchange,
          Step::G1828::DiscardTrain,
          Step::HomeToken,
          Step::G1828::SpecialTrack,
          Step::G1828::BuyCompany,
          Step::G1828::SpecialToken,
          Step::G1828::SpecialBuy,
          Step::G1828::Track,
          Step::G1828::Token,
          Step::G1828::Route,
          Step::G1828::Dividend,
          Step::G1828::SwapTrain,
          Step::G1828::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def setup
        setup_minors

        @log << "-- Setting game up for #{@players.size} players --"
        remove_extra_private_companies
        remove_extra_trains

        @coal_marker_ability =
          Engine::Ability::Description.new(type: 'description', description: 'Coal Marker')
        block_va_coalfields

        @blocking_corporation = Corporation.new(sym: 'B', name: 'Blocking', logo: '1828/blocking', tokens: [0])
      end

      def init_stock_market
        sm = Engine::G1828::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                            multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        sm.enable_par_price(67)
        sm.enable_par_price(71)
        sm.enable_par_price(79)

        sm
      end

      def init_tiles
        tiles = super

        tiles.find { |tile| tile.name == '53' }.label = 'Ba'
        tiles.find { |tile| tile.name == '61' }.label = 'Ba'
        tiles.find { |tile| tile.name == '121' }.label = 'Bo'
        tiles.find { |tile| tile.name == '997' }.label = 'Bo'

        tiles
      end

      SYSTEM_EXTRA_TILE_LAY = { lay: true, upgrade: :not_if_upgraded }.freeze
      CORP_EXTRA_TILE_LAY = { lay: :not_if_upgraded, upgrade: false, cost: 40 }.freeze
      EXTRA_TILE_LAY_CORPS = %w[B&M NYH].freeze

      def tile_lays(entity)
        tile_lays = super
        tile_lays += [SYSTEM_EXTRA_TILE_LAY] if entity.system?
        (entity.system? ? entity.corporations.map(&:name) : [entity.name]).each do |corp_name|
          tile_lays += [CORP_EXTRA_TILE_LAY] if EXTRA_TILE_LAY_CORPS.include?(corp_name)
        end

        tile_lays
      end

      def can_hold_above_limit?(_entity)
        true
      end

      def show_game_cert_limit?
        false
      end

      def init_round_finished
        @players.rotate!(@round.entity_index)

        @companies.each do |company|
          next unless company.owner

          abilities(company, :revenue_change, time: 'auction_end') do |ability|
            company.revenue = ability.revenue
          end
        end
      end

      def event_green_par!
        @log << "-- Event: #{EVENTS_TEXT['green_par'][1]} --"
        stock_market.enable_par_price(86)
        stock_market.enable_par_price(94)
        update_cache(:share_prices)
      end

      def event_blue_par!
        @log << "-- Event: #{EVENTS_TEXT['blue_par'][1]} --"
        stock_market.enable_par_price(105)
        update_cache(:share_prices)
      end

      def event_brown_par!
        @log << "-- Event: #{EVENTS_TEXT['brown_par'][1]} --"
        stock_market.enable_par_price(120)
        update_cache(:share_prices)
      end

      def event_close_companies!
        super

        @minors.dup.each { |minor| remove_minor!(minor, block: true) }
      end

      def event_remove_corporations!
        @log << "-- Event: #{EVENTS_TEXT['remove_corporations'][1]}. --"
        @corporations.reject(&:ipoed).each do |corporation|
          place_home_blocking_token(corporation)
          place_second_home_blocking_token(corporation) if corporation.name == 'ERIE'
          @log << "Removing #{corporation.name}"
          @corporations.delete(corporation)
        end
      end

      def custom_end_game_reached?
        @phase.current[:name] == 'Purple'
      end

      def remove_minor!(minor, block: false)
        minor.spend(minor.cash, @bank) if minor.cash.positive?
        minor.tokens.each do |token|
          city = token&.city
          token.remove!
          place_blocking_token(city.hex) if block && city
        end
        @graph.clear_graph_for(minor)
        @minors.delete(minor)

        @round.force_next_entity! if @round.current_entity == minor
      end

      def upgrades_to?(from, to, special = false)
        # Virginia tunnel can only be upgraded to #4 tile
        return false if from.hex.id == VA_TUNNEL_HEX && to.name != '4'

        super
      end

      def merge_candidates(player, corporation)
        return [] if !player || !corporation
        return [] if corporation.system?

        @corporations.select do |candidate|
          next if candidate == corporation ||
                  candidate.system? ||
                  !candidate.ipoed ||
                  (corporation.owner != player && candidate.owner != player) ||
                  candidate.operated? != corporation.operated? ||
                  (!candidate.floated? && !corporation.floated?)

          # account for another player having 5+ shares
          @players.any? do |p|
            num_shares = p.num_shares_of(candidate) + p.num_shares_of(corporation)
            num_shares >= 6 ||
              (num_shares == 5 && !sold_this_round?(p, candidate) && !sold_this_round?(p, corporation))
          end
        end
      end

      def sold_this_round?(entity, corporation)
        return false unless @round.players_sold

        @round.players_sold[entity][corporation]
      end

      def create_system(corporations)
        return nil unless corporations.size == 2

        system_data = CORPORATIONS.find { |c| c['sym'] == corporations.first.id }.dup
        system_data['sym'] = corporations.map(&:name).join('-')
        system_data['tokens'] = []
        system_data['game'] = self
        system_data['corporations'] = corporations
        system = init_system(@stock_market, system_data)

        @corporations << system
        @_corporations[system.id] = system
        system.shares.each { |share| @_shares[share.id] = share }

        place_system_blocking_tokens(system)

        # Make sure the system will not own two coal markers
        if coal_markers(system).size > 1
          remove_coal_marker(system)
          add_coal_marker_to_va_coalfields
          @log << "#{system.name} cannot have two coal markers, returning one to Virginia Coalfields"
        end

        @stock_market.set_par(system, system_market_price(corporations))
        system.ipoed = true

        system
      end

      def coal_marker_available?
        hex_by_id(VA_COALFIELDS_HEX).tile.icons.any? { |icon| icon.name == COAL_MARKER_ICON }
      end

      def coal_marker?(entity)
        return false unless entity.corporation?

        coal_markers(entity).any?
      end

      def coal_markers(entity)
        entity.all_abilities.select { |ability| ability.description == @coal_marker_ability.description }
      end

      def connected_to_coalfields?(entity)
        graph.connected_hexes(entity).include?(hex_by_id(VA_COALFIELDS_HEX))
      end

      def can_buy_coal_marker?(entity)
        return false unless entity.corporation?

        connected_to_coalfields?(entity) &&
          coal_marker_available? &&
          !coal_marker?(entity) &&
          buying_power(entity) >= COAL_MARKER_COST
      end

      def buy_coal_marker(entity)
        return unless can_buy_coal_marker?(entity)

        entity.spend(COAL_MARKER_COST, @bank)
        entity.add_ability(@coal_marker_ability.dup)
        @log << "#{entity.name} buys a coal marker for $#{COAL_MARKER_COST}"

        tile_icons = hex_by_id(VA_COALFIELDS_HEX).tile.icons
        tile_icons.delete_at(tile_icons.find_index { |icon| icon.name == COAL_MARKER_ICON })

        graph.clear
      end

      def acquire_va_tunnel_coal_marker(entity)
        entity = entity.owner if entity.company?

        @log << "#{entity.name} acquires a coal marker"
        if coal_marker?(entity)
          @log << "#{entity.name} already owns a coal marker, placing coal marker on Virginia Coalfields"
          add_coal_marker_to_va_coalfields
        else
          entity.add_ability(@coal_marker_ability.dup)
        end
      end

      def remove_coal_marker(entity)
        coal = entity.all_abilities.find { |ability| ability.description == @coal_marker_ability.description }
        entity.remove_ability(coal)
      end

      def add_coal_marker_to_va_coalfields
        hex_by_id(VA_COALFIELDS_HEX).tile.icons << Engine::Part::Icon.new('1828/coal', 'coal')
      end

      def block_va_coalfields
        coalfields = hex_by_id(VA_COALFIELDS_HEX).tile.cities.first

        coalfields.instance_variable_set(:@game, self)

        def coalfields.blocks?(corporation)
          !@game.coal_marker?(corporation)
        end
      end

      def can_run_route?(entity)
        return false if entity.id == 'C&P' && !@round.last_tile_lay

        super
      end

      def city_tokened_by?(city, entity)
        return @graph.connected_nodes(entity)[city] if entity.id == 'C&P'

        super
      end

      def place_home_token(corporation)
        if corporation.system? && !corporation.tokens.first&.used
          corporation.corporations.each do |c|
            token = Engine::Token.new(c)
            c.tokens << token
            place_home_token(c)
            token.swap!(corporation.tokens.find { |t| t.price.zero? && !t.used }, check_tokenable: false)
          end
        else
          super
        end
      end

      def place_blocking_token(hex, city_index: 0)
        @log << "Placing a blocking token on #{hex.name} (#{hex.location_name})"
        token = Token.new(@blocking_corporation)
        hex.tile.cities[city_index].place_token(@blocking_corporation, token, check_tokenable: false)
      end

      def exchange_for_partial_presidency?
        true
      end

      def exchange_partial_percent(share)
        return nil unless share.president

        100 / share.num_shares
      end

      def system_by_id(id)
        corporation_by_id(id)
      end

      private

      def setup_minors
        @minors.each do |minor|
          train = @depot.upcoming[1]
          train.buyable = false
          train.rusts_on = nil
          buy_train(minor, train, :free)
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token, free: true)
        end
      end

      def remove_extra_private_companies
        to_remove = companies.find_all { |company| company.value == 250 }
                             .sort_by { rand }
                             .take(7 - @players.size)
        to_remove.each do |company|
          company.close!
          @round.steps.find { |step| step.is_a?(Step::G1828::WaterfallAuction) }.companies.delete(company)
          @log << "Removing #{company.name}"
        end
      end

      def remove_extra_trains
        return unless @players.size < 5

        to_remove = @depot.trains.reverse.find { |train| train.name == '5' }
        @depot.remove_train(to_remove)
        @log << "Removing #{to_remove.name} train"
      end

      def place_home_blocking_token(corporation, city_index: 0)
        hex = hex_by_id(corporation.coordinates)
        hex.tile.cities[city_index].remove_reservation!(corporation)
        place_blocking_token(hex, city_index: city_index)
      end

      def place_second_home_blocking_token(corporation)
        place_home_blocking_token(corporation, city_index: 1)
      end

      def init_system(stock_market, system)
        Engine::G1828::System.new(
          min_price: stock_market.par_prices.map(&:price).min,
          capitalization: self.class::CAPITALIZATION,
          **system.merge(corporation_opts),
        )
      end

      def place_system_blocking_tokens(system)
        system.tokens.select(&:used).group_by(&:city).each do |city, tokens|
          next unless tokens.size > 1

          tokens[1].remove!
          place_blocking_token(city.hex)
        end
      end

      def system_market_price(corporations)
        market = @stock_market.market
        share_prices = corporations.map(&:share_price)
        share_values = share_prices.map(&:price).sort

        left_most_col = share_prices.min { |a, b| a.coordinates[1] <=> b.coordinates[1] }.coordinates[1]
        max_share_value = share_values[1] + (share_values[0] / 2).floor

        new_market_price = nil
        if market[0][left_most_col].price < max_share_value
          i = market[0].size - 1
          i -= 1 while market[0][i].price > max_share_value
          new_market_price = market[0][i]
        else
          i = 0
          i += 1 while market[i][left_most_col].price > max_share_value
          new_market_price = market[i][left_most_col]
        end

        new_market_price
      end
    end
  end
end
