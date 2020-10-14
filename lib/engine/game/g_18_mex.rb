# frozen_string_literal: true

require_relative '../config/game/g_18_mex'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'
module Engine
  module Game
    class G18MEX < Base
      load_from_json(Config::Game::G18MEX::JSON)
      AXES = { x: :number, y: :letter }.freeze

      GAME_LOCATION = 'Mexico'
      GAME_RULES_URL = 'https://secure.deepthoughtgames.com/games/18MEX/rules.pdf'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18MEX'
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

      IPO_RESERVED_NAME = 'Trade-in shares'

      STANDARD_GREEN_CITY_TILES = %w[14 15 619].freeze
      CURVED_YELLOW_CITY = %w[5 6].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'minors_closed' => ['Minors closed', 'Minors closed, NdM becomes available for buy & sell during stock round'],
        'ndm_merger' => ['NdM merger', 'Potential NdM merger if NdM has floated']
      ).freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_companies_from_other_players' => ['Interplayer Company Buy', 'Companies can be bought between players']
      ).merge(
        Step::SingleDepotTrainBuy::STATUS_TEXT
      ).merge(
        'ndm_unavailable' => ['NdM unavailable', 'NdM shares unavailable during stock round'],
      ).freeze

      def p2_company
        @p2_company ||= company_by_id('KCMO')
      end

      def ndm
        @ndm_corporation ||= corporation_by_id('NdM')
      end

      def minor_a_reserved_share
        @minor_a_reserved_share ||= ndm.shares[7]
      end

      def minor_b_reserved_share
        @minor_b_reserved_share ||= ndm.shares[8]
      end

      def ndm_merge_share
        @ndm_merge_share ||= ndm.shares.last
      end

      def udy
        @udy_corporation ||= corporation_by_id('UdY')
      end

      def minor_c_reserved_share
        @minor_c_reserved_share ||= udy.shares.last
      end

      def minor_a
        @minor_a ||= minor_by_id('A')
      end

      def minor_b
        @minor_b ||= minor_by_id('B')
      end

      def minor_c
        @minor_c ||= minor_by_id('C')
      end

      # Set to 1 if no-one accepts NdM merge
      def cert_limit_adjust
        @cert_limit_adjust ||= 0
      end

      def cert_limit
        super + cert_limit_adjust
      end

      include CompanyPrice50To150Percent

      def setup
        setup_company_price_50_to_150_percent

        @minors.each do |minor|
          train = @depot.upcoming[0]
          train.buyable = false
          minor.cash = 100
          minor.buy_train(train)
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token)
          minor.float!
        end

        # TODO: Can neutral be removed? Move shares to market instead
        # before deleting them.
        @neutral = Corporation.new(
          sym: 'N',
          name: 'Neutral',
          tokens: [],
        )
        @neutral.owner = @bank

        @brown_g_tile ||= @tiles.find { |t| t.name == '480' }
        @gray_tile ||= @tiles.find { |t| t.name == '455' }
        @green_l_tile ||= @tiles.find { |t| t.name == '475' }

        # The NdM 5% shares are trade-ins, that cannot be bought beforehand
        # And they are not counted towards the cert limit. (Paragraph 3.3b)
        minor_a_reserved_share.buyable = false
        minor_a_reserved_share.counts_for_limit = false
        minor_b_reserved_share.buyable = false
        minor_b_reserved_share.counts_for_limit = false

        # The last UdY 10% share is a trade-in for Minor C. Non-buyable before minor merge.
        minor_c_reserved_share.buyable = false

        # The last NdM 10% share is used for trade-in during NdM merge.
        # Before the NdM merge event it cannot be bought.
        ndm_merge_share.buyable = false

        # Remember the price for the last token; exchange tokens have the same.
        @ndm_exchange_token_price = ndm.tokens.last.price
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::G18MEX::Assign,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::HomeToken,
          Step::G18MEX::Merge,
          Step::G18MEX::SpecialTrack,
          Step::G18MEX::Track,
          Step::Token,
          Step::Route,
          Step::G18MEX::Dividend,
          Step::G18MEX::SingleDepotTrainBuy,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::G18MEX::BuySellParShares,
        ])
      end

      def new_stock_round
        @minors.each do |minor|
          matching_company = @companies.find { |company| company.sym == minor.name }
          minor.owner = matching_company.owner
        end if @turn == 1
        super
      end

      # If selling 5% NdM share it should not affect share price
      def sell_shares_and_change_price(bundle)
        return super if bundle.corporation != ndm || bundle.percent > 5

        @share_pool.sell_shares(bundle)
      end

      # 5% NdM is not counted for cert limit
      def countable_shares(shares)
        shares.select { |s| s.percent > 5 }
      end

      # In case of selling NdM, split 5% share in separate bundle and regular
      # shares in other. This means that each 5% need to be sold separately,
      # one at a time. (Even in the extremly rare case of selling 2 5% this
      # is done in two separate sell to simplify implementation.) Now the extra
      # sell actions does not matter as the stock price are not affect by sell
      # of any 5% shares.
      def bundles_for_corporation(player, corporation)
        return super unless ndm == corporation

        # Hansle bundles with half shares and non-half shares separately.
        regular_shares, half_shares = player.shares_of(ndm).partition { |s| s.percent > 5 }

        # Need only one bundle with half shares. Player will have to sell twice if s/he want to sell both.
        # This is to simplify other implementation - only handle sell bundles with one half share.
        half_shares = [half_shares.first] if half_shares.any?

        regular_bundles = super(player, ndm, shares: regular_shares)
        half_bundles = super(player, ndm, shares: half_shares)
        regular_bundles.concat(half_bundles)
      end

      def place_home_token(entity)
        super
        return if entity.minor?

        entity.trains.empty? ? handle_no_mail(entity) : handle_mail(entity)
      end

      def event_minors_closed!
        merge_minor(minor_a, ndm, minor_a_reserved_share)
        merge_minor(minor_b, ndm, minor_b_reserved_share)
        merge_minor(minor_c, udy, minor_c_reserved_share)
        ndm.abilities(:no_buy) do |ability|
          ndm.remove_ability(ability)
        end
      end

      def event_ndm_merger!
        @log << "-- Event: #{ndm.name} merger --"
        unless ndm.floated?
          @log << "No merge occur as #{ndm.name} has not floated!"
          return merge_major
        end

        @mergable_candidates = mergable_corporations
        @log << "Merge candidates: #{@mergable_candidates.map(&:name)}" if @mergable_candidates.any?
        possible_auto_merge
      end

      def decline_merge(major)
        @log << "#{major.name} declines"
        @mergable_candidates.delete(major)
        possible_auto_merge
      end

      # Called to perform the merge. If called without any major, this means
      # that there is noone that can or want to merge, which is handled here
      # as well.
      def merge_major(major = nil)
        @mergable_candidates = []

        # Make reserved share available
        ndm_merge_share.buyable = true

        unless major
          # Rule 5i: no merge? increase cert limit, and remove extra tokens from NdM
          @log << "-- #{ndm.name} does not merge - certificate limit increases by one --"
          @cert_limit_adjust += 1
          return
        end

        @log << "-- #{major.name} merges into #{ndm.name} --"

        # Rule 5e: Any other shares are sold off for half market price
        refund = major.ipoed ? (major.share_price.price / 2.0).ceil : 0
        @players.each do |p|
          refund_count = 0
          p.shares_of(major).dup.each do |s|
            next unless s

            share_pool.move_share(s, @neutral)
            if s.president
              # Rule 5d: Give owner of presidency share (if any) the reserved share
              # Might trigger presidency change in NdM
              share_pool.buy_shares(major.shares[0].player, ndm_merge_share, exchange: :free, exchange_price: 0)
            else
              bank.spend(refund, p) if refund.positive?
              refund_count += 1
            end
          end
          if refund_count.positive?
            @log << "#{p.name} receives #{format_currency(refund * refund_count)} in share compensation"
          end
        end

        # Rule 5f: Handle tokens. NdM gets two exchange tokens If company merge has put out its home token,
        # this will be swapped (for free) with the first exchange token. If company has tokened more,
        # NdM president get to choose which one to keep, and this is swapped (for free) with the second
        # exchange token, and the remaining tokens for the merged corporation is removed from the board.
        # Any remaining exchange tokens will be added to the charter, and have a cost of $80.

        (1..2).each do |_|
          ndm.tokens << Engine::Token.new(ndm)
          ndm.tokens.last.price = @ndm_exchange_token_price
        end
        exchange_tokens = [ndm.tokens[-2], ndm.tokens.last]

        home_token = major.tokens.first
        if major.floated? && home_token.city
          ndm_replacement = exchange_tokens.first
          home_token.city.remove_reservation!(major)
          if ndm.tokens.find { |t| t.city == home_token.city }
            @log << "#{major.name}'s home token is removed as #{ndm.name} already has a token there"
            home_token.remove!
          else
            home_token.city.reservations { |r| @log << "Reservation #{r}" }
            @log << "#{major.name}'s home token in #{home_token.city.hex.name} is replaced with an #{ndm.name} token"
            home_token.swap!(ndm_replacement)
            exchange_tokens.delete(ndm_replacement)
          end
        end
        major.tokens.select(&:city).dup.each do |t|
          if ndm.tokens.find { |n| n.city == t.city }
            @log << "#{major.name}'s token in #{t.city.name} is removed as #{ndm.name} already has a token there"
            t.remove!
          end
        end
        remaining_tokens = major.tokens.select(&:city).dup
        if remaining_tokens.size <= exchange_tokens.size
          remaining_tokens.each do |t|
            @log << "#{major.name}'s token in #{t.city.hex.name} is replaced with an #{ndm.name} token"
            t.swap!(exchange_tokens.first)
            exchange_tokens.delete(exchange_tokens.first)
          end
        else
          @merged_cities_to_select = remaining_tokens
        end

        # Rule 5g: transfer money and trains
        treasury = format_currency(major.cash).to_s
        major.spend(major.cash, ndm) if major.cash.positive?
        @log << "#{ndm.name} receives the treasury of #{treasury}" if major.cash.positive?
        if major.trains.any?
          trains_transfered = major.transfer(:trains, ndm).map(&:name)
          @log << "#{ndm.name} receives the trains: #{trains_transfered}"
        end

        corporations.delete(major)
        @round.entities.delete(major)
      end

      def buy_first_5_train(player)
        @ndm_merge_trigger ||= player
      end

      def merge_decider
        candidate = @mergable_candidates.first
        candidate.floated? ? candidate : ndm
      end

      def mergable_candidates
        @mergable_candidates ||= []
      end

      def merged_cities_to_select
        @merged_cities_to_select ||= []
      end

      def select_ndm_city(target)
        @merged_cities_to_select.each do |t|
          if t.city.hex == target
            @log << "#{t.corporation.name}'s token in #{t.city.hex.name} is replaced with an #{ndm.name} token"
            t.swap!(ndm.tokens.last)
          else
            @log << "#{t.corporation.name}'s token is removed in #{t.city.hex.name}"
            t.remove!
          end
        end
        @merged_cities_to_select = []
      end

      def upgrades_to?(from, to, special = false)
        # Copper Canyon cannot be upgraded
        return false if from.name == '470'

        # Guadalajara (O8) can only be upgraded to #480 in brown, and #455 in gray
        return to.name == '480' if from.color == :green && from.hex.name == 'O8'
        return to.name == '455' if from.color == :brown && from.hex.name == 'O8'
        return to.name == '475' if from.color == :yellow && from.hex.name == 'I4'

        super
      end

      def all_potential_upgrades(tile, tile_manifest: false)
        # Copper Canyon cannot be upgraded
        return [] if tile.name == '470'

        upgrades = super

        return upgrades unless tile_manifest

        # Tile manifest for standard green cities should show G tile as an option
        upgrades |= [@brown_g_tile] if @brown_g_tile && STANDARD_GREEN_CITY_TILES.include?(tile.name)

        # Tile manifest for Guadalajara brown (the G tile) should show gray tile as an option
        upgrades |= [@gray_tile] if @gray_tile && tile.name == '480'

        # Tile manifest for standard yellow cities with curve should show Los Mochos green tile as an option
        upgrades |= [@green_l_tile] if @green_l_tile && CURVED_YELLOW_CITY.include?(tile.name)

        upgrades
      end

      def tile_lays(entity)
        return super if entity.minor?

        [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
      end

      private

      def handle_no_mail(entity)
        @log << "#{entity.name} receives no mail income as it has no trains"
      end

      def handle_mail(entity)
        hex = hex_by_id(entity.coordinates)
        income = hex.tile.city_towns.first.route_revenue(@phase, entity.trains.first)
        @bank.spend(income, entity)
        @log << "#{entity.name} receives #{format_currency(income)} in mail"
      end

      def merge_minor(minor, major, share)
        treasury = format_currency(minor.cash).to_s
        @log << "-- Minor #{minor.name} merges into #{major.name} who receives the treasury of #{treasury} --"

        share.buyable = true
        share_pool.buy_shares(minor.player, share, exchange: :free, exchange_price: 0)

        hexes.each do |hex|
          hex.tile.cities.each do |city|
            if city.tokened_by?(minor)
              city.tokens.map! { |token| token&.corporation == minor ? nil : token }
              city.reservations.delete(minor)
            end
          end
        end

        minor.spend(minor.cash, major)
        hexes.each do |hex|
          hex.tile.cities.each do |city|
            if city.tokened_by?(minor)
              city.tokens.map! { |token| token&.corporation == minor ? nil : token }
            end
          end
        end

        @minors.delete(minor)
      end

      def mergable_corporations
        corporations = @corporations
          .reject { |c| c.player == ndm.player }
          .reject { |c| %w[PAC TM].include? c.name }
        player_corps, other_corps = corporations.partition(&:owned_by_player?)

        # Sort eligible corporations so that they are in player order
        # starting with the player to the left of the one that bought the 5 train
        index_for_trigger = @players.index(@ndm_merge_trigger)
        order = Hash[@players.each_with_index.map { |p, i| i <= index_for_trigger ? [p, i + 10] : [p, i] }]
        player_corps.sort_by! { |c| [order[c.player], @round.entities.index(c)] }

        # If any non-floated corporation has not yet been ipoed
        # then only non-ipoed corporations must be chosen
        other_corps.reject!(&:ipoed) if other_corps.any? { |c| !c.ipoed }

        # The players get the first choice, otherwise a non-floated corporation must be chosen
        player_corps.concat(other_corps)
      end

      def possible_auto_merge
        # Decline merge if no candidates left
        return merge_major if @mergable_candidates.empty?

        # Auto merge single if it is non-floated
        candidate = @mergable_candidates.first
        merge_major(candidate) if @mergable_candidates.one? && !candidate.floated?
      end
    end
  end
end
