# frozen_string_literal: true

require_relative '../config/game/g_18_eu'
require_relative 'base'

module Engine
  module Game
    class G18EU < Base
      load_from_json(Config::Game::G18EU::JSON)

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'Europe'
      GAME_RULES_URL = 'http://www.deepthoughtgames.com/games/18EU/Rules.pdf'
      GAME_DESIGNER = 'David Hecht'
      GAME_PUBLISHER = nil
      GAME_IMPLEMENTER = 'R. Ryan Driskel'

      SELL_BUY_ORDER = :sell_buy
      SELL_AFTER = :operate
      HOME_TOKEN_TIMING = :float

      MIN_BID_INCREMENT = 5
      MUST_BID_INCREMENT_MULTIPLE = true

      FIRST_OR_MINOR_TILE_LAYS = [{ lay: true, upgrade: false }, { lay: true, upgrade: false }].freeze
      MINOR_TILE_LAYS = [{ lay: true, upgrade: false }].freeze
      TILE_LAYS = [{ lay: true, upgrade: true }].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'minor_exchane' => [
            'Minor Exchange',
            'Conduct the Minor Company Final Exchange Round immediately prior to the next Stock Round.',
          ],
        ).freeze

      OPTIONAL_RULES = [
        {
          sym: :extra_three_train,
          short_name: 'Extra 3 Train',
          desc: 'Players wishing to try the optional trains might add a single 3 train in the '\
                'four-player game, and either two 3 trains or a 3 train and the 4 train in the'\
                ' five or six-player game.',
        },
        {
          sym: :second_extra_three_train,
          short_name: 'Another Extra 3 Train',
          desc: 'See Extra 3 Train',
        },
        {
          sym: :extra_four_train,
          short_name: 'Extra 4 Train',
          desc: 'See Extra 3 Train',
        },
      ].freeze

      def setup
        @minors.each do |minor|
          train = @depot.upcoming[0]
          buy_train(minor, train, :free)
          hex = hex_by_id(minor.coordinates)
          city = minor.city.to_i || 0
          hex.tile.cities[city].place_token(minor, minor.next_token, free: true)
        end

        add_optional_train('3') if @optional_rules&.include?(:extra_three_train)
        add_optional_train('3') if @optional_rules&.include?(:second_extra_three_train)
        add_optional_train('4') if @optional_rules&.include?(:extra_four_train)

        @minor_exchange = nil
      end

      # this could be a useful function in depot itself
      def add_optional_train(type)
        modified_trains = @depot.trains.select { |t| t.name == type }
        new_train = modified_trains.first.clone
        new_train.index = copy_this_train.length
        @depot.add_train(new_train)
      end

      def ipo_name(_entity = nil)
        'Treasury'
      end

      def init_round
        Round::Auction.new(self, [Step::G18EU::ModifiedDutchAuction])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::G18EU::Bankrupt,
          Step::HomeToken,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::G18EU::Dividend,
          Step::G18EU::BuyTrain,
          Step::IssueShares,
          Step::G18EU::DiscardTrain,
        ], round_num: round_num)
      end

      def stock_round
        Round::Stock.new(self, [
          Step::G18EU::DiscardTrain,
          Step::G18EU::BuySellParShares,
        ])
      end

      def new_minor_exchange_round
        # TODO: Implement Minor Exchange Round
        @minor_exchange = :done
        new_stock_round
      end

      # I don't like duplicating all of this just to add the minor exchange round, but
      # it requires refactoring the base code to be any cleaner
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
              if @minor_exchange == :triggered
                new_minor_exchange_round
              else
                new_stock_round
              end
            end
          when init_round.class
            init_round_finished
            reorder_players
            new_operating_round(@round.round_num)
          end
      end

      def train_limit(entity)
        return super unless entity.minor?

        @phase.name.to_i > 3 ? 1 : 2
      end

      def tile_lays(entity)
        return FIRST_OR_MINOR_TILE_LAYS if entity.minor? && !entity.operated?
        return MINOR_TILE_LAYS if entity.minor?

        super
      end

      def event_minor_exchange!
        @log << '-- Event: Minor Exchange occurs before next Stock Round --'

        @minor_exchange = :triggered
      end

      def player_card_minors(player)
        @minors.select { |m| m.owner == player }
      end

      def all_corporations
        @minors + @corporations
      end

      def player_sort(entities)
        minors, majors = entities.partition(&:minor?)
        (minors.sort_by { |m| m.name.to_i } + majors.sort_by(&:name)).group_by(&:owner)
      end

      # def revenue_for(route, stops)
      # revenue = super

      # TODO: Token Bonus
      # TODO: Pullman Car

      # revenue
      # end

      # def revenue_str(route)
      # str = super

      # TODO: Token Bonus
      # TODO: Pullman Car

      # str
      # end

      def emergency_issuable_cash(corporation)
        emergency_issuable_bundles(corporation).max_by(&:num_shares)&.price || 0
      end

      def emergency_issuable_bundles(entity)
        issuable_shares(entity)
      end

      def issuable_shares(entity)
        return [] unless entity.corporation?
        return [] unless entity.num_ipo_shares

        bundles_for_corporation(entity, entity)
          .select { |bundle| @share_pool.fit_in_bank?(bundle) }
          .map { |bundle| reduced_bundle_price_for_market_drop(bundle) }
      end

      def redeemable_shares(entity)
        return [] unless entity.corporation?

        bundles_for_corporation(share_pool, entity)
          .reject { |bundle| entity.cash < bundle.price }
      end

      def reduced_bundle_price_for_market_drop(bundle)
        return bundle if bundle.num_shares == 1

        new_price = (1..bundle.num_shares).sum do |max_drops|
          @stock_market.find_share_price(bundle.corporation, (1..max_drops).map { |_| :up }).price
        end

        bundle.share_price = new_price / bundle.num_shares

        bundle
      end
    end
  end
end
