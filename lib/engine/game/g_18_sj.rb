# frozen_string_literal: true

require_relative '../config/game/g_18_sj'
require_relative 'base'

module Engine
  module Game
    class G18SJ < Base
      register_colors(
        black: '#0a0a0a', # STJ
        brightGreen: '#7bb137', # UGJ
        brown: '#7b352a', # BJ
        green: '#237333', # SWB
        lavender: '#baa4cb', # SNJ
        olive: '#808000', # TGOJ (not right)
        orange: '#f48221', # MOJ
        red: '#d81e3e', # OSJ
        violet: '#4d2674', # OKJ
        white: '#ffffff', # KFJr
        yellow: '#FFF500' # MYJ
      )

      load_from_json(Config::Game::G18SJ::JSON)

      DEV_STAGE = :alpha

      GAME_LOCATION = 'Sweden'
      GAME_RULES_URL = 'https://drive.google.com/file/d/1WgvqSp5HWhrnCAhAlLiTIe5oXfYtnVt9/view?usp=drivesdk'
      GAME_DESIGNER = 'Örjan Wennman'
      GAME_PUBLISHER = :self_published
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18SJ'

      # Stock market 350 triggers end of game in same OR, but bank full OR set
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :full_or }.freeze

      SELL_BUY_ORDER = :sell_buy_sell

      # At most a corporation/minor can do two tile lay / upgrades but two is
      # only allowed if one improves main line situation. This means a 2nd
      # tile lay/upgrade might not be allowed.
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: true }].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'full_cap' => ['Full Capitalization', 'Unsold corporations becomes Full Capitalization and move shares to IPO'],
        'nationalization' => ['Nationalization check', 'The topmost corporation without trains are nationalized'],
      ).freeze

      STATUS_TEXT = {
        'incremental' => [
          'Incremental Cap',
          'New corporations will be capitalized for all 10 shares as they are sold',
        ],
        'fullcap' => [
          'Full Cap',
          'New corporations will be capitalized for 10 x par price when 60% of the IPO is sold',
        ],
      }.merge(Base::STATUS_TEXT).freeze

      OPTIONAL_PRIVATE_A = %w[NE AEvR].freeze
      OPTIONAL_PRIVATE_B = %w[NOJ FRY].freeze
      OPTIONAL_PRIVATE_C = %w[NOHAB MV].freeze
      OPTIONAL_PRIVATE_D = %w[GKB SB].freeze
      OPTIONAL_PUBLIC = %w[STJ TGOJ ÖSJ MYJ].freeze

      MAIN_LINE_INFO = {
        # Stockholm-Malmo main line
        'F9' => { orientation: [2, 5], main_line: 'M-S' },
        'E8' => { orientation: [2, 5], main_line: 'M-S' },
        'D7' => { orientation: [2, 5], main_line: 'M-S' },
        'C6' => { orientation: [2, 5], main_line: 'M-S' },
        'B5' => { orientation: [2, 5], main_line: 'M-S' },
        'A4' => { orientation: [1, 5], main_line: 'M-S' },
        # Stockholm-Goteborg main line
        'F11' => { orientation: [0, 3], main_line: 'G-S' },
        'E12' => { orientation: [0, 3], main_line: 'G-S' },
        'D13' => { orientation: [0, 2], main_line: 'G-S' },
        'C12' => { orientation: [2, 5], main_line: 'G-S' },
        'B11' => { orientation: [2, 5], main_line: 'G-S' },
        # Stockholm-Lulea main line
        'G12' => { orientation: [1, 3], main_line: 'L-S' },
        'F13' => { orientation: [0, 3], main_line: 'L-S' },
        'E14' => { orientation: [0, 4], main_line: 'L-S' },
        'E16' => { orientation: [1, 4], main_line: 'L-S' },
        'E18' => { orientation: [1, 4], main_line: 'L-S' },
        'E20' => { orientation: [1, 4], main_line: 'L-S' },
        'E22' => { orientation: [1, 4], main_line: 'L-S' },
        'E24' => { orientation: [1, 5], main_line: 'L-S' },
        'F25' => { orientation: [2, 5], main_line: 'L-S' },
      }.freeze
      MAIN_LINE_COUNT = {
        'M-S' => 6,
        'G-S' => 5,
        'L-S' => 9,
      }.freeze
      MAIN_LINE_DESCRIPTION = {
        'M-S' => 'Stockholm-Malmö',
        'G-S' => 'Stockholm-Göteborg',
        'L-S' => 'Stochholm-Luleå',
      }.freeze

      BONUS_ICONS = %w[N S O V M m_lower_case B b_lower_case].freeze

      ASSIGNMENT_TOKENS = {
        'SB' => '/icons/18_sj/sb_token.svg',
      }.freeze

      GKB_HEXES = %w[C8 C16 E8].freeze

      def init_corporations(stock_market)
        corporations = super
        removed_corporation = select(OPTIONAL_PUBLIC)
        to_close = corporations.find { |corp| corp.name == removed_corporation }
        corporations.delete(to_close)
        @log << "Removed corporation: #{to_close.full_name} (#{to_close.name})"
        corporations
      end

      def init_companies(players)
        companies = super
        @removed_companies = []
        [OPTIONAL_PRIVATE_A, OPTIONAL_PRIVATE_B, OPTIONAL_PRIVATE_C, OPTIONAL_PRIVATE_D].each do |optionals|
          to_remove = find_company(companies, optionals)
          to_remove.close!
          # companies.delete(to_remove)
          @removed_companies << to_remove
        end
        @log << "Removed companies: #{@removed_companies.map(&:name).join(', ')}"

        # Handle Priority Deal Chooser private (NEFT)
        # It is removed if Nils Ericsson is removed (as it does not appear among the buyable ones).
        # If Nils Ericsson remains, put NEFT last and let bank be owner, so it wont disturb auction,
        # and it will be assigned to NE owner in the auction.
        pdc = companies.find { |c| c.sym == 'NEFT' }
        if @removed_companies.find { |c| c.sym == 'NE' }
          @removed_companies << pdc
        else
          pdc.owner = @bank
        end

        companies - @removed_companies
      end

      def select(collection)
        collection[rand % collection.size]
      end

      def find_company(companies, collection)
        sym = collection[rand % collection.size]
        to_find = companies.find { |comp| comp.sym == sym }
        @log << "Could not find company with sym='#{sym}' in #{@companies}" unless to_find
        to_find
      end

      def minor_khj
        @minor_khj ||= minor_by_id('KHJ')
      end

      def company_khj
        @company_khj ||= company_by_id('KHJ')
      end

      def nils_ericsson
        @nils_ericsson ||= company_by_id('NE')
      end

      def priority_deal_chooser
        @priority_deal_chooser ||= company_by_id('NEFT')
      end

      def sveabolaget
        @sveabolaget ||= company_by_id('SB')
      end

      def motala_verkstad
        @motala_verkstad ||= company_by_id('MV')
      end

      def gkb
        @gkb ||= company_by_id('GKB')
      end

      def gc
        @gc ||= company_by_id('GC')
      end

      def ipo_name(entity)
        entity&.capitalization == :incremental ? 'Treasury' : 'IPO'
      end

      def setup
        # Possibly remove from map icons belonging to closed companies
        @removed_companies.each { |c| close_cleanup(c) }

        @minors.each do |minor|
          train = @depot.upcoming[0]
          train.buyable = false
          buy_train(minor, train, :free)
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token)
        end

        nils_ericsson.add_ability(Ability::Close.new(
          type: :close,
          when: :train,
          corporation: abilities(nils_ericsson, :shares).shares.first.corporation.name,
        )) if nils_ericsson && !nils_ericsson.closed?

        @main_line_hexes = @hexes.select { |h| main_line_hex?(h) }

        @tile_lays = []
        @special_tile_lays = []
        @fulfilled_main_line_hexes = []
        @main_line_built = {
          'M-S' => [],
          'G-S' => [],
          'L-S' => [],
        }

        # Create virtual SJ corporation
        @sj = Corporation.new(
          sym: 'SJ',
          name: 'Statens Järnvägar',
          logo: '18_sj/SJ',
          tokens: [],
        )
        @sj.owner = @bank

        @pending_nationalization = false
      end

      def cert_limit
        current_cert_limit
      end

      def num_certs(entity)
        count = super
        count -= 1 if priority_deal_chooser&.owner == entity
        count
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::CompanyPendingPar,
          Step::G18SJ::WaterfallAuction,
        ])
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::G18SJ::ChoosePriority,
          Step::G18SJ::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::G18SJ::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::G18SJ::Assign,
          Step::G18SJ::SpecialTrack,
          Step::G18SJ::BuyCompany,
          Step::G18SJ::IssueShares,
          Step::HomeToken,
          Step::Track,
          Step::Token,
          Step::G18SJ::BuyTrainBeforeRunRoute,
          Step::G18SJ::Route,
          Step::G18SJ::Dividend,
          Step::SpecialBuyTrain,
          Step::G18SJ::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def action_processed(action)
        is_tile_lay = action.is_a?(Action::LayTile)
        check_second_lay(action) if is_tile_lay && !@tile_lays.empty? && !special_tile_lay?(action)

        super

        return if !is_tile_lay || special_tile_lay?(action)

        remove_main_line_bonus(action)
        @tile_lays << action
      end

      def special_tile_lay(action)
        @special_tile_lays << action.hex.name
      end

      def special_tile_lay?(action)
        @special_tile_lays.include?(action.hex.name)
      end

      def redeemable_shares(entity)
        return [] unless entity.corporation?
        return [] unless round.steps.find { |step| step.class == Step::G18SJ::IssueShares }.active?

        share_price = stock_market.find_share_price(entity, :right).price

        bundles_for_corporation(share_pool, entity)
          .each { |bundle| bundle.share_price = share_price }
          .reject { |bundle| bundle.shares.size > 1 }
          .reject { |bundle| entity.cash < bundle.price }
      end

      def revenue_for(route, stops)
        revenue = super

        icons = visited_icons(stops)

        [lapplandspilen_bonus(icons),
         stockholm_goteborg_bonus(icons, stops),
         stockholm_malmo_bonus(icons, stops),
         bergslagen_bonus(icons),
         orefields_bonus(icons),
         sveabolaget_bonus(route),
         gkb_bonus(route)].map { |b| b[:revenue] }.each { |r| revenue += r }

        return revenue unless route.train.name == 'E'

        # E trains double any city revenue if corporation's token (or SJ) is present
        revenue + stops.sum do |stop|
          friendly_city?(route, stop) ? stop.route_revenue(route.phase, route.train) : 0
        end
      end

      def revenue_str(route)
        stops = route.stops
        stop_hexes = stops.map(&:hex)
        str = route.hexes.map do |h|
          stop_hexes.include?(h) ? h&.name : "(#{h&.name})"
        end.join('-')

        icons = visited_icons(stops)

        [lapplandspilen_bonus(icons),
         stockholm_goteborg_bonus(icons, stops),
         stockholm_malmo_bonus(icons, stops),
         bergslagen_bonus(icons),
         orefields_bonus(icons),
         sveabolaget_bonus(route),
         gkb_bonus(route)].map { |b| b[:description] }.compact.each { |d| str += " + #{d}" }

        str
      end

      def clean_up_after_entity
        @tile_lays = []

        # Remove Gellivare Company tile lay ability if it has been used this OR
        abilities(gc, :tile_lay) do |ability|
          company.remove_ability(ability)
          @log << "#{gc.name} tile lay ability removed"
        end unless @special_tile_lays.empty?
        @special_tile_lays = []

        return unless @round.current_entity

        make_sj_tokens_impassable
      end

      # Make SJ passable if current corporation has E train
      # This is a workaround that is not perfect in case a
      # corporation has E train + other train, but very unlikely
      def make_sj_tokens_passable_for_electric_trains(entity)
        return unless entity.trains.any? { |t| t.name == 'E' }

        @sj.tokens.each { |t| t.type = :neutral }
      end

      def make_sj_tokens_impassable
        @sj.tokens.each { |t| t.type = :blocking }
      end

      def event_close_companies!
        @companies.each { |c| close_cleanup(c) }
        super

        return if minor_khj.closed?

        @log << "Minor #{minor_khj.name} closes and its home token is removed"
        minor_khj.spend(minor_khj.cash, p)
        minor_khj.tokens.first.remove!
        minor_khj.close!
      end

      def event_full_cap!
        @corporations
          .select { |c| c.percent_of(c) == 100 && !c.closed? }
          .each do |c|
            @log << "#{c.name} becomes full capitalization as not pared"
            c.capitalization = :full
          end
      end

      def event_nationalization!
        @pending_nationalization = true
      end

      def pending_nationalization?
        @pending_nationalization
      end

      def perform_nationalization
        @pending_nationalization = false
        candidates = @corporations.select { |c| !c.closed? && c.operated? && c.trains.empty? }
        if candidates.empty?
          @log << 'Nationalization skipped as no trainless floated corporations'
          return
        end

        # Merge the corporation with highest share price, and use the first operated as tie break
        merged = candidates.max_by { |c| [c.share_price.price, -@round.entities.find_index(c)] }

        nationalize_major(merged)
      end

      # If there are 2 station markers on the same city the
      # merged corporation must remove one and return it to its charter.
      def remove_duplicate_tokens(target, merged)
        merged_tokens = merged.tokens.map(&:city).compact
        target.tokens.each do |token|
          city = token.city
          token.remove! if merged_tokens.include?(city)
        end
      end

      def remove_reservation(merged)
        hex = hex_by_id(merged.coordinates)
        tile = hex.tile
        cities = tile.cities
        city = cities.find { |c| c.reserved_by?(merged) } || cities.first
        city.remove_reservation!(merged)
      end

      def transfer_home_token(target, merged)
        merged_home_token = merged.tokens.first
        return unless merged_home_token.city

        transfer_token(merged_home_token, merged, target)
      end

      def transfer_non_home_tokens(target, merged)
        merged.tokens.each do |token|
          next unless token.city

          transfer_token(token, merged, target)
        end
      end

      private

      def check_second_lay(action)
        last_tile_lay = @tile_lays.first

        if !main_line_lay?(last_tile_lay) && !main_line_lay?(action)
          raise GameError, 'Second tile lay or upgrade only allowed if first or second improves the main line!'
        end

        @log << "#{last_tile_lay.entity.name} gets extra tile lay/upgrade as main line improvement."
      end

      def main_line_lay?(action)
        return false unless action
        return false unless @main_line_hexes.include?(action.hex)
        return true if @fulfilled_main_line_hexes.include?(main_line_lay(action))
        return false if main_line_fulfilled_by_other?(action)

        main_line_hex?(action.hex) && connects_main_line?(action.hex)
      end

      def main_line_fulfilled_by_other?(action)
        return false if @fulfilled_main_line_hexes.include?(main_line_lay(action))

        @fulfilled_main_line_hexes.each do |info|
          return true if info[:hex_name] == action.hex.name && info[:tile_name] != action.tile.name
        end
        false
      end

      def main_line_hex?(hex)
        MAIN_LINE_INFO[hex.name]
      end

      def connects_main_line?(hex)
        info = MAIN_LINE_INFO[hex.name]
        return unless info

        orientation = info[:orientation]
        edge1 = "#{hex.name}_#{orientation[0]}_0"
        edge2 = "#{hex.name}_#{orientation[1]}_0"
        edges = hex.tile.paths.flat_map(&:edges).map(&:id)
        edges.include?(edge1) && edges.include?(edge2)
      end

      def remove_main_line_bonus(action)
        return unless main_line_lay?(action)

        lay = main_line_lay(action)
        return if @fulfilled_main_line_hexes.include?(lay)

        info = MAIN_LINE_INFO[action.hex.name]
        @fulfilled_main_line_hexes << lay
        main_line = info[:main_line]
        @main_line_built[main_line] = (@main_line_built[main_line] << action.hex.name)
        return if @main_line_built[main_line].size < MAIN_LINE_COUNT[main_line]

        @log << "-- Main line #{MAIN_LINE_DESCRIPTION[main_line]} completed!"
        @log << 'Removes icons for main line'
        remove_icons(@main_line_built[main_line], [main_line])
      end

      def main_line_lay(action)
        { hex_name: action.hex.name, tile_name: action.tile.name }
      end

      CERT_LIMITS = {
        10 => { 2 => 39, 3 => 26, 4 => 20, 5 => 16, 6 => 13 },
        9 => { 2 => 35, 3 => 23, 4 => 18, 5 => 14, 6 => 12 },
        8 => { 2 => 30, 3 => 20, 4 => 15, 5 => 12, 6 => 10 },
        7 => { 2 => 26, 3 => 17, 4 => 13, 5 => 11, 6 => 9 },
      }.freeze

      def current_cert_limit
        available_corporations = @corporations.count { |c| !c.closed? }
        certs_per_player = CERT_LIMITS[available_corporations]
        raise GameError, "No cert limit defined for #{available_corporations} corporations" unless certs_per_player

        set_cert_limit = certs_per_player[@players.size]
        raise GameError, "No cert limit defined for #{@players.size} players" unless set_cert_limit

        set_cert_limit
      end

      def nationalize_major(major)
        @log << "#{major.name} is nationalized"

        remove_reservation(major)
        transfer_home_token(@sj, major)
        transfer_non_home_tokens(@sj, major)

        major.companies.dup.each(&:close!)

        # Decrease share price two step and then give compensation with this price
        prev = major.share_price.price
        @stock_market.move_left(major)
        @stock_market.move_left(major)
        log_share_price(major, prev)
        refund = major.share_price.price
        @players.each do |p|
          refund_amount = 0
          p.shares_of(major).dup.each do |s|
            next unless s

            refund_amount += (s.percent / 10) * refund
            s.transfer(major)
          end
          next unless refund_amount.positive?

          @log << "#{p.name} receives #{format_currency(refund_amount)} in share compensation"
          @bank.spend(refund_amount, p)
        end

        # Transfer bank pool shares to IPO
        @share_pool.shares_of(major).dup.each do |s|
          s.transfer(major)
        end

        major.spend(major.cash, @bank) if major.cash.positive?
        major.close!
        @log << "#{major.name} closes and its tokens becomes #{@sj.name} tokens"

        # Cert limit changes as the number of corporations decrease
        @log << "Certificate limit is now #{cert_limit}"
      end

      def transfer_token(token, merged, target_corporation)
        city = token.city

        if tokened_hex_by(city.hex, target_corporation)
          @log << "#{merged.name}'s token in #{token.city.hex.name} is removed "\
                  "as there is already a #{target_corporation.name} token there"
          token.remove!
        else
          @log << "#{merged.name}'s token in #{city.hex.name} is replaced with an #{target_corporation.name} token"
          token.remove!
          replacement_token = Engine::Token.new(target_corporation)
          target_corporation.tokens << replacement_token
          city.place_token(target_corporation, replacement_token, check_tokenable: false)
        end
      end

      def visited_icons(stops)
        icons = []
        stops.each do |s|
          s.hex.tile.icons.each do |icon|
            next unless BONUS_ICONS.include?(icon.name)

            icons << icon.name
          end
        end
        icons.sort!
      end

      def lapplandspilen_bonus(icons)
        bonus = { revenue: 0 }

        if icons.include?('N') && icons.include?('S')
          bonus[:revenue] += 100
          bonus[:description] = 'N/S'
        end

        bonus
      end

      def stockholm_goteborg_bonus(icons, stops)
        bonus = { revenue: 0 }
        hexes = stops.map { |s| s.hex.id }

        if icons.include?('O') && icons.include?('V') && hexes.include?('G10') && hexes.include?('A10')
          bonus[:revenue] += 120
          bonus[:description] = 'Ö/V[S/G]'
        end

        bonus
      end

      def stockholm_malmo_bonus(icons, stops)
        bonus = { revenue: 0 }
        hexes = stops.map { |s| s.hex.id }

        if icons.include?('O') && icons.include?('V') && hexes.include?('G10') && hexes.include?('A2')
          bonus[:revenue] += 100
          bonus[:description] = 'Ö/V[S/M]'
        end

        bonus
      end

      def bergslagen_bonus(icons)
        bonus = { revenue: 0 }

        if icons.include?('B') && icons.count('b_lower_case') == 1
          bonus[:revenue] += 50
          bonus[:description] = 'b/B'
        end
        if icons.include?('B') && icons.count('b_lower_case') > 1
          bonus[:revenue] += 80
          bonus[:description] = 'b/B/b'
        end

        bonus
      end

      def orefields_bonus(icons)
        bonus = { revenue: 0 }

        if icons.include?('M') && icons.count('m_lower_case') == 1
          bonus[:revenue] += 50
          bonus[:description] = 'm/M'
        end
        if icons.include?('M') && icons.count('m_lower_case') > 1
          bonus[:revenue] += 100
          bonus[:description] = 'm/M/m'
        end

        bonus
      end

      def sveabolaget_bonus(route)
        bonus = { revenue: 0 }

        steam = sveabolaget&.id
        revenue = 0
        if route.corporation == sveabolaget&.owner &&
           (port = route.stops.map(&:hex).find { |hex| hex.assigned?(steam) })
          revenue += 30 * port.tile.icons.select { |icon| icon.name == 'port' }.size
        end
        if revenue.positive?
          bonus[:revenue] = revenue
          bonus[:description] = 'Port'
        end

        bonus
      end

      def gkb_bonus(route)
        bonus = { revenue: 0 }

        return bonus if !route.abilities || route.abilities.empty?
        raise GameError, "Only one ability supported: #{route.abilities}" if route.abilities.size > 1

        ability = abilities(route.train.owner, route.abilities.first)
        raise GameError, "Cannot find ability #{route.abilities.first}" unless ability

        bonuses = route.stops.count { |s| ability.hexes.include?(s.hex.name) }
        if bonuses.positive?
          bonus[:revenue] = ability.amount * bonuses
          bonus[:description] = 'GKB'
          bonus[:description] += "x#{bonuses}" if bonuses > 1
        end

        bonus
      end

      def close_cleanup(company)
        cleanup_gkb(company) if company.sym == 'GKB'
        cleanup_sb(company) if company.sym == 'SB'
      end

      def cleanup_gkb(company)
        @log << "Removes icons for #{company.name}"
        remove_icons(GKB_HEXES, %w[GKB])
      end

      def cleanup_sb(company)
        @log << "Removes icons and token for #{company.name}"
        remove_icons(%w[A6 C2 D5 F19 F23 G26], %w[port sb_token])
        steam = sveabolaget&.id
        @hexes.select { |hex| hex.assigned?(sveabolaget.id) }.each { |h| h.remove_assignment!(steam) } if steam
      end

      def remove_icons(to_be_cleaned, icon_names)
        @hexes.each do |hex|
          next unless to_be_cleaned.include?(hex.name)

          icons = hex.tile.icons
          icons.reject! { |i| icon_names.include?(i.name) }
          hex.tile.icons = icons
        end
      end

      def friendly_city?(route, stop)
        corp = route.train.owner
        tokened_hex_by(stop.hex, corp) || tokened_hex_by(stop.hex, @sj)
      end

      def tokened_hex_by(hex, corporation)
        hex.tile.cities.any? { |c| c.tokened_by?(corporation) }
      end
    end
  end
end
