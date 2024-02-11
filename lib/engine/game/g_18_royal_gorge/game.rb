# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'trains'

module Engine
  module Game
    module G18RoyalGorge
      class Game < Game::Base
        include_meta(G18RoyalGorge::Meta)
        include Entities
        include Map
        include Trains

        attr_accessor :gold_shipped
        attr_reader :gold_corp, :steel_corp, :available_steel, :gold_cubes

        CURRENCY_FORMAT_STR = '$%s'
        BANK_CASH = 99_999
        CERT_LIMIT = { 2 => 20, 3 => 14, 4 => 10 }.freeze
        STARTING_CASH = { 2 => 800, 3 => 550, 4 => 400 }.freeze

        STOCKMARKET_COLORS = {
          par: :yellow,
          par_1: :green,
          par_2: :brown,
          endgame: :red,
        }.freeze
        MARKET = [
          %w[30 35 40 45 50 55 60p 65p 70p 80p 90x 100x 110x 120x 130z 145z 160z 180z 200 220 240 260 280 310e 340e 380e 420e
             460e],
        ].freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Par values in Yellow Phase',
                                              par_1: 'Additional par values in Green Phase',
                                              par_2: 'Additional par values in Brown Phase').freeze
        MUST_SELL_IN_BLOCKS = true
        SELL_BUY_ORDER = :sell_buy

        TILE_LAYS = ([{ lay: true, upgrade: true, cost: 0 }] * 6).freeze
        MUST_BUY_TRAIN = :always
        CAPITALIZATION = :incremental
        ESTABLISHED = {
          'KP' => 1869,
          'RG' => 1870,
          'SPP' => 1872,
          'PAV' => 1875,
          'SF' => 1876,
          'NO' => 1881,
          'CM' => 1883,
          'S' => 1887,
          'FCC' => 1893,
          'CSCC' => 1897,
          'CS' => 1898,
        }.freeze

        GOLD_DIVIDENDS = [50, 90, 140, 200, 270, 350].freeze
        GOLD_SHIP_LIMIT = {
          'Yellow' => 2,
          'Green' => 4,
          'Brown' => 5,
          'Silver' => 5,
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          green_par: ['Green Par Available'],
          brown_par: ['Brown Par Available'],
        )

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def game_companies
          YELLOW_COMPANIES.sort_by { rand }.take(2).sort_by { |c| c[:sym] } +
            GREEN_COMPANIES.sort_by { rand }.take(2).sort_by { |c| c[:sym] } +
            BROWN_COMPANIES.sort_by { rand }.take(1)
        end

        def game_corporations
          # SF, RG, and three random corporations
          corporations = INCLUDED_CORPORATIONS + MAYBE_CORPORATIONS.sort_by { rand }.take(3)

          # sort by established year, to create yellow/green/brown tranches
          corporations = corporations.sort_by { |c| ESTABLISHED[c[:sym]] }

          # put established year on charter
          corporations = corporations.map do |corporation|
            corp = corporation.dup
            corp[:abilities] = [{ type: 'base', description: "Est. #{ESTABLISHED[corp[:sym]]}" }]
            corp
          end

          @log << "Railroads in the game: #{corporations.map { |c| c[:sym] }.join(', ')}"

          corporations + self.class::METAL_CORPORATIONS
        end

        def setup
          @corporation_phase_color = {}
          @corporations[0..1].each { |c| @corporation_phase_color[c.name] = 'Yellow' }
          @corporations[2..3].each { |c| @corporation_phase_color[c.name] = 'Green' }
          @corporations[4..4].each { |c| @corporation_phase_color[c.name] = 'Brown' }

          @available_par_groups = %i[par]

          @steel_corp = init_metal_corp(corporation_by_id('CF&I'))
          @gold_corp = init_metal_corp(corporation_by_id('VGC'))

          init_available_steel
          @steel_corp.cash = 50

          @gold_cubes = Hash.new(0)
          @gold_shipped = 0
        end

        def init_available_steel
          @available_steel = {
            yellow: {
              'A' => [30, 20, 10, 0],
              'B' => [30, 20, 10, 0],
              'C' => [30, 20, 10, 0],
              'D' => [30, 20, 10, 0],
            },
            green: {
              'E' => [30, 20],
              'F' => [30, 20],
            },
            brown: {
              'G' => [30],
              'H' => [30],
            },
            gray: {
              'I' => [],
            },
          }
        end

        def status_array(corporation)
          if can_start?(corporation) || corporation.type == :metal
            nil
          else
            ["Available in #{@corporation_phase_color[corporation.name]} Phase"]
          end
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18RoyalGorge::Step::SingleItemAuction,
          ])
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G18RoyalGorge::Step::BuySellParShares,
          ])
        end

        def can_start?(corporation)
          case @phase.name
          when 'Yellow'
            @corporation_phase_color[corporation.name] == @phase.name
          when 'Green'
            @corporation_phase_color[corporation.name] != 'Brown'
          else
            true
          end
        end

        def can_par?(corporation, parrer)
          can_start?(corporation) && super
        end

        def event_green_par!
          @log << "-- Event: #{EVENTS_TEXT[:green_par]} --"
          @available_par_groups << :par_1
          update_cache(:share_prices)
        end

        def event_brown_par!
          @log << "-- Event: #{EVENTS_TEXT[:brown_par]} --"
          @available_par_groups << :par_2
          update_cache(:share_prices)
        end

        def par_prices
          @stock_market.share_prices_with_types(@available_par_groups)
        end

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
                new_stock_round
              end
            when Round::Auction
              # reorder as normal first so that if there is a tie for most cash,
              # the player who would be first with :after_last_to_act turn order
              # gets the tiebreaker
              reorder_players

              # most cash goes first, but keep same relative order; don't
              # reorder by descending cash
              @players.rotate!(@players.index(@players.max_by(&:cash)))

              new_stock_round
            end
        end

        def operating_order
          super.select { |c| c.type == :rail }
        end

        def market_share_limit(corporation)
          corporation.type == :metal ? 10 : self.class::MARKET_SHARE_LIMIT
        end

        def init_metal_corp(corporation)
          corporation.ipoed = true
          corporation.floated = true
          price = @stock_market.share_price([0, 3])
          @stock_market.set_par(corporation, price)
          bundle = ShareBundle.new(corporation.shares_of(corporation))
          @share_pool.transfer_shares(bundle, @share_pool)
          corporation
        end

        def corporation_opts
          @players.size == 2 ? { max_ownership_percent: 70 } : {}
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            G18RoyalGorge::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18RoyalGorge::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def or_round_finished
          # debt increases
        end

        def or_set_finished
          handle_metal_payout(@steel_corp)
          init_available_steel
          @steel_corp.cash = 50

          handle_metal_payout(@gold_corp)
          @gold_shipped = 0
          update_gold_corp_cash!
        end

        def handle_metal_payout(entity)
          revenue = entity.cash
          per_share = revenue / 10
          payouts = {}
          @players.each do |payee|
            amount = payee.num_shares_of(entity) * per_share
            payouts[payee] = amount if amount.positive?
            entity.spend(amount, payee, check_positive: false)
          end
          payouts[@bank] = entity.cash
          entity.spend(entity.cash, @bank, check_positive: false)
          receivers = payouts
                        .sort_by { |_r, c| -c }
                        .map { |receiver, cash| "#{format_currency(cash)} to #{receiver.name}" }.join(', ')
          msg = "#{entity.name} pays out #{format_currency(revenue)} = "\
                "#{format_currency(per_share)} per share"
          msg += " (#{receivers})" unless receivers.empty?
          @log << msg

          # share movement
          old_price = entity.share_price
          right_times = [(revenue / old_price.price).to_i, 3].min
          right_times.times do
            @stock_market.move_right(entity)
          end
          log_share_price(entity, old_price, right_times)

          # spreadsheet
          entity.operating_history[[turn - 1, @round.round_num]] = OperatingInfo.new(
            [],
            nil,
            revenue,
            [],
            dividend_kind: revenue.positive? ? 'paid out' : 'withhold',
          )
        end

        def show_map_legend?
          true
        end

        def show_map_legend_on_left?
          @round.is_a?(Round::Operating)
        end

        COLUMN_COLORS = {
          'A' => :yellow,
          'B' => :yellow,
          'C' => :yellow,
          'D' => :yellow,
          'E' => :green,
          'F' => :green,
          'G' => :brown,
          'H' => :brown,
          'I' => :gray,
        }.freeze

        def cell(cost, column, color, action_processor = nil)
          color_sym = COLUMN_COLORS[column]

          chosen_column =
            (@round.steel_column_choice[color_sym] if active_step.is_a?(G18RoyalGorge::Step::Track))

          blank = false
          image_text =
            if cost == 40
              { text: '∞' }
            elsif @available_steel[color_sym][column].include?(cost)
              { image: '/icons/18_royal_gorge/gray_cube.svg' }
            else
              blank = true
              { text: '' }
            end

          unchoosable_color = color_sym == :gray || !@phase.tiles.include?(color_sym)

          cheapest_in_column = cost == (@available_steel[color_sym][column].min || 40)

          # highlight the next cube to use; check for chosen column+price, if
          # none chosen default to cheapest available
          selected =
            if !active_step.is_a?(G18RoyalGorge::Step::Track) || unchoosable_color
              false
            else
              chosen_column = @round.steel_column_choice[color_sym]
              if !chosen_column
                cheapest_column = @available_steel[color_sym].min_by { |_, v| v[-1] || 40 }[0]
                (cheapest_column == column) && cheapest_in_column
              elsif chosen_column == column
                if (price_choice = @round.steel_price_choice[color_sym])
                  price_choice == cost
                else
                  cheapest_in_column
                end
              end
            end
          bg_color = selected ? 'white' : color.to_s

          onclick = lambda do
            puts "hello from #{column} #{cost}"

            if selected
              puts '    NOOP: already using this cell'
            elsif chosen_column && chosen_column != column && @round.laid_track[color_sym]
              puts '    NOOP: already using a different column'
            elsif blank
              puts '    NOOP: no cube available'
            elsif unchoosable_color
              puts '    NOOP: color not available'
            else
              puts '    should update choice to this cell'
              action = Engine::Action::Choose.new(
                current_entity,
                choice: "#{column}-#{cost}"
              )
              if action_processor
                action_processor.call(action)
              else
                process_action(action, add_auto_actions: true).maybe_raise!
              end
            end
          end

          {
            **image_text,
            props: {
              style: { border: '1px solid', color: 'black', backgroundColor: bg_color, cursor: 'pointer', 'user-select': 'none' },
              on: { click: onclick },
            },
          }
        end

        def map_legend(font_color, yellow, green, brown, gray, action_processor: nil)
          [
            # table-wide props
            {
              style: {
                margin: '0.5rem 0 0.5rem 0',
                border: '1px solid',
                borderCollapse: 'collapse',
              },
            },
            # header
            [
              { text: "(#{format_currency(@steel_corp.cash)})", props: { style: { border: '1px solid' } } },
              { text: 'A', props: { style: { border: '1px solid', **legend_header_style('A', :yellow, yellow) } } },
              { text: 'B', props: { style: { border: '1px solid', **legend_header_style('B', :yellow, yellow) } } },
              { text: 'C', props: { style: { border: '1px solid', **legend_header_style('C', :yellow, yellow) } } },
              { text: 'D', props: { style: { border: '1px solid', **legend_header_style('D', :yellow, yellow) } } },
              { text: 'E', props: { style: { border: '1px solid', **legend_header_style('E', :green, green) } } },
              { text: 'F', props: { style: { border: '1px solid', **legend_header_style('F', :green, green) } } },
              { text: 'G', props: { style: { border: '1px solid', **legend_header_style('G', :brown, brown) } } },
              { text: 'H', props: { style: { border: '1px solid', **legend_header_style('H', :brown, brown) } } },
              { text: 'I', props: { style: { border: '1px solid', **legend_header_style('I', :gray, gray) } } },
            ],
            # body
            [
              {
                text: format_currency(40),
                props: { style: { border: "1px solid #{font_color}", color: 'white', backgroundColor: 'black' } },
              },
              cell(40, 'A', yellow, action_processor),
              cell(40, 'B', yellow, action_processor),
              cell(40, 'C', yellow, action_processor),
              cell(40, 'D', yellow, action_processor),
              cell(40, 'E', green, action_processor),
              cell(40, 'F', green, action_processor),
              cell(40, 'G', brown, action_processor),
              cell(40, 'H', brown, action_processor),
              cell(40, 'I', gray, action_processor),
            ],
            [
              {
                text: format_currency(30),
                props: { style: { border: "1px solid #{font_color}", color: 'white', backgroundColor: 'black' } },
              },
              cell(30, 'A', yellow, action_processor),
              cell(30, 'B', yellow, action_processor),
              cell(30, 'C', yellow, action_processor),
              cell(30, 'D', yellow, action_processor),
              cell(30, 'E', green, action_processor),
              cell(30, 'F', green, action_processor),
              cell(30, 'G', brown, action_processor),
              cell(30, 'H', brown, action_processor),
            ],
            [
              {
                text: format_currency(20),
                props: { style: { border: "1px solid #{font_color}", color: 'white', backgroundColor: 'black' } },
              },
              cell(20, 'A', yellow, action_processor),
              cell(20, 'B', yellow, action_processor),
              cell(20, 'C', yellow, action_processor),
              cell(20, 'D', yellow, action_processor),
              cell(20, 'E', green, action_processor),
              cell(20, 'F', green, action_processor),
            ],
            [
              {
                text: format_currency(10),
                props: { style: { border: "1px solid #{font_color}", color: 'white', backgroundColor: 'black' } },
              },
              cell(10, 'A', yellow, action_processor),
              cell(10, 'B', yellow, action_processor),
              cell(10, 'C', yellow, action_processor),
              cell(10, 'D', yellow, action_processor),
            ],
            [
              {
                text: format_currency(0),
                props: { style: { border: "1px solid #{font_color}", color: 'white', backgroundColor: 'black' } },
              },
              cell(0, 'A', yellow, action_processor),
              cell(0, 'B', yellow, action_processor),
              cell(0, 'C', yellow, action_processor),
              cell(0, 'D', yellow, action_processor),
            ],
          ]
        end

        # highlight the selected columns
        def legend_header_style(column, color_sym, color)
          if active_step.is_a?(G18RoyalGorge::Step::Track) &&
             @round.steel_column_choice.value?(column) &&
             @round.laid_track[color_sym]
            { color: 'black', backgroundColor: color.to_s }
          else
            { color: 'white', backgroundColor: 'black' }
          end
        end

        def action_processed(action)
          case action
          when Action::LayTile
            if action.tile.color == :yellow

              hex = action.hex

              hex.original_tile.icons.each do |icon|
                if icon.name == 'mine'
                  action.hex.tile.icons << Part::Icon.new('../icons/18_royal_gorge/gold_cube', 'gold')
                  @gold_cubes[hex.id] += 1
                end
              end
            end
          end
        end

        def gold_slots_available?
          @gold_shipped < GOLD_SHIP_LIMIT[@phase.name]
        end

        def gold_dividend
          GOLD_DIVIDENDS[@gold_shipped]
        end

        def update_gold_corp_cash!
          bank.spend(gold_dividend - @gold_corp.cash, @gold_corp)
        end

        def sell_movement(corporation)
          corporation.type == :rail ? :left_block_pres : :none
        end
      end
    end
  end
end
