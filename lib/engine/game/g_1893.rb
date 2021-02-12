# frozen_string_literal: true

require_relative 'base'
require_relative '../config/game/g_1893'
require_relative '../round/g_1893/stock'

module Engine
  module Game
    class G1893 < Base
      register_colors(
        gray70: '#B3B3B3',
        gray50: '#7F7F7F'
      )

      load_from_json(Config::Game::G1893::JSON)
      AXES = { x: :number, y: :letter }.freeze

      GAME_LOCATION = 'Cologne, Germany'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/188718/1893-cologne-rule-summary-version-10'
      GAME_DESIGNER = 'Edwin Eckert'
      GAME_PUBLISHER = :marflow_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1893'

      GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or }.freeze

      # Move down one step for a whole block, not per share
      SELL_MOVEMENT = :down_block

      # Cannot sell until operated
      SELL_AFTER = :operate

      # Sell zero or more, then Buy zero or one
      SELL_BUY_ORDER = :sell_buy

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'remove_tile_block' => ['Remove tile block', 'Rhine may be passed. N5 P5 becomes possible to lay tiles in'],
        'agv_buyable' => ['AGV buyable', 'AGV shares can be bought in the stockmarket'],
        'agv_founded' => ['AGV founded', 'AGV is founded if not yet founded'],
        'hgk_buyable' => ['HGK buyable', 'HGK shares can be bought in the stockmarket'],
        'hgk_founded' => ['HGK founded', 'AGV is founded if not yet founded'],
        'bonds_exchanged' => ['FdSD exchanged', 'Any remaining Fond der Stadt Düsseldorf bonds are exchanged'],
        'eva_closed' => ['EVA closed', 'EVA Is closed']
      ).freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_trains' => ['Can Buy trains', 'Can buy trains from other corporations'],
        'rhine_impassible' => ['Rhine impassible', 'Cannot lay tile across the Rhine'],
        'may_found_agv' => ['May found AGV', 'AGV may be founded during the SR'],
        'may_found_hgk' => ['May found HGK', 'HGK may be founded during the SR']
      ).freeze

      MARKET_TEXT = {
        par: 'Par values for non-merged corporations',
        par_1: 'Par value for AGV',
        par_2: 'Par value for HGK',
      }.freeze

      STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
        par: :orange,
        par_1: :red,
        par_2: :green
      ).freeze

      OPTIONAL_RULES = [
        {
          sym: :optional_2_train,
          short_name: 'Optional 2-Train',
          desc: 'Add an 8th 2-train',
        },
        {
          sym: :optional_grey_phase,
          short_name: 'Gray Phase',
          desc: 'Changed Köln tiles. Extra gray KV259.',
        },
        {
          sym: :optional_existing_track,
          short_name: 'Existing Track',
          desc: 'E2 and D7 start as yellow. New S upgrades.',
        },
      ].freeze

      OPTION_TILES_USE_GREY_PHASE = %w[KV201-0 KV269-0 KV255-0 KV333-0 KV259-0].freeze
      OPTION_TILES_REMOVE_GREY_PHASE = %w[K269-0 K255-0].freeze
      OPTION_TILES_USE_EXISTING_TRACK = %w[KV619-0 KV63-0].freeze

      MERGED_CORPORATIONS = %w[AGV HGK].freeze
      TILE_BLOCK = %w[N5 P5].freeze

      def num_trains(train)
        return train[:num] unless train[:name] == '2'

        optional_2_train ? 8 : 7
      end

      def optional_2_train
        @optional_rules&.include?(:optional_2_train)
      end

      def optional_grey_phase
        @optional_rules&.include?(:optional_grey_phase)
      end

      def optional_existing_track
        @optional_rules&.include?(:optional_existing_track)
      end

      def optional_hexes
        base_map
      end

      def optional_tiles
        remove_tiles(OPTION_TILES_USE_GREY_PHASE) unless optional_grey_phase
        remove_tiles(OPTION_TILES_REMOVE_GREY_PHASE) if optional_grey_phase
        remove_tiles(OPTION_TILES_USE_EXISTING_TRACK) unless optional_existing_track
      end

      def remove_tiles(tiles)
        tiles.each do |ot|
          @tiles.reject! { |t| t.id == ot }
          @all_tiles.reject! { |t| t.id == ot }
        end
      end

      def init_round
        @log << '-- First Stock Round --'
        Round::Stock.new(self, [
          Step::G1893::BuySellParSharesFirstSR,
        ])
      end

      def stock_round
        Round::G1893::Stock.new(self, [
          Step::DiscardTrain,
          Step::G1893::BuySellParSharesFollowingSR,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::HomeToken,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::G1893::Dividend,
          Step::G1893::BuyTrain,
        ], round_num: round_num)
      end

      def float_str(entity)
        return 'Each pay 10M per OR' if entity.name == 'AdSK'
        return super if !entity.corporation || entity.floatable
        return super unless merged_corporation?(entity)

        'Floated via merge'
      end

      def status_str(entity)
        return 'Minor' if entity.minor?
        return 'Exchangable corporation' if !entity.floated? && merged_corporation?(entity)
        return 'Bond - Buy/Sell as share for set price' if entity == adsk

        'Corproation'
      end

      def adsk
        @adsk_corporation ||= corporation_by_id('AdSK')
      end

      def agv
        @agv_corporation ||= corporation_by_id('AGV')
      end

      def hgk
        @hgk_corporation ||= corporation_by_id('HGK')
      end

      def hdsk_reserved_share
        # 10% certificate in HGK
        { share: hgk.shares[1], private: company_by_id('HdSK'), minor: nil }
      end

      def ekb_reserved_share
        # President's certificate in AGV
        { share: agv.shares[0], private: nil, minor: minor_by_id('EKB') }
      end

      def kfbe_reserved_share
        # 20% certificate in HGK
        { share: hgk.shares[2], private: nil, minor: minor_by_id('KFBE') }
      end

      def ksz_reserved_share
        # 10% certificate in AGV
        { share: agv.shares[1], private: nil, minor: minor_by_id('KSZ') }
      end

      def kbe_reserved_share
        # President's certificate in HGK
        { share: hgk.shares[0], private: nil, minor: minor_by_id('KBE') }
      end

      def bkb_reserved_share
        # 20% certificate in AGV
        { share: agv.shares[2], private: nil, minor: minor_by_id('BKB') }
      end

      def merged_corporation?(corporation)
        MERGED_CORPORATIONS.include?(corporation.id)
      end

      def setup
        # Set up bonds to have a presidency share owned by the bank
        # and have a set price of 100
        adsk.shares[0].buyable = false
        @share_pool.transfer_shares(adsk.shares[0].to_bundle, @bank)
        bond_price = @stock_market.par_prices.find { |p| p.price == 100 }
        @stock_market.set_par(adsk, bond_price)
        adsk.ipoed = true
        move_buyable_shares_to_market(adsk)

        [hdsk_reserved_share, ekb_reserved_share, kfbe_reserved_share, ksz_reserved_share,
         kbe_reserved_share, bkb_reserved_share].each { |info| info[:share].buyable = false }

        @companies.each do |c|
          c.owner = @bank
          @bank.companies << c
        end

        @minors.each do |minor|
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token)
        end

        # Use neutral tokens to make cities passable, but not blockable
        @neutral = Corporation.new(
          sym: 'N',
          name: 'Neutral',
          logo: 'open_city',
          tokens: [0, 0],
        )
        @neutral.owner = @bank
        @neutral.tokens.each { |token| token.type = :neutral }
        city_by_id('H5-0-0').place_token(@neutral, @neutral.next_token)
        city_by_id('J5-0-0').place_token(@neutral, @neutral.next_token)
      end

      def upgrades_to?(from, to, special = false)
        return super unless TILE_BLOCK.include?(from.hex.name)
        return super if from.hex.tile.icons.empty?

        raise GameError, "Cannot place a tile in #{from.hex.name} until green phase"
      end

      def event_remove_tile_block!
        @hexes
          .select { |hex| TILE_BLOCK.include?(hex.name) }
          .each { |hex| hex.tile.icons = [] }
      end

      def event_agv_buyable!
        @log << "Unreserved #{agv.name} shares are now available to buy"
        bond_price = @stock_market.par_prices.find { |p| p.price == 120 }
        @stock_market.set_par(agv, bond_price)
        move_buyable_shares_to_market(agv)
      end

      def event_agv_founded!
        found_agv unless agv.presidents_share.buyable
      end

      def found_agv
        @log << "#{agv.name} founded"
        form_mergable(agv, [ekb_reserved_share, ksz_reserved_share, bkb_reserved_share])
      end

      def event_hgk_buyable!
        @log << "Unreserved #{hgk.name} shares are now available to buy"
        bond_price = @stock_market.par_prices.reverse.find { |p| p.price == 120 }
        @stock_market.set_par(hgk, bond_price)
        move_buyable_shares_to_market(hgk)
      end

      def event_hgk_founded!
        found_hgk unless hgk.presidents_share.buyable
      end

      def found_hgk
        @log << "#{hgk.name} founded"
        form_mergable(hgk, [kbe_reserved_share, hdsk_reserved_share, kfbe_reserved_share])
      end

      def form_mergable(_mergable, _exchange_info)
        @log << 'NOT YET IMPLEMENTED'
      end

      def buyable?(entity)
        return true unless entity.corporation?

        entity.all_abilities.none? { |a| a.type == :no_buy }
      end

      def remove_ability(corporation, ability_name)
        abilities(corporation, ability_name) do |ability|
          corporation.remove_ability(ability)
        end
      end

      def must_buy_train?(entity)
        return false if entity.minor?

        super
      end

      def payout_companies
        super

        @players.each do |player|
          bonds = player.num_shares_of(adsk)
          next unless bonds.positive?

          revenue = bonds * 10
          @log << "#{player.name} collects #{format_currency(revenue)} from #{adsk.name}"
          @bank.spend(revenue, player)
        end
      end

      private

      def move_buyable_shares_to_market(corporation)
        corporation.shares.each do |s|
          next unless s.buyable

          @share_pool.transfer_shares(s.to_bundle, @share_pool, price: 0, allow_president_change: false)
        end
      end

      def base_map
        simple_city = %w[I2 I8 L3 O2 O4 R7 T3]
        simple_city += %w[D7 E2] unless optional_existing_track
        optional_d7 = optional_existing_track ? ['D7'] : []
        optional_e2 = optional_existing_track ? ['E2'] : []
        {
          red: {
            ['A4'] => 'city=revenue:yellow_10|green_30|brown_50;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            ['B5'] => 'path=a:2,b:0;path=a:2,b:5',
            ['B9'] => 'offboard=revenue:yellow_20|green_30|brown_40,hide:1,groups:Wuppertal;'\
                      'path=a:1,b:_0,terminal:1',
            ['D9'] => 'offboard=revenue:yellow_20|green_30|brown_40,groups:Wuppertal'\
                      'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
            ['L9'] => 'offboard=revenue:yellow_20|green_20|brown_20;'\
                      'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
            ['N1'] => 'offboard=revenue:yellow_20|green_30|brown_50,hide:1,groups:Aachen;'\
                      'path=a:5,b:_0,terminal:1',
            ['P1'] => 'offboard=revenue:yellow_20|green_30|brown_50,groups:Aachen;'\
                      'path=a:4,b:_0,terminal:1',
            ['P9'] => 'offboard=revenue:yellow_20|green_20|brown_30;'\
                      'path=a:1,b:_0,terminal:1',
            ['U6'] => 'offboard=revenue:yellow_10|green_20|brown_30;'\
                      'path=a:4,b:_0,terminal:1',
            ['U8'] => 'offboard=revenue:yellow_20|green_30|brown_40;'\
                      'path=a:2,b:_0,terminal:1',
          },
          gray: {
            ['F1'] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0',
            %w[F5 T7] => 'path=a:1,b:2;path=a:3,b:5',
            ['F9'] => 'path=a:2,b:0',
            ['H5'] => 'city=revenue:20;path=a:0,b:_0',
            ['H9'] => 'path=a:3,b:1',
            ['J5'] => 'city=revenue:20;path=a:1,b:_0;path=a:0,b:_0;path=a:3,b:_0',
            ['J9'] => '',
            ['U4'] => 'town=revenue:10;path=a:2,b:_0;path=a:4,b:_0',
          },
          white: {
            %w[B3 C2 C6 D3 E6 F3 F7 G2 G4 I6 J3 J7 K2 K4 K8 L7 M2 N3 N7 O8 Q2 R5 S8 T5] => '',
            %w[B7 H3 I4 K6 M4 M8 Q4 Q8 S2] => 'town=revenue:0',
            simple_city => 'city=revenue:0',
            %w[C8 E8 G8 H7 P3 R3 S4] => 'upgrade=cost:40,terrain:mountain',
            ['G6'] => 'town=revenue:0;town=revenue:0;label=L',
            ['C4'] => 'border=edge:5,type:impassable',
            ['D5'] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable;label=BX',
            ['E4'] => 'city=revenue:0;border=edge:4,type:impassable',
            ['L5'] => 'city=revenue:0;border=edge:5,type:impassable;upgrade=cost:40,terrain:water;label=K',
            ['M6'] => 'upgrade=cost:40,terrain:water;border=edge:2,type:impassable',
            ['O6'] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['Q6'] => 'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['S6'] => 'city=revenue:0;upgrade=cost:40;border=edge:3,type:impassable;label=BX',
            ['N5'] => 'stub=edge:4;border=edge:5,type:impassable;icon=image:1893/green_hex',
            ['P5'] => 'town=revenue:0;border=edge:4,type:impassable;border=edge:5,type:impassable;'\
                      'icon=image:1893/green_hex',
          },
          yellow: {
            ['P7'] => 'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0',
            optional_d7 => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;label=S',
            optional_e2 => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
          },
        }
      end
    end
  end
end
