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
        SELL_AFTER = :operate
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
          setup_double_shares
          @minors.each do |minor|
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)

            Array(minor.coordinates).each { |coordinates| hex_by_id(coordinates).tile.cities[0].add_reservation!(minor) }
          end
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
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

        def after_buying_train(train, source)
          # if it is a 4D from the depot (not discard, event time)
          event_scl_formation_chance! if train.variant['name'] == '4D' && source == @depot && !@depot.discarded.include?(train)
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

        def can_go_bankrupt?(player, corporation)
          if @round.merge_presidency_cash_crisis_player
            # Normal train bankruptcy check, except for SCL/ICG formation
            total_emr_buying_power(player, corporation).negative?
          else
            total_emr_buying_power(player, corporation) < @depot.min_depot_price
          end
        end

        # OR Stuff
        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
          G18Dixie::Step::Bankrupt,
          Engine::Step::Bankrupt,
          G18Dixie::Step::HomeToken,
          Engine::Step::Exchange,
          Engine::Step::SpecialTrack,
          G18Dixie::Step::RemoveTokens,
          Engine::Step::BuyCompany,
          Engine::Step::Track,
          Engine::Step::Token,
          Engine::Step::Route,
          G18Dixie::Step::Dividend,
          Engine::Step::DiscardTrain,
          # ICG/SCL Merger!
          G18Dixie::Step::MergeConsent,
          G18Dixie::Step::PresidencyShareExchange,
          G18Dixie::Step::OptionShare,
          # normal stuff
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
          corporation.coordinates && hexes.select { |hex| corporation.coordinates.include?(hex.coordinates) }
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

        def setup_double_shares
          [icg, scl].each { |corp| corp.shares.last.double_cert = true }
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

        def can_par?(corporation, parrer)
          if corporation == sr
            @round.companies_pending_par.index(sr_company)
          elsif corporation == wra
            @round.companies_pending_par.index(wra_company)
          else
            super
          end
        end

        def sr_company
          @p6 ||= company_by_id('P6')
        end

        def sr
          @sr ||= corporation_by_id('SR')
        end

        def wra_company
          @p10 ||= company_by_id('P10')
        end

        def wra
          @wra ||= corporation_by_id('WRA')
        end

        # ICG/SCL merger stuff
        def ic
          @ic ||= corporation_by_id('IC')
        end

        def frisco
          @frisco ||= corporation_by_id('Fr')
        end

        def icg
          @icg ||= corporation_by_id('ICG')
        end

        def sal
          @sal ||= corporation_by_id('SAL')
        end

        def acl
          @acl ||= corporation_by_id('ACL')
        end

        def scl
          @scl ||= corporation_by_id('SCL')
        end

        def close_merger_corp(merger_corp)
          @log << "-- Event: #{merger_corp.name} fails to form --"
          merger_corp.close!
        end

        # If either of the input corporations haven't floated or operated yet, the merger automatically fails
        def merger_precheck(primary_corp, secondary_corp, merger_corp)
          if merger_corp.closed?
            @log << "#{merger_corp.name} is already removed from the game and fails to form"
            return false
          end
          unfloated_input_corp = [primary_corp, secondary_corp].find { |c| !c.floated? }
          unoperated_input_corp = [primary_corp, secondary_corp].find { |c| !c.operated? }
          return true if !unfloated_input_corp && !unoperated_input_corp

          @log << "-- #{unfloated_input_corp.name} has not floated so #{merger_corp.name} cannot form --" if unfloated_input_corp
          if unoperated_input_corp
            @log << "-- #{unoperated_input_corp.name} has not operated so #{merger_corp.name} cannot form --"
          end
          close_merger_corp(merger_corp)
          false
        end

        # Determine the eligibility of the merger, and either kick it off or close the merger corp
        def merger_consent_check(primary_corp, secondary_corp, merger_corp, subsidy)
          return unless merger_precheck(primary_corp, secondary_corp, merger_corp)

          # Since the merger didn't automatically fail, it is up to the presidents to decide
          @round.merge_consent_merging_corp = merger_corp
          @round.merge_consent_primary_corp = primary_corp
          @round.merge_consent_secondary_corp = secondary_corp
          @round.merge_consent_pending_corps << primary_corp
          @round.merge_consent_pending_corps << secondary_corp if primary_corp.owner != secondary_corp.owner
          @round.merge_consent_subsidy = subsidy
        end

        def other_merger_corp(merger_corp)
          merger_corp == scl ? icg : scl
        end

        def merger_price(merging_corps)
          # Putting the value, lower, and upper bounds in an array, sorting, and taking the new middle value
          #  is a pretty easy & lazy way to get the "capped" value. Sorting an array of length 3 is also pretty quick
          merger_value = [90, merging_corps.sum { |c| c.share_price.price }, 140].sort[1]
          # The 'highest stock value that does not exceed this sum'
          # Search from right to left (highest to lowest), take the first that does not exceed and call it a day
          @stock_market.market[0].reverse.find { |p| p.price <= merger_value }
        end

        def ipo_merger_corp(primary_corp, secondary_corp, merger_corp)
          merger_value = merger_price([primary_corp, secondary_corp])
          @stock_market.set_par(merger_corp, merger_value)
          @log << "#{merger_corp.name} IPOs at #{merger_value.price}"
        end

        def start_merge(primary_corp, secondary_corp, merger_corp, subsidy)
          @log << "-- Event: #{primary_corp.name} and #{secondary_corp.name} merge to form #{merger_corp.name} --"
          ipo_merger_corp(primary_corp, secondary_corp, merger_corp)
          close_merger_corp(other_merger_corp(merger_corp))

          @log << "Bank gives #{merger_corp.name} a #{format_currency(subsidy)} subsidy"
          @bank.spend(subsidy, merger_corp)

          exchange_presidencies(primary_corp, secondary_corp, merger_corp)
        end

        def all_players_exchange_share_pairs(primary_corp, secondary_corp, merger_corp)
          president = merger_corp.owner
          index_for_trigger = @players.index(president)
          # This is based off the code in 18MEX; 10 appears to be an arbitrarily large integer
          #  where the exact value doesn't really matter
          total_shares_by_player = {}
          [primary_corp, secondary_corp].each do |corp|
            corp.player_share_holders.each do |player, num|
              total_shares_by_player[player] ||= 0
              total_shares_by_player[player] += num
            end
          end
          awarded_shares_by_player = {}
          half_shares_by_player = {}
          total_shares_by_player.each do |player, percentage|
            num = percentage / 10
            if num.odd?
              half_shares_by_player[player] = 1
              num -= 1
            end
            awarded_shares_by_player[player] = num / 2
          end
          order = @players.rotate(index_for_trigger)
          order.each { |p| award_shares(merger_corp, p, awarded_shares_by_player[p] || 0) }

          sell_price = (merger_corp.share_price.price / 2).floor
          buy_price = (merger_corp.share_price.price / 2).ceil

          order = @players.rotate(@players.index(merger_corp.owner))
          order.each do |player|
            next unless half_shares_by_player[player]

            @round.pending_options << {
              entity: player,
              corporation: merger_corp,
              primary_corp: primary_corp,
              secondary_corp: secondary_corp,
              sell_price: sell_price,
              buy_price: buy_price,
            }
          end
          after_option_choice(primary_corp, secondary_corp, merger_corp)
        end

        def after_par(corporation)
          super
          return unless [wra, sr].find(corporation)

          bundle = ShareBundle.new(corporation.shares_of(corporation).slice(0, 3))
          @share_pool.buy_shares(@share_pool, bundle, exchange: :free, exchange_price: 0, allow_president_change: false)
        end

        def after_option_choice(primary_corp, secondary_corp, merger_corp)
          return unless @round.pending_options.empty?

          # shares are done being exchanged; final cleanup
          # all remaining icg/scl shares go to pool
          @share_pool.transfer_shares(ShareBundle.new(merger_corp.shares_of(merger_corp)), @share_pool)

          @log << "#{merger_corp.name} gets the cash from #{primary_corp.name} and #{secondary_corp.name}"
          primary_corp.spend(primary_corp.cash, merger_corp) if primary_corp.cash.positive?
          secondary_corp.spend(secondary_corp.cash, merger_corp) if secondary_corp.cash.positive?

          @log << "#{merger_corp.name} gets the trains from #{primary_corp.name} and #{secondary_corp.name}"
          [primary_corp, secondary_corp].each do |corp|
            corp.trains.dup.each { |t| buy_train(merger_corp, t, :free) }
            hexes.each do |hex|
              hex.tile.cities.each do |city|
                if city.tokened_by?(corp)
                  city.tokens.map! { |token| token&.corporation == corp ? nil : token }
                  city.reservations.delete(corp)
                end
              end
            end
          end

          @log << "#{merger_corp.name} gets the tokens from #{primary_corp.name} and #{secondary_corp.name}"
          merger_token_swap(primary_corp, secondary_corp, merger_corp)
          [primary_corp, secondary_corp].each { |corp| close_corporation(corp) }
        end

        # Creates and returns a token for the merger_corp
        def create_merger_corp_token(merger_corp, token_price)
          token = Engine::Token.new(merger_corp, price: token_price)
          merger_corp.tokens << token
          token
        end

        def remove_duplicate_tokens(merger_corp, corp)
          cities = Array(corp).flat_map(&:tokens).map(&:city).compact
          merger_corp.tokens.select { |t| cities.include?(t.city) }.each(&:destroy!)
        end

        def replace_token(merger_corp, major, major_token, merger_corp_token)
          city = major_token.city
          @log << "#{major.name}'s token in #{city.hex.name} is replaced with a #{merger_corp.name} token"
          major_token.remove!
          city.place_token(merger_corp, merger_corp_token, check_tokenable: false)
        end

        def merger_token_swap(primary_corp, secondary_corp, merger_corp)
          tokens_to_keep = 6
          token_cost = 100

          [primary_corp, secondary_corp].each do |corp|
            corp.tokens.each do |token|
              next if !token.used || !token.city

              remove_duplicate_tokens(merger_corp, corp)
              merger_corp_token = create_merger_corp_token(merger_corp, token_cost)
              merger_corp_token.price = 0
              replace_token(merger_corp, corp, token, merger_corp_token)
            end
          end
          return unless merger_corp.tokens.count(&:used) > tokens_to_keep

          @log << "-- #{merger_corp.name} is above token transfer limit (#{tokens_to_keep}) "\
                  ' and must decide which tokens to remove --'
          # This will be resolved in RemoveTokens
          @round.pending_removals << {
            corp: merger_corp,
            count: merger_corp.tokens.count(&:used) - tokens_to_keep,
            hexes: merger_corp.tokens.map(&:hex),
          }
        end

        # just a basic share move without payment or president change
        #
        def transfer_share(share, new_owner)
          corp = share.corporation
          corp.share_holders[share.owner] -= share.percent
          corp.share_holders[new_owner] += share.percent
          share.owner.shares_by_corporation[corp].delete(share)
          new_owner.shares_by_corporation[corp] << share
          share.owner = new_owner
        end

        def award_shares(corp, player, num)
          return unless num.positive?

          @log << "#{player.name} exchanges for #{num} shares of #{corp.name}"
          num.times { @share_pool.buy_shares(player, corp.shares_by_corporation[corp].last, exchange: :free, exchange_price: 0) }
        end

        def exchange_presidencies(primary_corp, secondary_corp, merger_corp)
          # Setup
          @round.merge_presidency_exchange_merging_corp = merger_corp
          @round.merge_presidency_exchange_corps = [primary_corp, secondary_corp]
          @round.merge_presidency_exchange_subsidy = @round.merge_consent_subsidy
          # Kick off presidency exchange
          try_exchange_for_merger_presidency(primary_corp, secondary_corp, merger_corp)
        end

        def try_exchange_for_merger_presidency(primary_corp, secondary_corp, merger_corp)
          president = primary_corp.owner
          @log << "#{president.name} exchanges 40% combined shares of " \
                  " #{primary_corp&.name} and #{secondary_corp&.name} for #{merger_corp&.name}'s presidency"
          if try_double_share_exchange(primary_corp, secondary_corp, merger_corp, president, merger_corp.shares.first)
            try_exchange_for_merger_20_share(primary_corp, secondary_corp, merger_corp)
          else
            @round.merge_presidency_cash_crisis_corp = primary_corp
            @round.merge_presidency_cash_crisis_player = president
          end
        end

        def try_exchange_for_merger_20_share(primary_corp, secondary_corp, merger_corp)
          president = secondary_corp.owner
          @log << "#{president.name} exchanges 40% combined shares of " \
                  " #{primary_corp&.name} and #{secondary_corp&.name} for #{merger_corp&.name}'s double share"
          if try_double_share_exchange(primary_corp, secondary_corp, merger_corp, president, merger_corp.shares.last)
            finish_exchanges
          else
            @round.merge_presidency_cash_crisis_corp = secondary_corp
            @round.merge_presidency_cash_crisis_player = president
          end
        end

        def finish_exchanges(primary_corp, secondary_corp, merger_corp)
          @log << 'Presidency exchanges done'
          all_players_exchange_share_pairs(primary_corp, secondary_corp, merger_corp)
        end

        # Return true if exchange was done automatically, return false if intervention is needed
        def try_double_share_exchange(primary_corp, secondary_corp, merger_corp, president, exchange_share)
          @share_pool.buy_shares(president, exchange_share, exchange: :free, exchange_price: 0)
          shares_to_exchange = 4
          # exchange presidency certificates first to make the later 2-for-1 share swap step easier
          [primary_corp, secondary_corp].each do |corp|
            president.shares_of(corp).dup.each do |share|
              next unless share&.president

              @log << "#{president.name} exchanges #{corp.name}'s president's certificate"
              share.transfer(corp)
              shares_to_exchange -= 2
            end
          end
          return true if shares_to_exchange.zero?

          # The player still has to exchange shares, now try 10% shares of the primary
          president.shares_of(primary_corp).dup.each do |share|
            next if share.president

            @log << "#{president.name} exchanges a 10% share of #{primary_corp.name}"
            share.transfer(primary_corp)
            shares_to_exchange -= 1
            return true if shares_to_exchange.zero?
          end

          # The player still has to exchange shares, finally try 10% shares of the secondary
          president.shares_of(secondary_corp).dup.each do |share|
            # If the player is president of the other corp, then they'll get a chance to exchange this later.
            next if share.president

            @log << "#{president.name} exchanges a 10% share of #{secondary_corp.name}"
            share.transfer(secondary_corp)
            shares_to_exchange -= 1
            return true if shares_to_exchange.zero?
          end

          # The player has a share shortfall and has to pay a penalty of merger_corp's market price _for_each_share_short_
          penalty = shares_to_exchange * merger_corp.share_price.price
          @log << "#{president.name} is short #{shares_to_exchange} exchange shares" \
                  " and must immediately pay a penalty of #{format_currency(penalty)} to the bank"
          president.spend(penalty, @bank, check_cash: false)
          false
        end

        def event_icg_formation_chance!
          @log << '-- Event: ICG Formation opportunity --'
          merger_consent_check(ic, frisco, icg, 200)
        end

        def event_scl_formation_chance!
          @log << '-- Event: SCL Formation opportunity -- '
          merger_consent_check(sal, acl, scl, 100)
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
