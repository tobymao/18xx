# frozen_string_literal: true

require_relative 'meta'
require_relative 'parliament_movement'
require_relative 'map'
require_relative 'entities'
require_relative 'tiles'
require_relative 'step/buy_cert'
require_relative 'step/dividend'
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
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
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
        end

        attr_reader :government_marker, :regulations

        def setup
          super

          @government_marker = GOVERNMENT_START.dup
          @faction_influence = Hash.new(0)
          @parliament_open = false
          @regulations = REGULATIONS.transform_values { |name| { name: name, position: NORMAL } }
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
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
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
        end

        def faction_display_name(faction_sym)
          self.class::FACTION_NAMES[faction_sym] || faction_sym
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
                    'Influence in Parliament (cube discarded)'
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

          governing = governing_faction_sym
          unless governing
            @log << 'Government is neutral — no consequences'
            return
          end

          opposition = self.class::OPPOSITES[governing]
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
