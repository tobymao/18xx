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
require_relative '../game_error'
require_relative '../option_error'
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
require_relative '../player_info'
require_relative '../game_log'
require_relative 'meta'

module Engine
  module Game
    def self.load(data, at_action: nil, actions: nil, pin: nil, optional_rules: nil, user: nil, **kwargs)
      case data
      when String
        parsed_data = JSON.parse(File.exist?(data) ? File.read(data) : data)
        return load(parsed_data,
                    at_action: at_action,
                    actions: actions,
                    pin: pin,
                    optional_rules: optional_rules,
                    user: user,
                    **kwargs)
      when Hash
        title = data['title']
        names = data['players'].to_h { |p| [p['id'] || p['name'], p['name']] }
        id = data['id']
        actions ||= data['actions'] || []
        pin ||= data.dig('settings', 'pin')
        optional_rules ||= data.dig('settings', 'optional_rules') || []
      when Integer
        return load(::Game[data],
                    at_action: at_action,
                    actions: actions,
                    pin: pin,
                    optional_rules: optional_rules,
                    user: user,
                    **kwargs)
      when ::Game
        title = data.title
        names = data.ordered_players.to_h { |u| [u.id, u.name] }
        id = data.id
        actions ||= data.actions.map(&:to_h)
        pin ||= data.settings['pin']
        optional_rules ||= data.settings['optional_rules'] || []
      end

      Engine.game_by_title(title).new(
        names, id: id, actions: actions, at_action: at_action, pin: pin, optional_rules: optional_rules, user: user, **kwargs
      )
    end

    class Base
      include Game::Meta

      attr_reader :raw_actions, :actions, :bank, :cities, :companies, :corporations,
                  :depot, :finished, :graph, :hexes, :id, :loading, :loans, :log, :minors,
                  :phase, :players, :operating_rounds, :round, :share_pool, :stock_market, :tile_groups,
                  :tiles, :turn, :total_loans, :undo_possible, :redo_possible, :round_history, :all_tiles,
                  :optional_rules, :exception, :last_processed_action, :broken_action,
                  :turn_start_action_id, :last_turn_start_action_id, :programmed_actions, :round_counter,
                  :manually_ended

      # Game end check is described as a dictionary
      # with reason => after
      #   reason: What kind of game end check to do
      #   after: When game should end if check triggered
      # Leave out a reason if game does not support that.
      # Allowed reasons:
      #  bankrupt, stock_market, bank, final_train, final_phase, custom
      # Allowed after:
      #  immediate - ends in current turn
      #  current_round - ends at the end of the current round
      #  current_or - ends at the next end of an OR
      #  full_or - ends at the next end of a complete OR set
      #  one_more_full_or_set - finish the current OR set, then
      #                         end after the next complete OR set
      GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or }.freeze

      BANKRUPTCY_ALLOWED = true
      # How many players does bankrupcy cause to end the game
      # one - as soon as any player goes bankrupt
      # all_but_one - all but one
      BANKRUPTCY_ENDS_GAME_AFTER = :one

      BANK_CASH = 12_000

      CURRENCY_FORMAT_STR = '$%s'

      STARTING_CASH = {}.freeze

      HEXES = {}.freeze

      LAYOUT = nil

      AXES = nil

      TRAINS = [].freeze

      CERT_LIMIT_TYPES = %i[multiple_buy unlimited no_cert_limit].freeze
      # Does the cert limit decrease when a player becomes bankrupt?
      CERT_LIMIT_CHANGE_ON_BANKRUPTCY = false
      CERT_LIMIT_INCLUDES_PRIVATES = true
      # Does the cert limit care about how many players started the game or how
      # many remain?
      CERT_LIMIT_COUNTS_BANKRUPTED = false

      PRESIDENT_SALES_TO_MARKET = false

      MULTIPLE_BUY_TYPES = %i[multiple_buy].freeze
      MULTIPLE_BUY_ONLY_FROM_MARKET = false

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
      ONLY_HIGHEST_BID_COMMITTED = false

      CAPITALIZATION = :full

      # Must sell all shares of a company in one action per turn
      MUST_SELL_IN_BLOCKS = false

      # Percent of one company you are allowed to sell in one turn. Nil means
      # unlimited and is the default
      TURN_SELL_LIMIT = nil

      # when can a share holder sell shares
      # first           -- after first stock round
      # after_ipo       -- after stock round in which company is opened
      # operate         -- after operation
      # p_any_operate   -- pres any time, share holders after operation
      # any_time        -- at any time
      SELL_AFTER = :first

      # down_share -- down one row per share
      # down_per_10 -- down one row per 10% sold
      # down_block -- down one row per block
      # left_share -- left one column per share
      # left_share_pres -- left one column per share if president
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

      # do sold out shares increase the price?
      SOLD_OUT_INCREASE = true

      # :after_last_to_act -- player after the last to act goes first. Order remains the same.
      # :first_to_pass -- players ordered by when they first started passing.
      NEXT_SR_PLAYER_ORDER = :after_last_to_act

      # do tile reservations completely block other companies?
      # :never -- token can be placed as long as there is a city space for existing tile reservations
      # :always -- token cannot be placed until tile reservation resolved
      # :single_slot_cities -- token cannot be placed if tile contains any single slot cities
      TILE_RESERVATION_BLOCKS_OTHERS = :never

      COMPANIES = [].freeze
      COMPANY_CLASS = Company

      CORPORATION_CLASS = Corporation
      CORPORATIONS = [].freeze

      TRAIN_CLASS = Train
      DEPOT_CLASS = Depot

      MINORS = [].freeze

      PHASES = [].freeze

      LOCATION_NAMES = {}.freeze

      TRACK_RESTRICTION = :semi_restrictive

      # ebuy = presidential cash is contributed
      EBUY_PRES_SWAP = true # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = true # allow ebuying other corp trains for up to face
      EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = true # if ebuying from depot, must buy cheapest train
      MUST_EMERGENCY_ISSUE_BEFORE_EBUY = false # corporation must issue shares before ebuy (if possible)
      EBUY_SELL_MORE_THAN_NEEDED = false # true if corporation may continue to sell shares even though enough funds
      EBUY_CAN_SELL_SHARES = true # true if a player can sell shares for ebuy
      EBUY_OWNER_MUST_HELP = false # owner of ebuying entity is on the hook

      # if sold more than needed then cannot then buy a cheaper train in the depot.
      EBUY_SELL_MORE_THAN_NEEDED_LIMITS_DEPOT_TRAIN = false

      # loans taken during ebuy can lead to receviership
      EBUY_CORP_LOANS_RECEIVERSHIP = false

      # where should sold shares go to?
      # :bank - bank pool
      # :corporation - back to corporation/ipo
      SOLD_SHARES_DESTINATION = :bank

      # when is the home token placed? on...
      # par
      # float
      # operating_round (start of next OR)
      # operate (corporation's first OR turn)
      HOME_TOKEN_TIMING = :operate

      DISCARDED_TRAINS = :discard # discard or remove
      DISCARDED_TRAIN_DISCOUNT = 0 # percent
      CLOSED_CORP_TRAINS_REMOVED = true
      CLOSED_CORP_RESERVATIONS_REMOVED = true

      MUST_BUY_TRAIN = :route # When must the company buy a train if it doesn't have one (route, never, always)

      ALLOW_TRAIN_BUY_FROM_OTHERS = true # Allows train buy from other corporations
      ALLOW_TRAIN_BUY_FROM_OTHER_PLAYERS = true # Allows train buy from other player's corporations
      ALLOW_OBSOLETE_TRAIN_BUY = false # Allows obsolete trains to be bought from other corporations

      # Default tile lay, one tile either upgrade or lay at zero cost
      # allows multiple lays, value must be either true, false or :not_if_upgraded
      TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze

      # The tile type of the game
      # :normal Tile type like 1830, 1846.
      # :lawson Tile type like 1817, 1822
      TILE_TYPE = :normal

      # games where minors can own shares
      MINORS_CAN_OWN_SHARES = false

      # Must an upgrade use the maximum number of exits
      # for track and/or cities?
      # :cities for cities, as in  #611 and #63 in 1822
      # :track  for track, as in 18USA
      TILE_UPGRADES_MUST_USE_MAX_EXITS = [].freeze

      TILE_COST = 0

      IMPASSABLE_HEX_COLORS = %i[blue gray red].freeze

      EVENTS_TEXT = {
        'close_companies' =>
          ['Companies Close', 'All companies unless otherwise noted are discarded from the game'],
      }.freeze

      STATUS_TEXT = {
        'can_buy_companies' =>
          ['Can Buy Companies', 'All corporations can buy companies from players'],
      }.freeze

      MARKET_TEXT = {
        par: 'Par value',
        no_cert_limit: 'Corporation shares do not count towards cert limit',
        unlimited: 'Corporation shares can be held above 60%',
        multiple_buy: 'Can buy more than one share in the corporation per turn',
        close: 'Corporation closes',
        endgame: 'End game trigger',
        liquidation: 'Liquidation',
        repar: 'Par value after bankruptcy',
        ignore_one_sale: 'Ignore first share sold when moving price',
      }.freeze

      GAME_END_REASONS_TEXT = {
        bankrupt: 'player is bankrupt', # this is prefixed in the UI
        bank: 'The bank runs out of money',
        stock_market: 'Corporation enters end game trigger on stock market',
        final_train: 'The final train is purchased',
        final_phase: 'The final phase is entered',
        custom: 'Unknown custom reason', # override on subclasses
      }.freeze

      GAME_END_REASONS_TIMING_TEXT = {
        immediate: 'Immediately',
        current_round: 'End of the current round',
        current_or: 'Next end of an OR',
        full_or: 'Next end of a complete OR set',
        one_more_full_or_set: 'End of the next complete OR set after the current one',
      }.freeze

      GAME_END_DESCRIPTION_REASON_MAP_TEXT = {
        bank: 'Bank Broken',
        bankrupt: 'Bankruptcy',
        stock_market: 'Company hit max stock value',
        final_train: 'Final train was purchased',
        final_phase: 'Final phase was reached',
      }.freeze

      ASSIGNMENT_TOKENS = {}.freeze

      OPERATING_ROUND_NAME = 'Operating'
      OPERATION_ROUND_SHORT_NAME = 'ORs'

      MARKET_SHARE_LIMIT = 50 # percent
      ALL_COMPANIES_ASSIGNABLE = false
      OBSOLETE_TRAINS_COUNT_FOR_LIMIT = false

      CORPORATE_BUY_SHARE_SINGLE_CORP_ONLY = false
      CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT = false

      VARIABLE_FLOAT_PERCENTAGES = false

      # whether corporation cards should show percentage ownership breakdown for players
      SHOW_SHARE_PERCENT_OWNERSHIP = false

      # Setting this to true is neccessary but insufficent to allow downgrading town tiles into plain track
      # See 1856 for an example
      ALLOW_REMOVING_TOWNS = false

      # Can a player have multiple outstanding programmed actions
      # If true, will possibly need to handle incompatable programmed actions
      # (e.g. ProgramSharePass and ProgramBuyShares)
      ALLOW_MULTIPLE_PROGRAMS = false

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

      def setup_preround; end

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

      # use to modify hexes based on optional rules
      def optional_hexes
        game_hexes
      end

      def game_hexes
        self.class::HEXES
      end

      def hex_neighbor(hex, edge)
        return hex.neighbors[edge] if hex.neighbors[edge]

        letter = hex.id.match(Engine::Hex::COORD_LETTER)[1]
        number = hex.id.match(Engine::Hex::COORD_NUMBER)[1].to_i

        flip_axes = case [layout, axes]
                    when [:flat, { x: :number, y: :letter }]
                      true
                    else
                      false
                    end

        d_letter, d_number = case [layout, edge]
                             when [:flat, 0], [:pointy, 4]
                               [0, 2]
                             when [:flat, 1], [:pointy, 3]
                               [-1, 1]
                             when [:flat, 2], [:pointy, 2]
                               [-1, -1]
                             when [:flat, 3], [:pointy, 1]
                               [0, -2]
                             when [:flat, 4], [:pointy, 0]
                               [1, -1]
                             when [:flat, 5], [:pointy, 5]
                               [1, 1]
                             end
        d_letter, d_number = [d_number, d_letter] if flip_axes

        letter = Engine::Hex::LETTERS[Engine::Hex::LETTERS.index(letter) + d_letter]
        number += d_number

        hex_by_id("#{letter}#{number}")
      end

      # use to modify location names based on optional rules
      def location_name(coord)
        self.class::LOCATION_NAMES[coord]
      end

      # use to modify tiles based on optional rules
      def optional_tiles; end

      def self.register_colors(colors)
        colors.default_proc = proc do |_, key|
          key
        end

        const_set(:COLORS, colors)
      end

      def self.include_meta(meta_module)
        include meta_module

        meta_module.constants.each do |const|
          const_set(const, meta_module.const_get(const))
        end

        const_set(:META, meta_module)
      end

      def self.meta
        self::META
      end

      def meta
        self.class.meta
      end

      def game_instance?
        true
      end

      def initialize(names, id: 0, actions: [], at_action: nil, pin: nil, strict: false, optional_rules: [], user: nil)
        @id = id
        @turn = 1
        @final_turn = nil
        @loading = false
        @strict = strict
        @finished = false
        @log = Engine::GameLog.new(self)
        @queued_log = []
        @actions = []
        @raw_actions = []
        @turn_start_action_id = 0
        @last_turn_start_action_id = 0
        @exception = nil
        @names = if names.is_a?(Hash)
                   names.freeze
                 else
                   names.to_h { |n| [n, n] }
                 end

        @players = @names.map { |player_id, name| Player.new(player_id, name) }
        @user = user
        @programmed_actions = Hash.new { |h, k| h[k] = [] }
        @round_counter = 0

        @optional_rules = init_optional_rules(optional_rules)

        @seed = @id.to_s.scan(/\d+/).first.to_i % RAND_M

        case self.class::DEV_STAGE
        when :prealpha
          @log << "#{self.class.title} is in prealpha state, no support is provided at all"
        when :alpha
          @log << "#{self.class.title} is currently considered 'alpha',"\
                  ' the rules implementation is likely to not be complete.'
          @log << 'As the implementation improves, games that are not compatible'\
                  ' with the latest version will be archived without notice.'
          @log << 'We suggest that any alpha quality game is concluded within 7 days.'
        when :beta
          @log << "#{self.class.title} is currently considered 'beta',"\
                  ' the rules implementation may allow illegal moves.'
          @log << 'As the implementation improves, games that are not compatible'\
                  ' with the latest version will be pinned but may be archived after 7 days.'
          @log << 'Because of this we suggest not playing games that may take months to complete.'
        end

        if self.class::PROTOTYPE
          @log << "#{self.class.title} is currently a prototype game, "\
                  ' the design is not final, and so may change at any time.'
          @log << 'If the game is modified due to a design change, games will be pinned' unless self.class::DEV_STAGE == :alpha

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
        optional_tiles
        @tile_groups = []
        @cert_limit = init_cert_limit
        @removals = []

        @depot = init_train_handler
        init_starting_cash(@players, @bank)
        @share_pool = init_share_pool
        @hexes = init_hexes(@companies, @corporations)
        @graph = init_graph

        # call here to set up ids for all cities before any tiles from @tiles
        # can be placed onto the map
        @cities = (@hexes.map(&:tile) + @tiles).map(&:cities).flatten

        @phase = init_phase
        @operating_rounds = @phase&.operating_rounds

        @round_history = []
        setup_preround
        @round = init_round

        cache_objects
        connect_hexes

        init_company_abilities

        setup_optional_rules
        log_optional_rules
        setup
        @round.setup

        initialize_actions(actions, at_action: at_action)

        return unless pin

        @log << '----'
        @log << 'Your game was unable to be upgraded to the latest version of 18xx.games.'
        @log << "It is pinned to version #{pin}."
        @log << 'Please do not submit bug reports for pinned games. Pinned games cannot be debugged.'
        @log << 'Please note, pinned games may be deleted after 7 days.' if self.class::DEV_STAGE == :beta
        @log << '----'
      end

      def rand
        @seed =
          if RUBY_ENGINE == 'opal'
            `parseInt(Big(#{RAND_A}).times(#{@seed}).plus(#{RAND_C}).mod(#{RAND_M}).toString())`
          else
            ((RAND_A * @seed) + RAND_C) % RAND_M
          end
      end

      def inspect
        "#{self.class.name} - #{self.class.title} #{players.map(&:name)}"
      end

      def result_players
        @players
      end

      def result
        result_players
          .map { |p| [p.id, player_value(p)] }
          .sort_by { |_, v| v }
          .reverse
          .to_h
      end

      def turn_round_num
        [turn, @round.round_num]
      end

      def current_entity
        @round.active_step&.current_entity || actions[-1].entity
      end

      def pass_entity(_user)
        current_entity
      end

      def active_players
        players_ = @round.active_entities.map { |e| acting_for_player(e&.player) }.compact

        players_.empty? ? @players.reject(&:bankrupt) : players_
      end

      def active_step
        @round.active_step
      end

      def active_players_id
        active_players.map(&:id)
      end

      def valid_actors(action)
        if (player = action.entity.player)
          [acting_for_player(player)]
        else
          active_players
        end
      end

      def acting_for_entity(entity)
        entity&.owner
      end

      def acting_for_player(player)
        player
      end

      def player_log(entity, msg)
        @log << "-- #{msg}" if entity.id == @user
      end

      def available_programmed_actions
        # By default assume normal 1830esk buy shares
        [Action::ProgramBuyShares, Action::ProgramSharePass]
      end

      def self.filtered_actions(actions)
        active_undos = []
        filtered_actions = Array.new(actions.size)

        actions.each.with_index do |action, index|
          case action['type']
          when 'undo'
            undo_to = if (id = action['action_id'])
                        id.zero? ? 0 : actions.index { |a| a['id'] == action['action_id'] } + 1
                      else
                        filtered_actions.rindex { |a| a && a['type'] != 'message' } || 0
                      end
            active_undos << filtered_actions[undo_to...index].map.with_index do |a, i|
              next if !a || a['type'] == 'message'

              filtered_actions[undo_to + i] = nil
              [a, undo_to + i]
            end.compact
          when 'redo'
            active_undos.pop.each { |undo| filtered_actions[undo.last] = undo.first }
          when 'message'
            # Messages do not get undoed.
            # warning adding more types of action here will break existing game
            filtered_actions[index] = action
          else
            active_undos.clear unless active_undos.empty?
            filtered_actions[index] = action
          end
        end
        [filtered_actions, active_undos]
      end

      # Initialize actions respecting the undo state
      def initialize_actions(actions, at_action: nil)
        @loading = true unless @strict
        @filtered_actions, active_undos = self.class.filtered_actions(actions)

        # Store all actions for history navigation
        @raw_all_actions = actions

        @undo_possible = false
        process_to_action(at_action || actions.last['id']) unless actions.empty?
        @redo_possible = active_undos.any?
        @loading = false
      end

      # Override this if a game has a licensing mechanic for corporations and trains
      # See 1862 for an example
      def able_to_operate?(_entity, _train, _name)
        true
      end

      def process_action(action, add_auto_actions: false, validate_auto_actions: false)
        action = Engine::Action::Base.action_from_h(action, self) if action.is_a?(Hash)

        action.id = current_action_id + 1
        @raw_actions << action.to_h
        return clone(@raw_actions) if action.is_a?(Action::Undo) || action.is_a?(Action::Redo)

        @actions << action

        # Process the main action we came here to do first
        process_single_action(action)

        unless action.is_a?(Action::Message)
          @redo_possible = false
          @undo_possible = true
          @last_game_action_id = action.id
        end

        if add_auto_actions || validate_auto_actions
          auto_actions = []
          until (actions = round.auto_actions || []).empty?
            actions.each { |a| process_single_action(a) }
            auto_actions.concat(actions)
          end
          if validate_auto_actions
            raise GameError, 'Auto actions do not match' unless auto_actions_match?(action.auto_actions, auto_actions)
          else
            # Update the last raw actions as the hash maybe incorrect
            action.clear_cache
            action.auto_actions = auto_actions
            @raw_actions[-1] = action.to_h
          end
        else
          action.auto_actions.each { |a| process_single_action(a) }
        end
        @last_processed_action = action.id

        self
      rescue StandardError => e
        rescue_exception(e, action)
        self
      end

      def process_single_action(action)
        if action.user && action.user != acting_for_player(action.entity&.player)&.id && action.type != 'message'
          @log << "• Action(#{action.type}) via Master Mode by: #{player_by_id(action.user)&.name || 'Owner'}"
        end

        preprocess_action(action)

        @round.process_action(action)

        action_processed(action)

        end_timing = game_end_check&.last
        end_game! if end_timing == :immediate

        while @round.finished? && !@finished
          @round.entities.each(&:unpass!)

          if end_now?(end_timing)
            end_game!
          else
            transition_to_next_round!
          end
        end
      rescue Engine::GameError => e
        rescue_exception(e, action)
      end

      def rescue_exception(e, action)
        @raw_actions.pop
        @actions.pop
        @exception = e
        @broken_action = action
      end

      def transition_to_next_round!
        store_player_info
        next_round!
        check_programmed_actions

        finalize_round_setup
      end

      def finalize_round_setup
        # Finalize round setup (for things that need round correctly set like place_home_token)
        @round.at_start = true
        @round.setup
        @round_history << current_action_id
      end

      def maybe_raise!
        if @exception
          exception = @exception
          @exception = nil
          @broken_action = nil
          raise exception
        end

        self
      end

      def auto_actions_match?(actions_a, actions_b)
        return false unless actions_a.size == actions_b.size

        actions_a.zip(actions_b).all? do |a, b|
          a.to_h.except('created_at') == b.to_h.except('created_at')
        end
      end

      def store_player_info
        return unless @round.show_in_history?

        @players.each do |p|
          p.history << PlayerInfo.new(@round.class.short_name, turn, @round.round_num, player_value(p))
        end
      end

      def preprocess_action(_action); end

      def all_corporations
        corporations
      end

      def sorted_corporations
        # Corporations sorted by some potential game rules
        ipoed, others = corporations.partition(&:ipoed)
        ipoed.sort + others
      end

      def operating_order
        @minors.select(&:floated?) + @corporations.select(&:floated?).sort
      end

      def operated_operators
        (@corporations + @minors).select(&:operated?)
      end

      def current_action_id
        @raw_actions[-1]&.fetch('id') || 0
      end

      def last_game_action_id
        @last_game_action_id || 0
      end

      def previous_action_id_from(action_id)
        # Skips messages and undone actions
        @filtered_actions.reverse.find { |a| a && a['id'] < action_id && a['type'] != 'message' }&.fetch('id') || 0
      end

      def next_action_id_from(action_id)
        # Skips messages and undone actions
        @filtered_actions.find { |a| a && a['id'] > action_id && a['type'] != 'message' }&.fetch('id')
      end

      def process_to_action(id)
        last_processed_action_id = @raw_actions.last&.fetch('id') || 0
        @raw_all_actions.each.with_index do |action, index|
          next if @exception
          next if action['id'] <= last_processed_action_id
          break if action['id'] > id

          if @filtered_actions[index]
            process_action(action)
            # maintain original action ids
            @raw_actions.last['id'] = action['id']
            @last_processed_action = action['id']
          else
            @raw_actions << action
          end
        end
      end

      def next_turn!
        return if @turn_start_action_id == current_action_id

        @last_turn_start_action_id = @turn_start_action_id
        @turn_start_action_id = current_action_id
      end

      def clone(actions)
        self.class.new(@names, id: @id, pin: @pin, actions: actions, optional_rules: @optional_rules)
      end

      def trains
        @depot.trains
      end

      def train_limit(entity)
        @phase.train_limit(entity)
      end

      def train_owner(train)
        train.owner
      end

      def route_trains(entity)
        entity.runnable_trains
      end

      def discarded_train_placement
        self.class::DISCARDED_TRAINS
      end

      # Before rusting, check if this train individual should rust.
      def rust?(train, purchased_train)
        train.rusts_on == purchased_train.sym ||
          (train.obsolete_on == purchased_train.sym && @depot.discarded.include?(train))
      end

      # Before obsoleting, check if this specific train should obsolete.
      def obsolete?(train, purchased_train)
        train.obsolete_on == purchased_train.sym
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

      def format_revenue_currency(val)
        format_currency(val)
      end

      def routes_subsidy(_routes)
        0
      end

      def submit_revenue_str(routes, show_subsidy)
        revenue_str = format_revenue_currency(routes_revenue(routes))
        subsidy = routes_subsidy(routes)
        subsidy_str = show_subsidy || subsidy.positive? ? " + #{format_currency(routes_subsidy(routes))} (subsidy)" : ''
        revenue_str + subsidy_str
      end

      def purchasable_companies(entity = nil)
        @companies.select do |company|
          company.owner&.player? && entity != company.owner && !abilities(company, :no_buy)
        end
      end

      def buyable_bank_owned_companies
        @companies.select { |c| !c.closed? && c.owner == @bank }
      end

      def after_buy_company(player, company, _price)
        abilities(company, :shares) do |ability|
          ability.shares.each do |share|
            if share.president
              @round.companies_pending_par << company
            else
              share_pool.buy_shares(player, share, exchange: :free)
            end
          end
        end
      end

      def after_sell_company(_buyer, _company, _price, _seller); end

      def player_value(player)
        player.value
      end

      def liquidity(player, emergency: false)
        return player.cash unless sellable_turn?

        value = player.cash
        if emergency
          return liquidity(player) unless @round

          value += player.shares_by_corporation.sum do |corporation, shares|
            next 0 if shares.empty?

            value_for_sellable(player, corporation)
          end
        else
          player.shares_by_corporation.reject { |_, s| s.empty? }.each do |corporation, _|
            case self.class::SELL_AFTER
            when :operate
              next unless corporation.operated?
            when :p_any_operate
              next if !corporation.operated? && !corporation.president?(player)
            end

            value += value_for_dumpable(player, corporation)
          end
        end
        value
      end

      def check_sale_timing(entity, bundle)
        corporation = bundle.corporation

        case self.class::SELL_AFTER
        when :first
          @turn > 1 || @round.operating?
        when :after_ipo
          corporation.operated? || @round.operating?
        when :operate
          corporation.operated?
        when :p_any_operate
          corporation.operated? || corporation.president?(entity)
        when :round
          @round.stock? &&
            corporation.share_holders[entity] - @round.players_bought[entity][corporation] >= bundle.percent
        when :any_time
          true
        else
          raise NotImplementedError
        end
      end

      def value_for_sellable(player, corporation)
        max_bundle = sellable_bundles(player, corporation).max_by(&:price)
        max_bundle&.price || 0
      end

      def value_for_dumpable(player, corporation)
        return value_for_sellable(player, corporation) if self.class::PRESIDENT_SALES_TO_MARKET

        max_bundle = bundles_for_corporation(player, corporation)
          .select { |bundle| bundle.can_dump?(player) && @share_pool&.fit_in_bank?(bundle) }
          .max_by(&:price)
        max_bundle&.price || 0
      end

      def issuable_shares(_entity)
        []
      end

      def redeemable_shares(_entity)
        []
      end

      def sellable_bundles(player, corporation)
        return [] unless @round.active_step.respond_to?(:can_sell?)

        bundles = bundles_for_corporation(player, corporation)
        bundles.select { |bundle| @round.active_step.can_sell?(player, bundle) }
      end

      def bundles_for_corporation(share_holder, corporation, shares: nil)
        all_bundles_for_corporation(share_holder, corporation, shares: shares)
      end

      # Needed for 18MEX
      def all_bundles_for_corporation(share_holder, corporation, shares: nil)
        return [] unless corporation.ipoed

        shares = (shares || share_holder.shares_of(corporation)).sort_by { |h| [h.president ? 1 : 0, h.percent] }

        bundles = shares.flat_map.with_index do |share, index|
          bundle = shares.take(index + 1)
          percent = bundle.sum(&:percent)
          bundles = [Engine::ShareBundle.new(bundle, percent)]
          bundles.concat(partial_bundles_for_presidents_share(corporation, bundle, percent)) if share.president
          bundles
        end

        bundles.sort_by(&:percent)
      end

      def partial_bundles_for_presidents_share(corporation, bundle, percent)
        normal_percent = corporation.share_percent
        difference = corporation.presidents_percent - normal_percent
        num_partial_bundles = difference / normal_percent
        (1..num_partial_bundles).map do |n|
          Engine::ShareBundle.new(bundle, percent - (normal_percent * n))
        end
      end

      def can_buy_presidents_share_directly_from_market?
        false
      end

      def can_swap_for_presidents_share_directly_from_corporation?
        true
      end

      def shares_for_presidency_swap(shares, num_shares)
        shares.take(num_shares)
      end

      def num_certs(entity)
        certs = entity.shares.sum do |s|
          s.corporation.counts_for_limit && s.counts_for_limit ? s.cert_size : 0
        end
        certs + (self.class::CERT_LIMIT_INCLUDES_PRIVATES ? entity.companies.size : 0)
      end

      def sellable_turn?
        self.class::SELL_AFTER == :first ? (@turn > 1 || !@round.stock?) : true
      end

      def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
        corporation = bundle.corporation
        old_price = corporation.share_price
        was_president = corporation.president?(bundle.owner)
        @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
        case self.class::SELL_MOVEMENT
        when :down_share
          bundle.num_shares.times { @stock_market.move_down(corporation) }
        when :down_per_10
          percent = bundle.percent
          percent -= swap.percent if swap
          (percent / 10).to_i.times { @stock_market.move_down(corporation) }
        when :down_block
          @stock_market.move_down(corporation)
        when :left_share
          bundle.num_shares.times { @stock_market.move_left(corporation) }
        when :left_share_pres
          bundle.num_shares.times { @stock_market.move_left(corporation) } if was_president
        when :left_block
          @stock_market.move_left(corporation)
        when :down_block_pres
          stock_market.move_down(corporation) if was_president
        when :left_block_pres
          stock_market.move_left(corporation) if was_president
        when :left_per_10_if_pres_else_left_one
          spaces = if was_president
                     ((bundle.percent - (swap ? swap.percent : 0)) / 10).round(0)
                   else
                     1
                   end
          spaces.times { @stock_market.move_left(corporation) }
        when :none
          nil
        else
          raise NotImplementedError
        end
        log_share_price(corporation, old_price) if self.class::SELL_MOVEMENT != :none
      end

      def sold_out_increase?(_corporation)
        self.class::SOLD_OUT_INCREASE
      end

      def log_share_price(entity, from, steps = nil, log_steps: false)
        from_price = from.price
        to = entity.share_price
        to_price = to.price
        return unless from != to

        jumps = ''
        if steps
          steps = share_jumps(steps)
          jumps = " (#{steps} step#{steps == 1 ? '' : 's'})" if (steps > 1) || log_steps
        end

        r1, c1 = from.coordinates
        r2, c2 = to.coordinates
        dirs = []
        dirs << 'up' if r2 < r1
        dirs << 'down' if r2 > r1
        dirs << 'left' if c2 < c1
        dirs << 'right' if c2 > c1
        dir_str = dirs.join(' and ')

        @log << "#{entity.name}'s share price moves #{dir_str} from #{format_currency(from_price)} "\
                "to #{format_currency(to_price)}#{jumps}"
      end

      def share_jumps(steps)
        return steps unless @stock_market.zigzag

        if steps > 1
          steps / 2
        else
          steps
        end
      end

      def can_run_route?(entity)
        graph_for_entity(entity).route_info(entity)&.dig(:route_available)
      end

      def must_buy_train?(entity)
        entity.trains.empty? &&
          !depot.depot_trains.empty? &&
          (self.class::MUST_BUY_TRAIN == :always ||
           (self.class::MUST_BUY_TRAIN == :route && @graph.route_info(entity)&.dig(:route_train_purchase)))
      end

      def discard_discount(train, price)
        return price unless self.class::DISCARDED_TRAIN_DISCOUNT
        return price unless @depot.discarded.include?(train)

        (price * (100.0 - self.class::DISCARDED_TRAIN_DISCOUNT.to_f) / 100.0).ceil.to_i
      end

      def end_game!(player_initiated: false)
        return if @finished

        @finished = true
        @manually_ended = player_initiated
        store_player_info
        @round_counter += 1
        scores = result.map { |id, value| "#{@players.find { |p| p.id == id.to_i }&.name} (#{format_currency(value)})" }
        @log << "-- Game over: #{scores.join(', ')} --"
      end

      def revenue_for(route, stops)
        stops.sum { |stop| stop.route_revenue(route.phase, route.train) }
      end

      def revenue_str(route)
        route.hexes.map(&:name).join('-')
      end

      def float_str(entity)
        "#{entity.percent_to_float}% to float" if entity.corporation? && entity.floatable
      end

      def route_distance_str(route)
        route_distance(route).to_s
      end

      def route_distance(route)
        route.visited_stops.sum(&:visit_cost)
      end

      def routes_revenue(routes)
        routes.sum(&:revenue)
      end

      def compute_other_paths(routes, route)
        routes.reject { |r| r == route }.flat_map(&:paths)
      end

      def city_tokened_by?(city, entity)
        city.tokened_by?(entity)
      end

      def check_route_token(_route, token)
        raise NoToken, 'Route must contain token' unless token
      end

      def check_overlap(routes)
        tracks = {}

        check = lambda do |key|
          raise GameError, "Route cannot reuse track on #{key[0].id}" if tracks[key]

          tracks[key] = true
        end

        routes.each do |route|
          route.paths.each do |path|
            a = path.a
            b = path.b

            check.call([path.hex, a.num, path.lanes[0][1]]) if a.edge?
            check.call([path.hex, b.num, path.lanes[1][1]]) if b.edge?

            # check track between edges and towns not in center
            # (essentially, that town needs to act like an edge for this purpose)
            if b.edge? && a.town? && (nedge = a.tile.preferred_city_town_edges[a]) && nedge != b.num
              check.call([path.hex, a, path.lanes[0][1]])
            end
            if a.edge? && b.town? && (nedge = b.tile.preferred_city_town_edges[b]) && nedge != a.num
              check.call([path.hex, b, path.lanes[1][1]])
            end

            # check intra-tile paths between nodes
            check.call([path.hex, path]) if path.nodes.size > 1
          end
        end
      end

      def check_connected(route, corporation)
        return if route.ordered_paths.each_cons(2).all? { |a, b| a.connects_to?(b, corporation) }

        raise GameError, 'Route is not connected'
      end

      def check_distance(route, visits, train = nil)
        train ||= route.train
        distance = train.distance
        if distance.is_a?(Numeric)
          route_distance = visits.sum(&:visit_cost)
          raise RouteTooLong, "#{route_distance} is too many stops for #{distance} train" if distance < route_distance

          return
        end

        type_info = Hash.new { |h, k| h[k] = [] }

        distance.each do |h|
          pay = h['pay']
          visit = h['visit'] || pay
          info = { pay: pay, visit: visit }
          h['nodes'].each { |type| type_info[type] << info }
        end

        grouped = visits.group_by(&:type)

        grouped.sort_by { |t, _| type_info[t].size }.each do |type, group|
          num = group.sum(&:visit_cost)

          type_info[type].each do |info|
            next unless info[:visit].positive?

            if num <= info[:visit]
              info[:visit] -= num
              num = 0
            else
              num -= info[:visit]
              info[:visit] = 0
            end
            break unless num.positive?
          end

          raise RouteTooLong, 'Route has too many stops' if num.positive?
        end
      end

      def check_other(_route); end

      def compute_stops(route, train = nil)
        train ||= route.train
        visits = revenue_stops(route)
        distance = train.distance
        return visits if distance.is_a?(Numeric)
        return [] if visits.empty?

        # distance is an array of hashes defining how many locations of
        # each type can be hit. A 2+2 train (4 locations, at most 2 of
        # which can be cities) looks like this:
        #   [ { nodes: [ 'town' ],                     pay: 2},
        #     { nodes: [ 'city', 'town', 'offboard' ], pay: 2} ]
        # Stops use the first available slot, so for each stop in this case
        # we'll try to put it in a town slot if possible and then
        # in a city/town/offboard slot.
        distance = distance.sort_by { |types, _| types.size }

        max_num_stops = [distance.sum { |h| h['pay'] }, visits.size].min

        max_num_stops.downto(1) do |num_stops|
          # to_i to work around Opal bug
          stops, revenue = visits.combination(num_stops.to_i).map do |stops|
            # Make sure this set of stops is legal
            # 1) At least one stop must have a token (if enabled)
            next if train.requires_token && stops.none? { |stop| stop.tokened_by?(route.corporation) }

            # 2) We can't ask for more revenue centers of a type than are allowed
            types_used = Array.new(distance.size, 0) # how many slots of each row are filled

            next unless stops.all? do |stop|
              row = distance.index.with_index do |h, i|
                h['nodes'].include?(stop.type) && types_used[i] < h['pay']
              end

              types_used[row] += 1 if row
              row
            end

            [stops, revenue_for(route, stops)]
          end.compact.max_by(&:last)

          revenue ||= 0

          # We assume that no stop collection with m < n stops could be
          # better than a stop collection with n stops, so if we found
          # anything usable with this number of stops we return it
          # immediately.
          return stops if revenue.positive?
        end

        []
      end

      def visited_stops(route)
        route.connection_data.flat_map { |c| [c[:left], c[:right]] }.uniq.compact
      end

      def revenue_stops(route)
        visited_stops(route)
      end

      def get(type, id)
        return nil if !type || !id

        send("#{type}_by_id", id)
      end

      def all_companies_with_ability(ability_type)
        @companies.each do |company|
          Array(abilities(company, ability_type)).each do |ability|
            yield company, ability
          end
        end
      end

      def payout_companies(ignore: [])
        companies = @companies.select { |c| c.owner && c.revenue.positive? && !ignore.include?(c.id) }

        companies.sort_by! do |company|
          [
            company.owned_by_player? ? [0, @players.index(company.owner)] : [1, company.owner],
            company.revenue,
            company.name,
          ]
        end

        companies.each do |company|
          owner = company.owner
          next if owner == bank

          revenue = company.revenue
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

      def home_token_can_be_cheater
        false
      end

      def place_home_token(corporation)
        return unless corporation.next_token # 1882
        # If a corp has laid it's first token assume it's their home token
        return if corporation.tokens.first&.used

        hex = hex_by_id(corporation.coordinates)

        tile = hex&.tile
        if !tile || (tile.reserved_by?(corporation) && tile.paths.any?)

          if @round.pending_tokens.any? { |p| p[:entity] == corporation }
            # 1867: Avoid adding the same token twice
            @round.clear_cache!
            return
          end

          # If the tile does not have any paths at the present time, clear up the ambiguity when the tile is laid
          # otherwise the entity must choose now.
          hexes =
            if hex
              [hex]
            else
              home_token_locations(corporation)
            end

          return unless hexes

          @log << "#{corporation.name} must choose city for home token"
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

        if city.tokenable?(corporation, tokens: token)
          @log << "#{corporation.name} places a token on #{hex.name}"
          city.place_token(corporation, token)
        elsif home_token_can_be_cheater
          @log << "#{corporation.name} places a token on #{hex.name}"
          city.place_token(corporation, token, cheater: true)
        end
      end

      def graph_for_entity(_entity)
        @graph
      end

      def token_graph_for_entity(_entity)
        @graph
      end

      def clear_graph
        @graph.clear
      end

      def clear_graph_for_entity(entity)
        graph_for_entity(entity).clear
      end

      def clear_token_graph_for_entity(entity)
        token_graph_for_entity(entity).clear
      end

      def graph_skip_paths(_entity)
        nil
      end

      def upgrade_cost(tile, hex, entity, spender)
        entity = entity.owner if !entity.corporation? && entity.owner&.corporation?
        ability = entity.all_abilities.find do |a|
          a.type == :tile_discount &&
            (!a.hexes || a.hexes.include?(hex.name))
        end

        discount = ability&.discounts_tile?(tile) ? ability.discount : 0
        log_cost_discount(spender, ability, discount)

        tile.upgrades.sum(&:cost) - discount
      end

      def tile_cost_with_discount(_tile, hex, entity, spender, cost)
        entity = entity.owner if !entity.corporation? && entity.owner&.corporation?
        ability = entity.all_abilities.find do |a|
          a.type == :tile_discount &&
            !a.terrain &&
            (!a.hexes || a.hexes.include?(hex.name))
        end

        return cost unless ability

        discount = [cost, ability.discount].min
        log_cost_discount(spender, ability, discount)

        cost - discount
      end

      def log_cost_discount(spender, ability, discount)
        return unless discount.positive?

        @log << "#{spender.name} receives a discount of "\
                "#{format_currency(discount)} from "\
                "#{ability.owner.name}"
      end

      def declare_bankrupt(player)
        if player.bankrupt
          msg = "#{player.name} is already bankrupt, cannot declare bankruptcy again."
          raise GameError, msg
        end

        player.bankrupt = true
        return unless self.class::CERT_LIMIT_CHANGE_ON_BANKRUPTCY

        # Assume that games without cert limits at lower player counts retain previous counts (1817 and 2 players)
        @cert_limit = init_cert_limit
      end

      def tile_lays(_entity)
        # Some games change available lays depending on if minor or corp
        self.class::TILE_LAYS
      end

      def upgrades_to?(from, to, special = false, selected_company: nil)
        # correct color progression?
        return false unless upgrades_to_correct_color?(from, to, selected_company: selected_company)

        # honors pre-existing track?
        return false unless from.paths_are_subset_of?(to.paths)

        # If special ability then remaining checks is not applicable
        return true if special

        # correct label?
        return false unless upgrades_to_correct_label?(from, to)

        # correct number of cities and towns
        return false unless upgrades_to_correct_city_town?(from, to)

        true
      end

      def upgrade_ignore_num_cities(_from)
        false
      end

      def upgrades_to_correct_color?(from, to, selected_company: nil)
        Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)
      end

      def upgrades_to_correct_label?(from, to)
        # If the from tile has a future label and the to tile is the color for it use that, otherwise use the from's label
        return from.future_label.label == to.label&.to_s if from.future_label && to.color.to_s == from.future_label.color

        from.label == to.label
      end

      def upgrades_to_correct_city_town?(from, to)
        # honors existing town/city counts and connections?
        # - allow labelled cities to upgrade regardless of count; they're probably
        #   fine (e.g., 18Chesapeake's OO cities merge to one city in brown)
        # - TODO: account for games that allow double dits to upgrade to one town
        return false if from.towns.size != to.towns.size
        return false if !from.label && from.cities.size != to.cities.size && !upgrade_ignore_num_cities(from)
        return false if from.cities.size > 1 && to.cities.size > 1 && !from.city_town_edges_are_subset_of?(to.city_town_edges)

        # but don't permit a labelled city to be downgraded to 0 cities.
        return false if from.label && !from.cities.empty? && to.cities.empty?

        # handle case where we are laying a yellow OO tile and want to exclude single-city tiles
        return false if (from.color == :white) && from.label.to_s == 'OO' && from.cities.size != to.cities.size

        true
      end

      def legal_tile_rotation?(_entity, _hex, _tile)
        true
      end

      def can_par?(corporation, parrer)
        return false if corporation.par_via_exchange && corporation.par_via_exchange.owner != parrer
        return false if corporation.needs_token_to_par && corporation.tokens.empty?
        return false if corporation.all_abilities.find { |a| a.type == :unparrable }

        !corporation.ipoed
      end

      # Called by Engine::Step::BuyCompany to determine if the company's owner is even allowed to sell the company
      def company_sellable(company)
        !company.owner.is_a?(Corporation)
      end

      # Called by View::Game::Entities to determine if the company should be shown on entities
      def unowned_purchasable_companies(_entity)
        []
      end

      def multiple_buy_only_from_market?
        self.class::MULTIPLE_BUY_ONLY_FROM_MARKET
      end

      def float_corporation(corporation)
        @log << "#{corporation.name} floats"

        return if %i[incremental none].include?(corporation.capitalization)

        @bank.spend(corporation.par_price.price * corporation.total_shares, corporation)
        @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
      end

      def total_shares_to_float(corporation, _price)
        corporation.percent_to_float / corporation.share_percent
      end

      def close_corporation(corporation, quiet: false)
        @log << "#{corporation.name} closes" unless quiet

        hexes.each do |hex|
          hex.tile.cities.each do |city|
            city.tokens.select { |t| t&.corporation == corporation }.each(&:remove!)

            if self.class::CLOSED_CORP_RESERVATIONS_REMOVED && city.reserved_by?(corporation)
              city.reservations.delete(corporation)
            end
          end
          if self.class::CLOSED_CORP_RESERVATIONS_REMOVED && hex.tile.reserved_by?(corporation)
            hex.tile.reservations.delete(corporation)
          end
        end

        corporation.spend(corporation.cash, @bank) if corporation.cash.positive?
        if self.class::CLOSED_CORP_TRAINS_REMOVED
          corporation.trains.each { |t| t.buyable = false }
        else
          corporation.trains.dup.each { |t| depot.reclaim_train(t) }
        end
        if corporation.companies.any?
          @log << "#{corporation.name}'s companies close: #{corporation.companies.map(&:sym).join(', ')}"
          corporation.companies.dup.each(&:close!)
        end
        @round.force_next_entity! if @round.current_entity == corporation

        if corporation.corporation?
          corporation.share_holders.keys.each do |share_holder|
            share_holder.shares_by_corporation.delete(corporation)
          end

          @share_pool.shares_by_corporation.delete(corporation)
          corporation.share_price&.corporations&.delete(corporation)
          @corporations.delete(corporation)
        else
          @minors.delete(corporation)
        end

        corporation.close!
        @cert_limit = init_cert_limit
      end

      def shares_for_corporation(corporation)
        @_shares.values.select { |share| share.corporation == corporation }
      end

      def reset_corporation(corporation)
        @_shares.reject! do |_, share|
          next if share.corporation != corporation

          share.owner.shares_by_corporation[corporation].clear

          true
        end

        corporation.companies.dup.each(&:close!)

        corporation.share_price&.corporations&.delete(corporation)
        corporation = init_corporations(@stock_market).find { |c| c.id == corporation.id }

        @corporations.map! { |c| c.id == corporation.id ? corporation : c }
        @_corporations[corporation.id] = corporation
        corporation.shares.each { |share| @_shares[share.id] = share }
        corporation
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
        buying_power = liquidity(player, emergency: true)
        buying_power += corporation.cash + emergency_issuable_cash(corporation) if corporation
        buying_power
      end

      def buying_power(entity, **)
        entity.cash
      end

      def company_sale_price(_company)
        raise NotImplementedError
      end

      def two_player?
        @two_player ||= @players.size == 2
      end

      def add_extra_tile(tile)
        raise GameError, 'Add extra tile only works if unlimited' unless tile.unlimited

        # Find the highest tile that exists of this type in the tile list and duplicate it.
        # The highest one in the list should be the highest index anywhere.
        tiles = @_tiles.values.select { |t| t.name == tile.name }
        new_tile = tiles.max_by(&:index).dup
        @tiles << new_tile

        @_tiles[new_tile.id] = new_tile
        extra_cities = new_tile.cities
        @cities.concat(extra_cities)
        extra_cities.each { |c| @_cities[c.id] = c }

        new_tile
      end

      def find_share_price(price)
        # NOTE: this only works on a 2d stock market
        @stock_market
          .market[0]
          .reverse
          .find { |sp| sp.price <= price }
      end

      def after_par(corporation)
        if corporation.capitalization == :incremental
          all_companies_with_ability(:shares) do |company, ability|
            next unless corporation.name == ability.shares.first.corporation.name

            amount = ability.shares.sum { |share| corporation.par_price.price * share.num_shares }
            @bank.spend(amount, corporation)
            @log << "#{corporation.name} receives #{format_currency(amount)}
                   from #{company.name}"
          end
        end

        close_companies_on_event!(corporation, 'par')
        place_home_token(corporation) if self.class::HOME_TOKEN_TIMING == :par
      end

      def close_companies_on_event!(entity, event)
        @companies.each do |company|
          next if company.closed?

          abilities(company, :close, time: event) do |ability|
            next if entity&.name != ability.corporation

            company.close!
            @log << "#{company.name} closes"
          end
        end
      end

      def train_help(_entity, _runnable_trains, _routes)
        []
      end

      def queue_log!
        old_size = @log.size
        yield
        @queued_log = @log.pop(@log.size - old_size)
      end

      def flush_log!
        @queued_log.each { |l| @log << l }
        @queued_log = []
      end

      # This is a hook to allow game specific logic to be invoked after a company is bought
      def company_bought(company, buyer); end

      def ipo_name(_entity = nil)
        'IPO'
      end

      def ipo_verb(_entity = nil)
        'pars'
      end

      def ipo_reserved_name(_entity = nil)
        'IPO Reserved'
      end

      def share_flags(_shares)
        nil
      end

      def corporation_show_loans?(_corporation)
        true
      end

      def corporation_show_shares?(corporation)
        !corporation.minor?
      end

      def corporation_show_individual_reserved_shares?(_corporation)
        true
      end

      def abilities(entity, type = nil, time: nil, on_phase: nil, passive_ok: nil, strict_time: nil)
        return nil unless entity

        active_abilities = entity.all_abilities.select do |ability|
          ability_right_type?(ability, type) &&
            ability_right_owner?(ability.owner, ability) &&
            ability_usable_this_or?(ability) &&
            ability_right_time?(ability,
                                time,
                                on_phase,
                                passive_ok.nil? ? true : passive_ok,
                                strict_time.nil? ? true : strict_time) &&
            ability_usable?(ability)
        end

        active_abilities.each { |a| yield a, a.owner } if block_given?

        return nil if active_abilities.empty?
        return active_abilities.first if active_abilities.one?

        active_abilities
      end

      def entity_can_use_company?(_entity, _company)
        true
      end

      # price is nil, :free, or a positive int
      def buy_train(operator, train, price = nil)
        operator.spend(price || train.price, train.owner) if price != :free
        remove_train(train)
        train.owner = operator
        operator.trains << train
        @crowded_corps = nil

        close_companies_on_event!(operator, 'bought_train')
      end

      def discountable_trains_for(corporation)
        discountable_trains = @depot.depot_trains.select { |train| train.discount || train.variants.any? { |_, v| v[:discount] } }

        corporation.trains.flat_map do |train|
          discountable_trains.flat_map do |discount_train|
            discount_info = []
            discounted_price = discount_train.price(train)
            name = discount_train.name
            discount_info = [[train, discount_train, name, discounted_price]] if discount_train.price > discounted_price

            # Add variants if any - they have same discount as base version
            discount_train.variants.each do |_, v|
              next if v[:name] == name

              discounted_price = discount_train.price(train, variant: v)
              discount_info << [train, discount_train, v[:name], discounted_price] if v[:price] > discounted_price
            end

            discount_info
          end.compact
        end
      end

      def remove_train(train)
        return unless (owner = train.owner)
        return @depot.remove_train(train) if train.from_depot?

        owner.trains.delete(train)
        @crowded_corps = nil
      end

      def rust(train)
        train.rusted = true
        remove_train(train)
        train.owner = nil
      end

      def num_corp_trains(entity)
        self.class::OBSOLETE_TRAINS_COUNT_FOR_LIMIT ? entity.trains.size : entity.trains.count { |t| !t.obsolete }
      end

      def crowded_corps
        @crowded_corps ||= (minors + corporations).select do |c|
          num_corp_trains(c) > train_limit(c)
        end
      end

      def transfer(ownable_type, from, to)
        ownables = from.send(ownable_type)
        to_ownables = to.send(ownable_type)

        @crowded_corps = nil if ownable_type == :trains

        ownables.each do |ownable|
          ownable.owner = to
          to_ownables << ownable
        end

        transferred = ownables.dup
        ownables.clear
        transferred
      end

      def exchange_for_partial_presidency?
        false
      end

      def exchange_partial_percent(_share)
        nil
      end

      def exchange_corporations(exchange_ability)
        candidates = case exchange_ability.corporations
                     when 'any'
                       corporations
                     when 'ipoed'
                       corporations.select(&:ipoed)
                     else
                       exchange_ability.corporations.map { |c| corporation_by_id(c) }
                     end
        candidates.reject(&:closed?)
      end

      def round_start?
        @last_game_action_id == @round_history.last
      end

      def can_hold_above_corp_limit?(_entity)
        false
      end

      def show_game_cert_limit?
        true
      end

      def cannot_pay_interest_str
        nil
      end

      def hex_blocked_by_ability?(_entity, ability, hex)
        ability.hexes.include?(hex.id)
      end

      def rust_trains!(train, _entity)
        obsolete_trains = []
        rusted_trains = []
        owners = Hash.new(0)

        trains.each do |t|
          next if t.obsolete || !obsolete?(t, train)

          obsolete_trains << t.name
          t.obsolete = true
        end

        trains.each do |t|
          next if t.rusted
          next unless rust?(t, train)

          rusted_trains << t.name
          owners[t.owner.name] += 1
          rust(t)
        end

        @crowded_corps = nil

        @log << "-- Event: #{obsolete_trains.uniq.join(', ')} trains are obsolete --" if obsolete_trains.any?

        return unless rusted_trains.any?

        @log << "-- Event: #{rusted_trains.uniq.join(', ')} trains rust " \
                "( #{owners.map { |c, t| "#{c} x#{t}" }.join(', ')}) --"
      end

      def show_progress_bar?
        false
      end

      def progress_information; end

      def assignment_tokens(assignment, simple_logos = false)
        if assignment.is_a?(Engine::Corporation)
          return assignment.simple_logo if simple_logos && assignment.simple_logo

          return assignment.logo
        end

        self.class::ASSIGNMENT_TOKENS[assignment]
      end

      def bankruptcy_limit_reached?
        case self.class::BANKRUPTCY_ENDS_GAME_AFTER
        when :one
          @players.any?(&:bankrupt)
        when :all_but_one
          @players.count { |p| !p.bankrupt } == 1
        end
      end

      def update_tile_lists(tile, old_tile)
        add_extra_tile(tile) if tile.unlimited
        @tiles.delete(tile)
        @tiles << old_tile unless old_tile.preprinted
      end

      def local_length
        2
      end

      def skip_route_track_type; end

      def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
        phase_color_cache ||= @phase.tiles
        phase_color_cache.include?(tile.color)
      end

      def token_owner(entity)
        entity&.company? ? entity.owner : entity
      end

      def company_header(_company)
        'PRIVATE COMPANY'
      end

      def market_share_limit(_corporation = nil)
        self.class::MARKET_SHARE_LIMIT
      end

      def cert_limit(_player = nil)
        @cert_limit
      end

      def corporation_show_interest?
        true
      end

      def after_buying_train(train, source); end

      private

      def init_graph
        Graph.new(self)
      end

      def init_bank
        cash = self.class::BANK_CASH
        cash = cash[players.size] if cash.is_a?(Hash)

        Bank.new(cash, log: @log)
      end

      def init_cert_limit
        cert_limit = game_cert_limit
        if cert_limit.is_a?(Hash)
          player_count = (self.class::CERT_LIMIT_COUNTS_BANKRUPTED ? players : players.reject(&:bankrupt)).size
          cert_limit = cert_limit[player_count]
        end
        if cert_limit.is_a?(Hash)
          cert_limit = cert_limit.reject { |k, _| k.to_i < @corporations.size }
                         .min_by(&:first)&.last || cert_limit.first.last
        end
        cert_limit || @cert_limit
      end

      def game_cert_limit
        self.class::CERT_LIMIT
      end

      def init_phase
        Phase.new(game_phases, self)
      end

      def game_phases
        self.class::PHASES
      end

      def init_round
        new_auction_round
      end

      def init_stock_market
        StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                        multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
      end

      def game_market
        self.class::MARKET
      end

      def init_companies(players)
        game_companies.map do |company|
          next if players.size < (company[:min_players] || 0)

          self.class::COMPANY_CLASS.new(**company)
        end.compact
      end

      def game_companies
        self.class::COMPANIES
      end

      def init_train_handler
        trains = game_trains.flat_map do |train|
          Array.new((train[:num] || num_trains(train))) do |index|
            self.class::TRAIN_CLASS.new(**train, index: index)
          end
        end

        self.class::DEPOT_CLASS.new(trains, self)
      end

      def game_trains
        self.class::TRAINS
      end

      def num_trains(_train)
        raise NotImplementedError
      end

      def init_minors
        game_minors.map { |minor| Minor.new(**minor) }
      end

      def game_minors
        self.class::MINORS
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

      def loan_value(_entity = nil)
        0
      end

      def num_emergency_loans(_entity, _debt)
        0
      end

      def corporation_opts
        {}
      end

      def init_corporations(stock_market)
        game_corporations.map do |corporation|
          self.class::CORPORATION_CLASS.new(
            min_price: stock_market.par_prices.map(&:price).min,
            capitalization: self.class::CAPITALIZATION,
            **corporation.merge(corporation_opts),
          )
        end
      end

      def game_corporations
        self.class::CORPORATIONS
      end

      def init_hexes(companies, corporations)
        blockers = {}
        (companies + minors + corporations).each do |company|
          abilities(company, :blocks_hexes) do |ability|
            ability.hexes.each do |hex|
              blockers[hex] = company
            end
          end
          abilities(company, :blocks_hexes_consent) do |ability|
            ability.hexes.each do |hex|
              blockers[hex] = company
            end
          end
        end

        partition_blockers = {}
        partition_companies.each do |company|
          abilities(company, :blocks_partition) do |ability|
            partition_blockers[ability.partition_type] = company
          end
        end

        reservations = Hash.new { |k, v| k[v] = [] }
        reservation_corporations.each do |c|
          Array(c.coordinates).each_with_index do |coord, idx|
            reservations[coord] << {
              entity: c,
              city: c.city.is_a?(Array) ? c.city[idx] : c.city,
            }
          end
        end

        (corporations + companies).each do |c|
          abilities(c, :reservation) do |ability|
            reservations[ability.hex] << {
              entity: c,
              city: ability.city.to_i,
              slot: ability.slot.to_i,
              ability: ability,
            }
          end
        end

        optional_hexes.map do |color, hexes|
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

              tile.partitions.each do |partition|
                if (blocker = partition_blockers[partition.type])
                  partition.add_blocker!(blocker)
                end
              end

              reservations[coord].each do |res|
                res[:ability].tile = tile if res[:ability]
                tile.add_reservation!(res[:entity], res[:city], res[:slot])
              end

              # name the location (city/town)
              location_name = location_name(coord)

              Hex.new(coord, layout: layout, axes: axes, tile: tile, location_name: location_name)
            end
          end
        end.flatten.compact
      end

      def partition_companies
        companies
      end

      def reservation_corporations
        corporations
      end

      def init_tiles
        game_tiles.flat_map { |name, val| init_tile(name, val) }
      end

      def game_tiles
        self.class::TILES
      end

      def init_tile(name, val)
        if val.is_a?(Integer) || val == 'unlimited'
          count = val == 'unlimited' ? 1 : val
          Array.new(count) do |i|
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
          hidden = !!val['hidden']
          Array.new(count) do |i|
            Tile.from_code(
              name,
              color,
              code,
              index: i,
              reservation_blocks: self.class::TILE_RESERVATION_BLOCKS_OTHERS,
              unlimited: val['count'] == 'unlimited',
              hidden: hidden
            )
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
          next unless (ability = abilities(company, :shares))

          real_shares = []
          ability.shares.each do |share|
            case share
            when 'random_president', 'first_president'
              idx = share == 'first_president' ? 0 : rand % @corporations.size
              corporation = @corporations[idx]
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
        SharePool.new(self, allow_president_sale: self.class::PRESIDENT_SALES_TO_MARKET)
      end

      def connect_hexes
        coordinates = @hexes.to_h { |h| [[h.x, h.y], h] }

        @hexes.each do |hex|
          Hex::DIRECTIONS[hex.layout].each do |xy, direction|
            x, y = xy
            neighbor = coordinates[[hex.x + x, hex.y + y]]
            next unless neighbor

            hex.all_neighbors[direction] = neighbor
            next if self.class::IMPASSABLE_HEX_COLORS.include?(neighbor.tile.color) && !neighbor.targeting?(hex)
            next if hex.tile.borders.any? { |border| border.edge == direction && border.type == :impassable }

            hex.neighbors[direction] = neighbor
          end
        end
      end

      def total_rounds(name)
        # Return the total number of rounds for those with more than one.
        @operating_rounds if name == self.class::OPERATING_ROUND_NAME
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

      def clear_programmed_actions
        @programmed_actions.clear
      end

      def check_programmed_actions
        @programmed_actions.each do |entity, action_list|
          action_list.reject! do |action|
            if action&.disable?(self)
              player_log(entity, "Programmed action '#{action}' removed due to round change")
              true
            end
          end
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
          final_phase: @phase&.phases&.last == @phase&.current,
          custom: custom_end_game_reached?,
        }.select { |_, t| t }

        %i[immediate current_round current_or full_or one_more_full_or_set].each do |after|
          triggers.keys.each do |reason|
            if game_end_check_values[reason] == after
              @final_turn ||= @turn + 1 if after == :one_more_full_or_set
              return [reason, after]
            end
          end
        end

        nil
      end

      def final_or_in_set?(round)
        round.round_num == @operating_rounds
      end

      def end_now?(after)
        return false unless after
        return true if after == :immediate
        return true if after == :current_round
        return false unless @round.is_a?(round_end)
        return true if after == :current_or

        final_or_in_set = final_or_in_set?(@round)

        return (@turn == @final_turn) if final_or_in_set && (after == :one_more_full_or_set)

        final_or_in_set
      end

      def round_end
        Round::Operating
      end

      def final_operating_rounds
        @phase.operating_rounds
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
                         if @round.is_a?(Round::Operating)
                           " : Game Ends at conclusion of #{round_end.short_name} #{turn}.#{operating_rounds}"
                         else
                           " : Game Ends at conclusion of #{round_end.short_name} #{turn}.#{@phase.operating_rounds}"
                         end
                       when :one_more_full_or_set
                         " : Game Ends at conclusion of #{round_end.short_name}"\
                         " #{@final_turn}.#{final_operating_rounds}"
                       end
          after_text += additional_ending_after_text
        end

        "#{self.class::GAME_END_DESCRIPTION_REASON_MAP_TEXT[reason]}#{after_text}"
      end

      def additional_ending_after_text
        ''
      end

      def action_processed(_action)
        return unless stock_market.has_close_cell

        @corporations.dup.each { |c| close_corporation(c) if c.share_price&.type == :close }
      end

      def show_priority_deal_player?(order)
        order == :after_last_to_act
      end

      def priority_deal_player
        players = @players.reject(&:bankrupt)

        if @round.current_entity&.player?
          # We're in a round that iterates over players, so the
          # priority deal card goes to the player who will go first if
          # everyone passes starting now.  last_to_act is nil before
          # anyone has gone, in which case the first player has PD.
          last_to_act = @round.last_to_act
          priority_idx = last_to_act ? (players.index(last_to_act) + 1) % players.size : 0
          players[priority_idx]
        else
          # We're in a round that iterates over something else, like
          # corporations.  The player list was already rotated when we
          # left a player-focused round to put the PD player first.
          players.first
        end
      end

      def next_sr_position(entity)
        player_order = if @round.current_entity&.player?
                         next_sr_player_order == :first_to_pass ? @round.pass_order : []
                       else
                         @players
                       end
        player_order.reject(&:bankrupt).index(entity)
      end

      def next_sr_player_order
        self.class::NEXT_SR_PLAYER_ORDER
      end

      def reorder_players(order = nil, log_player_order: false)
        order ||= next_sr_player_order
        case order
        when :after_last_to_act
          player = @players.reject(&:bankrupt)[@round.entity_index]
          @players.rotate!(@players.index(player))
        when :first_to_pass
          @players = @round.pass_order unless @round.pass_order.empty?
        when :most_cash
          current_order = @players.dup.reverse
          @players.sort_by! { |p| [p.cash, current_order.index(p)] }.reverse!
        when :least_cash
          current_order = @players.dup
          @players.sort_by! { |p| [p.cash, current_order.index(p)] }
        end
        @log << if log_player_order
                  "Priority order: #{@players.reject(&:bankrupt).map(&:name).join(', ')}"
                else
                  "#{@players.first.name} has priority deal"
                end
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::CompanyPendingPar,
          Step::WaterfallAuction,
        ])
      end

      def new_stock_round
        @log << "-- #{round_description('Stock')} --"
        @round_counter += 1
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
        @log << "-- #{round_description(self.class::OPERATING_ROUND_NAME, round_num)} --"
        @round_counter += 1
        operating_round(round_num)
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::DiscardTrain,
          Step::BuyTrain,
          [Step::BuyCompany, { blocks: true }],
        ], round_num: round_num)
      end

      def event_close_companies!
        @log << '-- Event: Private companies close --'
        @companies.each do |company|
          if (ability = abilities(company, :close, on_phase: 'any')) && (ability.on_phase == 'never' ||
                    @phase.phases.any? { |phase| ability.on_phase == phase[:name] })
            next
          end

          company.close!
        end
      end

      def cache_objects
        CACHABLE.each do |type, name|
          ivar = "@_#{type}"
          instance_variable_set(ivar, send(type).to_h { |x| [x.id, x] })

          self.class.define_method("#{name}_by_id") do |id|
            instance_variable_get(ivar)[id]
          end
        end
      end

      def update_cache(type)
        return unless CACHABLE.any? { |t, _n| t == type }

        ivar = "@_#{type}"
        instance_variable_set(ivar, send(type).to_h { |x| [x.id, x] })
      end

      def bank_cash
        @bank.cash
      end

      def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
        colors = Array(@phase.phases.last[:tiles])
        @all_tiles
          .select { |t| tile_valid_for_phase?(t, phase_color_cache: colors) }
          .uniq(&:name)
          .select { |t| upgrades_to?(tile, t, selected_company: selected_company) }
          .reject(&:blocks_lay)
      end

      def interest_paid?(_entity)
        true
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

      def corporation_size(_entity)
        # For display purposes is a corporation small, medium or large
        :small
      end

      def corporation_size_name(_entity); end

      def company_status_str(_company); end

      def status_str(_corporation); end

      def status_array(_corporation); end

      def par_price_str(share_price)
        format_currency(share_price.price)
      end

      # Override this, and add elements (paragraphs of text) here to display it on Info page.
      def timeline
        []
      end

      def count_available_tokens(corporation)
        corporation.tokens.sum { |t| t.used ? 0 : 1 }
      end

      def token_string(corporation)
        "#{count_available_tokens(corporation)}/#{corporation.tokens.size}"
      end

      def highlight_token?(_token)
        false
      end

      def show_value_of_companies?(entity)
        entity&.player?
      end

      def company_table_header
        'Company'
      end

      # minors to show on player cards
      def player_card_minors(_player)
        []
      end

      def player_entities
        @players
      end

      def player_sort(entities)
        entities.sort_by { |entity| [operating_order.index(entity) || Float::INFINITY, entity.name] }.group_by(&:owner)
      end

      def bank_sort(corporations)
        corporations.sort_by(&:name)
      end

      def info_train_name(train)
        train.names_to_prices.keys.join(', ')
      end

      def info_available_train(first_train, train)
        train.sym == first_train&.sym
      end

      def info_train_price(train)
        train.names_to_prices.values.map { |p| format_currency(p) }.join(', ')
      end

      def info_on_trains(phase)
        Array(phase[:on]).first
      end

      def ability_right_type?(ability, type)
        !type || (ability.type == type)
      end

      def ability_right_owner?(entity, ability)
        correct_owner_type =
          case ability.owner_type
          when :player
            !entity.owner || entity.owner.player?
          when :corporation
            entity.owner&.corporation?
          when nil
            true
          end

        !!correct_owner_type
      end

      def ability_usable_this_or?(ability)
        !ability.count_per_or || (ability.count_this_or < ability.count_per_or)
      end

      def ability_right_time?(ability, time, on_phase, passive_ok, strict_time)
        return true unless @round
        return true if time == 'any' || ability.when?('any')
        return (on_phase == ability.on_phase) || (on_phase == 'any') if ability.on_phase
        return false if ability.passive && !passive_ok
        return true if ability.passive && ability.when.empty?

        # using active_step causes an infinite loop
        current_step = ability_blocking_step
        current_step_name = current_step&.type

        if ability.type == :tile_lay && ability.must_lay_all && current_step.is_a?(Step::SpecialTrack)
          return current_step.company == ability.owner
        end

        times = Array(time).map { |t| t == '%current_step%' ? current_step_name : t.to_s }
        if times.empty?
          times_to_check = ability.when
          default = false
        else
          times_to_check = ability.when & times
          default = true
          return true if !times_to_check.empty? && !strict_time
        end
        times_to_check.any? do |ability_when|
          case ability_when
          when current_step_name
            (@round.operating? && @round.current_operator == ability.corporation) ||
              (@round.stock? && @round.current_entity == ability.player)
          when 'owning_corp_or_turn'
            @round.operating? && @round.current_operator == ability.corporation
          when 'owning_player_or_turn'
            @round.operating? && @round.current_operator.player == ability.player
          when 'owning_player_track'
            @round.operating? && @round.current_operator.player == ability.player && current_step.is_a?(Step::Track)
          when 'owning_player_sr_turn'
            @round.stock? && @round.current_entity == ability.player
          when 'or_between_turns'
            @round.operating? && !@round.current_operator_acted
          when 'or_start'
            ability_time_is_or_start?
          else
            default
          end
        end
      end

      def ability_time_is_or_start?
        @round.operating? && @round.at_start
      end

      def ability_blocking_step
        supported_steps = [Step::Tracker, Step::Token, Step::BuyTrain]
        @round.steps.find do |step|
          # Currently, abilities only care about Tracker, Token and BuyTrain steps
          # The is_a? check can be expanded to include more classes/modules when needed
          supported_steps.any? { |s| step.is_a?(s) } && !step.passed? && step.active? && step.blocks?
        end
      end

      def ability_usable?(ability)
        case ability
        when Ability::Token
          return true if ability.hexes.none?

          corporation =
            if ability.owner.is_a?(Corporation)
              ability.owner
            elsif ability.owner.owner.is_a?(Corporation)
              ability.owner.owner
            end
          return true unless corporation

          return false unless token_ability_from_owner_usable?(ability, corporation)

          tokened_hexes = []

          corporation.tokens.each do |token|
            tokened_hexes << token.city.hex.id if token.used
          end

          !(ability.hexes - tokened_hexes).empty?
        else
          true
        end
      end

      def token_ability_from_owner_usable?(ability, corporation)
        ability.from_owner ? corporation.find_token_by_type : true
      end

      def separate_treasury?
        false
      end

      def decorate_marker(_icon)
        nil
      end

      def adjustable_train_list?(_entity)
        false
      end

      def adjustable_train_sizes?(_entity)
        false
      end

      def reset_adjustable_trains!(_entity, _routes); end

      def operation_round_short_name
        self.class::OPERATION_ROUND_SHORT_NAME
      end

      def operation_round_name
        self.class::OPERATING_ROUND_NAME
      end

      def trains_str(corporation)
        (corporation.system? ? corporation.shells : [corporation]).map do |c|
          if c.trains.empty?
            'None'
          else
            c.trains.map { |t| t.obsolete ? "(#{t.name})" : t.name }.join(' ')
          end
        end
      end

      def on_train_header
        'On Train'
      end

      def train_limit_header
        'Train Limit'
      end

      def train_power?
        false
      end

      def show_map_legend?
        false
      end

      def train_purchase_name(train)
        train.name
      end

      # If a game overrides this to true, then if the possible actions for the current entity include any of
      #   buy_train, scrap_train, or reassign_train then
      # the Operating view will be used instead of the Merger round view for train actiosn in a merger round.
      # See https://github.com/tobymao/18xx/issues/7169
      def train_actions_always_use_operating_round_view?
        false
      end

      def nav_bar_color
        @phase.current[:tiles].last
      end

      def round_phase_string
        "Phase #{@phase.name}"
      end

      def phase_valid?
        true
      end

      def market_par_bars(_price)
        []
      end

      def show_player_percent?(_player)
        true
      end

      def companies_sort(companies)
        companies
      end

      def stock_round_name
        'Stock Round'
      end

      def force_unconditional_stock_pass?
        false
      end

      def second_icon(corporation); end
    end
  end
end
