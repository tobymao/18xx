# frozen_string_literal: true

require_relative 'meta'
require_relative 'tiles'
require_relative 'map'
require_relative 'market'
require_relative 'trains'
require_relative 'entities'
require_relative 'phases'

require_relative '../base'
require_relative '../company_price_50_to_150_percent'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G18GA
      class Game < Game::Base
        include_meta(G18GA::Meta)
        include G18GA::Tiles
        include G18GA::Map
        include G18GA::Market
        include G18GA::Trains
        include G18GA::Entities
        include G18GA::Phases

        include CitiesPlusTownsRouteDistanceStr

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 8000

        CERT_LIMIT = { 3 => 15, 4 => 12, 5 => 10 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_companies_from_other_players' => ['Interplayer Company Buy',
                                                     'Companies can be bought between players']
        ).merge(
          Engine::Step::SingleDepotTrainBuy::STATUS_TEXT
        ).freeze

        def p2_company
          @p2_company ||= company_by_id('MRC')
        end

        def p3_company
          @p3_company ||= company_by_id('W&SR')
        end

        def waycross_hex
          @waycross_hex ||= @hexes.find { |h| h.name == 'I9' }
        end

        include CompanyPrice50To150Percent

        def setup
          setup_company_price_50_to_150_percent

          @recently_floated = []
          make_train_soft_rust if @optional_rules&.include?(:soft_rust_4t)

          # Place neutral tokens in the off board cities
          neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: 'open_city',
            simple_logo: 'open_city',
            tokens: [0, 0],
          )
          neutral.owner = @bank

          neutral.tokens.each { |token| token.type = :neutral }

          city_by_id('E1-0-0').place_token(neutral, neutral.next_token)
          city_by_id('J4-0-0').place_token(neutral, neutral.next_token)

          # Remember specific tiles for upgrades check later
          @green_aug_tile ||= @tiles.find { |t| t.name == '453a' }
          @green_s_tile ||= @tiles.find { |t| t.name == '454a' }
          @brown_b_tile ||= @tiles.find { |t| t.name == '457a' }
          @brown_m_tile ||= @tiles.find { |t| t.name == '458a' }

          # The last 2 train will be used as free train for a private
          # Store it in neutral corporation in the meantime
          @free_2_train = train_by_id('2-5')
          @free_2_train.buyable = false
          buy_train(neutral, @free_2_train, :free)
        end

        def tile_lays(entity)
          return super if !@optional_rules&.include?(:double_yellow_first_or) ||
            !@recently_floated&.include?(entity)

          [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
        end

        # Only buy and sell par shares is possible action during SR
        def stock_round
          Round::Stock.new(self, [
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18GA::Step::SpecialToken,
            G18GA::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::SpecialTrack,
            Engine::Step::Track,
            G18GA::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::SingleDepotTrainBuy,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def or_round_finished
          @recently_floated = []
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Augusta (D10) use standard tiles for yellow, and special tile for green
          return to.name == '453a' if from.color == :yellow && from.hex.name == 'D10'

          # Savannah (G13) use standard tiles for yellow, and special tile for green
          return to.name == '454a' if from.color == :yellow && from.hex.name == 'G13'

          # Brunswick (I11) use standard tiles for yellow/green, and special tile for brown
          return to.name == '457a' if from.color == :green && from.hex.name == 'I11'

          # Macon (F6) use standard tiles for yellow/green, and special tile for brown
          return to.name == '458a' if from.color == :green && from.hex.name == 'F6'

          super
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super

          return upgrades unless tile_manifest

          upgrades |= [@green_aug_tile] if @green_aug_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)
          upgrades |= [@green_s_tile] if @green_s_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)
          upgrades |= [@brown_b_tile] if @brown_b_tile && STANDARD_GREEN_CITY_TILES.include?(tile.name)
          upgrades |= [@brown_m_tile] if @brown_m_tile && STANDARD_GREEN_CITY_TILES.include?(tile.name)

          upgrades
        end

        def add_free_two_train(corporation)
          @free_2_train.buyable = true
          buy_train(corporation, @free_2_train, :free)
          @free_2_train.buyable = false
          @log << "#{corporation.name} receives a bonus non sellable 2 train"
        end

        def make_train_soft_rust
          @depot.trains.select { |t| t.name == '4' }.each { |t| update_end_of_life(t, nil, t.rusts_on) }
        end

        def update_end_of_life(t, rusts_on, obsolete_on)
          t.rusts_on = rusts_on
          t.obsolete_on = obsolete_on
          t.variants.each { |_, v| v.merge!(rusts_on: rusts_on, obsolete_on: obsolete_on) }
        end

        def event_close_companies!
          super

          remove_icon_from_waycross
        end

        def remove_icon_from_waycross
          waycross_hex.tile.icons = []
        end
      end
    end
  end
end
