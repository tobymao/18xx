# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'market'
require_relative 'trains'
require_relative '../base'

module Engine
  module Game
    module G18EU
      class Game < Game::Base
        include_meta(G18EU::Meta)
        include G18EU::Map
        include G18EU::Entities
        include G18EU::Market
        include G18EU::Trains
        include CitiesPlusTownsRouteDistanceStr

        attr_accessor :corporations_operated

        HOME_TOKEN_TIMING = :par
        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true
        TOKENS_FEE = 100

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
            'minor_exchange' => [
              'Minor Exchange',
              'Conduct the Minor Company Final Exchange Round immediately prior to the next Stock Round.',
            ],
          ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'minor_limit_two' => [
            'Minor Train Limit: 2',
            'Minor companies are limited to owning 2 trains.',
          ],
          'minor_limit_one' => [
            'Minor Train Limit: 1',
            'Minor companies are limited to owning 1 train.',
          ],
          'normal_formation' => [
            'Full Capitalization',
            'Corporations may be formed without exchanging a minor, selecting any open city. '\
            'The five remaining shares are placed in the bank pool, with the par price paid '\
            'to the corporation.',
          ]
        ).freeze

        RED_TO_RED_BONUS = {
          '2' => [0, 0],
          '3' => [10, 10],
          '4' => [10, 10],
          '5' => [20, 80],
          '6' => [20, 80],
          '8' => [30, 150],
        }.freeze

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
          @corporations_operated = []
        end

        # this could be a useful function in depot itself
        def add_optional_train(type)
          modified_trains = @depot.trains.select { |t| t.name == type }
          new_train = modified_trains.first.clone
          new_train.index = modified_trains.size
          @depot.add_train(new_train)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def init_round
          Round::Auction.new(self, [G18EU::Step::ModifiedDutchAuction])
        end

        def exchange_for_partial_presidency?
          false
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            G18EU::Step::Bankrupt,
            G18EU::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18EU::Step::Dividend,
            G18EU::Step::BuyTrain,
            G18EU::Step::IssueShares,
            G18EU::Step::DiscardTrain,
          ], round_num: round_num)
        end

        def stock_round
          Round::Stock.new(self, [
            G18EU::Step::DiscardTrain,
            G18EU::Step::HomeToken,
            G18EU::Step::ReplaceToken,
            G18EU::Step::BuySellParShares,
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

        def must_buy_train?(entity)
          return false if entity.minor?

          super
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

        def route_ends_red?(stops)
          return false unless stops.size > 1

          stops.first.hex.tile.color == :red && stops.last.hex.tile.color == :red
        end

        def revenue_for_red_to_red_bonus(route, stops)
          return 0 unless route_ends_red?(stops)

          per_token, max_bonus = RED_TO_RED_BONUS[@phase.name]
          [stops.sum do |stop|
            next per_token if stop.city? && stop.tokened_by?(route.train.owner)

            0
          end, max_bonus].min
        end

        def revenue_for(route, stops)
          super + revenue_for_red_to_red_bonus(route, stops)
        end

        def revenue_str(route)
          str = super

          bonus = revenue_for_red_to_red_bonus(route, route.stops)
          str += " + R2R(#{bonus})" if bonus.positive?

          str
        end

        def check_other(route)
          city_hexes = route.stops.map do |stop|
            next unless stop.city?

            stop.tile.hex
          end.compact

          raise GameError, 'Cannot stop at Paris/Vienna/Berlin twice' if city_hexes.size != city_hexes.uniq.size
        end

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
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        def owns_any_minor?(entity)
          @minors.find { |minor| minor.owner == entity }
        end

        def can_par?(corporation, entity)
          return super if @phase.status.include?('normal_formation')
          return false unless owns_any_minor?(entity)

          super
        end

        def all_free_hexes(corporation)
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        # The player will swap one of their minors tokens for the major home token
        # This gets the list of cities where their minors have tokens
        def all_minor_cities(corporation)
          @minors.map do |minor|
            next unless minor.owner == corporation.owner

            # only need to use first since minors have one token
            minor.tokens.first.city
          end.compact
        end

        def all_minor_hexes(corporation)
          all_minor_cities(corporation).map(&:hex)
        end

        def home_token_locations(corporation)
          return all_free_hexes(corporation) if @minors.empty?

          all_minor_hexes(corporation)
        end

        def exchange_corporations(exchange_ability)
          return super if !exchange_ability.owner.minor? || @loading

          parts = graph.connected_nodes(exchange_ability.owner).keys
          connected = parts.select(&:city?).flat_map { |c| c.tokens.compact.map(&:corporation) }

          minor_tile = exchange_ability.owner.tokens.first.city.tile
          colocated = corporations.select do |c|
            c.tokens.any? { |t| t.city&.tile == minor_tile }
          end

          (connected + colocated).uniq
        end

        def after_par(corporation)
          @log << "#{corporation.name} spends #{format_currency(TOKENS_FEE)} for four additional tokens"

          corporation.spend(TOKENS_FEE, @bank)
        end
      end
    end
  end
end
