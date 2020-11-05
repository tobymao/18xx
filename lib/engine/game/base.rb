# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree '../action'
  require_tree '../round'
  require_tree '../step'
else
  require 'require_all'
  require 'json'
  require_rel '../action'
  require_rel '../round'
  require_rel '../step'
end

require_relative '../bank'
require_relative '../company'
require_relative '../corporation'
require_relative '../depot'
require_relative '../graph'
require_relative '../hex'
require_relative '../minor'
require_relative '../phase'
require_relative '../player'
require_relative '../publisher'
require_relative '../share_pool'
require_relative '../stock_market'
require_relative '../tile'
require_relative '../train'

module Engine
  module Game
    class Base
      attr_reader :actions, :bank, :cert_limit, :cities, :companies, :corporations,
                  :depot, :finished, :graph, :hexes, :id, :loading, :loans, :log, :minors,
                  :phase, :players, :operating_rounds, :round, :share_pool, :stock_market,
                  :tiles, :turn, :total_loans, :undo_possible, :redo_possible, :round_history, :all_tiles,
                  :optional_rules

      DEV_STAGES = %i[production beta alpha prealpha].freeze
      DEV_STAGE = :prealpha

      GAME_LOCATION = nil
      GAME_RULES_URL = nil
      GAME_DESIGNER = nil
      GAME_PUBLISHER = nil
      GAME_IMPLEMENTER = nil
      GAME_INFO_URL = nil

      # Game end check is described as a dictionary
      # with reason => after
      #   reason: What kind of game end check to do
      #   after: When game should end if check triggered
      # Leave out a reason if game does not support that.
      # Allowed reasons:
      #  bankrupt, stock_market, bank, final_train
      # Allowed after:
      #  immediate - ends in current turn
      #  current_round - ends at the end of the current round
      #  current_or - ends at the next end of an OR
      #  full_or - ends at the next end of a complete OR set
      #  one_more_full_or_set - finish the current OR set, then
      #                         end after the next complete OR set
      GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or }.freeze

      OPTIONAL_RULES = [].freeze

      BANKRUPTCY_ALLOWED = true

      BANK_CASH = 12_000

      CURRENCY_FORMAT_STR = '$%d'

      STARTING_CASH = {}.freeze

      HEXES = {}.freeze

      LAYOUT = nil

      AXES = nil

      TRAINS = [].freeze

      CERT_LIMIT = {
        2 => 28,
        3 => 20,
        4 => 16,
        5 => 13,
        6 => 11,
      }.freeze

      CERT_LIMIT_TYPES = %i[multiple_buy unlimited no_cert_limit].freeze

      MULTIPLE_BUY_TYPES = %i[multiple_buy].freeze

      STOCKMARKET_COLORS = {
        par: :red,
        endgame: :blue,
        close: :black,
        multiple_buy: :brown,
        unlimited: :orange,
        no_cert_limit: :yellow,
        liquidation: :red,
        acquisition: :yellow,
        repar: :gray,
        ignore_one_sale: :green,
        safe_par: :white,
      }.freeze

      MIN_BID_INCREMENT = 5

      MUST_BID_INCREMENT_MULTIPLE = false

      CAPITALIZATION = :full

      MUST_SELL_IN_BLOCKS = false

      # when can a share holder sell shares
      # first           -- after first stock round
      # operate         -- after operation
      # p_any_operate   -- pres any time, share holders after operation
      # any_time        -- at any time
      SELL_AFTER = :first

      # down_share -- down one row per share
      # down_per_10 -- down one row per 10% sold
      # down_block -- down one row per block
      # left_block_pres -- left one column per block if president
      # left_block -- one row per block
      # none -- don't drop price
      SELL_MOVEMENT = :down_share

      # :sell_buy_or_buy_sell
      # :sell_buy
      # :sell_buy_sell
      SELL_BUY_ORDER = :sell_buy_or_buy_sell

      # do shares in the pool drop the price?
      # none, one, each
      POOL_SHARE_DROP = :none

      # :after_last_to_act -- player after the last to act goes first. Order remains the same.
      # :first_to_pass -- players ordered by when they first started passing.
      NEXT_SR_PLAYER_ORDER = :after_last_to_act

      # do tile reservations completely block other companies?
      TILE_RESERVATION_BLOCKS_OTHERS = false

      COMPANIES = [].freeze

      CORPORATIONS = [].freeze

      PHASES = [].freeze

      LOCATION_NAMES = {}.freeze

      TRACK_RESTRICTION = :semi_restrictive

      # ebuy = presidential cash is contributed
      EBUY_PRES_SWAP = true # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = true # allow ebuying other corp trains for up to face
      EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = true # if ebuying from depot, must buy cheapest train
      MUST_EMERGENCY_ISSUE_BEFORE_EBUY = false # corporation must issue shares before ebuy (if possible)
      EBUY_SELL_MORE_THAN_NEEDED = false # true if corporation may continue to sell shares even though enough funds

      # when is the home token placed? on...
      # operate
      # float
      # operating_round // 1889 places on first operating round
      HOME_TOKEN_TIMING = :operate

      DISCARDED_TRAINS = :discard # discarded or removed?

      MUST_BUY_TRAIN = :route # When must the company buy a train if it doesn't have one (route, never, always)

      # Default tile lay, one tile either upgrade or lay at zero cost
      # allows multiple lays, value must be either true, false or :not_if_upgraded
      TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze

      IMPASSABLE_HEX_COLORS = %i[blue gray red].freeze

      EVENTS_TEXT = { 'close_companies' =>
                      ['Companies Close', 'All companies unless otherwise noted are discarded from the game'] }.freeze

      STATUS_TEXT = { 'can_buy_companies' =>
                      ['Can Buy Companies', 'All corporations can buy companies from players'] }.freeze

      MARKET_TEXT = { par: 'Par value',
                      no_cert_limit: 'Corporation shares do not count towards cert limit',
                      unlimited: 'Corporation shares can be held above 60%',
                      multiple_buy: 'Can buy more than one share in the corporation per turn',
                      close: 'Corporation closes',
                      endgame: 'End game trigger',
                      liquidation: 'Liquidation',
                      repar: 'Par value after bankruptcy',
                      ignore_one_sale: 'Ignore first share sold when moving price' }.freeze

      IPO_NAME = 'IPO'
      IPO_RESERVED_NAME = 'IPO Reserved'
      MARKET_SHARE_LIMIT = 50 # percent
      ALL_COMPANIES_ASSIGNABLE = false

      CACHABLE = [
        %i[players player],
        %i[corporations corporation],
        %i[companies company],
        %i[trains train],
        %i[hexes hex],
        %i[tiles tile],
        %i[shares share],
        %i[share_prices share_price],
        %i[cities city],
        %i[minors minor],
        %i[loans loan],
      ].freeze

      # https://en.wikipedia.org/wiki/Linear_congruential_generator#Parameters_in_common_use
      RAND_A = 1_103_515_245
      RAND_C = 12_345
      RAND_M = 2**31

      def setup; end

      def init_optional_rules(optional_rules)
        optional_rules = (optional_rules || []).map(&:to_sym)
        self.class::OPTIONAL_RULES.each do |rule|
          optional_rules.delete(rule[:sym]) if rule[:players] && !rule[:players].include?(@players.size)
        end
        optional_rules
      end

      def setup_optional_rules; end

      def log_optional_rules
        return if @optional_rules.empty?

        @log << 'Optional rules used in this game:'
        self.class::OPTIONAL_RULES.each do |o_r|
          next unless @optional_rules.include?(o_r[:sym])

          @log << " * #{o_r[:short_name]}: #{o_r[:desc]}"
        end
      end

      def self.title
        name.split('::').last.slice(1..-1)
      end

      def self.<=>(other)
        [DEV_STAGES.index(self::DEV_STAGE), title] <=> [DEV_STAGES.index(other::DEV_STAGE), other.title]
      end

      def self.register_colors(colors)
        colors.default_proc = proc do |_, key|
          key
        end

        const_set(:COLORS, colors)
      end

      def self.load_from_json(*jsons)
        data = Array(jsons).reverse.reduce({}) do |memo, json|
          memo.merge!(JSON.parse(json))
        end

        # Make sure player objects have numeric keys
        data['bankCash'].transform_keys!(&:to_i) if data['bankCash'].is_a?(Hash)
        data['certLimit'].transform_keys!(&:to_i) if data['certLimit'].is_a?(Hash)
        data['startingCash'].transform_keys!(&:to_i) if data['startingCash'].is_a?(Hash)

        data['phases'].map! do |phase|
          phase.transform_keys!(&:to_sym)
          phase[:tiles]&.map!(&:to_sym)
          phase[:events]&.transform_keys!(&:to_sym)
          phase
        end

        data['trains'].map! do |train|
          train.transform_keys!(&:to_sym)
          train[:variants]&.each { |variant| variant.transform_keys!(&:to_sym) }
          train
        end

        data['companies'].map! do |company|
          company.transform_keys!(&:to_sym)
          company[:abilities]&.each { |ability| ability.transform_keys!(&:to_sym) }
          company
        end

        data['minors'] ||= []

        data['minors'].map! do |minor|
          minor.transform_keys!(&:to_sym)
          minor[:color] = const_get(:COLORS)[minor[:color]] if const_defined?(:COLORS)
          minor
        end

        data['corporations'].map! do |corporation|
          corporation.transform_keys!(&:to_sym)
          corporation[:abilities]&.each { |ability| ability.transform_keys!(&:to_sym) }
          corporation[:color] = const_get(:COLORS)[corporation[:color]] if const_defined?(:COLORS)
          corporation
        end

        data['hexes'].transform_keys!(&:to_sym)
        data['hexes'].transform_values!(&:invert)

        hex_ids = data['hexes'].values.map(&:keys).flatten

        dup_hexes = hex_ids.group_by(&:itself).select { |_, v| v.size > 1 } .keys
        raise GameError, "Found multiple definitions in #{self} for hexes #{dup_hexes}" if dup_hexes.any?

        const_set(:CURRENCY_FORMAT_STR, data['currencyFormatStr'])
        const_set(:BANK_CASH, data['bankCash'])
        const_set(:CERT_LIMIT, data['certLimit'])
        const_set(:STARTING_CASH, data['startingCash'])
        const_set(:CAPITALIZATION, data['capitalization'].to_sym) if data['capitalization']
        const_set(:MUST_SELL_IN_BLOCKS, data['mustSellInBlocks'])
        const_set(:TILES, data['tiles'])
        const_set(:LOCATION_NAMES, data['locationNames'])
        const_set(:MARKET, data['market'])
        const_set(:PHASES, data['phases'])
        const_set(:TRAINS, data['trains'])
        const_set(:COMPANIES, data['companies'])
        const_set(:CORPORATIONS, data['corporations'])
        const_set(:MINORS, data['minors'])
        const_set(:HEXES, data['hexes'])
        const_set(:LAYOUT, data['layout'].to_sym)
      end

      def initialize(names, id: 0, actions: [], pin: nil, strict: false, optional_rules: [])
        @id = id
        @turn = 1
        @final_turn = nil
        @loading = false
        @strict = strict
        @finished = false
        @log = []
        @actions = []
        @names = names.freeze
        @players = @names.map { |name| Player.new(name) }
        @optional_rules = init_optional_rules(optional_rules)

        @seed = @id.to_s.scan(/\d+/).first.to_i % RAND_M

        case self.class::DEV_STAGE
        when :prealpha
          @log << "#{self.class.title} is in prealpha state, no support is provided at all"
        when :alpha
          @log << "#{self.class.title} is currently considered 'alpha',"\
            ' the rules implementation is likely to not be complete.'
          @log << 'As the implementation improves, games that are not compatible'\
            ' with the latest version will be deleted without notice.'
          @log << 'We suggest that any alpha quality game is concluded within 7 days.'
        when :beta
          @log << "#{self.class.title} is currently considered 'beta',"\
            ' the rules implementation may allow illegal moves.'
          @log << 'As the implementation improves, games that are not compatible'\
            ' with the latest version will be pinned but may be deleted after 7 days.'
          @log << 'Because of this we suggest not playing games that may take months to complete.'
        end

        @companies = init_companies(@players)
        @stock_market = init_stock_market
        @minors = init_minors
        @loans = init_loans
        @total_loans = @loans.size
        @corporations = init_corporations(@stock_market)
        @bank = init_bank
        @tiles = init_tiles
        @all_tiles = init_tiles
        @cert_limit = init_cert_limit
        @removals = []

        @depot = init_train_handler
        init_starting_cash(@players, @bank)
        @share_pool = init_share_pool
        @hexes = init_hexes(@companies, @corporations)
        @graph = Graph.new(self)

        # call here to set up ids for all cities before any tiles from @tiles
        # can be placed onto the map
        @cities = (@hexes.map(&:tile) + @tiles).map(&:cities).flatten

        @phase = init_phase
        @operating_rounds = @phase.operating_rounds

        @round_history = []
        @round = init_round

        cache_objects
        connect_hexes

        init_company_abilities

        setup_optional_rules
        log_optional_rules
        setup

        initialize_actions(actions)

        return unless pin

        @log << '----'
        @log << 'Your game was unable to be upgraded to the latest version of 18xx.games.'
        @log << "It is pinned to version #{pin}, if any bugs are raised please include this version number."
        @log << 'Please note, pinned games may be deleted after 7 days.' if self.class::DEV_STAGE == :beta
        @log << '----'
      end

      def rand
        @seed =
          if RUBY_ENGINE == 'opal'
            `parseInt(Big(#{RAND_A}).times(#{@seed}).plus(#{RAND_C}).mod(#{RAND_M}).toString())`
          else
            (RAND_A * @seed + RAND_C) % RAND_M
          end
      end

      def inspect
        "#{self.class.name} - #{self.class.title} #{players.map(&:name)}"
      end

      def result
        @players
          .sort_by(&:value)
          .reverse
          .map { |p| [p.name, p.value] }
          .to_h
      end

      def turn_round_num
        [turn, @round.round_num]
      end

      def current_entity
        @round.active_step&.current_entity || actions[-1].entity
      end

      def active_players
        players_ = @round.active_entities.map(&:player).compact

        players_.empty? ? @players.reject(&:bankrupt) : players_
      end

      def active_step
        @round.active_step
      end

      def active_player_names
        active_players.map(&:name)
      end

      def self.filtered_actions(actions)
        active_undos = []
        filtered_actions = Array.new(actions.size)

        actions.each.with_index do |action, index|
          case action['type']
          when 'undo'
            i = filtered_actions.rindex { |a| a && a['type'] != 'message' }
            active_undos << [filtered_actions[i], i]
            filtered_actions[i] = nil
          when 'redo'
            a, i = active_undos.pop
            filtered_actions[i] = a
          when 'message'
            # Messages do not get undoed.
            # warning adding more types of action here will break existing game
            filtered_actions[index] = action
          else
            active_undos = []
            filtered_actions[index] = action
          end
        end
        [filtered_actions, active_undos]
      end

      # Initialize actions respecting the undo state
      def initialize_actions(actions)
        @loading = true unless @strict

        filtered_actions, active_undos = self.class.filtered_actions(actions)
        @undo_possible = false
        # replay all actions with a copy
        filtered_actions.each.with_index do |action, index|
          if !action.nil?
            action = action.copy(self) if action.is_a?(Action::Base)
            process_action(action)
          else
            # Restore the original action to the list to ensure action ids remain consistent but don't apply them
            @actions << actions[index]
          end
        end
        @redo_possible = active_undos.any?
        @loading = false
      end

      def process_action(action)
        action = action_from_h(action) if action.is_a?(Hash)
        action.id = current_action_id
        if action.is_a?(Action::Undo) || action.is_a?(Action::Redo)
          @actions << action
          return clone(@actions)
        end

        @log << "• Action(#{action.type}) via Master Mode by #{action.user}:" if action.user

        @round.process_action(action)

        unless action.is_a?(Action::Message)
          @redo_possible = false
          @undo_possible = true
        end

        action_processed(action)
        @actions << action

        end_timing = game_end_check&.last
        end_game! if end_timing == :immediate

        while @round.finished? && !@finished
          @round.entities.each(&:unpass!)

          if end_now?(end_timing)
            end_game!
          else
            next_round!

            # Finalize round setup (for things that need round correctly set like place_home_token)
            @round.setup
            @round_history << @actions.size
          end
        end

        self
      end

      def sorted_corporations
        # Corporations sorted by some potential game rules
        ipoed, others = corporations.partition(&:ipoed)
        ipoed.sort + others
      end

      def current_action_id
        @actions.size + 1
      end

      def action_from_h(h)
        Object
          .const_get("Engine::Action::#{Action::Base.type(h['type'])}")
          .from_h(h, self)
      end

      def clone(actions)
        self.class.new(@names, id: @id, pin: @pin, actions: actions, optional_rules: @optional_rules)
      end

      def trains
        @depot.trains
      end

      def shares
        @corporations.flat_map(&:shares)
      end

      def share_prices
        @stock_market.par_prices
      end

      def layout
        self.class::LAYOUT
      end

      def axes
        @axes ||=
          if (axes = self.class::AXES)
            axes
          elsif layout == :flat
            { x: :letter, y: :number }
          elsif layout == :pointy
            { x: :number, y: :letter }
          end
      end

      def format_currency(val)
        self.class::CURRENCY_FORMAT_STR % val
      end

      def purchasable_companies(entity = nil)
        @companies.select do |company|
          company.owner&.player? && entity != company.owner && !company.abilities(:no_buy)
        end
      end

      def liquidity(player, emergency: false)
        return player.cash unless sellable_turn?

        value = player.cash
        if emergency
          return liquidity(player) unless @round

          value += player.shares_by_corporation.sum do |corporation, shares|
            next 0 if shares.empty?

            last = sellable_bundles(player, corporation).last
            last ? last.price : 0
          end
        else
          player.shares_by_corporation.reject { |_, s| s.empty? }.each do |corporation, _|
            case self.class::SELL_AFTER
            when :operate
              next unless corporation.operated?
            when :p_any_operate
              next unless corporation.operated? || corporation.president?(player)
            end

            max_bundle = bundles_for_corporation(player, corporation)
              .select { |bundle| bundle.can_dump?(player) && @share_pool&.fit_in_bank?(bundle) }
              .max_by(&:price)
            value += max_bundle&.price || 0
          end
        end
        value
      end

      def issuable_shares(_entity)
        []
      end

      def redeemable_shares(_entity)
        []
      end

      def sellable_bundles(player, corporation)
        bundles = bundles_for_corporation(player, corporation)
        bundles.select { |bundle| @round.active_step&.can_sell?(player, bundle) }
      end

      def bundles_for_corporation(share_holder, corporation, shares: nil)
        return [] unless corporation.ipoed

        shares = (shares || share_holder.shares_of(corporation)).sort_by(&:price)

        bundles = shares.flat_map.with_index do |share, index|
          bundle = shares.take(index + 1)
          percent = bundle.sum(&:percent)
          bundles = [Engine::ShareBundle.new(bundle, percent)]
          if share.president
            normal_percent = corporation.share_percent
            difference = corporation.presidents_percent - normal_percent
            num_partial_bundles = difference / normal_percent
            (1..num_partial_bundles).each do |n|
              bundles.insert(0, Engine::ShareBundle.new(bundle, percent - (normal_percent * n)))
            end
          end
          bundles
        end

        bundles
      end

      def num_certs(entity)
        entity.companies.size + entity.shares.count { |s| s.corporation.counts_for_limit && s.counts_for_limit }
      end

      def sellable_turn?
        self.class::SELL_AFTER == :first ? @turn > 1 : true
      end

      def sell_shares_and_change_price(bundle)
        corporation = bundle.corporation
        price = corporation.share_price.price
        was_president = corporation.president?(bundle.owner)
        @share_pool.sell_shares(bundle)
        case self.class::SELL_MOVEMENT
        when :down_share
          bundle.num_shares.times { @stock_market.move_down(corporation) }
        when :down_per_10
          (bundle.percent / 10).to_i.times { @stock_market.move_down(corporation) }
        when :left_block_pres
          stock_market.move_left(corporation) if was_president
        when :none
          nil
        else
          raise NotImplementedError
        end
        log_share_price(corporation, price) if self.class::SELL_MOVEMENT != :none
      end

      def log_share_price(entity, from)
        to = entity.share_price.price
        return unless from != to

        @log << "#{entity.name}'s share price changes from #{format_currency(from)} "\
          "to #{format_currency(to)}"
      end

      def can_run_route?(entity)
        @graph.route_info(entity)&.dig(:route_available)
      end

      def must_buy_train?(entity)
        !entity.rusted_self &&
          entity.trains.empty? &&
          depot.depot_trains.any? &&
          (self.class::MUST_BUY_TRAIN == :always ||
           (self.class::MUST_BUY_TRAIN == :route && @graph.route_info(entity)&.dig(:route_train_purchase)))
      end

      def end_game!
        return if @finished

        @finished = true
        scores = result.map { |name, value| "#{name} (#{format_currency(value)})" }
        @log << "-- Game over: #{scores.join(', ')} --"
      end

      def revenue_for(route, stops)
        stops.sum { |stop| stop.route_revenue(route.phase, route.train) }
      end

      def revenue_str(route)
        route.hexes.map(&:name).join('-')
      end

      def routes_revenue(routes)
        routes.sum(&:revenue)
      end

      def compute_other_paths(routes, route)
        routes.reject { |r| r == route }.flat_map(&:paths)
      end

      def check_overlap(routes)
        tracks = []

        routes.each do |route|
          route.paths.each do |path|
            a = path.a
            b = path.b

            tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
            tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?
          end
        end

        tracks.group_by(&:itself).each do |k, v|
          @game.game_error("Route cannot reuse track on #{k[0].id}") if v.size > 1
        end
      end

      def get(type, id)
        send("#{type}_by_id", id)
      end

      def all_companies_with_ability(ability)
        @companies.each do |company|
          if (found_ability = company.abilities(ability))
            yield company, found_ability
          end
        end
      end

      def payout_companies
        companies = @companies.select { |c| c.owner && c.revenue.positive? }

        companies.sort_by! do |company|
          [
            company.owned_by_player? ? [0, @players.index(company.owner)] : [1, company.owner],
            company.revenue,
            company.name,
          ]
        end

        companies.each do |company|
          revenue = company.revenue
          owner = company.owner
          @bank.spend(revenue, owner)
          @log << "#{owner.name} collects #{format_currency(revenue)} from #{company.name}"
        end
      end

      def init_round_finished; end

      def or_round_finished; end

      def or_set_finished; end

      def home_token_locations(_corporation)
        raise NotImplementedError
      end

      def place_home_token(corporation)
        return unless corporation.next_token # 1882
        # If a corp has laid it's first token assume it's their home token
        return if corporation.tokens.first&.used

        hex = hex_by_id(corporation.coordinates)

        tile = hex&.tile
        if !tile || (tile.reserved_by?(corporation) && tile.paths.any?)

          # If the tile does not have any paths at the present time, clear up the ambiguity when the tile is laid
          # otherwise the entity must choose now.
          @log << "#{corporation.name} must choose city for home token"

          hexes =
            if hex
              [hex]
            else
              home_token_locations(corporation)
            end

          @round.pending_tokens << {
            entity: corporation,
            hexes: hexes,
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

      def tile_cost(tile, entity)
        ability = entity.all_abilities.find { |a| a.type == :tile_discount }

        tile.upgrades.sum do |upgrade|
          discount = ability && upgrade.terrains.uniq == [ability.terrain] ? ability.discount : 0

          if discount.positive?
            @log << "#{entity.name} receives a discount of "\
              "#{format_currency(discount)} from "\
              "#{ability.owner.name}"
          end

          total_cost = upgrade.cost - discount
          total_cost
        end
      end

      def declare_bankrupt(player)
        if player.bankrupt
          msg = "#{player.name} is already bankrupt, cannot declare bankruptcy again."
          game_error(msg)
        end

        player.bankrupt = true
      end

      def tile_lays(_entity)
        # Some games change available lays depending on if minor or corp
        self.class::TILE_LAYS
      end

      def upgrades_to?(from, to, special = false)
        # correct color progression?
        return false unless Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)

        # honors pre-existing track?
        return false unless from.paths_are_subset_of?(to.paths)

        # If special ability then remaining checks is not applicable
        return true if special

        # correct label?
        return false if from.label != to.label

        # honors existing town/city counts?
        # - allow labelled cities to upgrade regardless of count; they're probably
        #   fine (e.g., 18Chesapeake's OO cities merge to one city in brown)
        # - TODO: account for games that allow double dits to upgrade to one town
        return false if from.towns.size != to.towns.size
        return false if !from.label && from.cities.size != to.cities.size

        true
      end

      def legal_tile_rotation?(_entity, _hex, _tile)
        true
      end

      def game_error(msg)
        raise GameError.new(msg, current_action_id)
      end

      def float_corporation(corporation)
        @log << "#{corporation.name} floats"

        return if corporation.capitalization == :incremental

        @bank.spend(corporation.par_price.price * 10, corporation)
        @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
      end

      def reset_corporation(corporation)
        @_shares.reject! do |_, share|
          next if share.corporation != corporation

          share.owner.shares_by_corporation[corporation].clear

          true
        end

        corporation.companies.dup.each(&:close!)

        corporation.share_price.corporations.delete(corporation)
        corporation = init_corporations(@stock_market).find { |c| c.id == corporation.id }

        @corporations.map! { |c| c.id == corporation.id ? corporation : c }
        @_corporations[corporation.id] = corporation
        corporation.shares.each { |share| @_shares[share.id] = share }
      end

      def emergency_issuable_bundles(_corporation)
        []
      end

      def emergency_issuable_cash(corporation)
        emergency_issuable_bundles(corporation).max_by(&:num_shares)&.price || 0
      end

      def can_go_bankrupt?(player, corporation)
        return false unless self.class::BANKRUPTCY_ALLOWED

        total_emr_buying_power(player, corporation) < @depot.min_depot_price
      end

      def total_emr_buying_power(player, corporation)
        corporation.cash +
          emergency_issuable_cash(corporation) +
          liquidity(player, emergency: true)
      end

      def buying_power(entity)
        entity.cash + (issuable_shares(entity).map(&:price).max || 0)
      end

      def two_player?
        @two_player ||= @players.size == 2
      end

      def add_extra_tile(tile)
        game_error('Add extra tile only works if unlimited') unless tile.unlimited

        # Find the highest tile that exists of this type in the tile list and duplicate it.
        # The highest one in the list should be the highest index anywhere.
        tiles = @_tiles.values.select { |t| t.name == tile.name }
        new_tile = tiles.max { |a, b| a.index <=> b.index }.dup
        @tiles << new_tile

        @_tiles[new_tile.id] = new_tile
        extra_cities = new_tile.cities
        @cities.concat(extra_cities)
        extra_cities.each { |c| @_cities[c.id] = c }
      end

      def after_par(corporation)
        return unless corporation.capitalization == :incremental

        all_companies_with_ability(:shares) do |company, ability|
          next unless corporation.name == ability.shares.first.corporation.name

          amount = ability.shares.sum { |share| corporation.par_price.price * share.num_shares }
          @bank.spend(amount, corporation)
          @log << "#{corporation.name} receives #{format_currency(amount)}
                   from #{company.name}"
        end
      end

      private

      def init_bank
        cash = self.class::BANK_CASH
        cash = cash[players.size] if cash.is_a?(Hash)

        Bank.new(cash, log: @log)
      end

      def init_cert_limit
        cert_limit = self.class::CERT_LIMIT
        cert_limit.is_a?(Hash) ? cert_limit[players.size] : cert_limit
      end

      def init_phase
        Phase.new(self.class::PHASES, self)
      end

      def init_round
        new_auction_round
      end

      def init_stock_market
        StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                        multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
      end

      def init_companies(players)
        self.class::COMPANIES.map do |company|
          next if players.size < (company[:min_players] || 0)

          Company.new(**company)
        end.compact
      end

      def init_train_handler
        trains = self.class::TRAINS.flat_map do |train|
          (train[:num] || num_trains(train)).times.map do |index|
            Train.new(**train, index: index)
          end
        end

        Depot.new(trains, self)
      end

      def num_trains(_train)
        raise NotImplementedError
      end

      def init_minors
        self.class::MINORS.map { |minor| Minor.new(**minor) }
      end

      def init_loans
        []
      end

      def loans_taken
        @total_loans - @loans.size
      end

      def maximum_loans(_entity)
        0
      end

      def corporation_opts
        {}
      end

      def init_corporations(stock_market)
        min_price = stock_market.par_prices.map(&:price).min

        self.class::CORPORATIONS.map do |corporation|
          Corporation.new(
            min_price: min_price,
            capitalization: self.class::CAPITALIZATION,
            **corporation.merge(corporation_opts),
          )
        end
      end

      def init_hexes(companies, corporations)
        blockers = {}
        companies.each do |company|
          company.abilities(:blocks_hexes) do |ability|
            ability.hexes.each do |hex|
              blockers[hex] = company
            end
          end
        end

        reservations = Hash.new { |k, v| k[v] = [] }
        corporations.each do |c|
          reservations[c.coordinates] << { entity: c,
                                           city: c.city }
        end
        (corporations + companies).each do |c|
          c.abilities(:reservation) do |ability|
            reservations[ability.hex] << { entity: c,
                                           city: ability.city.to_i,
                                           slot: ability.slot.to_i,
                                           ability: ability }
          end
        end

        self.class::HEXES.map do |color, hexes|
          hexes.map do |coords, tile_string|
            coords.map.with_index do |coord, index|
              next Hex.new(coord, layout: layout, axes: axes, empty: true) if color == :empty

              tile =
                begin
                  Tile.for(tile_string, preprinted: true, index: index)
                rescue Engine::GameError
                  Tile.from_code(coord, color, tile_string, preprinted: true, index: index)
                end

              if (blocker = blockers[coord])
                tile.add_blocker!(blocker)
              end

              reservations[coord].each do |res|
                res[:ability].tile = tile if res[:ability]
                tile.add_reservation!(res[:entity], res[:city], res[:slot])
              end

              # name the location (city/town)
              location_name = self.class::LOCATION_NAMES[coord]

              Hex.new(coord, layout: layout, axes: axes, tile: tile, location_name: location_name)
            end
          end
        end.flatten
      end

      def init_tiles
        self.class::TILES.flat_map do |name, val|
          if val.is_a?(Integer) || val == 'unlimited'
            count = val == 'unlimited' ? 1 : val
            count.times.map do |i|
              Tile.for(
                name,
                index: i,
                reservation_blocks: self.class::TILE_RESERVATION_BLOCKS_OTHERS,
                unlimited: val == 'unlimited'
              )
            end
          else
            count = val['count'] == 'unlimited' ? 1 : val['count']
            color = val['color']
            code = val['code']
            count.times.map do |i|
              Tile.from_code(
                name,
                color,
                code,
                index: i,
                reservation_blocks: self.class::TILE_RESERVATION_BLOCKS_OTHERS,
                unlimited: val['count'] == 'unlimited'
              )
            end
          end
        end
      end

      def init_starting_cash(players, bank)
        cash = self.class::STARTING_CASH
        cash = cash[players.size] if cash.is_a?(Hash)

        players.each do |player|
          bank.spend(cash, player)
        end
      end

      def init_company_abilities
        @companies.each do |company|
          next unless (ability = company.abilities(:shares))

          real_shares = []
          ability.shares.each do |share|
            case share
            when 'random_president'
              corporation = @corporations[rand % @corporations.size]
              share = corporation.shares[0]
              real_shares << share
              company.desc = "Purchasing player takes a president's share (20%) of #{corporation.name} \
              and immediately sets its par value. #{company.desc}"
              @log << "#{company.name} comes with the president's share of #{corporation.name}"
            when 'random_share'
              corporations = ability.corporations&.map { |id| corporation_by_id(id) } || @corporations
              corporation = corporations[rand % corporations.size]
              share = corporation.shares.find { |s| !s.president }
              real_shares << share
              company.desc = "#{company.desc} The random corporation in this game is #{corporation.name}."
              @log << "#{company.name} comes with a #{share.percent}% share of #{corporation.name}"
            else
              real_shares << share_by_id(share)
            end
          end

          ability.shares = real_shares
        end
      end

      def init_share_pool
        SharePool.new(self)
      end

      def connect_hexes
        coordinates = @hexes.map { |h| [[h.x, h.y], h] }.to_h

        @hexes.each do |hex|
          Hex::DIRECTIONS[hex.layout].each do |xy, direction|
            x, y = xy
            neighbor = coordinates[[hex.x + x, hex.y + y]]
            next unless neighbor
            next if self.class::IMPASSABLE_HEX_COLORS.include?(neighbor.tile.color) && !neighbor.targeting?(hex)
            next if hex.tile.borders.any? { |border| border.edge == direction && border.type == :impassable }

            hex.neighbors[direction] = neighbor
          end
        end

        @hexes.select { |h| h.tile.cities.any? || h.tile.exits.any? }.each(&:connect!)
      end

      def total_rounds(name)
        # Return the total number of rounds for those with more than one.
        @operating_rounds if name == 'Operating'
      end

      def next_round!
        @round =
          case @round
          when Round::Stock
            @operating_rounds = @phase.operating_rounds
            reorder_players
            new_operating_round
          when Round::Operating
            if @round.round_num < @operating_rounds
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
            reorder_players
            new_stock_round
          end
      end

      def game_end_check_values
        self.class::GAME_END_CHECK
      end

      def custom_end_game_reached?
        false
      end

      def game_end_check
        triggers = {
          bankrupt: bankruptcy_limit_reached?,
          bank: @bank.broken?,
          stock_market: @stock_market.max_reached?,
          final_train: @depot.empty?,
          custom: custom_end_game_reached?,
        }.select { |_, t| t }

        %i[immediate current_round current_or full_or one_more_full_or_set].each do |after|
          triggers.keys.each do |reason|
            if game_end_check_values[reason] == after
              (@turn == (@final_turn ||= @turn + 1)) if after == :one_more_full_or_set
              return [reason, after]
            end
          end
        end

        nil
      end

      def end_now?(after)
        return false unless after
        return true if after == :immediate
        return true if after == :current_round
        return false unless @round.is_a?(round_end)
        return true if after == :current_or

        final_or_in_set = @round.round_num == @operating_rounds

        return (@turn == @final_turn) if final_or_in_set && (after == :one_more_full_or_set)

        final_or_in_set
      end

      def round_end
        Round::Operating
      end

      def final_operating_rounds
        operating_rounds
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
                         if @round.is_a?(Round::Operating)
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
        }
        "#{reason_map[reason]}#{after_text}"
      end

      def action_processed(_action); end

      def priority_deal_player
        players = @players.reject(&:bankrupt)

        if @round.current_entity&.player?
          # We're in a round that iterates over players, so the
          # priority deal card goes to the player who will go first if
          # everyone passes starting now.  last_to_act is nil before
          # anyone has gone, in which case the first player has PD.
          players[((players.index(@round.last_to_act) || -1) + 1) % players.size]
        else
          # We're in a round that iterates over something else, like
          # corporations.  The player list was already rotated when we
          # left a player-focused round to put the PD player first.
          players.first
        end
      end

      def next_sr_position(entity)
        player_order = @round.current_entity&.player? ? @round.pass_order : @players
        player_order.reject(&:bankrupt).index(entity)
      end

      def reorder_players
        case self.class::NEXT_SR_PLAYER_ORDER
        when :after_last_to_act
          player = @players.reject(&:bankrupt)[@round.entity_index]
          @players.rotate!(@players.index(player))
        when :first_to_pass
          @players = @round.pass_order if @round.pass_order.any?
        end
        @log << "#{@players.first.name} has priority deal"
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::CompanyPendingPar,
          Step::WaterfallAuction,
        ])
      end

      def new_stock_round
        @log << "-- #{round_description('Stock')} --"
        stock_round
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::Exchange,
          Step::SpecialTrack,
          Step::BuySellParShares,
        ])
      end

      def new_operating_round(round_num = 1)
        @log << "-- #{round_description('Operating', round_num)} --"
        operating_round(round_num)
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::DiscardTrain,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def event_close_companies!
        @log << '-- Event: Private companies close --'

        @companies.each do |company|
          if (ability = company.abilities(:close))
            next if ability.when == 'never' ||
              @phase.phases.any? { |phase| ability.when == phase[:name] }
          end

          company.close!
        end
      end

      def cache_objects
        CACHABLE.each do |type, name|
          ivar = "@_#{type}"
          instance_variable_set(ivar, send(type).map { |x| [x.id, x] }.to_h)

          self.class.define_method("#{name}_by_id") do |id|
            instance_variable_get(ivar)[id]
          end
        end
      end

      def bankruptcy_limit_reached?
        @players.any?(&:bankrupt)
      end

      def all_potential_upgrades(tile, tile_manifest: false) # rubocop:disable Lint/UnusedMethodArgument
        colors = Array(@phase.phases.last[:tiles])
        @all_tiles
          .select { |t| colors.include?(t.color) }
          .uniq(&:name)
          .select { |t| upgrades_to?(tile, t) }
          .reject(&:blocks_lay)
      end

      def interest_rate; end

      def president_assisted_buy(_corporation, _train, _price)
        [0, 0]
      end

      def round_description(name, round_number = nil)
        round_number ||= @round.round_num
        description = "#{name} Round "

        total = total_rounds(name)

        description += @turn.to_s unless @turn.zero?
        description += '.' if total && !@turn.zero?
        description += "#{round_number} (of #{total})" if total

        description.strip
      end

      def corporation_available?(_entity)
        true
      end

      def or_description_short(turn, round)
        "#{turn}.#{round}"
      end

      # Override this, and add elements (paragraphs of text) here to display it on Info page.
      def timeline
        []
      end
    end
  end
end
