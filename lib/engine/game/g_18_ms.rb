# frozen_string_literal: true

require_relative '../config/game/g_18_ms'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18MS < Base
      attr_accessor :chattanooga_reached

      load_from_json(Config::Game::G18MS::JSON)

      GAME_LOCATION = 'Mississippi, USA'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18MS'

      # Game ends after 5 * 2 ORs
      GAME_END_CHECK = { final_or_set: 5 }.freeze

      HOME_TOKEN_TIMING = :operating_round

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_companies_operation_round_one' =>
          ['Can Buy Companies OR 1', 'Corporations can buy AGS/BS companies for face value in OR 1'],
      ).freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'remove_tokens' => ['Remove Tokens', 'New Orleans route bonus removed']
      ).freeze

      HEXES_FOR_GRAY_TILE = %w[C9 E11].freeze
      COMPANY_1_AND_2 = %w[AGS BS].freeze

      def p2_company
        @p2_company ||= company_by_id('BS')
      end

      include CompanyPrice50To150Percent

      def setup
        @chattanooga_reached = false
        setup_company_price_50_to_150_percent

        @mobile_city_brown ||= @tiles.find { |t| t.name == 'X31b' }
        @gray_tile ||= @tiles.find { |t| t.name == '446' }
        @recently_floated = []

        # The last 2+ train will be used as free train for a private
        # Store it in the company in the meantime
        neutral = Corporation.new(
          sym: 'N',
          name: 'Neutral',
          tokens: [],
        )
        neutral.owner = @bank
        @free_train = train_by_id('2+-4')
        @free_train.buyable = false
        neutral.buy_train(@free_train, :free)
      end

      def new_operating_round(round_num = 1)
        # For OR 1, set company buy price to face value only
        @companies.each do |company|
          company.min_price = company.value
          company.max_price = company.value
        end if @turn == 1 && round_num == 1

        # When OR1.2 is to start setup company prices and switch to green phase
        if @turn == 1 && round_num == 2
          setup_company_price_50_to_150_percent
          @phase.next!
        end

        if round_num == 1
          @players.each do |p|
            next unless p.cash.negative?

            debt = -p.cash
            interest = (debt / 2.0).ceil
            p.spend(interest, @bank, check_cash: false)
            @log << "#{p.name} has to borrow another #{format_currency(interest)} as being in debt at end of SR"
          end
        end
        super
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Exchange,
          Step::DiscardTrain,
          Step::G18MS::SpecialTrack,
          Step::G18MS::SpecialToken,
          Step::G18MS::BuyCompany,
          Step::G18MS::Track,
          Step::G18MS::Token,
          Step::Route,
          Step::Dividend,
          Step::SpecialBuyTrain,
          Step::G18MS::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def init_round
        Round::Draft.new(self, [Step::G18MS::SimpleDraft])
      end

      def priority_deal_player
        return @players.first if @round.is_a?(Round::Draft)

        super
      end

      def or_round_finished
        @recently_floated = []
      end

      def or_set_finished
        case @turn
        when 3 then rust('2+', 20)
        when 4 then rust('3+', 30)
        when 5 then rust('4+', 60)
        end
      end

      def purchasable_companies(entity = nil)
        entity ||= current_entity
        return [] if entity.company?

        # Only companies owned by the president may be bought
        # Allow MC to be bought only before OR 3.1 and there is room for a 2+ train
        companies = super.select { |c| c.owned_by?(entity.player) }
        companies.reject! { |c| c.id == 'MC' && (@turn >= 3 || entity.trains.size == @phase.train_limit) }

        return companies unless @phase.status.include?('can_buy_companies_operation_round_one')

        return [] if @turn > 1

        companies.select do |company|
          COMPANY_1_AND_2.include?(company.id)
        end
      end

      def revenue_for(route, stops)
        revenue = super

        # Diesels double normal revenue
        revenue *= 2 if route.train.name.end_with?('D')

        route.corporation.abilities(:hexes_bonus) do |ability|
          revenue += stops.map { |s| s.hex.id }.uniq.sum { |id| ability.hexes.include?(id) ? ability.amount : 0 }
        end

        revenue
      end

      def routes_revenue(routes)
        active_step.current_entity.trains.each do |t|
          next unless t.name == "#{@turn}+"

          # Trains that are going to be salvaged at the end of this OR
          # cannot be sold when they have been run
          t.buyable = false
        end

        super
      end

      def event_remove_tokens!
        @corporations.each do |corporation|
          corporation.abilities(:hexes_bonus) do |a|
            bonus_hex = @hexes.find { |h| a.hexes.include?(h.name) }
            hex_name = bonus_hex.name
            corporation.remove_ability(a)

            @log << "Route bonus is removed from #{get_location_name(hex_name)} (#{hex_name})"
          end
        end
      end

      def upgrades_to?(from, to, _special = false)
        # Only allow tile gray tile (446) in Montgomery (E11) or Birmingham (C9)
        return to.name == '446' if from.color == :brown && HEXES_FOR_GRAY_TILE.include?(from.hex.name)

        # Only allow tile Mobile City brown tile in Mobile City hex (H6)
        return to.name == 'X31b' if from.color == :green && from.hex.name == 'H6'

        super
      end

      def all_potential_upgrades(tile, tile_manifest: false)
        upgrades = super

        return upgrades unless tile_manifest

        # Tile manifest for tile 15 should show brown Mobile City as a potential upgrade
        upgrades |= [@mobile_city_brown] if @mobile_city_brown && tile.name == '15'

        # Tile manifest for tile 63 should show 446 as a potential upgrade
        upgrades |= [@gray_tile] if @gray_tile && tile.name == '63'

        upgrades
      end

      def float_corporation(corporation)
        @recently_floated << corporation

        super
      end

      def tile_lays(entity)
        return super unless @recently_floated.include?(entity)

        [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
      end

      def add_free_train(corporation)
        @free_train.buyable = true
        corporation.buy_train(@free_train, :free)
        @free_train.buyable = false
        @log << "#{corporation.name} receives a bonus non sellable #{@free_train.name} train"
      end

      def get_location_name(hex_name)
        @hexes.find { |h| h.name == hex_name }.location_name
      end

      def remove_icons(hex_to_clear)
        @hexes
          .select { |hex| hex_to_clear == hex.name }
          .each { |hex| hex.tile.icons = [] }
      end

      def president_assisted_buy(corporation, train, price)
        # Can only assist if corporation cannot afford the train, but can pay at least 50%.
        # Corporation also need to own at least one train, and the train need to be permanent.
        if corporation.trains.size.positive? &&
          !train.name.include?('+') &&
          corporation.cash >= price / 2 &&
          price > corporation.cash

          fee = 50
          president_assist = price - corporation.cash
          return [president_assist, fee] unless corporation.owner.cash < president_assist + fee
        end

        super
      end

      private

      def rust(train, salvage)
        rusted_trains = trains.select { |t| !t.rusted && t.name == train }
        return if rusted_trains.empty?

        rusted_trains.each do |t|
          @bank.spend(salvage, t.owner) if t.buyable
          t.rust!
        end

        @log << "-- Event: #{rusted_trains.map(&:name).uniq.join(', ')} trains rust --"
        exception = train == '2+' ? ' (except any free 2+ train)' : ''
        @log << "Corporations salvages #{format_currency(salvage)} from each rusted train#{exception}"
      end
    end
  end
end
