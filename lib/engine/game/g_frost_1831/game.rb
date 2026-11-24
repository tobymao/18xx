# frozen_string_literal: true

require_relative 'meta'
require_relative 'parliament_movement'
require_relative 'map'
require_relative 'entities'
require_relative 'faction'
require_relative 'tiles'
require_relative 'stock_market'
require_relative 'round/stock'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/choose_factions'
require_relative 'step/choose_influence'
require_relative 'step/track'
require_relative 'step/home_token'
require_relative 'step/token'
require_relative 'step/exchange'
require_relative 'step/buy_cert'
require_relative 'step/dividend'
require_relative 'step/special_track'
require_relative '../base'

module Engine
  module Game
    module GFrost1831
      class Game < Game::Base
        include_meta(GFrost1831::Meta)
        include Entities
        include Map
        include Tiles

        CURRENCY_FORMAT_STR = '£%s'

        BANK_CASH = 9000

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        SELL_BUY_ORDER = :sell_buy

        EBUY_CAN_SELL_SHARES = false

        CONVOY = 'PCO'

        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: :not_if_upgraded, upgrade: false },
        ].freeze

        GAME_END_CHECK = { bank: :full_or, custom: :one_more_full_or_set }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'First D train is purchased'
        )

        GAME_END_REASONS_TIMING_TEXT = Base::GAME_END_REASONS_TIMING_TEXT.merge(
          one_more_full_or_set: 'Finish current OR, then 1 more full set (SR + Voting + ORs)'
        )

        EBUY_OWNER_MUST_HELP = false

        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = false

        # Rusted/discarded trains are removed from the game, not sent to bank pool
        DISCARDED_TRAINS = :remove

        CERT_LIMIT = {
          2 => { 8 => 31, 7 => 27, 6 => 25, 5 => 22 },
          3 => { 8 => 25, 7 => 22, 6 => 20, 5 => 18 },
          4 => { 8 => 22, 7 => 20, 6 => 18, 5 => 16 },
          5 => { 8 => 19, 7 => 17, 6 => 15, 5 => 14 },
        }.freeze

        MARKET = [
          %w[0B,arrow:none 70B,arrow:down 80B,arrow:down 90B,arrow:down 100B,arrow:down 110B,arrow:down
             120B,arrow:down 140B,arrow:down 160B,arrow:down 190B,arrow:down 220B,arrow:down 250B,arrow:down
             300B,arrow:down],
          %w[0c,arrow:none 70y 80 90 100p 110 120 140 160 190 220 250 300W 300B,arrow:left],
          %w[0c,arrow:none 60y 70 80 90p 100 110 130 150 180 210 240W],
          %w[0c,arrow:none 50y 60 70 80p 90 100 120 140 170 200W],
          %w[0c,arrow:none 40y 50 60 70p 80 90 110 130 160W],
          %w[0c,arrow:none 30y 40 50 60p 70 80 100 120W],
          %w[0c,arrow:none 20y 30 40 50 60 70 80W],
          %w[0c,arrow:none 10y 20 30 40 50 60W],
          %w[0c,arrow:none 0c,arrow:none],
          %w[70r 80r 100r 120r 140r 160r 190r 220r 250r,arrow:none],
        ].freeze

        FACTION_ROW = 9

        FACTION_START_PRICE = 70

        FACTION_RESERVED_CITIES = %w[F3 G8 K14 M8].freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          close: :orange,
          pays_bonus: :purple,
          pays_bonus_1: :blue,
          repar: :gray,
        ).freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par: 'Initial Offering (£60–£100)',
          close: 'Intervention Zone — apply consequences',
          pays_bonus: 'Influence Zone — grants Influence',
          pays_bonus_1: 'Influence — first to reach',
          no_cert_limit: 'Shares do not count towards cert limit, may hold >60%',
          repar: 'Faction Values in Parliament',
        ).freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
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
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 8,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 5,
            events: [{ 'type' => 'parliament_opens' }],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 4,
            events: [{ 'type' => 'turmoil' }],
          },
          {
            name: '5',
            distance: 5,
            price: 530,
            num: 3,
            events: [{ 'type' => 'blizzard' }, { 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 2,
            events: [{ 'type' => 'turmoil' }],
          },
          {
            name: 'D',
            distance: 999,
            price: 1100,
            num: 'unlimited',
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300, '4◆' => 300, '5◆' => 300, '6◆' => 300 },
            events: [{ 'type' => 'turmoil' }],
          },
        ].freeze

        TRAIN_NAMES = {
          '2' => 'Hope',
          '3' => 'Long John',
          '4' => 'Ice Breaker',
          '5' => 'The Queen',
          '6' => 'Nightmare',
          'D' => 'Silver Bullet',
          '2◆' => 'Hope ◆',
          '3◆' => 'Long John ◆',
          '4◆' => 'Ice Breaker ◆',
          '5◆' => 'The Queen ◆',
          '6◆' => 'Nightmare ◆',
          'D◆' => 'Silver Bullet ◆',
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'parliament_opens' => ['Parliament Opens', 'Factions become available in the next Stock Round'],
          'turmoil' => ['Turmoil', 'Political turmoil — consequences depend on Parliament state'],
          'blizzard' => ['Blizzard', 'Yellow tiles on marked hexes are removed; isolated stations are eliminated'],
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'parliament_opens' => ['Parliament Opens', 'Factions are available for purchase'],
          'turmoil' => ['Turmoil', 'Political turmoil triggered'],
          'blizzard' => ['Blizzard', 'Blizzard event active — marked yellow tiles removed'],
        ).freeze

        FACTION_NAMES = {
          'TEC' => 'Technicians',
          'GUA' => 'Guardians',
          'EXP' => 'Expansionists',
          'LOR' => 'Lords',
        }.freeze

        FACTION_ORDER = %w[TEC LOR GUA EXP].freeze

        OPPOSITES = {
          'TEC' => 'GUA',
          'GUA' => 'TEC',
          'EXP' => 'LOR',
          'LOR' => 'EXP',
        }.freeze

        GOVERNMENT_START = [3, 4].freeze

        GOVERNMENT_NEUTRAL_LINES = [3, 4].freeze

        GOVERNMENT_QUADRANTS = {
          [true, true] => 'TEC',
          [true, false] => 'LOR',
          [false, true] => 'EXP',
          [false, false] => 'GUA',
        }.freeze

        GOVERNMENT_MIDDLE = 4

        SECOND_SUPPORT_SET_FLOAT = 4

        CORPORATION_INFLUENCE_LIMITS = { '2' => 3, '3' => 4, '4' => 4, '5' => 5, '6' => 5, 'D' => 5 }.freeze

        FACTION_INFLUENCE_LIMITS = { '2' => 6, '3' => 6, '4' => 6, '5' => 8, '6' => 8, 'D' => 10 }.freeze

        TURMOIL_INFLUENCE_LEVEL = 2

        REGULATIONS = {
          'R1' => 'Track Laying',
          'R2' => 'Track Upgrade',
          'R3' => 'Corporation Limit',
          'R4' => 'Favor',
        }.freeze

        LOOSE = 0
        NORMAL = 1
        TIGHT = 2

        REGULATION_COST = 20

        R3_OWNERSHIP_LIMITS = [70, 60, 50].freeze

        NO_CERT_LIMIT_OWNERSHIP = 100

        INFLUENCE_ICON = 'influence_cube'

        D_TRAIN = 'D'

        INFLUENCE_REASONS = {
          blue_space: 'first to reach a blue space',
          influence_zone: 'Influence Zone',
          d_train: 'D-train purchase',
          new_london_route: 'New London Route',
        }.freeze

        # Track when bank breaks so D train doesn't override it
        def end_now?(after)
          @bank_broken_trigger ||= true if after == :full_or && @bank.broken?

          super
        end

        def game_end_check_custom?
          @d_train_bought
        end

        # The game ends when the bank breaks.
        def game_end_check_values
          { bank: :full_or }
        end

        def game_ending_description
          reason, after = game_end_check
          return unless after

          if @d_train_bought && @final_turn
            "Game ends at conclusion of OR #{@final_turn}.#{@phase.operating_rounds}"
          elsif reason == :bank
            if @round.is_a?(Engine::Round::Operating)
              "Game ends at conclusion of OR #{@turn}.#{operating_rounds}"
            else
              'Game ends at conclusion of the next full OR set'
            end
          end
        end

        def share_price_changed(entity, from)
          return if entity.share_price == from

          claim_first_to_arrive_cell(entity, entity.share_price)
          update_ownership_limit_for(entity)
        end

        def claim_first_to_arrive_cell(entity, price)
          return unless price.types.delete(:pays_bonus_1)

          @log << "#{entity.name} is first to reach #{format_currency(price.price)}"
          grant_corporation_influence!(entity, :blue_space)
        end

        def sold_out_stock_movement(corporation)
          previous = corporation.share_price
          @stock_market.move_up(corporation)
          check_influence_zone!(corporation, previous)
        end

        def log_share_price(entity, from, steps = nil, log_steps: false)
          return check_influence_zone!(entity, from) if entity.share_price != from && entity.share_price.type == :pays_bonus

          super
          share_price_changed(entity, from)
        end

        def check_influence_zone!(corporation, previous)
          return if corporation.share_price.type != :pays_bonus || corporation.type == :faction

          @stock_market.move(corporation, previous.coordinates)
          @log << "#{corporation.name} reaches the Influence Zone and returns to #{format_currency(previous.price)}"
          grant_corporation_influence!(corporation, :influence_zone)
        end

        def buy_train(operator, train, price = nil)
          d_train = train.name == self.class::D_TRAIN && train.owner == @depot
          super
          grant_corporation_influence!(operator, :d_train) if d_train
        end

        def after_lay_tile(hex, tile, entity)
          return unless new_london_route_icon(hex)

          edge_a, edge_b = hex.original_tile.future_paths.first.exits
          return unless edges_connected?(tile, edge_a, edge_b)

          hex.tile.icons.delete(new_london_route_icon(hex))
          corporation = entity.company? ? entity.owner : entity
          grant_corporation_influence!(corporation, :new_london_route, hex.name) if corporation&.corporation?
        end

        def new_london_route_icon(hex)
          hex.tile.icons.find { |icon| icon.name == self.class::INFLUENCE_ICON }
        end

        def edges_connected?(tile, edge_a, edge_b)
          tile.paths.any? { |path| path.exits.include?(edge_a) && path.exits.include?(edge_b) } ||
            tile.nodes.any? do |node|
              exits = node.paths.flat_map(&:exits)
              exits.include?(edge_a) && exits.include?(edge_b)
            end
        end

        def grant_corporation_influence!(corporation, reason, place = nil)
          return if corporation_factions(corporation).empty?

          available = corporation_factions(corporation).select { |f| within_influence_limit?(corporation, f) }
          if available.empty?
            @log << "#{corporation.name} cannot receive influence (both factions at limit — cube discarded)"
            return
          end

          choice = { corporation: corporation, factions: available, reason: reason, place: place }
          @log << "#{corporation.name} gains 1 Influence (#{influence_reason_text(choice)})"
          @pending_influence_queue << choice
          @round&.clear_cache!
        end

        def influence_reason_text(choice)
          text = self.class::INFLUENCE_REASONS[choice[:reason]]
          choice[:place] ? "#{text}, #{choice[:place]}" : text
        end

        def pending_influence_choice
          @pending_influence_queue.first
        end

        def resolve_influence_choice!(faction_sym)
          choice = @pending_influence_queue.shift
          apply_faction_influence!(choice[:corporation], faction_sym)
          execute_deferred_turmoil! if choice[:reason] == :d_train
        end

        def within_influence_limit?(corporation, faction_sym)
          corporation_influence_for(corporation, faction_sym) < corporation_influence_limit
        end

        attr_reader :government_marker, :regulations

        FACTION_TREASURY = 500

        def setup
          super

          @government_marker = GOVERNMENT_START.dup
          @faction_influence = Hash.new(0)
          @parliament_open = false
          @regulations = REGULATIONS.transform_values { |name| { name: name, position: NORMAL } }
          @player_influence = Hash.new(0)

          factions.each { |faction| @bank.spend(self.class::FACTION_TREASURY, faction) }

          @faction_support_pool = faction_names.keys.flat_map { |f| [f, f] }
          @faction_support_reserve = @faction_support_pool.dup
          @corporations_floated_count = 0
          @corporation_factions = {}
          @corporation_influence = {}
          @pending_faction_choices = []
          @pending_influence_queue = []
          @deferred_turmoil = false
        end

        # Factions are not capitalized: founding one pays nothing into its Treasury
        def init_corporations(stock_market)
          min_price = stock_market.par_prices.map(&:price).min
          factions = self.class::FACTIONS.map do |faction|
            Faction.new(min_price: min_price, capitalization: :none, **faction.merge(corporation_opts))
          end
          super + factions
        end

        # Factions are bought from Parliament, never parred like Corporations
        def can_par?(corporation, parrer)
          corporation.type != :faction && super
        end

        # The certificate limit depends on the Corporations in play (8.6), not the Factions
        def init_cert_limit
          cert_limit = self.class::CERT_LIMIT[@players.size]
          corporations = @corporations.count { |c| c.type != :faction && !c.closed? }
          cert_limit.reject { |k, _| k < corporations }.min_by(&:first)&.last || cert_limit.first.last
        end

        def factions
          @corporations.select { |c| c.type == :faction }
        end

        # Actions store a Faction's entity_type as 'faction'
        def faction_by_id(id)
          corporation_by_id(id)
        end

        def ipo_name(entity = nil)
          entity&.type == :faction ? 'Parliament' : super
        end

        def count_available_tokens(corporation)
          return super unless corporation.type == :faction

          corporation.tokens_in_parliament
        end

        def token_string(corporation)
          return super unless corporation.type == :faction

          "#{corporation.tokens_in_parliament}/#{corporation.tokens_total}"
        end

        def status_array(corporation)
          if corporation.type == :faction
            return [
              ["Influence: #{faction_influence(corporation.id)}/#{faction_influence_limit}", ''],
              ["Tokens: #{token_string(corporation)}", ''],
            ]
          end

          influence = corporation_influence(corporation)
          corporation_factions(corporation).map do |f|
            ["#{faction_display_name(f)}: #{influence[f] || 0}/#{corporation_influence_limit}", '']
          end
        end

        def float_corporation(corporation)
          super
          return if corporation.type == :faction

          @pending_faction_choices << { corporation: corporation, entity: corporation.owner, step: :first }
        end

        def parliamentary_intervention?
          @optional_rules&.include?(:parliamentary_intervention)
        end

        def faction_support_available
          @faction_support_pool.uniq
        end

        def faction_support_remaining(faction_sym)
          @faction_support_pool.count(faction_sym)
        end

        def faction_support_available_for_second(first_choice)
          @faction_support_pool.uniq - [first_choice, opposite_faction(first_choice)]
        end

        def pending_faction_choice
          @pending_faction_choices.first
        end

        def choose_first_faction!(faction_sym)
          pending_faction_choice[:step] = :second
          pending_faction_choice[:first_choice] = faction_sym
        end

        def finish_faction_choice!(faction_sym)
          choice = @pending_faction_choices.shift
          support_factions!(choice[:corporation], [choice[:first_choice], faction_sym])
        end

        def consume_faction_support!(faction_sym)
          @faction_support_pool.delete_at(@faction_support_pool.index(faction_sym))
        end

        def apply_faction_influence!(corporation, faction_sym)
          @corporation_factions[corporation.id] ||= []
          @corporation_factions[corporation.id] << faction_sym unless @corporation_factions[corporation.id].include?(faction_sym)

          @corporation_influence[corporation.id] ||= {}
          @corporation_influence[corporation.id][faction_sym] ||= 0

          limit = corporation_influence_limit
          if @corporation_influence[corporation.id][faction_sym] >= limit
            @log << "#{corporation.name} has reached the limit of #{limit} Influence for "\
                    "#{faction_display_name(faction_sym)} (discarded)"
            return
          end

          @corporation_influence[corporation.id][faction_sym] += 1
          faction_influence_gain(faction_sym)
          move_government(faction_sym)
        end

        def support_factions!(corporation, factions)
          @corporations_floated_count += 1
          if @corporations_floated_count == self.class::SECOND_SUPPORT_SET_FLOAT
            @faction_support_pool = @faction_support_reserve.dup
          end

          @log << "#{corporation.name} now supports #{factions.map { |f| faction_display_name(f) }.join(' and ')}"
        end

        def corporation_factions(corporation)
          @corporation_factions[corporation.id] || []
        end

        def corporation_influence(corporation)
          @corporation_influence[corporation.id] || {}
        end

        def corporation_influence_for(corporation, faction_sym)
          corporation_influence(corporation).fetch(faction_sym, 0)
        end

        def corporation_influence_limit
          self.class::CORPORATION_INFLUENCE_LIMITS[@phase.name]
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            GFrost1831::Step::BuyCert,
          ])
        end

        def after_buy_company(player, company, _price)
          abilities(company, :shares) do |ability|
            ability.shares.reject(&:president).each do |share|
              share_pool.buy_shares(player, share, exchange: :free)
            end
          end
          return unless company.sym == self.class::CONVOY

          @player_influence[player.id] += 1
          @log << "#{player.name} receives 1 Influence from #{company.name}"
        end

        def player_influence(player)
          @player_influence[player.id]
        end

        def player_card_rows(player)
          influence = player_influence(player)
          return unless influence.positive?

          ['Influence', influence.to_s]
        end

        def stock_round
          GFrost1831::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            GFrost1831::Step::ChooseFactions,
            GFrost1831::Step::ChooseInfluence,
            GFrost1831::Step::HomeToken,
            GFrost1831::Step::Exchange,
            GFrost1831::Step::BuySellParShares,
          ])
        end

        def init_stock_market
          GFrost1831::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                      multiple_buy_types: self.class::MULTIPLE_BUY_TYPES,
                                      sold_out_top_row_movement: self.class::SOLD_OUT_TOP_ROW_MOVEMENT)
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            GFrost1831::Step::HomeToken,
            GFrost1831::Step::ChooseInfluence,
            GFrost1831::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            GFrost1831::Step::Track,
            GFrost1831::Step::Token,
            Engine::Step::Route,
            GFrost1831::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def parliament_open?
          @parliament_open
        end

        def event_parliament_opens!
          @log << "-- Event: New London's Parliament opens! --"
          @parliament_open = true

          start_price = stock_market.market[FACTION_ROW].find { |p| p&.price == FACTION_START_PRICE }
          factions.each do |faction|
            faction.ipoed = true
            faction.par_price = start_price
            faction.share_price = start_price
            start_price.corporations << faction
          end
        end

        def faction_share_price(faction)
          faction.share_price.price
        end

        def operating_order
          super.reject { |c| c.type == :faction }
        end

        def sold_shares_destination(corporation)
          corporation.type == :faction ? :corporation : super
        end

        def sold_out_increase?(corporation)
          corporation.type != :faction && super
        end

        def available_faction_cities
          FACTION_RESERVED_CITIES.select do |hex_id|
            hex_by_id(hex_id).tile.cities.first.tokens.none? { |t| t&.corporation&.type == :faction }
          end
        end

        def reserved_for_faction?(city)
          available_faction_cities.include?(city.hex.id) && city.available_slots < 2
        end

        def faction_names
          self.class::FACTION_NAMES
        end

        def faction_order
          self.class::FACTION_ORDER
        end

        def opposite_faction(faction_sym)
          self.class::OPPOSITES[faction_sym]
        end

        def faction_display_name(faction_sym)
          faction_names[faction_sym] || faction_sym
        end

        def faction_influence(faction_sym)
          @faction_influence[faction_sym]
        end

        def faction_influence_limit
          self.class::FACTION_INFLUENCE_LIMITS[@phase.name]
        end

        def faction_influence_gain(faction_sym)
          limit = faction_influence_limit
          if @faction_influence[faction_sym] >= limit
            @log << "#{faction_display_name(faction_sym)} has reached the limit of #{limit} "\
                    'Influence in Parliament (discarded)'
            return false
          end

          @faction_influence[faction_sym] += 1
          true
        end

        def faction_influence_lose(faction_sym)
          return false unless @faction_influence[faction_sym].positive?

          @faction_influence[faction_sym] -= 1
          true
        end

        def government_neutral?
          row, col = @government_marker
          self.class::GOVERNMENT_NEUTRAL_LINES.include?(row) && self.class::GOVERNMENT_NEUTRAL_LINES.include?(col)
        end

        def governing_faction_sym
          return if government_neutral?

          row, col = @government_marker
          middle = self.class::GOVERNMENT_MIDDLE
          self.class::GOVERNMENT_QUADRANTS[[row < middle, col < middle]]
        end

        def move_government(faction_sym)
          row, col = @government_marker
          destination = ParliamentMovement.move(row, col, faction_sym)

          if destination.nil?
            @log << "Government marker cannot move from (#{row},#{col}) toward #{faction_display_name(faction_sym)}"
            return
          end

          if destination == @government_marker
            @log << "Government marker already at maximum for #{faction_display_name(faction_sym)}"
            return
          end

          @government_marker = destination
          @log << "Government marker moves toward #{faction_display_name(faction_sym)}"
        end

        def event_turmoil!
          @log << '-- Event: Turmoil! --'
          if @pending_influence_queue.any? { |choice| choice[:reason] == :d_train }
            @log << 'D train influence must be allocated before Turmoil consequences'
            @deferred_turmoil = true
            return
          end

          execute_turmoil_consequences!
        end

        def execute_deferred_turmoil!
          return unless @deferred_turmoil

          @deferred_turmoil = false
          execute_turmoil_consequences!
        end

        def execute_turmoil_consequences!
          governing = governing_faction_sym
          unless governing
            @log << 'Government is neutral — no consequences'
            return
          end

          opposition = opposite_faction(governing)
          level = ParliamentMovement.polarization_level(*@government_marker)
          @log << "Government: #{faction_display_name(governing)} (Level #{level})"
          @log << "Opposition: #{faction_display_name(opposition)}"
          return if level < self.class::TURMOIL_INFLUENCE_LEVEL

          @log << "#{faction_display_name(governing)} gains 1 Influence in Parliament" if faction_influence_gain(governing)
          return unless faction_influence_lose(opposition)

          @log << "#{faction_display_name(opposition)} loses 1 Influence in Parliament"
        end

        def regulation_value(regulation_id)
          @regulations[regulation_id][:position]
        end

        def move_regulation(regulation_id, direction)
          regulation = @regulations[regulation_id]
          position = regulation[:position] + (direction == :up ? 1 : -1)
          regulation[:position] = [[position, self.class::LOOSE].max, self.class::TIGHT].min
          apply_r3_limits if regulation_id == 'R3'
        end

        def r3_ownership_limit
          self.class::R3_OWNERSHIP_LIMITS[regulation_value('R3')]
        end

        def apply_r3_limits
          @corporations.each { |corporation| update_ownership_limit_for(corporation) }
        end

        def update_ownership_limit_for(corporation)
          return if corporation.type == :faction

          corporation.max_ownership_percent =
            if corporation.share_price&.type == :no_cert_limit
              self.class::NO_CERT_LIMIT_OWNERSHIP
            else
              r3_ownership_limit
            end
        end

        def upgrade_cost(tile, hex, entity, spender)
          cost = super
          return cost if tile.color == :white

          cost + r2_track_upgrade_cost(tile)
        end

        def tile_cost_with_discount(tile, hex, entity, spender, cost)
          discounted = super
          return discounted unless tile.color == :yellow

          discounted + r1_track_laying_cost
        end

        def r1_track_laying_cost
          case regulation_value('R1')
          when self.class::LOOSE then 0
          when self.class::NORMAL then @round.num_laid_track.positive? ? self.class::REGULATION_COST : 0
          else self.class::REGULATION_COST
          end
        end

        def r2_track_upgrade_cost(tile)
          case regulation_value('R2')
          when self.class::LOOSE then 0
          when self.class::NORMAL then tile.cities.empty? && tile.towns.empty? ? self.class::REGULATION_COST : 0
          else self.class::REGULATION_COST
          end
        end
      end
    end
  end
end
