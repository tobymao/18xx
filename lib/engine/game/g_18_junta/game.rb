# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'map_2p'
require_relative 'meta'
require_relative 'player'
require_relative 'stock_market'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/coup_private_i_choice'
require_relative 'step/dividend'
require_relative 'step/fix_par_price'
require_relative 'step/paramilitary_choice'
require_relative 'step/private_auction'
require_relative 'step/private_m_draw'
require_relative 'step/special_choose'
require_relative 'step/special_track'
require_relative 'step/track'
require_relative 'step/upgrade_license'
require_relative '../base'

module Engine
  module Game
    module G18Junta
      class Game < Game::Base
        include_meta(G18Junta::Meta)
        include Entities
        include Map

        PLAYER_CLASS = G18Junta::Player

        CURRENCY_FORMAT_STR = '$%s'

        # Rules summary 1.1: setup by player count.
        BANK_CASH = { 2 => 5_000, 3 => 7_000, 4 => 7_000 }.freeze

        CERT_LIMIT = { 2 => 22, 3 => 16, 4 => 14 }.freeze

        STARTING_CASH = { 2 => 580, 3 => 520, 4 => 450 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        SELL_BUY_ORDER = :sell_buy_sell

        POOL_SHARE_LIMIT = 50

        SOLD_OUT_INCREASE = true

        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or, stock_market: :current_or }.freeze

        # Rules summary 3.2, 3.3 and 3.6: par prices from $65 to $100, no yellow/orange/brown zones, and
        # the $330 and $350 spaces end the game.
        MARKET = [
          %w[75 85 95 105 115 130 145 160 180 205 230 260 290 320 350e],
          %w[70 80 90 100 110 125 140 155 175 200 225 250 275 300 330e],
          %w[65 70 80 90 100p 110 125 140 155 175 200 225 250 280],
          %w[55 65 70 80p 90p 100 110 125 140 155 175 200],
          %w[50 55 65 70p 80 90 100 110 125 140],
          %w[45 50 60 65p 70 80 90 100],
          %w[35 45 55 60 65 70],
          %w[25 35 45 55],
          %w[10 25 35],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[can_buy_companies coup_attempt],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
          { name: '3', distance: 3, price: 180, rusts_on: '6', num: 5 },
          { name: '4', distance: 4, price: 300, rusts_on: %w[8 D], num: 4 },
          { name: '5', distance: 5, price: 450, num: 3 },
          { name: '6', distance: 6, price: 630, num: 2 },
          # Rules summary 8 and 8.1: the final train is either the 8 or the D (decided by the coup in a
          # later PR); both trade in a 4, 5 or 6 for $750 and $800 respectively.
          {
            name: '8',
            distance: 8,
            price: 900,
            num: 6,
            available_on: '6',
            discount: { '4' => 150, '5' => 150, '6' => 150 },
          },
          {
            name: 'D',
            distance: 999,
            price: 1_100,
            num: 6,
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
        ].freeze

        # Rules summary 1.5: shown in the phase table while the coup is still to come.
        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'coup_attempt' => [
            'Coup Attempt',
            'Each 5-train bought reveals the top card of the Political Situation deck '\
            '(three cards: 2 Calm and 1 Coup Attempt). The coup is resolved when the Coup Attempt card appears.',
          ],
        ).freeze

        EBUY_PRES_SWAP = false
        EBUY_FROM_OTHERS = :value
        # Rules summary 4.3: trains can only be bought from companies with the same president.
        ALLOW_TRAIN_BUY_FROM_OTHER_PLAYERS = false
        # Rules summary 10: the home station is placed when the company floats.
        HOME_TOKEN_TIMING = :float

        # Rules summary 1.2: number of private companies kept in play by player count.
        PRIVATES_IN_PLAY = { 2 => 5, 3 => 6, 4 => 7 }.freeze

        # Rules summary 1.4: the corruption bag starts with 28 white and 7 black tokens, and three black
        # tokens are added when the last 2-, 3- and 4-train is bought.
        CORRUPTION_BAG_INITIAL = { white: 28, black: 7 }.freeze
        CORRUPTION_BAG_REFILL = { '2' => 3, '3' => 3, '4' => 3 }.freeze

        # Rules summary 6.1: the marker runs from Military 5 (-5) through Neutral (0) to Civilian 5 (5);
        # from space 3 on one side, a move toward the other side is 2 spaces.
        POLITICAL_TRACK_LIMIT = 5
        RADICAL_THRESHOLD = 3

        # Rules summary 6.5: under Dictatorship, each Military-aligned company receives $80 per token.
        MILITARY_BONUS_PER_TOKEN = 80

        # Rules summary 11 (E): what the bank gives the company Casa Ruiz de Assistencia is donated to.
        PRIVATE_E_DONATION = 150

        # Rules summary 6.2: hexes with a paramilitary token.
        PARAMILITARY_HEXES = %w[B14 C11 E7 F4 G13 I3 I9 K11 L8].freeze

        # Rules summary 9.2: $ per black token at game end, by total tokens held (row) and regime (column).
        CORRUPTION_PENALTY_TABLE = [
          { max: 15, dictatorship: 12, democracy: 20 },
          { max: 20, dictatorship: 16, democracy: 25 },
          { max: 25, dictatorship: 20, democracy: 30 },
          { max: 30, dictatorship: 24, democracy: 35 },
          { max: 35, dictatorship: 28, democracy: 40 },
          { max: 40, dictatorship: 32, democracy: 45 },
          { max: 45, dictatorship: 36, democracy: 50 },
          { max: 50, dictatorship: 40, democracy: 55 },
          { max: Float::INFINITY, dictatorship: 44, democracy: 60 },
        ].freeze

        def setup
          @or_round_number = 0
          @upgrade_licenses = {}
          @corruption_bag = CORRUPTION_BAG_INITIAL.flat_map { |color, count| [color] * count }.sort_by { rand }

          setup_political_track!
          # Rules summary 1.5: two Calm cards and one Coup Attempt card, shuffled.
          @political_situation_deck = %i[calm calm coup].sort_by { rand }
          @coup_outcome = nil
          @private_a_used = false
          @fixed_par_prices = {}
          @private_m_used_turn = nil
          @private_k_used_or = nil
          @pending_coup_i = nil
        end

        # Rules summary 1.2: the companies out of the game are drawn before the private auction round
        # is built, so the auction only offers the privates in play.
        def setup_preround
          remove_random_corporation!
          select_random_privates!
        end

        # Rules summary 1.2: one public company, drawn at random, is out of the game. Its home
        # reservation is cleared so the city is open to everyone.
        # In a 2-player game Hijos Muñoz (H), whose home is not on the smaller map, goes first.
        def remove_random_corporation!
          if two_player?
            @corporations.delete(@corporations.find { |c| c.name == 'H' })
            setup_log << '2-Player Game (smaller map): Corporation H not available'
          end

          corporation = @corporations.min_by { rand }
          hex = @hexes.find { |h| h.id == corporation.coordinates } # the id cache is built after setup_preround
          hex.tile.cities[corporation.city || 0].remove_reservation!(corporation)
          @corporations.delete(corporation)
          setup_log << "Corporation removed in this game: #{corporation.name}"
        end

        # Rules summary 1.1: the 2-player game uses the smaller map, with Campesina (C) at home in F4,
        # and one 2-, one 3- and one 4-train fewer.
        def optional_hexes
          two_player? ? Map2P::HEXES_2P : game_hexes
        end

        def location_name(coord)
          two_player? ? Map2P::LOCATION_NAMES_2P[coord] : super
        end

        def game_corporations
          return super unless two_player?

          super.map { |corporation| corporation[:sym] == 'C' ? corporation.merge(coordinates: 'F4') : corporation }
        end

        def game_trains
          return super unless two_player?

          super.map { |train| %w[2 3 4].include?(train[:name]) ? train.merge(num: train[:num] - 1) : train }
        end

        def paramilitary_hexes
          two_player? ? Map2P::PARAMILITARY_HEXES_2P : self.class::PARAMILITARY_HEXES
        end

        def dictatorship_border_tiles
          two_player? ? Map2P::DICTATORSHIP_BORDER_TILES_2P : self.class::DICTATORSHIP_BORDER_TILES
        end

        # Rules summary 9.1: private companies do not count in a bankrupt player's final score.
        def player_value(player)
          return super unless player.bankrupt

          super - player.companies.sum(&:value)
        end

        # Rules summary 1.2: only a random set of the private companies is used in each game.
        def select_random_privates!
          kept = @companies.sort_by { rand }.take(self.class::PRIVATES_IN_PLAY[@players.size])
          (@companies - kept).each { |company| remove_company(company) }
          setup_log << "Private companies available in this game: #{@companies.map(&:name).join(', ')}"
        end

        def remove_company(company)
          company.close!
          @companies.delete(company)
        end

        # Rules summary 2.1: the private companies are sold only through the open auction.
        def new_auction_round
          Round::Auction.new(self, [G18Junta::Step::PrivateAuction])
        end

        # Rules summary 2.1: minimum raise between bids; $10 with the optional faster auction.
        def bid_increment
          @optional_rules.include?(:bid_increment_10) ? 10 : 5
        end

        # Rules summary 2.1: after the auction the player with the most cash gets priority; ties are
        # broken by seating order.
        def reorder_players(order = nil, log_player_order: false)
          return super unless @round.is_a?(Engine::Round::Auction)

          richest = @players.max_by(&:cash)
          tied = @players.select { |p| p.cash == richest.cash } - [richest]
          @players.rotate!(@players.index(richest))

          msg = "#{richest.name} has priority (most cash after the auction)."
          unless tied.empty?
            names = tied.map(&:name)
            names = names.size == 1 ? names.first : "#{names[0..-2].join(', ')} and #{names.last}"
            msg += " Tied with #{names}; the tie was broken by seating order."
          end
          @log << msg
        end

        TOP_ROW_RIGHT_SYMBOL = "\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0↱"

        # Rules summary 3.5: the top-row spaces from $75 to $320 show an arrow, as a reminder that a
        # move up there goes right instead (see stock_market.rb).
        def game_market
          market = self.class::MARKET
          top_row = market.first.each_with_index.map do |code, col|
            next code if col == market.first.size - 1 || code.match?(/[a-zA-Z]/)

            { price: code.to_i, info: self.class::TOP_ROW_RIGHT_SYMBOL }
          end
          [top_row, *market.drop(1)]
        end

        def init_stock_market
          G18Junta::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                    multiple_buy_types: self.class::MULTIPLE_BUY_TYPES,
                                    sold_out_top_row_movement: self.class::SOLD_OUT_TOP_ROW_MOVEMENT)
        end

        def stock_round
          # PrivateMDraw is a free action, so it stays first: it never blocks the Private (A) question.
          Round::Stock.new(self, [
            G18Junta::Step::PrivateMDraw,
            G18Junta::Step::FixParPrice,
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G18Junta::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @or_round_number += 1
          expire_stale_upgrade_licenses!

          Round::Operating.new(self, [
            G18Junta::Step::CoupPrivateIChoice,
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G18Junta::Step::SpecialTrack,
            G18Junta::Step::SpecialChoose,
            Engine::Step::BuyCompany,
            G18Junta::Step::ParamilitaryChoice,
            G18Junta::Step::Track,
            G18Junta::Step::UpgradeLicense,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Junta::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        # Rules summary 2.2: unlike 1830, where a company may buy a private from any player, here the
        # private's owner must be the company's president.
        # The buy companies view calls this without an argument, hence the current_entity default.
        def purchasable_companies(entity = nil)
          entity ||= current_entity
          companies = super(entity)
          return companies unless entity&.corporation?

          companies.select { |company| company.owner == entity.owner }
        end

        # Rules summary 4.2: the license is granted for the company's next Operating Round only.
        def upgrade_license_granted?(corporation)
          @upgrade_licenses.key?(corporation)
        end

        def upgrade_license?(corporation)
          @upgrade_licenses[corporation] == @or_round_number
        end

        def grant_upgrade_license!(corporation)
          @upgrade_licenses[corporation] = @or_round_number + 1
        end

        def consume_upgrade_license!(corporation)
          return false unless upgrade_license?(corporation)

          @upgrade_licenses.delete(corporation)
          true
        end

        def expire_upgrade_license_if_unused!(corporation)
          return unless upgrade_license?(corporation)

          @upgrade_licenses.delete(corporation)
          @log << "#{corporation.name} did not use its Upgrade License, which has expired"
        end

        def expire_stale_upgrade_licenses!
          @upgrade_licenses.reject! { |_corporation, valid_on_round| valid_on_round < @or_round_number }
        end

        # Company card lines, as [text, css class] pairs.
        def status_array(corporation)
          alignment = @corporation_alignment[corporation]
          status = []
          status << ["Civilian x#{alignment[:civilian]}", 'civilian_support'] if alignment[:civilian].positive?
          status << ["Military x#{alignment[:military]}", 'military_support'] if alignment[:military].positive?
          fixed = fixed_par_price_for(corporation)
          status << ["Fixed Par Price: #{format_currency(fixed.price)}", 'fixed_par_price'] if fixed && !corporation.ipoed
          status << ['(Upgrade License acquired)', 'upgrade_license'] if upgrade_license_granted?(corporation)
          status unless status.empty?
        end

        # Rules summary 7.1: a farm does not count as a stop for train distance (its tiles have
        # visit_cost 0) and may not be the start or end of a route.
        def check_other(route)
          stops = route.visited_stops
          return if stops.empty?

          raise GameError, 'A farm cannot be the start or the end of a route' if farm_stop?(stops.first) || farm_stop?(stops.last)
        end

        # Farm tiles are the ones whose label is a single space (the label ties farm tiles to farm hexes).
        def farm_stop?(stop)
          stop.tile.label.to_s == ' '
        end

        # Farms are shown as a single symbol in the route text.
        # Towns that Expresso Resplandor (G) leaves out of the train range are shown in brackets.
        def revenue_str(route)
          farm_hexes = route.visited_stops.select { |stop| farm_stop?(stop) }.map(&:hex)
          free_towns = owns_private?(route.corporation, '(G)') ? route.visited_stops.select(&:town?).map(&:hex) : []
          route.hexes.map do |hex|
            next 'Ⓕ' if farm_hexes.include?(hex)

            free_towns.include?(hex) ? "[#{hex.name}]" : hex.name
          end.join('+')
        end

        # Rules summary 11 (G): towns do not count toward the range of the owning company's trains.
        def check_distance(route, visits, train = nil)
          train ||= route.train
          return super if !train.distance.is_a?(Numeric) || !owns_private?(route.corporation, '(G)')

          distance = visits.sum { |visit| visit.town? ? 0 : visit.visit_cost }
          raise RouteTooLong, "#{distance} is too many stops for #{train.distance} train" if distance > train.distance
        end

        def owns_private?(corporation, sym)
          corporation&.companies&.any? { |company| company.sym == sym }
        end

        # Rules summary 7.3: the yellow Laguna tile (J16) upgrades straight to its gray tile (J17), once
        # gray tiles are available.
        def upgrades_to_correct_color?(from, to, selected_company: nil)
          return @phase.tiles.include?(to.color) if from.name == 'J16' && to.name == 'J17'

          super
        end

        # Rules summary 1.4: when the last 2-, 3- or 4-train is bought from the bank, black tokens are
        # added to the corruption bag.
        def buy_train(operator, train, price = nil)
          last_of_type = @depot.upcoming.include?(train) && @depot.upcoming.count { |t| t.name == train.name } == 1
          from_depot = @depot.upcoming.include?(train)
          super
          refill_corruption_bag!(train.name) if last_of_type
          reveal_political_situation_card! if train.name == '5' && from_depot && !coup_resolved?
        end

        def refill_corruption_bag!(train_name)
          count = self.class::CORRUPTION_BAG_REFILL[train_name]
          return unless count

          @corruption_bag.concat(%i[black] * count).sort_by! { rand }
          @log << "Last #{train_name}-train bought: #{count} black tokens are added to the corruption bag"
        end

        # Rules summary 5.1: a player draws a corruption token from the bag. If the bag is empty, the
        # token is black, from the unlimited stock.
        def draw_corruption_token!(player, reason, corporation: nil)
          source = @corruption_bag.empty? ? ' (the bag is empty, so it comes from the stock)' : ''
          color = @corruption_bag.pop || :black
          color = redraw_with_private_k(player, corporation) if color == :black && source.empty? && corporation
          player.corruption_tokens[color] += 1
          @log << "#{player.name} draws a #{color} corruption token for #{reason}#{source}"
          color
        end

        def total_corruption_tokens
          @players.sum { |player| player.corruption_tokens.values.sum }
        end

        # Rules summary 9.2: the coup outcome picks the column; before the coup, the political track does
        # (Military: Dictatorship; Civilian or Neutral: Democracy).
        def corruption_penalty_regime
          @coup_outcome || track_regime
        end

        def track_regime
          @political_track.negative? ? :dictatorship : :democracy
        end

        def corruption_penalty_rate
          row = self.class::CORRUPTION_PENALTY_TABLE.find { |r| total_corruption_tokens <= r[:max] }
          row[corruption_penalty_regime]
        end

        def end_game!(game_end_reason)
          pay_corruption_penalty! unless @finished
          super
        end

        # Rules summary 9.2: each player pays the rate for every black token held. A player without
        # enough cash pays what they can and the rest comes off their final wealth (negative cash).
        def pay_corruption_penalty!
          rate = corruption_penalty_rate
          @log << "Corruption penalty: #{total_corruption_tokens} tokens held in total, "\
                  "#{format_currency(rate)} per black token (#{corruption_penalty_regime.to_s.capitalize})"

          @players.each do |player|
            black = player.corruption_tokens[:black]
            next unless black.positive?

            amount = rate * black
            player.spend(amount, @bank, check_cash: false, check_positive: false)
            @log << "#{player.name} pays #{format_currency(amount)} for #{black} black tokens"
          end
        end

        # Rules summary 9.3: ties go to the player with fewer black tokens, then fewer white tokens.
        def result
          result_players
            .sort_by { |p| [-player_value(p), p.corruption_tokens[:black], p.corruption_tokens[:white]] }
            .to_h { |p| [p.id, player_value(p)] }
        end

        def player_card_rows(player)
          tokens = player.corruption_tokens
          ['Corruption:', corruption_counts(tokens[:white], tokens[:black])]
        end

        # Info page: what is left in the bag, the tokens each player holds and the end-game table.
        # Info page: the Political Track scale (Neutral only while the marker is still there), the corruption
        # bag, the tokens held by each player and the end-game penalty table.
        def timeline
          bag = @corruption_bag.tally
          held = @players.map do |player|
            tokens = player.corruption_tokens
            "#{player.name}:  #{corruption_counts(tokens[:white], tokens[:black])}"
          end

          [
            "#{bold_text('POLITICAL TRACK')}: #{track_scale_label(@political_track)}",
            political_track_scale,
            "\u00A0",
            "#{bold_text('CORRUPTION')}:",
            "BAG:  #{corruption_counts(bag[:white] || 0, bag[:black] || 0)}",
            *held,
            "#{bold_text('End-game Corruption Penalty')} ($ per black token) - Dictatorship / Democracy",
            corruption_penalty_table_line,
          ]
        end

        def political_track_scale
          limit = self.class::POLITICAL_TRACK_LIMIT
          (-limit..limit).filter_map do |position|
            next if position.zero? && !@political_track.zero?

            label = track_scale_label(position)
            label = "\u25B6#{bold_text(label)}\u25C0" if position == @political_track
            if position <= -self.class::RADICAL_THRESHOLD
              "#{label} >>"
            elsif position >= self.class::RADICAL_THRESHOLD
              "<< #{label}"
            else
              label
            end
          end.join(' | ')
        end

        def corruption_counts(white, black)
          "#{white}x\u26AA  #{black}x\u26AB"
        end

        def corruption_penalty_table_line
          low = 1
          self.class::CORRUPTION_PENALTY_TABLE.map do |row|
            range = if row[:max] == Float::INFINITY
                      "#{bold_text(low.to_s)}+"
                    elsif low == 1
                      "<=#{bold_text(row[:max].to_s)}"
                    else
                      "#{bold_text(low.to_s)}\u2013#{bold_text(row[:max].to_s)}"
                    end
            low = row[:max] + 1
            "#{range}: #{format_currency(row[:dictatorship])}/#{format_currency(row[:democracy])}"
          end.join(' | ')
        end

        # Mathematical bold letters, to fake bold in the plain-text Info page and log.
        BOLD_CHARS = {
          'A' => '𝐀',
          'B' => '𝐁',
          'C' => '𝐂',
          'D' => '𝐃',
          'E' => '𝐄',
          'F' => '𝐅',
          'G' => '𝐆',
          'H' => '𝐇',
          'I' => '𝐈',
          'J' => '𝐉',
          'K' => '𝐊',
          'L' => '𝐋',
          'M' => '𝐌',
          'N' => '𝐍',
          'O' => '𝐎',
          'P' => '𝐏',
          'Q' => '𝐐',
          'R' => '𝐑',
          'S' => '𝐒',
          'T' => '𝐓',
          'U' => '𝐔',
          'V' => '𝐕',
          'W' => '𝐖',
          'X' => '𝐗',
          'Y' => '𝐘',
          'Z' => '𝐙',
          'a' => '𝐚',
          'b' => '𝐛',
          'c' => '𝐜',
          'd' => '𝐝',
          'e' => '𝐞',
          'f' => '𝐟',
          'g' => '𝐠',
          'h' => '𝐡',
          'i' => '𝐢',
          'j' => '𝐣',
          'k' => '𝐤',
          'l' => '𝐥',
          'm' => '𝐦',
          'n' => '𝐧',
          'o' => '𝐨',
          'p' => '𝐩',
          'q' => '𝐪',
          'r' => '𝐫',
          's' => '𝐬',
          't' => '𝐭',
          'u' => '𝐮',
          'v' => '𝐯',
          'w' => '𝐰',
          'x' => '𝐱',
          'y' => '𝐲',
          'z' => '𝐳',
          '0' => '𝟎',
          '1' => '𝟏',
          '2' => '𝟐',
          '3' => '𝟑',
          '4' => '𝟒',
          '5' => '𝟓',
          '6' => '𝟔',
          '7' => '𝟕',
          '8' => '𝟖',
          '9' => '𝟗',
        }.freeze

        def bold_text(text)
          text.gsub(/[A-Za-z0-9]/, BOLD_CHARS)
        end

        # Rules summary 1.3: four different companies start with one alignment token each, two Civilian
        # and two Military, drawn at random among the companies in play.
        def setup_political_track!
          @political_track = 0
          @corporation_alignment = Hash.new { |h, k| h[k] = { civilian: 0, military: 0 } }
          @paramilitary_hexes_remaining = paramilitary_hexes.dup
          @pending_paramilitary = nil

          military, civilian = @corporations.sort_by { rand }.first(4).each_slice(2).to_a
          military.each { |c| @corporation_alignment[c][:military] += 1 }
          civilian.each { |c| @corporation_alignment[c][:civilian] += 1 }
          tokens = military.map { |c| "#{c.name} (Military)" } + civilian.map { |c| "#{c.name} (Civilian)" }
          setup_log << "Starting corporation alignment tokens: #{tokens.join(', ')}."
          flush_setup_log!
        end

        attr_reader :political_track, :coup_outcome

        def corporation_alignment(corporation)
          @corporation_alignment[corporation]
        end

        # Rules summary 1.3: when a company with a starting alignment token floats, the marker moves
        # toward that token's side.
        def float_corporation(corporation)
          super
          alignment = @corporation_alignment[corporation]
          move_political_track!(:civilian) if alignment[:civilian].positive?
          move_political_track!(:military) if alignment[:military].positive?
        end

        # Rules summary 6.1: one space, or two from space 3 or more on the opposite side; Neutral is
        # skipped and the marker never goes beyond either end.
        def move_political_track!(side)
          return @log << 'The Political Track is locked after the coup: the marker does not move' if coup_resolved?

          direction = side == :civilian ? 1 : -1
          far_on_other_side = -direction * @political_track >= self.class::RADICAL_THRESHOLD
          position = @political_track + (direction * (far_on_other_side ? 2 : 1))
          position += direction if position.zero?
          limit = self.class::POLITICAL_TRACK_LIMIT
          @political_track = position.clamp(-limit, limit)
          @log << "The political marker moves to #{political_track_label}"
          update_status_tile!
        end

        # The A2 status tile shows the marker: orange on Neutral, green on the Military side and blue on
        # the Civilian side.
        def update_status_tile!
          tile = hex_by_id('A2').tile
          tile.location_name = "STATUS: \n#{track_scale_label(@political_track)}"
          tile.color = if @political_track.zero?
                         :orange
                       else
                         @political_track.negative? ? :green : :blue
                       end
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return false if from.hex&.id == 'A2'

          super
        end

        def track_scale_label(position)
          return 'NEUTRAL' if position.zero?

          position.positive? ? "CIV #{position}" : "MIL #{position.abs}"
        end

        def political_track_label
          return 'Neutral' if @political_track.zero?

          "#{@political_track.positive? ? 'Civilian' : 'Military'} #{@political_track.abs}"
        end

        def paramilitary_hex_unclaimed?(hex)
          @paramilitary_hexes_remaining.include?(hex.id)
        end

        # Rules summary 6.2: the first tile laid in a paramilitary hex hands its token to the company,
        # whose president then chooses a side (ParamilitaryChoice step).
        def claim_paramilitary_hex!(hex, corporation)
          @paramilitary_hexes_remaining.delete(hex.id)
          @pending_paramilitary = { corporation: corporation, hex: hex }
        end

        def pending_paramilitary_choice_for?(entity)
          @pending_paramilitary&.dig(:corporation) == entity
        end

        def pending_paramilitary_hex
          @pending_paramilitary&.dig(:hex)
        end

        # Rules summary 6.2: the token counts as one of the company's alignment tokens, the marker moves
        # toward the chosen side, and the president draws a corruption token, plus a second one if the
        # first is white.
        def resolve_paramilitary_choice!(corporation, choice)
          raise GameError, "Invalid choice: #{choice}" unless %w[civilian military discard].include?(choice)

          hex = pending_paramilitary_hex
          @pending_paramilitary = nil
          # Rules summary 11 (C): the token is discarded; the marker does not move and nothing is drawn.
          if choice == 'discard'
            raise GameError, 'Only the owner of Misioneros Campesinos may discard' unless owns_private?(corporation, '(C)')

            return @log << "#{corporation.name} discards the paramilitary token at #{hex.name} (Misioneros Campesinos)"
          end

          side = choice.to_sym
          @corporation_alignment[corporation][side] += 1
          @log << "#{corporation.name} supports the #{side.to_s.capitalize} side at #{hex.name}"
          move_political_track!(side)

          reason = 'supporting a side in a paramilitary hex'
          first = draw_corruption_token!(corporation.owner, reason, corporation: corporation)
          draw_corruption_token!(corporation.owner, reason, corporation: corporation) if first == :white
        end

        def coup_resolved?
          !@coup_outcome.nil?
        end

        # Rules summary 1.5: each 5-train bought from the bank reveals the top card of the deck; the
        # Coup Attempt card resolves the coup at once.
        def reveal_political_situation_card!
          card = @political_situation_deck.shift
          return @log << 'Political Situation card: Calm' if card == :calm

          @log << 'Political Situation card: Coup Attempt'
          resolve_coup!
        end

        # Rules summary 6.3: outcome, token cancellation, regime effects, then closures.
        def resolve_coup!
          @coup_outcome = track_regime

          # Rules summary 11 (I): the owning company may first discard one of its alignment tokens.
          i_owner = @corporations.find { |c| owns_private?(c, '(I)') }
          return @pending_coup_i = i_owner if i_owner && @corporation_alignment[i_owner].values.sum.positive?

          finish_coup!
        end

        def pending_coup_i_choice
          @pending_coup_i
        end

        def resolve_private_i_choice!(choice)
          corporation = @pending_coup_i
          side = choice.to_sym
          if %i[civilian military].include?(side) && @corporation_alignment[corporation][side].positive?
            @corporation_alignment[corporation][side] -= 1
            @log << "#{corporation.name} discards 1 #{side.to_s.capitalize} token (Orejuela Abogados)"
          end
          @pending_coup_i = nil
          finish_coup!
        end

        def finish_coup!
          @coup_report = Hash.new { |h, k| h[k] = [] }
          @corporation_alignment.each_value do |alignment|
            pairs = [alignment[:civilian], alignment[:military]].min
            alignment[:civilian] -= pairs
            alignment[:military] -= pairs
          end

          @coup_outcome == :democracy ? apply_democracy! : apply_dictatorship!

          @companies.dup.each { |company| remove_company(company) }
          unless @paramilitary_hexes_remaining.empty?
            @coup_report[:other] << 'The remaining paramilitary tokens are removed from the board.'
          end
          @paramilitary_hexes_remaining.each { |hex_id| remove_militia_icon!(hex_id) }.clear
          @coup_report[:other] << 'All Private Companies close, without compensation to the owners.'
          log_coup_report!
        end

        COUP_LOG_RULE = '-' * 61

        # Rules summary 6.3: the coup is written to the log as one block.
        def log_coup_report!
          @log << COUP_LOG_RULE
          @log << "#{'-' * 19}  #{bold_text('COUP ATTEMPT')}  #{'-' * 19}"
          @log << COUP_LOG_RULE
          @log << "Coup Attempt Result: #{@coup_outcome.to_s.upcase}"
          { benefited: 'BENEFITED:', punishment: 'PUNISHMENT:', direct: 'DIRECT EFFECTS:', other: 'OTHER EFFECTS:' }
            .each do |key, title|
              next if @coup_report[key].empty?

              @log << COUP_LOG_RULE
              @log << title
              @coup_report[key].each { |line| @log << line }
            end
          @log << COUP_LOG_RULE
        end

        # Rules summary 6.3: the floated company with the worst balance toward the winning side; ties go
        # to the higher share price, then to the one that operates first (Corporation#<=>).
        def least_aligned_corporation(winner)
          loser = winner == :civilian ? :military : :civilian
          @corporations.select(&:floated?).min_by do |corporation|
            alignment = @corporation_alignment[corporation]
            [alignment[winner] - alignment[loser], corporation]
          end
        end

        # Rules summary 6.4: 8-trains leave the game (gray tiles come with the D phase), Civilian
        # companies move right once per Civilian token, and the least aligned company's share price
        # drops to the lowest value that is at least half of it.
        def apply_democracy!
          remove_trains!('8')
          @phase.phases.reject! { |phase| phase[:name] == '8' } unless @phase.name == '8'
          @phase.next_on = Array(@phase.upcoming&.dig(:on))

          @corporations.select(&:floated?).each do |corporation|
            tokens = @corporation_alignment[corporation][:civilian]
            next unless tokens.positive?

            tokens.times { @stock_market.move_right(corporation) }
            @coup_report[:benefited] << "#{corporation.name} - (#{tokens} CIVILIAN token(s)). Moves #{tokens} space(s) "\
                                        "right on the stock market (#{format_currency(corporation.share_price.price)})."
          end
          @coup_report[:direct] << 'Last train type available: D (8-trains removed from the game).'
          @coup_report[:direct] << 'Higher corruption cost at game end.'

          return unless (corporation = least_aligned_corporation(:civilian))

          @stock_market.move(corporation, half_share_price(corporation.share_price.price).coordinates, force: true)
          @coup_report[:punishment] << "#{corporation.name} (least aligned with the winner) loses share price."
          @coup_report[:punishment] << "Its share price drops to #{format_currency(corporation.share_price.price)}."
        end

        # Rightmost (then highest) space with the lowest value that is at least half of the price.
        def half_share_price(price)
          candidates = @stock_market.market.flatten.compact.select { |sp| sp.price * 2 >= price }
          lowest = candidates.map(&:price).min
          candidates.select { |sp| sp.price == lowest }.min_by { |sp| [-sp.coordinates[1], sp.coordinates[0]] }
        end

        # Rules summary 6.5: D-trains leave the game (so gray tiles never come), the border cities get
        # fixed military values, Military companies receive $80 per Military token, and the president of
        # the least aligned company receives 10 black corruption tokens from the stock.
        def apply_dictatorship!
          remove_trains!('D')

          dictatorship_border_tiles.each do |hex_id, code|
            hex = hex_by_id(hex_id)
            tile = Tile.from_code(hex_id, :red, code)
            tile.location_name = hex.tile.location_name
            update_tile_lists(tile, hex.tile)
            hex.lay(tile)
          end
          clear_graph

          @corporations.select(&:floated?).each do |corporation|
            tokens = @corporation_alignment[corporation][:military]
            next unless tokens.positive?

            amount = tokens * self.class::MILITARY_BONUS_PER_TOKEN
            @bank.spend(amount, corporation)
            @coup_report[:benefited] << "#{corporation.name} receives #{format_currency(amount)} from the bank "\
                                        "(#{tokens} Military token(s))."
          end
          @coup_report[:direct] << 'Border city hexes have their revenue changed.'
          @coup_report[:direct] << 'Last train type available: 8 (D-trains and gray tiles removed from the game).'
          @coup_report[:direct] << 'Lower corruption cost at game end.'

          return unless (corporation = least_aligned_corporation(:military))

          @coup_report[:punishment] << "#{corporation.name} (least aligned with the winner) is persecuted "\
                                       'by the new government.'
          return unless (president = corporation.owner)

          president.corruption_tokens[:black] += 10
          @coup_report[:punishment] << "Its president (#{president.name}) receives 10 black corruption tokens."
        end

        # A copy, so Democracy can drop the 8 phase.
        def game_phases
          self.class::PHASES.dup
        end

        def remove_trains!(name)
          @depot.upcoming.select { |train| train.name == name }.each { |train| @depot.remove_train(train) }
        end

        # Rules summary 11 (A): once per game, the owner of Investidores Unidos fixes the par price of a
        # company that has not been started (FixParPrice step, at the start of each Stock Round).
        def private_a_usable_this_stock_round?
          !@private_a_used
        end

        def private_a_owner
          owner = @companies.find { |c| c.sym == '(A)' }&.owner
          owner if owner&.player?
        end

        def use_private_a!(corporation, share_price)
          @private_a_used = true
          @fixed_par_prices[corporation] = share_price
          @log << "#{corporation.name} has its par price fixed at #{format_currency(share_price.price)} "\
                  '(Investidores Unidos)'
        end

        def skip_private_a!(player)
          @log << "#{player.name} does not use Investidores Unidos in this Stock Round"
        end

        def fixed_par_price_for(corporation)
          @fixed_par_prices[corporation]
        end

        # Rules summary 11 (E): from the first 3-train, Casa Ruiz de Assistencia may be donated to a
        # company its owner presides over.
        def private_e_donatable?(corporation)
          return false unless corporation&.corporation?
          return false unless @phase.status.include?('can_buy_companies')

          owner = @companies.find { |c| c.sym == '(E)' }&.owner
          owner&.player? && corporation.owner == owner
        end

        def donate_private_e!(corporation)
          company = @companies.find { |c| c.sym == '(E)' }
          owner = company.owner
          owner.companies.delete(company)
          company.owner = corporation
          corporation.companies << company
          @bank.spend(self.class::PRIVATE_E_DONATION, corporation)
          @log << "#{owner.name} donates #{company.name} to #{corporation.name}, which receives "\
                  "#{format_currency(self.class::PRIVATE_E_DONATION)} from the bank"
        end

        # Rules summary 11 (M): once per Stock Round, on the owner's turn, draw a corruption token and
        # receive $5 times the phase number. The D phase has no number, and an empty bag ends the ability.
        def private_m_payment
          5 * @phase.name.to_i
        end

        def private_m_usable?(player)
          return false unless player&.player?
          return false unless @round.is_a?(Engine::Round::Stock)
          return false if @private_m_used_turn == @turn || @phase.name == 'D' || @corruption_bag.empty?

          @companies.find { |c| c.sym == '(M)' }&.owner == player
        end

        def use_private_m!(player)
          raise GameError, 'Sociedade Caja Negra cannot be used now' unless private_m_usable?(player)

          @private_m_used_turn = @turn
          amount = private_m_payment
          draw_corruption_token!(player, 'using Sociedade Caja Negra')
          @bank.spend(amount, player)
          @log << "#{player.name} receives #{format_currency(amount)} from the bank (Sociedade Caja Negra)"
        end

        # Rules summary 3.5 and 11 (H): on a high dividend, the bank adds 10% of it to the treasury of the
        # company that owns Gutiérrez y Asociados.
        def pay_private_h_bonus!(corporation, revenue)
          return unless owns_private?(corporation, '(H)')

          bonus = (revenue * 0.1).round
          @bank.spend(bonus, corporation)
          @log << "#{corporation.name} receives #{format_currency(bonus)} from the bank for a high dividend "\
                  '(Gutiérrez y Asociados)'
        end

        # Rules summary 5 and 11 (K): once per Operating Round, a black token from the bag drawn because
        # of the company that owns Hernandez Abogados goes back, and the president draws again.
        def redraw_with_private_k(player, corporation)
          return :black if corporation.owner != player || !owns_private?(corporation, '(K)')
          return :black if @private_k_used_or == @or_round_number

          @private_k_used_or = @or_round_number
          @corruption_bag = (@corruption_bag + [:black]).sort_by { rand }
          @log << "#{player.name} returns a black token to the bag and draws again (Hernandez Abogados)"
          @corruption_bag.pop
        end

        # Rules summary 11 (D): the new train is the cheapest one in the supply (not one discarded by
        # another company).
        def private_d_target_train
          @depot.upcoming.min_by(&:price)
        end

        def exchange_train_for_private_d!(corporation, old_train)
          new_train = private_d_target_train
          price = new_train.price - old_train.price
          corporation.trains.delete(old_train)
          @depot.forget_train(old_train)
          @log << "#{corporation.name} discards a #{old_train.name}-train, which leaves the game, and buys a "\
                  "#{new_train.name}-train for #{format_currency(price)} (Ferramenteria Ochoa)"
          source = new_train.owner
          buy_train(corporation, new_train, price)
          @phase.buying_train!(corporation, new_train, source)
        end

        def remaining_paramilitary_hexes
          @paramilitary_hexes_remaining
        end

        # Rules summary 6.2 and 11 (N): the token leaves the board and the president takes 2 black
        # corruption tokens from the stock.
        def use_private_n!(corporation, hex_id)
          @paramilitary_hexes_remaining.delete(hex_id)
          remove_militia_icon!(hex_id)
          corporation.owner.corruption_tokens[:black] += 2
          @log << "#{corporation.name} removes the paramilitary token at #{hex_id} (Emisarios de las Sombras); "\
                  "#{corporation.owner.name} takes 2 black corruption tokens"
        end

        # A paramilitary token that leaves the board without a tile (N or the coup) takes its icon with it.
        def remove_militia_icon!(hex_id)
          hex_by_id(hex_id).tile.icons.reject! { |icon| icon.name == 'militia' }
        end

        SETUP_LOG_RULE = "#{'-' * 31} SETUP #{'-' * 32}".freeze
        SETUP_LOG_END = '-' * 70

        def setup_log
          @setup_log ||= []
        end

        # Writes the setup draws to the log as one block, the private companies last.
        def flush_setup_log!
          privates, others = setup_log.partition { |line| line.start_with?('Private companies') }
          @log << SETUP_LOG_RULE
          (others + privates).each { |line| @log << line }
          @log << SETUP_LOG_END
          @setup_log = []
        end

        # Each private giving a discount is named once (the core message repeats it per ability).
        def log_cost_discount(spender, abilities, discount)
          return unless discount.positive?

          @log << "#{spender.name} receives a discount of #{format_currency(discount)} from "\
                  "#{Array(abilities).map { |a| a.owner.name }.uniq.join(', ')}"
        end

        # A star marks a route longer than the train's range, which only Expresso Resplandor (G) allows.
        def route_distance_str(route)
          used = route_distance(route)
          distance = route.train.distance
          distance.is_a?(Numeric) && used > distance ? "#{used}*" : used.to_s
        end
      end
    end
  end
end
