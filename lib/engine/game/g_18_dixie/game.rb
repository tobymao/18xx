# frozen_string_literal: true

require_relative 'meta'
require_relative 'corporations'
require_relative 'tiles'
require_relative 'map'
require_relative 'market'
require_relative 'phases'
require_relative 'trains'
require_relative 'minors'
require_relative 'companies'
require_relative '../base'
require_relative '../../share_bundle'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G18Dixie
      class Game < Game::Base
        include_meta(G18Dixie::Meta)
        include G18Dixie::Tiles
        include G18Dixie::Map
        include G18Dixie::Market
        include G18Dixie::Phases
        include G18Dixie::Trains
        include G18Dixie::Companies
        include G18Dixie::Minors
        include G18Dixie::Corporations

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')

        include CitiesPlusTownsRouteDistanceStr

        # General Constants
        BANK_CASH = 12_000
        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12, 6 => 11 }.freeze
        CURRENCY_FORMAT_STR = '$%s'
        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :full_or }.freeze
        EVENTS_TEXT = Base::EVENTS_TEXT.merge({
                                                'scl_formation_chance' => ['SCL may form',
                                                                           'SCL may form on purchase of first 4D '\
                                                                           'if ICG not formed'],
                                                'icg_formation_chance' => ['ICG may form',
                                                                           'ICG may form on purchase of first 5D '\
                                                                           'if SCL not formed'],
                                              }).freeze
        SELL_BUY_ORDER = :sell_buy_sell
        STARTING_CASH = { 3 => 700, 4 => 525, 5 => 425, 6 => 375 }.freeze
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        TRACK_RESTRICTION = :permissive
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        # OR Constants
        FIRST_TURN_EXTRA_TILE_LAYS = [{ lay: true, upgrade: false }].freeze
        MAJOR_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze
        MINOR_TILE_LAYS = [{ lay: true, upgrade: true }].freeze

        def setup
          @recently_floated = []
          setup_preferred_shares
          @minors.each do |minor|
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)

            Array(minor.coordinates).each { |coordinates| hex_by_id(coordinates).tile.cities[0].add_reservation!(minor) }
          end
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18Dixie::Step::SelectionAuction,
          ])
        end

        def player_card_minors(player)
          minors.select { |m| m.owner == player }
        end

        def init_round_finished
          [M1_SYM, M2_SYM, M3_SYM, M4_SYM, M5_SYM, M6_SYM, M7_SYM, M8_SYM, M9_SYM, M10_SYM, M11_SYM, M12_SYM]
              .each { |m_id| make_minor_available(m_id) }
          first_player = %w[P1 P2 P3 P4 P5 P6 P7].filter_map { |p_id| company_by_id(p_id).owner }.first
          @log << "#{first_player.name} bought the lowest numbered private"
          @round.goto_entity!(first_player)
        end

        def timeline
          @timeline = [
            'End of ISR: Highest numbered remaining private is permanently closed',
            'SR1: Unsold ISR private companies* are available, Minors 1-12 are available for purcahse ',
            'End of OR 1.2: All unsold 2 trains are put in the open market',
            'SR2: Private companies 8-10 are available for auction Minor 13 is now available for purchase from the bank',
            'End of OR 2.1: Minors 1-4 are closed',
            'End of OR 2.2: Minors 5-8 are closed. Unsold private companies are put into open market for purchase in SR3',
            'End of SR3: All unsold Minors and Privates are closed',
            'End of OR 3.1: Minors 9-13 are closed',
          ].freeze
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              # Store the share price of each corp to determine if they can be acted upon in the AR
              @stock_prices_start_merger = @corporations.to_h { |corp| [corp, corp.share_price] }

              if closing_minors
                @log << "-- #{round_description('Minor Exchanges', @round.round_num)} --"
                G18Dixie::Round::Merger.new(self, [
                  G18Dixie::Step::Conversion,
                ], round_num: @round.round_num)
              elsif @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_stock_round
              end
            when G18Dixie::Round::Merger
              # 18Dixie merger round handles minor mergers ("closures / share exchanges")
              closing_minors.each { |minor| close_unstarted_minor_maybe(minor) }
              release_preferred_shares if "#{@turn}.#{@round.round_num}" == '3.1'
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def ipo_reserved_name(_entity = nil)
          'IPO Preferred'
        end

        # OR Stuff
        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
          Engine::Step::Bankrupt,
          G18Dixie::Step::HomeToken,
          Engine::Step::Exchange,
          Engine::Step::SpecialTrack,
          Engine::Step::BuyCompany,
          Engine::Step::Track,
          Engine::Step::Token,
          Engine::Step::Route,
          G18Dixie::Step::Dividend,
          Engine::Step::DiscardTrain,
          Engine::Step::BuyTrain,
          [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def or_round_finished
          @recently_floated = []
          turn = "#{@turn}.#{@round.round_num}"
          # Turn is X.Y where X is from the *following* OR, and Y is from the *preceding* OR. :(
          case turn
          when '2.2'
            @depot.reclaim_all!('2')
            make_minor_available(M13_SYM)
            %w[P8 P9 P10].each { |company_id| add_private(company_by_id(company_id)) }
          when '3.2'
            %w[P8 P9 P10].each { |company_id| put_private_in_pool(company_by_id(company_id)) }
          end
        end

        def home_token_locations(corporation)
          hexes.select { |hex| corporation.coordinates.include?(hex.coordinates) }
        end

        def closing_minors
          turn = "#{@turn}.#{@round.round_num}"
          case turn
          when '2.1'
            return [M1_SYM, M2_SYM, M3_SYM, M4_SYM].map { |m_id| minor_by_id(m_id) }
          when '2.2'
            return [M5_SYM, M6_SYM, M7_SYM, M8_SYM].map { |m_id| minor_by_id(m_id) }
          when '3.1'
            return [M9_SYM, M10_SYM, M11_SYM, M12_SYM, M13_SYM].map { |m_id| minor_by_id(m_id) }
          end
          []
        end

        # the unstarted minor could be started & closed, hence, maybe
        def close_unstarted_minor_maybe(minor)
          return if minor.closed?

          @log << "Unstarted minor #{minor.name} is removed from the game"
          # Minors don't have cash until they run, so no cash to transfer
          # Minors don't have tokens until they first operate, so unstarted minors don't have home tokens to transfer

          company_by_id(minor.id).close!
          minor.close!
        end

        def tile_lays(entity)
          operator = entity.company? ? entity.owner : entity
          extra_tile_lays = @recently_floated&.include?(operator) ? FIRST_TURN_EXTRA_TILE_LAYS : []
          if operator.corporation?
            extra_tile_lays + MAJOR_TILE_LAYS
          elsif operator.minor?
            extra_tile_lays + MINOR_TILE_LAYS
          else
            super
          end
        end

        def operating_order
          corporations = @corporations.select(&:floated?)
          if @turn == 1 && (@round_num || 1) == 1
            corporations.sort_by! do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          else
            corporations.sort!
          end
          @minors.select(&:floated?) + corporations
        end

        def exchange_minor(minor, major)
          share = preferred_shares_by_major.to_h[major].find { |s| s.owner == major }
          share.buyable = true
          # Don't exchange presidency unless parred
          @share_pool.buy_shares(minor.owner, share, exchange: :free, allow_president_change: major.ipoed)
          close_minor(minor, major)
        end

        def close_minor(minor, _corporation)
          @log << "#{minor.name} closes"
          company_by_id(minor.id)&.close!
          minor.close!
        end

        # SR stuff
        def stock_round
          Engine::Round::Stock.new(self, [
          Engine::Step::DiscardTrain,
          Engine::Step::Exchange,
          Engine::Step::SpecialTrack,
          G18Dixie::Step::BuySellParShares,
          ])
        end

        def float_str(entity)
          return nil if entity == scl || entity == icg

          super
        end

        def share_flags(shares)
          return if shares.empty?

          'P' * shares.count(&:preferred)
        end

        def preferred_share_slices_by_major(m_id)
          {
            'ACL' => (8...9),
            'CoG' => (7...9),
            'Fr' => (7...9),
            'IC' => (7...9),
            'L&N' => (6...9),
            'SAL' => (8...9),
            'SR' => (7...9),
            'WRA' => (7...9),
          }.freeze[m_id]
        end

        def preferred_shares_by_major
          @preferred_shares_by_major ||= %w[ACL CoG Fr IC L&N SAL SR WRA].map do |c|
            [corporation_by_id(c), corporation_by_id(c).shares.slice(preferred_share_slices_by_major(c))]
          end
        end

        def setup_preferred_shares
          preferred_shares_by_major.each { |_corp, shares| shares.each { |s| setup_preferred_share(s) } }
        end

        def release_preferred_shares
          @log << 'Unclaimed preferred shares in IPO are put into the open market'
          preferred_shares_by_major.each { |corp, shares| shares.each { |s| release_preferred_share_maybe(s, corp) } }
        end

        # Release the share to the open market if it's still in IPO, otherwise do nothing
        def release_preferred_share_maybe(share, major)
          return unless share.owner == major

          # Don't exchange presidency unless parred
          share.buyable = true
          @share_pool.buy_shares(@share_pool, share, exchange: :free, allow_president_change: major.ipoed)
        end

        def setup_preferred_share(share)
          share.buyable = false
          share.preferred = true
        end

        def bidding_power(player)
          player.cash
        end

        def buyable_bank_owned_companies
          return super if !@round.respond_to?(:auctioning) || !@round.auctioning

          super.select { |c| @round.auctioning == c }
        end

        def sr_round_finished
          super
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end

        def make_minor_available(minor_id)
          minor_company = company_by_id(minor_id)
          minor_company.owner = @bank
          minor_company.add_ability(POOL_PRIVATE_ABILITY)
          @log << "Minor #{minor_id} is now available for purchase"
        end

        def add_private(entity)
          raise GameError "#{entity.name} is not a private" unless entity.company?

          @log << "#{entity.name} is available to be put up for auction"
          entity.owner = @bank
        end

        def must_auction_company?(company)
          !company.all_abilities.include?(POOL_PRIVATE_ABILITY)
        end

        def put_private_in_pool(entity)
          raise GameError "#{entity.name} is not a private" unless entity.company?

          auctionable_ability = entity.all_abilities.find { |a| a.description == AUCTIONABLE_PRIVATE_DESCRIPTION }
          entity.remove_ability(auctionable_ability) if auctionable_ability
          entity.add_ability(POOL_PRIVATE_ABILITY)
          @log << "#{entity.name} is available to be bought from the bank for face value"
          entity.owner = @bank
        end

        def float_minor(minor_id, owner)
          minor = minor_by_id(minor_id)
          minor.owner = owner
          minor.float!
          company_by_id(minor_id).close!
          @recently_floated << minor
        end

        # ICG/SCL merger stuff
        def icg
          @icg ||= corporation_by_id('ICG')
        end

        def scl
          @scl ||= corporation_by_id('SCL')
        end

        def event_icg_formation_chance!
          @log << '-- Event: ICG Formation opportunity --'
        end

        def event_scl_formation_chance!
          @log << '-- Event: SCL Formation opportunity -- '
        end

        # Train stuff
        def info_on_trains(phase)
          Array(phase[:on]).join(', ')
        end

        def give_spare_part_to_train(train)
          raise GameError "Permanent train #{train.name} cannot get a spare part" unless train.rusts_on

          train.name = train.name + SPARE_PART_CHAR
        end

        def obsolete?(train, purchased_train)
          train.rusts_on == purchased_train.sym && train.name.include?(SPARE_PART_CHAR)
        end

        def rust?(train, purchased_train)
          super && !train.name.include?(SPARE_PART_CHAR)
        end

        def remove_spare_part(train)
          return unless train.name[-1] == SPARE_PART_CHAR

          @log << "#{train.name} uses up a spare part"
          train.name = train.name[0..-2]
        end

        def rust(train)
          return if train.name[-1] == SPARE_PART_CHAR

          if train.owner.corporation? && train.salvage
            @bank.spend(train.salvage, train.owner)
            @log << "#{train.owner.name} gets #{format_currency(train.salvage)} salvage for rusted #{train.name} train"
          end

          super
        end
      end
    end
  end
end
