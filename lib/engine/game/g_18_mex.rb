# frozen_string_literal: true

require_relative '../config/game/g_18_mex'
require_relative '../g_18_mex/share_pool'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'
module Engine
  module Game
    class G18Mex < Base
      load_from_json(Config::Game::G18Mex::JSON)
      AXES = { x: :number, y: :letter }.freeze

      DEV_STAGE = :alpha

      GAME_LOCATION = 'Mexico'
      GAME_RULES_URL = 'https://secure.deepthoughtgames.com/games/18MEX/rules.pdf'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_PUBLISHER = :all_aboard_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18MEX'
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

      IPO_RESERVED_NAME = 'Trade-in'

      TRACK_RESTRICTION = :city_permissive

      STANDARD_GREEN_CITY_TILES = %w[14 15 619].freeze
      CURVED_YELLOW_CITY = %w[5 6].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'companies_buyable' => ['Companies become buyable', 'All companies may now be bought in by corporation'],
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

      OPTIONAL_RULES = [
        { sym: :triple_yellow_first_or,
          short_name: 'Extra yellow',
          desc: 'Allow corporations to lay 3 yellow tiles their first OR' },
        { sym: :early_buy_of_kcmo,
          short_name: 'Early buy of KCM&O private',
          desc: 'KCM&O private may be bought in for up to face value' },
        { sym: :delay_minor_close,
          short_name: 'Delay minor close',
          desc: "Minor closes at the start of the SR following buy of first 3'" },
        { sym: :hard_rust_t4,
          short_name: 'Hard rust',
          desc: "4 trains rust when 6' train is bought" },
      ].freeze

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

      def pac
        @pac_corporation ||= corporation_by_id('PAC')
      end

      def tm
        @tm_corporation ||= corporation_by_id('TM')
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
          update_end_of_life(train, nil, nil) if @optional_rules&.include?(:delay_minor_close)
          minor.cash = 100
          minor.buy_train(train)
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token)
          minor.float!
        end

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

        # Rest is needed for optional rules

        @recently_floated = []
        change_4t_to_hardrust if @optional_rules&.include?(:hard_rust_t4)
        @minor_close = false
        return unless @optional_rules&.include?(:early_buy_of_kcmo)

        p2_company.min_price = 1
        p2_company.max_price = p2_company.value
      end

      def init_share_pool
        Engine::G18Mex::SharePool.new(self)
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::G18Mex::Assign,
          Step::DiscardTrain,
          Step::G18Mex::BuyCompany,
          Step::HomeToken,
          Step::G18Mex::Merge,
          Step::G18Mex::SpecialTrack,
          Step::G18Mex::Track,
          Step::Token,
          Step::Route,
          Step::G18Mex::Dividend,
          Step::G18Mex::SingleDepotTrainBuy,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def or_round_finished
        @recently_floated = []
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::G18Mex::BuySellParShares,
        ])
      end

      def new_stock_round
        # Trigger possible delayed close of minors
        event_minors_closed! if @minor_close

        @minors.each do |minor|
          matching_company = @companies.find { |company| company.sym == minor.name }
          minor.owner = matching_company.owner
        end if @turn == 1
        super
      end

      def float_corporation(corporation)
        @recently_floated << corporation

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

        # Handle bundles with half shares and non-half shares separately.
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

      def event_companies_buyable!
        setup_company_price_50_to_150_percent
      end

      def purchasable_companies(_entity)
        return super if @phase.current[:name] != '2' || !@optional_rules&.include?(:early_buy_of_kcmo)
        return [] unless p2_company.owner.player?

        [p2_company]
      end

      def event_minors_closed!
        if !@minor_close && @optional_rules&.include?(:delay_minor_close)
          @log << 'Close of minors delayed to next stock round'
          @minor_close = true
          return
        end
        merge_and_close_minor(minor_a, ndm, minor_a_reserved_share)
        merge_and_close_minor(minor_b, ndm, minor_b_reserved_share)
        merge_and_close_minor(minor_c, udy, minor_c_reserved_share)
        remove_ability(ndm, :no_buy)
      end

      def event_ndm_merger!
        @log << "-- Event: #{ndm.name} merger --"
        remove_ability(pac, :base)
        remove_ability(tm, :base)
        unless ndm.floated?
          @log << "No merge occur as #{ndm.name} has not floated!"
          return merge_major
        end

        @mergable_candidates = mergable_corporations
        @log << "Merge candidates: #{present_mergable_candidates(@mergable_candidates)}" if @mergable_candidates.any?
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

            if s.president
              # Rule 5d: Give owner of presidency share (if any) the reserved share
              # Might trigger presidency change in NdM
              @share_pool.buy_shares(major.owner, ndm_merge_share, exchange: :free, exchange_price: 0)
            else
              bank.spend(refund, p) if refund.positive?
              refund_count += 1
            end
            s.transfer(major)
          end
          # Transfer bank pool shares to IPO
          @share_pool.shares_of(major).dup.each do |s|
            s.transfer(major)
          end
          if refund_count.positive?
            @log << "#{p.name} receives #{format_currency(refund * refund_count)} in share compensation"
          end
        end

        # Rule 5f: Handle tokens. NdM gets two exchange tokens. The first exchange token will be used
        # to replace the home token, even if merged company isn't floated. This placement is free.
        # Note! If NdM already have a token in that hex, the home token is just removed.
        #
        # If company has tokened more, NdM president get to choose which one to keep, and this is swapped
        # (for free) with the second exchange token, and the remaining tokens for the merged corporation
        # is removed from the board.
        #
        # Any remaining exchange tokens will be added to the charter, and have a cost of $80.

        (1..2).each do |_|
          ndm.tokens << Engine::Token.new(ndm)
          ndm.tokens.last.price = @ndm_exchange_token_price
        end
        exchange_tokens = [ndm.tokens[-2], ndm.tokens.last]

        home_token = major.tokens.first
        if home_token.city
          home_token.city.remove_reservation!(major)
          if ndm.tokens.find { |t| t.city == home_token.city }
            @log << "#{major.name}'s home token is removed as #{ndm.name} already has a token there"
            home_token.remove!
          else
            replace_token(major, home_token, exchange_tokens)
          end
        else
          hex = hex_by_id(major.coordinates)
          tile = hex.tile
          cities = tile.cities
          city = cities.find { |c| c.reserved_by?(major) } || cities.first
          city.remove_reservation!(major)
          if ndm.tokens.find { |t| t.city == city }
            @log << "#{ndm.name} does not place token in #{city.hex.name} as it already has a token there"
          else
            @log << "#{ndm.name} places an exchange token in #{major.name}'s home location in #{city.hex.name}"
            ndm_replacement = exchange_tokens.first
            city.place_token(ndm, ndm_replacement)
            exchange_tokens.delete(ndm_replacement)
          end
        end
        major.tokens.select(&:city).dup.each do |t|
          if ndm.tokens.find { |n| n.city == t.city }
            @log << "#{major.name}'s token in #{t.city.hex.name} is removed as #{ndm.name} already has a token there"
            t.remove!
          end
        end
        remaining_tokens = major.tokens.select(&:city).reject { |t| t == home_token }.dup
        if remaining_tokens.size <= exchange_tokens.size
          remaining_tokens.each { |t| replace_token(major, t, exchange_tokens) }
          @merged_cities_to_select = []
        else
          @merged_cities_to_select = remaining_tokens
        end

        # Rule 5g: transfer money and trains
        if major.cash.positive?
          treasury = format_currency(major.cash)
          @log << "#{ndm.name} receives the #{major.name} treasury of #{treasury}"
          major.spend(major.cash, ndm)
        end
        if major.trains.any?
          trains_transfered = major.transfer(:trains, ndm).map(&:name)
          @log << "#{ndm.name} receives the trains: #{trains_transfered}"
        end

        major.close!
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
        return [{ lay: true, upgrade: false }] if entity.minor?

        lays = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
        if @optional_rules&.include?(:triple_yellow_first_or) && @recently_floated&.include?(entity)
          lays << { lay: :not_if_upgraded, upgrade: false }
        end
        lays
      end

      private

      def handle_no_mail(entity)
        @log << "#{entity.name} receives no mail income as it has no trains"
      end

      def handle_mail(entity)
        hex = hex_by_id(entity.coordinates)
        income = hex.tile.city_towns.first.route_base_revenue(@phase, entity.trains.first)
        @bank.spend(income, entity)
        @log << "#{entity.name} receives #{format_currency(income)} in mail"
      end

      def merge_and_close_minor(minor, major, share)
        transfer = minor.cash.positive? ? " who receives the treasury of #{format_currency(minor.cash)}" : ''
        @log << "-- Minor #{minor.name} merges into #{major.name}#{transfer} --"

        share.buyable = true
        @share_pool.buy_shares(minor.player, share, exchange: :free, exchange_price: 0)

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

        # Delete train so it wont appear in rust message
        train = minor.trains.first
        minor.remove_train(train)
        trains.delete(train)

        @minors.delete(minor)
        minor.close!
      end

      def mergable_corporations
        corporations = @corporations
          .reject { |c| c.player == ndm.player }
          .reject { |c| %w[PAC TM].include? c.name }
        floated_player_corps, other_corps = corporations.partition { |c| c.owned_by_player? && c.floated? }

        # Sort eligible corporations so that they are in player order
        # starting with the player to the left of the one that bought the 5 train
        index_for_trigger = @players.index(@ndm_merge_trigger)
        order = Hash[@players.each_with_index.map { |p, i| i <= index_for_trigger ? [p, i + 10] : [p, i] }]
        floated_player_corps.sort_by! { |c| [order[c.player], @round.entities.index(c)] }

        # If any non-floated corporation has not yet been ipoed
        # then only non-ipoed corporations must be chosen
        other_corps.reject!(&:ipoed) if other_corps.any? { |c| !c.ipoed }

        # The players get the first choice, otherwise a non-floated corporation must be chosen
        floated_player_corps.concat(other_corps)
      end

      def possible_auto_merge
        # Decline merge if no candidates left
        return merge_major if @mergable_candidates.empty?

        # Auto merge single if it is non-floated
        candidate = @mergable_candidates.first
        merge_major(candidate) if @mergable_candidates.one? && !candidate.floated?
      end

      def replace_token(major, major_token, exchange_tokens)
        city = major_token.city
        @log << "#{major.name}'s token in #{city.hex.name} is replaced with an #{ndm.name} token"
        ndm_replacement = exchange_tokens.first
        major_token.remove!
        city.place_token(ndm, ndm_replacement, check_tokenable: false)
        exchange_tokens.delete(ndm_replacement)
      end

      def change_4t_to_hardrust
        @depot.trains
          .select { |t| t.name == '4' }
          .each { |t| update_end_of_life(t, t.obsolete_on, nil) }
      end

      def update_end_of_life(t, rusts_on, obsolete_on)
        t.rusts_on = rusts_on
        t.obsolete_on = obsolete_on
        t.variants.each { |_, v| v.merge!(rusts_on: rusts_on, obsolete_on: obsolete_on) }
      end

      def remove_ability(corporation, ability_name)
        corporation.abilities(ability_name) do |ability|
          corporation.remove_ability(ability)
        end
      end

      def present_mergable_candidates(mergable_candidates)
        last = mergable_candidates.last
        mergable_candidates.map do |c|
          controller_name = if c.floated?
                              # Floated means president gets to merge/decline
                              c.player.name
                            elsif c == last
                              # Non-floated and last will be automatically chosen
                              'automatic'
                            else
                              # If several non-floated candidates NdM gets to choose
                              ndm.player.name
                            end
          "#{c.name} (#{controller_name})"
        end.join(', ')
      end
    end
  end
end
