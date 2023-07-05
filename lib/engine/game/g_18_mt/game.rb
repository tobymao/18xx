# frozen_string_literal: true

require_relative 'meta'
require_relative 'corporations'
require_relative 'tiles'
require_relative 'map'
require_relative 'market'
require_relative 'phases'
require_relative 'trains'
require_relative 'companies'
require_relative 'share_pool'
require_relative '../base'
require_relative '../company_price_50_to_150_percent'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G18MT
      class Game < Game::Base
        include_meta(G18MT::Meta)
        include G18MT::Tiles
        include G18MT::Map
        include G18MT::Market
        include G18MT::Phases
        include G18MT::Trains
        include G18MT::Companies
        include G18MT::Corporations

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        lightBlue: '#a2dced',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a',
                        black: '#000000',
                        pink: '#FF0099',
                        purple: '#9900FF',
                        white: '#FFFFFF')
        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 8000

        CERT_LIMIT = { 3 => 13, 4 => 11, 5 => 9 }.freeze

        STARTING_CASH = { 3 => 450, 4 => 350, 5 => 300 }.freeze

        CAPITALIZATION = :incremental

        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = false

        SELL_BUY_ORDER = :sell_buy
        MUST_SELL_IN_BLOCKS = false
        NEXT_SR_PLAYER_ORDER = :first_to_pass
        MULTIPLE_BUY_ONLY_FROM_MARKET = true
        SELL_AFTER = :operate

        MUST_BUY_TRAIN = :always
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        EBUY_SELL_MORE_THAN_NEEDED = false
        EBUY_OTHER_VALUE = false

        CORPORATE_BUY_SHARE_SINGLE_CORP_ONLY = true
        CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT = true

        MAX_SHARE_VALUE = 485
        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :full_or }.freeze

        PLAIN_GREEN = %w[16 17 18 19 20 21 22].freeze

        EXTRA_TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: :not_if_upgraded, upgrade: false },
        ].freeze

        TILE_LAYS = [
          { lay: true, upgrade: true },
        ].freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'extra_tile_lays' => [
            'Extra Tile Lay',
            'A corporation may lay two yellow tiles',
          ],
          'corporate_shares_open' => [
            'Corporate Shares Open',
            'All corporate shares are available for any player to purchase',
          ]
        ).freeze

        include CompanyPrice50To150Percent
        include CitiesPlusTownsRouteDistanceStr

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def setup
          setup_company_price_50_to_150_percent
        end

        def init_share_pool
          G18MT::SharePool.new(self)
        end

        def next_sr_player_order
          return :after_last_to_act if round.auction?

          self.class::NEXT_SR_PLAYER_ORDER
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G18MT::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
          Engine::Step::Bankrupt,
          G18MT::Step::Takeover,
          Engine::Step::DiscardTrain,
          Engine::Step::HomeToken,
          Engine::Step::BuyCompany,
          G18MT::Step::RedeemShares, # TODO: Move to Module
          G18MT::Step::CorporateBuyShares,
          Engine::Step::SpecialTrack,
          G18MT::Step::Track,
          Engine::Step::Token,
          Engine::Step::Route,
          G18MT::Step::Dividend,
          G18MT::Step::SpecialBuyTrain,
          G18MT::Step::BuyTrain,
          Engine::Step::CorporateSellShares,
          G18MT::Step::IssueShares, # TODO: Refactor to Module
          [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def tile_lays(_entity)
          return EXTRA_TILE_LAYS if @phase.status.include?('extra_tile_lays')

          super
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return PLAIN_GREEN.include?(from.name) && special if to.name == 'mts'

          super
        end

        def company_bought(company, _buyer)
          remove_corporation_block(corporation_by_id('UP')) if company.sym == 'GP'
          remove_corporation_block(corporation_by_id('NP')) if company.sym == 'GV'
        end

        def event_close_companies!
          remove_corporation_block(corporation_by_id('UP'))
          remove_corporation_block(corporation_by_id('NP'))
          remove_corporation_block(corporation_by_id('GN'))
        end

        def close_companies_on_event!(entity, event)
          remove_corporation_block(corporation_by_id('GN')) if event == :bought_train && entity.name == 'MILW'

          super
        end

        # TODO: SHARED WITH 18CO - Move to Modules
        def check_distance(route, visits)
          super

          distance = route.train.distance

          return if distance.is_a?(Numeric)

          cities_allowed = distance.find { |d| d['nodes'].include?('city') }['pay']
          cities_visited = visits.count { |v| v.city? || v.offboard? }
          start_at_town = visits.first.town? ? 1 : 0
          end_at_town = visits.last.town? ? 1 : 0

          return unless cities_allowed < (cities_visited + start_at_town + end_at_town)

          raise GameError, 'Towns on route ends are counted against city limit.'
        end

        def revenue_for(route, stops)
          revenue = super

          revenue += east_west_bonus(stops)[:revenue]

          revenue
        end

        def east_west_bonus(stops)
          bonus = { revenue: 0 }

          east = stops.find { |stop| stop.groups.include?('W') }
          west = stops.find { |stop| stop.groups.include?('E') }

          if east && west
            bonus[:revenue] = 100
            bonus[:description] = 'E/W'
          end

          bonus
        end

        def revenue_str(route)
          str = super

          bonus = east_west_bonus(route.stops)[:description]
          str += " + #{bonus}" if bonus

          str
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          corporation = bundle.corporation
          old_price = corporation.share_price
          was_president = corporation.president?(bundle.owner)
          was_issued = bundle.owner == bundle.corporation

          @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
          share_drop_num = bundle.num_shares - (swap ? 1 : 0)

          return if !(was_president || was_issued) && share_drop_num == 1

          share_drop_num.times { @stock_market.move_down(corporation) }

          log_share_price(corporation, old_price) if self.class::SELL_MOVEMENT != :none
        end

        def buying_power(entity)
          entity.cash
        end

        def emergency_issuable_cash(corporation)
          emergency_issuable_bundles(corporation).max_by(&:num_shares)&.price || 0
        end

        def emergency_issuable_bundles(entity)
          return [] if entity.cash >= @depot.min_depot_price

          eligible, remaining = issuable_shares(entity)
            .partition { |bundle| bundle.price + entity.cash < @depot.min_depot_price }
          eligible.concat(remaining.take(1))
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

          new_price = (0..bundle.num_shares - 1).sum do |max_drops|
            @stock_market.find_share_price(bundle.corporation, (1..max_drops).map { |_| :down }).price
          end

          bundle.share_price = new_price / bundle.num_shares

          bundle
        end

        def soo
          @soo ||= company_by_id('SOO')
        end

        def player_value(player)
          value = player.value
          return value unless soo&.owner == player

          value - soo.value
        end

        def buy_train(operator, train, price = nil)
          return super unless train&.owner&.corporation?

          train.operated = false unless train.owner.operating_history[[turn, @round.round_num]]
          super
        end

        def train_limit(entity)
          super + Array(abilities(entity, :train_limit)).sum(&:increase)
        end

        private

        def remove_corporation_block(corporation)
          ability = corporation.all_abilities.find { |a| a.type == :description }
          return unless ability

          corporation.remove_ability(ability)
        end

        def available_programmed_actions
          super << Action::ProgramAuctionBid
        end
      end
    end
  end
end
