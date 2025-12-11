# frozen_string_literal: true

require_relative '../g_1846/game'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'step/buy_train'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G18BB
      class Game < G1846::Game
        include_meta(G18BB::Meta)
        include Entities
        include Map

        attr_accessor :leftover_group, :green_2_corps

        GREEN_GROUP = %w[C&O ERIE PRR B&O IC].freeze
        MINORS_GROUP = [
          'Big 4 (Minor)',
          'Nashville and Northwestern (Minor)',
          'Virginia Coal Company (Minor)',
          'Buffalo, Rochester and Pittsburgh (Minor)',
          'Cleveland, Columbus and Cincinnati (Minor)',
        ].freeze
        EXCLUSION_MAP = {
          'BRP' => 'Lake Shore Line',
          'VCC' => 'Tunnel Blasting Company',
          'N&N' => 'Bridging Company',
          'CCC' => 'Ohio & Indiana',
        }.freeze

        ABILITY_ICONS = G1846::Game::ABILITY_ICONS.merge(
          SSC: '18_bb/port-orange'
        ).freeze

        ASSIGNMENT_TOKENS = G1846::Game::ABILITY_ICONS.merge(
          'SSC' => '/icons/18_bb/ssc_token.svg',
          'O&G' => '/icons/18_bb/og_token.svg',
        ).freeze

        OIL_AND_GAS_REVENUE_DESC = 'Oil & Gas'
        BANK_CASH = { 3 => 8000, 4 => 9500, 5 => 11_000, 6 => 13_000 }.freeze

        CERT_LIMIT = {
          3 => { 5 => 14, 4 => 11 },
          4 => { 7 => 14, 6 => 12, 5 => 10, 4 => 8 },
          5 => { 8 => 13, 7 => 12, 6 => 10, 5 => 8, 4 => 6 },
          6 => { 8 => 12, 7 => 10, 6 => 8, 5 => 7, 4 => 6 },

        }.freeze

        STARTING_CASH = { 2 => 600, 3 => 400, 4 => 400, 5 => 400, 6 => 400 }.freeze

        MARKET = [
          %w[0c 10 20 30
             40p 50p 60p 70p 80p 90p 100p 112p 124p 137p 150p
             165 180 195 210 225 240 258 276 295 315 335 355 375 400 430 460
             500 540 580 620 660 700 750 800],
           ].freeze

        def setup
          @leftover_group = [
            'Bridging Company',
            'Boomtown',
            'Grain Mill Company',
            'Lake Shore Line',
            'Little Miami',
            'Louisville, Cincinnati, and Lexington Railroad',
            'Meat Packing Company',
            'Michigan Central',
            'Ohio & Indiana',
            'Oil and Gas Company',
            'Southwestern Steamboat Company',
            'Steamboat Company',
            'Tunnel Blasting Company',
          ]
          @turn = setup_turn
          @second_tokens_in_green = {}

          # When creating a game the game will not have enough to start
          unless (player_count = @players.size).between?(*self.class::PLAYER_RANGE)
            raise GameError, "#{self.class::GAME_TITLE} does not support #{player_count} players"
          end

          corporation_removal_groups.each do |group|
            remove_from_group!(group, @corporations) do |corporation|
              place_home_token(corporation)
              ability_with_icons = corporation.abilities.find { |ability| ability.type == 'tile_lay' }
              remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[corporation.id]) if ability_with_icons
              abilities(corporation, :reservation) do |ability|
                corporation.remove_ability(ability)
              end
              place_second_token(corporation, **place_second_token_kwargs(corporation))
            end
          end

          remove_from_group!(minors_group, @companies) do |company|
            minor_to_close = @minors.find { |m| m.id == company.id }
            minor_to_close.close!
            @minors.delete(minor_to_close)
            company.close!
            @round.active_step.companies.delete(company)
          end

          @minors.each do |m|
            removal = exculsion_map[m.id]
            next unless removal

            @log << "Removing #{removal}"
            company = @companies.find { |c| c.name == removal }
            ability_with_icons = company.abilities.find { |ability| ability.type == 'tile_lay' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            company.close!
            @round.active_step.companies.delete(company)
            @companies.delete(company)
            leftover_group.delete(removal)
          end

          remove_from_group!(leftover_group, @companies) do |company|
            ability_with_icons = company.abilities.find { |ability| ability.type == 'assign_hexes' || ability.type == 'tile_lay' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            company.close!
            @round.active_step.companies.delete(company)
          end

          @log << "Privates in the game: #{@companies.reject { |c| c.name.include?('Pass') }.map(&:name).sort.join(', ')}"
          @log << "Corporations in the game: #{@corporations.map(&:name).sort.join(', ')}"

          @cert_limit = init_cert_limit

          setup_company_price_up_to_face

          @draft_finished = false

          @minors.each do |minor|
            update_map(minor)
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)
            hex = hex_by_id(minor.coordinates)
            token_city = hex&.tile&.cities&.first
            token_city&.place_token(minor, minor.next_token, free: true)
          end

          @tiles.delete(tile_by_id('CM1-0')) if @minors.none? { |m| m.name == 'VCC' }
          @tiles.delete(tile_by_id('M1-0')) if @companies.none? { |c| c.sym == 'GMC' }

          @last_action = nil
        end

        def game_trains
          trains = self.class::TRAINS
          t2 = trains.find { |t| t[:name] == '2' }
          t2[:variants] = [{
            name: '2g',
            distance: 2,
            price: 80,
            obsolete_on: 6,
            rust_on: 6,
          }]
          trains
        end

        def num_trains(train)
          num = super
          num = num +1 if train[:name] == '2' && !@minors.none? {|m| m.name == "BRP"}
          num
        end

        def update_map(minor)
          case minor.name
          when 'BRP'
            brp_tile = Engine::Tile.from_code('E21', :gray, Map::BRP_TILE)
            hex_by_id('E21').lay(brp_tile)
            clear_graph
            connect_hexes
          when 'VCC'
            vcc_tile = Engine::Tile.from_code('H18', :brown, Map::VCC_TILE)
            hex_by_id('H18').lay_downgrade(vcc_tile)
            hex_by_id('G17').tile.borders << Part::Border.new(5, :water, 20, :blue)
            hex_by_id('H16').tile.borders << Part::Border.new(4, :water, 20, :blue)
            clear_graph
            connect_hexes
          when 'BIG4'
            hex = hex_by_id(minor.coordinates)
            old_tile = hex.tile
            big4_tile = tile_by_id('6-0')
            big4_tile.rotate!(1)
            update_tile_lists(big4_tile, old_tile)
            hex.lay(big4_tile)
            clear_graph
            connect_hexes
          end
        end

        def operating_round(round_num)
          @round_num = round_num
          G1846::Round::Operating.new(self, [
            G1846::Step::Bankrupt,
            G18BB::Step::Assign,
            Engine::Step::SpecialToken,
            G1846::Step::SpecialTrack,
            G1846::Step::BuyCompany,
            G1846::Step::IssueShares,
            G1846::Step::TrackAndToken,
            Engine::Step::Route,
            G1846::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18BB::Step::BuyTrain,
            [G1846::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def corporation_removal_groups
          [GREEN_GROUP]
        end

        def minors_group
          @minors_group ||= self.class::MINORS_GROUP
        end

        def exculsion_map
          @exculsion_map ||= self.class::EXCLUSION_MAP
        end

        def sw_steamboat
          @sw_steamboat ||= company_by_id('SSC')
        end

        def oil_and_gas
          @oil_and_gas ||= company_by_id('O&G')
        end

        def num_removals(group)
          num =
            case group
            when MINORS_GROUP
              case @players.size
              when 6
                3
              when 5, 4, 3
                4
              end
            when leftover_group
              case @players.size
              when 6
                leftover_group.size - 7
              when 5
                leftover_group.size - 6
              when 4
                leftover_group.size - 4
              when 3
                leftover_group.size - 2
              end
            else
              case @players.size
              when 6, 5
                0
              when 4
                1
              when 3
                3
              end
            end

          # handle special CCC case.
          num -= 1 if group == leftover_group && @companies.any? { |c| c.id == 'CCC' }
          num
        end

        def new_operating_round(round_num = 1)
          unless @green_2_corps
            corp_num = @players.size == 6 ? 2 : 1
            @green_2_corps = [@corporations.sort.last(corp_num)].flatten
          end
          super
        end

        def crowded_corps
          return super unless @phase.tiles.include?(:brown)

          # 2g does not create a crowded corp in brown
          @crowded_corps ||= corporations.select do |c|
            c.trains.count { |t| !t.obsolete && t.name != '2g' } > train_limit(c)
          end
        end

        def must_buy_train?(entity)
          return super unless @phase.tiles.include?(:brown)

          # 2g does not count as compulsory train purchase
          entity.trains.reject { |t| t.name == '2g' }.empty? &&
            !depot.depot_trains.empty?
        end

        def revenue_for(route, stops)
          revenue = super
          [
          [oil_and_gas, 20],
          [sw_steamboat, 20, 'port-orange'],
          ].each do |company, bonus_revenue, icon|
            id = company&.id
            if id && route.corporation.assigned?(id) && (assigned_stop = stops.find { |s| s.hex.assigned?(id) })
              revenue += bonus_revenue * (icon ? assigned_stop.hex.tile.icons.count { |i| i.name == icon } : 1)
            end
          end

          revenue
        end

        def revenue_str(route)
          str = super
          stops = route.stops
          [
            [oil_and_gas, self.class::OIL_AND_GAS_REVENUE_DESC],
            [sw_steamboat, 'SW Port'],
          ].each do |company, desc|
            id = company&.id
            str += " + #{desc}" if id && route.corporation.assigned?(id) && stops.any? { |s| s.hex.assigned?(id) }
          end
          str
        end

        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          return true if tile.name == 'M1'
          super
        end

         def upgrades_to?(from, to, _special = false, selected_company: nil)
          return true if from.color == :white && to.name == "M1"

          super
        end

      end
    end
  end
end
