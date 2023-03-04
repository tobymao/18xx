# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'
require_relative '../trainless_shares_half_value'
require_relative '../../distance_graph'

module Engine
  module Game
    module G1860
      class Game < Game::Base
        include_meta(G1860::Meta)
        include TrainlessSharesHalfValue
        include Entities
        include Map

        attr_reader :nationalization, :sr_after_southern, :distance_graph

        register_colors(black: '#000000',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#ff0000',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '£%s'

        BANK_CASH = 10_000

        CERT_LIMIT = { 2 => 32, 3 => 21, 4 => 16 }.freeze

        STARTING_CASH = { 2 => 1000, 3 => 670, 4 => 500 }.freeze

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
             40r
             44r
             47r
             50r
             52r
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
             105
             110
             116
             122
             128
             134
             142
             150
             158i
             166i
             174i
             182i
             191i
             200i
             210i
             220i
             230i
             240i
             250i
             260i
             270i
             280i
             290i
             300i
             310i
             320i
             330i
             340e],
           ].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3+2',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '4',
                    on: '4+2',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '5',
                    on: '5+3',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '6',
                    on: '6+3',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '7',
                    on: '7+4',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '8',
                    on: '8+4',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '9',
                    on: '9+5',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [
          {
            name: '2+1',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[town halt], 'pay' => 1, 'visit' => 99 }],
            price: 250,
            rusts_on: '4+2',
            num: 5,
          },
          {
            name: '3+2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => %w[town halt], 'pay' => 2, 'visit' => 99 }],
            price: 300,
            rusts_on: '6+3',
            num: 4,
          },
          {
            name: '4+2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => %w[town halt], 'pay' => 2, 'visit' => 99 }],
            price: 350,
            rusts_on: '7+4',
            num: 3,
          },
          {
            name: '5+3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[town halt], 'pay' => 3, 'visit' => 99 }],
            price: 400,
            rusts_on: '8+4',
            num: 2,
          },
          {
            name: '6+3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => %w[town halt], 'pay' => 3, 'visit' => 99 }],
            price: 500,
            num: 2,
            events: [{ 'type' => 'fishbourne_to_bank' }],
          },
          {
            name: '7+4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => %w[town halt], 'pay' => 4, 'visit' => 99 }],
            price: 600,
            num: 1,
          },
          {
            name: '8+4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => %w[town halt], 'pay' => 4, 'visit' => 99 }],
            price: 700,
            num: 1,
            events: [{ 'type' => 'relax_cert_limit' }],
          },
          {
            name: '9+5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 9, 'visit' => 9 },
                       { 'nodes' => %w[town halt], 'pay' => 5, 'visit' => 99 }],
            price: 800,
            num: 16,
            events: [{ 'type' => 'southern_forms' }],
          },
        ].freeze

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        HOME_TOKEN_TIMING = :float
        SELL_AFTER = :any_time
        SELL_BUY_ORDER = :sell_buy
        PRESIDENT_SALES_TO_MARKET = true
        MARKET_SHARE_LIMIT = 100
        TRAIN_PRICE_MIN = 10
        TRAIN_PRICE_MULTIPLE = 10
        MIN_PAR_AFTER_BANKRUPTCY = 40

        COMPANY_SALE_FEE = 30

        SOLD_OUT_INCREASE = false

        STOCKMARKET_COLORS = {
          par: :yellow,
          endgame: :orange,
          close: :purple,
          repar: :gray,
          ignore_one_sale: :olive,
          multiple_buy: :brown,
          unlimited: :orange,
          no_cert_limit: :yellow,
          liquidation: :red,
          acquisition: :yellow,
          safe_par: :white,
        }.freeze

        MARKET_TEXT = {
          par: 'Par values (varies by corporation)',
          no_cert_limit: 'UNUSED',
          unlimited: 'UNUSED',
          multiple_buy: 'UNUSED',
          close: 'Corporation bankrupts',
          endgame: 'End game trigger',
          liquidation: 'UNUSED',
          repar: 'Par values after bankruptcy (varies by corporation)',
          ignore_one_sale: 'Ignore first share sold when moving price',
        }.freeze

        HALT_SUBSIDY = 10

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'fishbourne_to_bank' => ['Fishbourne', 'Fishbourne Ferry Company available for purchase.'],
          'relax_cert_limit' => ['No Cert Limit',
                                 "No limit on certificates/player; Selling doesn't reduce share price."],
          'southern_forms' => ['Southern Forms', 'Southern RR forms; No track or token after the next SR.']
        ).freeze

        OPTION_REMOVE_HEXES = %w[A5 A7 B4 E11].freeze
        OPTION_ADD_HEXES = { ['B4'] => 'city=revenue:0' }.freeze
        OPTION_TILES = %w[776-2 770-1].freeze

        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded_or_city, upgrade: false }].freeze

        GAME_END_CHECK = { stock_market: :current_or, bank: :current_or, custom: :immediate }.freeze
        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Nationalization complete'
        )

        PAR_RANGE = {
          1 => [74, 100],
          2 => [62, 82],
          3 => [58, 68],
          4 => [54, 62],
        }.freeze

        REPAR_RANGE = {
          1 => [40, 100],
          2 => [40, 82],
          3 => [40, 68],
          4 => [40, 62],
        }.freeze

        LAYER_BY_NAME = {
          'C&N' => 1,
          'IOW' => 1,
          'IWNJ' => 2,
          'FYN' => 2,
          'NGStL' => 3,
          'BHI&R' => 3,
          'S&C' => 4,
          'VYSC' => 4,
        }.freeze

        NO_ROTATION_TILES = %w[
          758
          761
          763
          773
          775
        ].freeze

        def init_bank
          # amount doesn't matter here
          Bank.new(20_000, log: @log, check: false)
        end

        def option_23p_map?
          @optional_rules&.include?(:two_player_map) || @optional_rules&.include?(:original_game)
        end

        def option_original_insolvency?
          @optional_rules&.include?(:original_insolvency) || @optional_rules&.include?(:original_game)
        end

        def option_no_skip_towns?
          @optional_rules&.include?(:no_skip_towns) || @optional_rules&.include?(:original_game)
        end

        def optional_hexes
          return self.class::HEXES unless option_23p_map?

          new_hexes = {}
          HEXES.keys.each do |color|
            new_map = self.class::HEXES[color].transform_keys do |coords|
              coords - OPTION_REMOVE_HEXES
            end
            OPTION_ADD_HEXES.each { |coords, tile_str| new_map[coords] = tile_str } if color == :white

            new_hexes[color] = new_map
          end

          new_hexes
        end

        def optional_tiles
          return unless option_23p_map?

          # remove 2nd edition tiles
          OPTION_TILES.each do |ot|
            @tiles.reject! { |t| t.id == ot }
            @all_tiles.reject! { |t| t.id == ot }
          end
        end

        def setup
          @distance_graph = DistanceGraph.new(self, separate_node_types: true)
          @bankrupt_corps = []
          @insolvent_corps = []
          @nationalized_corps = []
          @highest_layer = 1
          @node_distances = {}
          @path_distances = {}
          @hex_distances = {}

          reserve_share('BHI&R')
          reserve_share('FYN')
          reserve_share('C&N')
          reserve_share('IOW')

          @no_price_drop_on_sale = false
          @southern_formed = false
          @sr_after_southern = false
          @nationalization = false
          @entity_crowded = []
        end

        def corporation_opts
          { float_excludes_market: true }
        end

        def share_prices
          repar_prices
        end

        def reserve_share(name)
          @corporations.find { |c| c.name == name }.shares.last.buyable = false
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1860::Step::HomeTrack,
            G1860::Step::Exchange,
            G1860::Step::BuySellParSharesCompanies,
          ])
        end

        def operating_round(round_num)
          G1860::Round::Operating.new(self, [
            G1860::Step::DiscardTrain,
            G1860::Step::Track,
            G1860::Step::Token,
            G1860::Step::Route,
            G1860::Step::Dividend,
            G1860::Step::BuyTrain,
          ], round_num: round_num)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: true)
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1860::Step::BuyCert,
          ])
        end

        def init_round_finished
          players_by_cash = @players.sort_by(&:cash).reverse

          if players_by_cash[0].cash > players_by_cash[1].cash
            player = players_by_cash[0]
            reason = 'most cash'
          else
            # tie-breaker: lowest total face value in private companies
            player = @players.select { |p| p.companies.any? }.min_by { |p| p.companies.sum(&:value) }
            reason = 'least value of private companies'
          end
          @log << "#{player.name} has #{reason}"

          @players.rotate!(@players.index(player))
          @log << "#{@players.first.name} has priority deal"
        end

        def new_stock_round
          trigger_sr_after_southern! if @southern_formed

          super
        end

        def or_set_finished
          check_new_layer
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              trigger_nationalization! if check_nationalize?
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds || check_nationalize?
                trigger_nationalization! if check_nationalize?
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              new_stock_round
            end
        end

        def round_description(name, round_number = nil)
          round_number ||= @round.round_num
          description = "#{name} Round "

          total = total_rounds(name)

          description += @turn.to_s unless @turn.zero?
          description += '.' if total && !@turn.zero?
          description += round_number.to_s if total
          description += " (of #{total})" if total && !@nationalization
          description += ' (Nationalization)' if total && @nationalization

          description.strip
        end

        def bank_cash
          self.class::BANK_CASH - @players.sum(&:cash)
        end

        def check_bank_broken!
          @bank.break! if !@nationalization && bank_cash.negative?
        end

        def liquidity(player)
          without_companies = super
          return without_companies unless turn > 1

          without_companies + player.companies.sum { |c| c.value - COMPANY_SALE_FEE }
        end

        def operating_order
          @corporations.select { |c| c.floated? && !nationalized?(c) }.sort
        end

        def place_home_token(corporation)
          # will this break the game?
          return if sr_after_southern

          super
        end

        def show_game_cert_limit?
          !@no_price_drop_on_sale
        end

        def event_fishbourne_to_bank!
          ffc = @companies.find { |c| c.sym == 'FFC' }
          ffc.owner = @bank
          @log << "#{ffc.name} is now available for purchase from the Bank"
        end

        def event_relax_cert_limit!
          @log << 'Selling shares no longer decreases share value; No limit on certificates per player.'
          @no_price_drop_on_sale = true
          @cert_limit = 999
        end

        def event_southern_forms!
          @log << 'Southern Railway Forms; '\
                  'Nationalization will be triggered when all players’ companies have at least one train.'
          @southern_formed = true
        end

        def trigger_sr_after_southern!
          return if @sr_after_southern

          @log << 'Stock round after Southern has formed - No track or token building, halts are ignored'
          @sr_after_southern = true
        end

        def trigger_nationalization!
          return if @nationalization

          @log << 'All non-Receivership corporations own at least one train. Nationalization begins.'
          @nationalization = true
        end

        def check_nationalize?
          return false unless @southern_formed
          return true if @nationalization

          @corporations.select { |c| c.ipoed && !c.receivership? }.all? { |c| c.trains.any? }
        end

        def get_or_revenue(info)
          !info.dividend.is_a?(Action::Dividend) || info.dividend.kind == 'withhold' ? 0 : info.revenue
        end

        # OR has just finished, find two lowest revenues and nationalize the corporations
        # associated with each
        def nationalize_corps!
          revenues = @corporations.select { |c| c.floated? && !nationalized?(c) }
            .to_h { |c| [c, get_or_revenue(c.operating_history[c.operating_history.keys.max])] }

          sorted_corps = revenues.keys.sort_by { |c| revenues[c] }

          if sorted_corps.size < 3
            # if two or less corps left, they are both nationalized
            sorted_corps.each { |c| make_nationalized!(c) }
          else
            # all companies with the lowest revenue are nationalized
            # if only one has the lowest revenue, then all companies with the next lowest revenue are nationalized
            min_revenue = revenues[sorted_corps[0]]
            next_revenue_corp = sorted_corps.find { |c| revenues[c] > min_revenue }
            next_revenue = revenues[next_revenue_corp] if next_revenue_corp

            grouped = revenues.keys.group_by { |c| revenues[c] }
            grouped[min_revenue].each { |c| make_nationalized!(c) }
            grouped[next_revenue].each { |c| make_nationalized!(c) } if next_revenue_corp && grouped[min_revenue].one?
          end
        end

        # game ends when all floated corps have nationalized
        def custom_end_game_reached?
          return false unless @nationalization
          return false unless @round.finished?

          nationalize_corps! if @nationalization
          @corporations.select(&:floated?).all? { |corp| nationalized?(corp) }
        end

        def insolvent?(corp)
          @insolvent_corps.include?(corp)
        end

        def make_insolvent(corp)
          return if insolvent?(corp)

          @insolvent_corps << corp
          @log << "#{corp.name} is now Insolvent"
        end

        def clear_insolvent(corp)
          return unless insolvent?(corp)

          @insolvent_corps.delete(corp)
          @log << "#{corp.name} is no longer Insolvent"
        end

        def bankrupt?(corp)
          @bankrupt_corps.include?(corp)
        end

        def make_bankrupt!(corp)
          return if bankrupt?(corp)

          @bankrupt_corps << corp
          @log << "#{corp.name} enters Bankruptcy"

          # un-IPO the corporation
          corp.share_price.corporations.delete(corp)
          corp.share_price = nil
          corp.par_price = nil
          corp.ipoed = false
          corp.min_price = MIN_PAR_AFTER_BANKRUPTCY
          corp.unfloat!

          # return shares to IPO
          corp.share_holders.keys.each do |share_holder|
            next if share_holder == corp

            shares = share_holder.shares_by_corporation[corp].compact
            corp.share_holders.delete(share_holder)
            shares.each do |share|
              share_holder.shares_by_corporation[corp].delete(share)
              share.owner = corp
              corp.shares_by_corporation[corp] << share
            end
          end
          corp.shares_by_corporation[corp].sort_by!(&:index)
          corp.share_holders[corp] = 100
          corp.owner = nil

          # "flip" any tokens for corporation placed on map
          corp.tokens.each do |token|
            token.status = :flipped if token.used
          end

          # find new priority deal: player with lowest total share count
          player = @players.min_by { |p| p.shares.sum(&:percent) }
          @players.rotate!(@players.index(player))
          @log << "#{@players.first.name} has priority deal"

          @round.force_next_entity! if @round.operating?
          return unless @round.stock?

          # restart stock round if in middle of one
          @round.clear_cache!
          clear_programmed_actions
          @log << 'Restarting Stock Round'
          @round.entities.each(&:unpass!)
          @round = stock_round
        end

        def clear_bankrupt!(corp)
          return unless bankrupt?(corp)

          # Designer says that bankrupt corps keep insolvency flag

          # "unflip" any tokens for corporation placed on map
          corp.tokens.each do |token|
            token.status = nil if token.used
          end
          @bankrupt_corps.delete(corp)
        end

        def nationalized?(corp)
          @nationalized_corps.include?(corp)
        end

        def make_nationalized!(corp)
          return if nationalized?(corp)

          @log << "#{corp.name} is Nationalized and will cease to operate."
          @nationalized_corps << corp
        end

        def status_array(corp)
          layer_str = "Layer #{corp_layer(corp)}"
          layer_str += ' (N/A)' unless can_ipo?(corp)

          prices = par_prices(corp).map(&:price).sort
          par_str = if !corp.ipoed && bankrupt?(corp)
                      "Par #{prices[0]}-#{prices[-1]}"
                    elsif !corp.ipoed
                      "Par #{prices.join(', ')}"
                    end

          status = [[layer_str]]
          status << [par_str] if par_str
          status << %w[Insolvent bold] if insolvent?(corp)
          status << %w[Receivership bold] if corp.receivership?
          status << %w[Bankrupt bold] if bankrupt?(corp)
          status << %w[Nationalized bold] if nationalized?(corp)

          status
        end

        def corp_hi_par(corp)
          (bankrupt?(corp) ? REPAR_RANGE[corp_layer(corp)] : PAR_RANGE[corp_layer(corp)]).last
        end

        def corp_lo_par(corp)
          (bankrupt?(corp) ? REPAR_RANGE[corp_layer(corp)] : PAR_RANGE[corp_layer(corp)]).first
        end

        def corp_layer(corp)
          LAYER_BY_NAME[corp.name]
        end

        def par_prices(corp)
          par_prices = bankrupt?(corp) ? repar_prices : stock_market.par_prices
          par_prices.select { |p| p.price <= corp_hi_par(corp) && p.price >= corp_lo_par(corp) }
        end

        def repar_prices
          @repar_prices ||= stock_market.market.first.select { |p| p.type == :repar || p.type == :par }
        end

        def can_ipo?(corp)
          corp_layer(corp) <= current_layer
        end

        def check_new_layer
          layer = current_layer
          @log << "-- Layer #{layer} corporations now available --" if layer > @highest_layer
          @highest_layer = layer
        end

        def current_layer
          layers = LAYER_BY_NAME.select do |name, _layer|
            corp = @corporations.find { |c| c.name == name }
            corp.num_ipo_shares.zero? || corp.operated?
          end.values
          layers.empty? ? 1 : [layers.max + 1, 4].min
        end

        def move_marker_to_bottom!(corporation)
          @stock_market.move_left(corporation)
          @stock_market.move_right(corporation)
        end

        def float_corporation(corporation)
          clear_bankrupt!(corporation)
          move_marker_to_bottom!(corporation)
          super
        end

        def action_processed(_action); end

        def check_bankruptcy!(entity)
          return unless entity.corporation?

          make_bankrupt!(entity) if entity.share_price&.type == :close
        end

        def sorted_corporations
          @corporations.sort_by { |c| corp_layer(c) }
        end

        def corporation_available?(entity)
          entity.corporation? && can_ipo?(entity)
        end

        def selling_movement?(corporation)
          corporation.operated? && !@no_price_drop_on_sale
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          corporation = bundle.corporation
          old_price = corporation.share_price

          @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
          num_shares = bundle.num_shares
          num_shares -= 1 if corporation.share_price.type == :ignore_one_sale
          num_shares.times { @stock_market.move_down(corporation) } if selling_movement?(corporation)
          log_share_price(corporation, old_price)
          check_bankruptcy!(corporation)
        end

        def close_other_companies!(company)
          return unless @companies.reject { |c| c == company }.reject(&:closed?)

          @corporations.each { |corp| corp.shares.each { |share| share.buyable = true } }
          @companies.reject { |c| c == company }.each(&:close!)
          @log << '-- Event: starting private companies close --'
        end

        def game_ending_description
          reason, after = game_end_check
          return unless after

          after_text = ''

          unless @finished
            after_text = case after
                         when :immediate
                           ' : Game Ends immediately'
                         when :current_round
                           if @round.is_a?(Engine::Round::Operating)
                             " : Game Ends at conclusion of this OR (#{turn}.#{@round.round_num})"
                           else
                             " : Game Ends at conclusion of this round (#{turn})"
                           end
                         when :current_or
                           " : Game Ends at conclusion of this OR (#{turn}.#{@round.round_num})"
                         when :full_or
                           " : Game Ends at conclusion of #{round_end.short_name} #{turn}.#{operating_rounds}"
                         when :one_more_full_or_set
                           " : Game Ends at conclusion of #{round_end.short_name}"\
                           " #{@final_turn}.#{final_operating_rounds}"
                         end
          end

          reason_map = {
            bank: 'Bank Broken',
            bankrupt: 'Bankruptcy',
            stock_market: 'Company hit max stock value',
            final_train: 'Final train was purchased',
            custom: 'Nationalization complete',
          }
          "#{reason_map[reason]}#{after_text}"
        end

        def train_help(_entity, trains, _routes)
          help = []

          if trains.select { |t| t.owner == @depot }.any? && !option_original_insolvency?
            help << 'Leased trains ignore town/halt allowance.'
            help << "Revenue = #{format_currency(40)} + number_of_stops * #{format_currency(20)}"
            help << "Max revenue possible: #{format_currency(40 + (@depot.min_depot_train.distance[0]['pay'] * 20))}"
          end
          if trains.select { |t| t.owner == @depot }.any? && option_original_insolvency?
            help << 'Leased trains run for half revenue (but full subsidies).'
          end

          help
        end

        def train_owner(train)
          train.owner == @depot ? lessee : train.owner
        end

        def lessee
          current_entity
        end

        def legal_route?(entity)
          @graph.route_info(entity)&.dig(:route_train_purchase)
        end

        def route_trains(entity)
          if insolvent?(entity)
            [@depot.min_depot_train]
          else
            super
          end
        end

        def biggest_train_distance(corporation)
          if (biggest = corporation.trains.max_by { |t| t.distance[0]['pay'] })
            town_distance = option_no_skip_towns? ? biggest.distance[-1]['pay'] : 9999
            [biggest.distance[0]['pay'], town_distance]
          else
            [0, 0]
          end
        end

        def custom_blocks?(node, corporation)
          return false unless node.city?
          return false unless corporation
          return false if node.tokened_by?(corporation)
          return false if node.tokens.include?(nil)
          return false if node.tokens.any? { |t| t&.type == :neutral || t&.status == :flipped }

          true
        end

        def legal_tile_rotation?(_entity, _hex, tile)
          return true unless NO_ROTATION_TILES.include?(tile.name)

          tile.rotation.zero?
        end

        # at least one route must include home token
        def check_home_token(corporation, routes)
          tokens = @distance_graph.get_token_cities(corporation)
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

        def tokened_out?(route)
          visits = route.visited_stops
          return false unless visits.size > 2

          corporation = route.corporation
          visits[1..-2].any? { |node| node.city? && custom_blocks?(node, corporation) }
        end

        def check_connected(route, corporation)
          visits = route.visited_stops
          blocked = nil

          if visits.size > 2
            visits[1..-2].each do |node|
              next if !node.city? || !custom_blocks?(node, corporation)
              raise GameError, 'Route can only bypass one tokened-out city' if blocked

              blocked = node
            end
          end

          # no need to check whether cities are tokened out because of the above
          super(route, nil)

          return if !blocked || route.routes.none? { |r| r != route && tokened_out?(r) }

          raise GameError, 'Only one train can bypass a tokened-out city'
        end

        def check_distance(route, visits)
          city_stops = visits.select { |node| node.city? || node.offboard? }
          town_stops = visits.select { |node| node.town? && !node.halt? }

          # in 1860, unused city/offboard allowance can be used for towns/halts
          c_allowance = route.train.distance[0]['pay']
          th_allowance = if !ignore_second_allowance?(route)
                           [route.train.distance[-1]['pay'] + c_allowance - city_stops.size, 0].max
                         else
                           [c_allowance - city_stops.size, 0].max
                         end

          raise GameError, 'Route has too many cities/offboards' if city_stops.size > c_allowance
          raise GameError, 'Route has too many towns' if town_stops.size > th_allowance && option_no_skip_towns?
          raise GameError, 'Route cannot begin/end in a halt' if visits.first.halt? || visits.last.halt?
        end

        def check_hex_reentry(route)
          visited_hexes = {}
          last_hex = nil
          route.ordered_paths.each do |path|
            hex = path.hex
            raise GameError, 'Route cannot re-enter a hex' if hex != last_hex && visited_hexes[hex]

            visited_hexes[hex] = true
            last_hex = hex
          end
        end

        def check_other(route)
          check_hex_reentry(route)
          check_home_token(current_entity, route.routes) unless route.routes.empty?
          check_intersection(route.routes) unless route.routes.empty?
        end

        # must stop at all towns on route or must maximize revenue
        def use_all_towns?
          @nationalization || option_no_skip_towns?
        end

        def ignore_halts?
          @sr_after_southern
        end

        def loaner?(route)
          route.train.owner == @depot
        end

        def loaner_new_rules?(route)
          loaner?(route) && !option_original_insolvency?
        end

        def loaner_orig_rules?(route)
          loaner?(route) && option_original_insolvency?
        end

        def ignore_halt_subsidies?(route)
          loaner_new_rules?(route)
        end

        def ignore_second_allowance?(route)
          loaner_new_rules?(route) || @nationalization
        end

        def max_halts(route)
          visits = route.visited_stops
          return 0 if visits.empty? || ignore_halts?

          cities = visits.select { |node| node.city? || node.offboard? }
          towns = visits.select { |node| node.town? && !node.halt? }
          halts = visits.select(&:halt?)
          c_allowance = route.train.distance[0]['pay']
          th_allowance = if !ignore_second_allowance?(route)
                           route.train.distance[-1]['pay'] + c_allowance - cities.size
                         else
                           c_allowance - cities.size
                         end
          # if required to use all towns only use halts if there aren't enough cities or towns
          th_allowance = [th_allowance - towns.size, 0].max if use_all_towns?
          [halts.size, th_allowance].min
        end

        def compute_stops(route)
          # will need to be modifed for original rules option
          visits = route.visited_stops
          return [] if visits.empty?

          # no choice about citys/offboards => they must be stops
          stops = visits.select { |node| node.city? || node.offboard? }

          # in 1860, unused city/offboard allowance can be used for towns/halts
          c_allowance = route.train.distance[0]['pay']
          th_allowance = if !ignore_second_allowance?(route)
                           route.train.distance[-1]['pay'] + c_allowance - stops.size
                         else
                           c_allowance - stops.size
                         end

          # add in halts requested (from previous run or UI button)
          #
          # reset requested halts to nil if no halts on route, ignoring halts, not using halt for subsidies,
          # maximum halts allowed is zero, or requested halts is greater than maximum allowed
          halts = visits.select(&:halt?)

          halt_max = max_halts(route)

          route.halts = nil if halts.empty? || ignore_halts? || ignore_halt_subsidies?(route) || halt_max.zero?
          route.halts = nil if route.halts && route.halts > halt_max

          num_halts = [halts.size, (route.halts || 0)].min
          if num_halts.positive?
            stops.concat(halts.take(num_halts))
            th_allowance -= num_halts
          end

          # after adding requested halts, pick highest revenue towns
          towns = visits.select { |node| node.town? && !node.halt? }
          num_towns = option_no_skip_towns? ? towns.size : [th_allowance, towns.size].min
          if num_towns.positive?
            stops.concat(towns.sort_by { |t| t.uniq_revenues.first }.reverse.take(num_towns))
            th_allowance -= num_towns
          end

          # if requested halts is nil (i.e. this is first time for this route), add as many halts as possible if
          # there are halts on route, there is room for some, and we aren't ignoring halts
          if !route.halts && halts.any? && th_allowance.positive? && !ignore_halts?
            num_halts = [halts.size, th_allowance].min
            stops.concat(halts.take(num_halts))
          end

          # update route halts
          route.halts = num_halts if (!halts.empty? || route.halts) && !loaner_new_rules?(route) && !ignore_halts?

          stops
        end

        def route_distance(route)
          n_cities = route.stops.count { |n| n.city? || n.offboard? }
          # halts are treated like towns for leased trains (new rules)
          n_towns = if !loaner_new_rules?(route)
                      route.stops.count { |n| n.town? && !n.halt? }
                    else
                      route.stops.count(&:town?)
                    end
          loaner_new_rules?(route) ? (n_cities + n_towns).to_s : "#{n_cities}+#{n_towns}"
        end

        def revenue_for(route, stops)
          if loaner_new_rules?(route)
            40 + (20 * stops.size)
          elsif loaner_orig_rules?(route)
            (stops.sum { |stop| stop.route_base_revenue(route.phase, route.train) } / 2).ceil
          else
            stops.sum { |stop| stop.route_base_revenue(route.phase, route.train) }
          end
        end

        def subsidy_for(route, stops)
          !ignore_halt_subsidies?(route) ? stops.count(&:halt?) * HALT_SUBSIDY : 0
        end

        def routes_revenue(routes)
          routes.sum(&:revenue)
        end

        def routes_subsidy(routes)
          routes.sum(&:subsidy)
        end

        def player_sort(entities)
          entities.sort_by(&:name).sort_by { |e| corp_layer(e) }.group_by(&:owner)
        end

        def bank_sort(entities)
          entities.sort_by(&:name).sort_by { |e| corp_layer(e) }
        end

        def highlight_token?(token)
          return false unless token
          return false unless (corporation = token.corporation)

          corporation.tokens.find_index(token).zero?
        end

        def entity_can_use_company?(entity, company)
          company.owner == entity
        end

        def update_crowded(entity)
          @entity_crowded = crowded_corps.select { |c| c == entity }
        end

        def entity_crowded_corps
          @entity_crowded
        end
      end
    end
  end
end
