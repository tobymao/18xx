# frozen_string_literal: true

require_relative '../g_1862/game'
require_relative 'corporation'
require_relative 'meta'

module Engine
  module Game
    module G1862Solo
      class Game < G1862::Game
        include_meta(G1862Solo::Meta)

        attr_reader :ipo_rows
        attr_accessor :ipo_row_index

        # No cert limit
        CERT_LIMIT = {
          1 => 999,
        }.freeze

        STARTING_CASH = {
          1 => 600,
        }.freeze

        # No cert limit
        def show_game_cert_limit?
          false
        end

        def setup_preround
          @base_tiles = []
          @skip_round = {}
          @lner_triggered = nil
          @lner = nil

          # remove reservations (nice to have in starting map)
          @corporations.each { |corp| remove_reservation(corp) }

          @double_parliament = false

          # randomize order of corporations, then remove some based on player count
          @offer_order = @corporations.sort_by { rand }
          removed = @offer_order.take(4)
          removed.each do |corp|
            @offer_order.delete(corp)
            @corporations.delete(corp)

            remove_corporation_hex(corp)

            @log << "Removing #{corp.name} from game"
          end

          # add markers for remaining companies
          @corporations.each { |corp| add_marker(corp) }

          @chartered = {}
          @ipo_row_index = {}

          # randomize and distribute train permits
          permit_list = 2.times.flat_map { %i[freight express local] }
          permit_list.sort_by! { rand }
          @all_permits = permit_list.dup
          @permits = Hash.new { |h, k| h[k] = [] }
          @original_permits = Hash.new { |h, k| h[k] = [] }

          @corporations.each { |c| convert_to_full!(c) }

          # Build draw and draft decks for player hand and IPO rows
          @ipo_rows = [[], [], [], [], [], [], [], [], []]
          create_decks(@corporations)
        end

        def ready_corporations
          @corporations.reject(:closed?)
        end

        def create_decks(corporations)
          draw_deck = []

          corporations.each do |corporation|
            corporation.ipo_shares.each do |share|
              next if share.percent > 10

              company = convert_share_to_company(share)
              company.owner = bank
              draw_deck << company
              @companies << company
            end
          end

          draw_deck.sort_by! { rand }
          deal_deck_to_ipo(draw_deck)
        end

        # create a placeholder 'company' for shares in IPO
        def convert_share_to_company(share)
          description = "Certificate for #{share.percent}\% of #{share.corporation.full_name}."
          Company.new(
            sym: share.id,
            name: share.corporation.name,
            value: 0,
            desc: description,
            type: :share,
            color: share.corporation.color,
            text_color: share.corporation.text_color,
            # reference to share in treasury
            treasury: share,
            revenue: nil,
          )
        end

        def deal_deck_to_ipo(deck)
          all_rows_indexes.each do |row|
            @ipo_rows[row] = deck.pop(6) # 6 shares per row
            @ipo_rows[row].each do |company|
              @ipo_row_index[company] = row
            end
          end
        end

        def game_tiles
          TILES.dup.merge!({
                             'X' =>
                                 {
                                   'count' => 4,
                                   'color' => 'brown',
                                   'code' => '',
                                 },
                           })
        end

        # 1862 solo does not have any parliament rounds
        def next_round!
          @skip_round.clear
          @round =
            case @round
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
                if @lner_triggered
                  @lner_triggered = false
                  form_lner
                end
                new_stock_round
              end
            else
              raise "round class #{@round.class} not handled"
            end
        end

        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        def stock_round
          G1862::Round::Stock.new(self, [
            G1862::Step::BuyTokens,
            G1862::Step::ForcedSales,
            G1862Solo::Step::BuySellParShares,
          ])
        end

        def show_ipo_rows?
          @round.buy_tokens.nil?
        end

        def can_par_corporations?
          @all_permits.any?
        end

        def in_ipo?(company)
          @ipo_rows.flatten.include?(company)
        end

        def ipo_row_and_index(company)
          all_rows_indexes.each do |row|
            index = @ipo_rows[row].index(company)
            return [row, index] if index
          end
          nil
        end

        def ipo_remove(row, company)
          @ipo_rows[row].delete(company)
        end

        def buyable_bank_owned_companies
          []
        end

        def companies_to_payout(_ignore)
          []
        end

        def init_corporations(_stock_market)
          self.class::CORPORATIONS.map do |corp|
            corporation = corp.dup
            corp.deep_freeze
            corporation[:float_percent] = 30
            corporation[:shares] = [30, 10, 10, 10, 10, 10, 10, 10]
            corporation[:max_ownership_percent] = 70
            corporation[:min_price] = 1
            initiated_corp = G1862Solo::Corporation.new(
              **corporation.merge(corporation_opts),
            )
            initiated_corp.presidents_share.buyable = false
            initiated_corp
          end
        end

        def stock_prices
          par_prices
        end

        def par_prices
          @par_prices ||= stock_market.market.first.select { |p| p.type == :par }
        end

        def repar_prices
          @repar_prices ||= stock_market.market.first.select { |p| p.type == :repar }
        end

        # So that value is not shown on company cards representing shares
        def company_value(company)
          corporation = company.treasury.corporation
          corporation.share_price ? corporation.share_price.price : 0
        end

        def company_header(_company)
          '10% SHARE'
        end

        def show_value_of_companies?(_owner)
          true
        end

        def company_revenue_str(_company)
          '0'
        end

        # Timeline information for INFO tab
        def timeline
          timeline = []

          timeline << if @all_permits.empty?
                        'Permits left to assign: None'
                      else
                        "Permits left to assign: #{@all_permits.map(&:to_s).join(', ')}"
                      end

          all_rows_indexes.each do |i|
            ipo_row_i = ipo_timeline(i)
            timeline << "IPO ROW #{i + 1}: #{ipo_row_i.join(', ')}" unless ipo_row_i.empty?
          end

          timeline
        end

        def ipo_timeline(index)
          row = @ipo_rows[index]
          row.map do |company|
            company.name.to_s
          end
        end

        def status_array(corp)
          status = []
          status << %w[Chartered bold] if @chartered[corp]
          status << ["Par: #{format_currency(corp.original_par_price.price)}"] if corp.ipoed
          status << ['Cannot start'] if @all_permits.empty? && !corp.ipoed
          status << ["Permits: #{@permits[corp].map(&:to_s).join(',')}"] if corp.floated?
          status
        end

        def assign_first_permit(corporation)
          raise GameError, 'No permits left to assign' if @all_permits.empty?

          permit = @all_permits.shift
          @permits[corporation] << permit
          @original_permits[corporation] << permit
          @log << "#{corporation.name} is assigned a #{permit.to_s.capitalize} permit"
        end

        # TODO: I assume there is no obligations in 1862 Solo?
        def enforce_obligations; end

        # TODO: Should we use any special sorting in 1862 Solo?
        def bank_sort(corporations)
          corporations.sort_by(&:name)
        end

        def sorted_corporations
          ipoed, others = corporations.reject(&:closed?).partition(&:ipoed)
          ipoed.sort + others
        end

        # TODO: Is this OK as 1862 solo version?
        def available_to_start?(corporation)
          legal_to_start?(corporation)
        end

        def remove_corporation(corp)
          corp.close!

          # TODO: If there are tile or token in this hex, freeze it instead
          remove_corporation_hex(corp)

          all_rows_indexes.each do |row|
            @ipo_rows[row].reject! { |c| c.name == corp.name }
          end

          @log << "Removing #{corp.name} from game"
        end

        # No use in 1862 Solo
        def reorder_players(_order, _log_player_order, _silent); end

        private

        def all_rows_indexes
          (0..8)
        end

        def remove_corporation_hex(corp)
          hex = @hexes.find { |h| h.id == corp.coordinates } # hex_by_id doesn't work here
          old_tile = hex.tile
          tile_string = ''
          hex.tile = Tile.from_code(old_tile.name, 'brown', tile_string)
        end
      end
    end
  end
end
