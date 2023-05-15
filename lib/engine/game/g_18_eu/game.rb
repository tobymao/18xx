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

        attr_accessor :corporations_operated, :minor_exchange, :minor_exchange_priority

        EBUY_OTHER_VALUE = true # allow ebuying other corp trains for up to face
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = true # if ebuying from depot, must buy cheapest train
        EBUY_CAN_SELL_SHARES = true # true if a player can sell shares for ebuy

        HOME_TOKEN_TIMING = :par
        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true
        TOKENS_FEE = 100

        BIDDING_BOX_MINOR_COLOR = '#c6e9af'

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or }.freeze

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
          end

          add_optional_train('3') if @optional_rules&.include?(:extra_three_train)
          add_optional_train('3') if @optional_rules&.include?(:second_extra_three_train)
          add_optional_train('4') if @optional_rules&.include?(:extra_four_train)

          @minor_exchange = nil
          @corporations_operated = []

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

          city_by_id('G2-0-0').place_token(neutral, neutral.next_token)
        end

        def add_optional_train(type)
          proto = self.class::TRAINS.find { |e| e[:name] == type }
          index = @depot.trains.count { |t| t.name == type }
          upcoming_index = @depot.upcoming.find_index { |t| t.name == type }
          new_train = Train.new(**proto, index: index)
          @depot.insert_train(new_train, upcoming_index + index)
          update_cache(:trains)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def reservation_corporations
          minors
        end

        def init_round
          Engine::Round::Auction.new(self, [G18EU::Step::ModifiedDutchAuction])
        end

        def exchange_for_partial_presidency?
          false
        end

        def available_programmed_actions
          super << Action::ProgramAuctionBid
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G18EU::Step::Bankrupt,
            G18EU::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18EU::Step::Dividend,
            G18EU::Step::OptionalDiscardTrain,
            G18EU::Step::BuyTrain,
            G18EU::Step::IssueShares,
            Engine::Step::DiscardTrain,
          ], round_num: round_num)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18EU::Step::HomeToken,
            G18EU::Step::ReplaceToken,
            G18EU::Step::BuySellParShares,
          ])
        end

        def new_minor_exchange_round
          @log << '-- Minor Company Final Exchange --'
          G18EU::Round::FinalExchange.new(self, [
            G18EU::Step::ReplaceToken,
            G18EU::Step::FinalExchange,
          ])
        end

        # I don't like duplicating all of this just to add the minor exchange round, but
        # it requires refactoring the base code to be any cleaner
        def next_round!
          @round =
            case @round
            when G18EU::Round::FinalExchange
              new_stock_round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
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
          @minor_exchange_priority = @round.current_operator.owner
        end

        def player_card_minors(player)
          @minors.select { |m| m.owner == player }
        end

        def all_corporations
          @minors + @corporations
        end

        def place_home_token(corporation)
          return if corporation.placed_tokens.any?

          super
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

        def emergency_issuable_bundles(_entity)
          []
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

        def float_corporation(corporation)
          super

          return unless @phase.status.include?('normal_formation')

          bundle = Engine::ShareBundle.new(corporation.treasury_shares)
          @bank.spend(bundle.price, corporation)
          @share_pool.transfer_shares(bundle, @share_pool)
          @log << "#{corporation.name} places remaining shares on the Market for #{format_currency(bundle.price)}"
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
          return corporations if @loading
          return super unless exchange_ability.owner.minor?

          minor_tile = exchange_ability&.owner&.tokens&.first&.city&.tile
          return [] unless minor_tile

          parts = graph.connected_nodes(exchange_ability.owner).keys
          connected = parts.select(&:city?).flat_map { |city| city.tokens.compact.map(&:corporation) }

          colocated = corporations.select do |c|
            c.tokens.any? { |t| t.city&.tile == minor_tile }
          end

          (connected + colocated).uniq.reject(&:minor?)
        end

        def after_par(corporation)
          @log << "#{corporation.name} spends #{format_currency(TOKENS_FEE)} for four additional tokens"

          corporation.spend(TOKENS_FEE, @bank)
        end

        def check_overlap(routes)
          super

          pullman_stop = routes.find { |r| pullman?(r.train) }&.visited_stops&.first
          return unless pullman_stop

          raise GameError, 'Pullman cannot be run alone' if routes.one?

          matching_stop = routes.find do |r|
            next if pullman?(r.train)

            r.visited_stops.include?(pullman_stop)
          end

          raise GameError, "Pullman must reuse another route's city or off-board" unless matching_stop
        end

        def check_route_token(route, token)
          return if pullman?(route.train)

          super
        end

        def check_connected(route, corporation)
          return if pullman?(route.train)

          super
        end

        def pullman?(train)
          train.name == 'P'
        end

        def owns_pullman?(entity)
          entity.trains.find { |t| pullman?(t) }
        end

        def rust_trains!(train, entity)
          super

          all_corporations.each { |c| maybe_discard_pullman(c) }
        end

        def maybe_discard_pullman(entity)
          pullman = owns_pullman?(entity)
          return unless pullman

          trains = self.class::OBSOLETE_TRAINS_COUNT_FOR_LIMIT ? entity.trains.size : entity.trains.count { |t| !t.obsolete }
          return if trains > 1 && trains <= train_limit(entity)

          depot.reclaim_train(pullman)
          @log << "#{entity.name} is forced to discard pullman train"
        end

        def depot_trains(entity)
          has_pullman = owns_pullman?(entity)
          has_train = entity.trains.empty?
          @depot.depot_trains.reject do |t|
            pullman?(t) && (has_train || has_pullman)
          end
        end

        def min_depot_train(entity)
          depot_trains(entity).min_by(&:price)
        end

        def min_depot_price(entity)
          return 0 unless (train = min_depot_train(entity))

          train.variants.map { |_, v| v[:price] }.min
        end

        def can_go_bankrupt?(player, corporation)
          total_emr_buying_power(player, corporation) < min_depot_price(corporation)
        end

        def maybe_remove_duplicate_token!(tile)
          tile.cities.each do |city|
            prev = nil
            city.tokens.compact.sort_by { |t| t.corporation.name }.each do |token|
              if prev&.corporation == token.corporation
                prev.remove!
                @log << "#{token.corporation.name} redundant token removed from #{tile.hex.name}"
              end
              prev = token
            end
          end
        end

        def hex_blocked_by_ability?(entity, ability, hex, _tile = nil)
          return false unless hex.tile.color == :white
          return false if entity&.owner == ability&.owner&.owner

          super
        end

        def mark_auctioning(minor)
          minor.reservation_color = self.class::BIDDING_BOX_MINOR_COLOR
        end
      end
    end
  end
end
