# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'stock_market'
require_relative '../base'

module Engine
  module Game
    module G1844
      class Game < Game::Base
        include_meta(G1844::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '%s SFR'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 24, 4 => 18, 5 => 15, 6 => 13, 7 => 11 }.freeze
        CERT_LIMIT_INCLUDES_PRIVATES = false

        STARTING_CASH = { 3 => 800, 4 => 620, 5 => 510, 6 => 440, 7 => 400 }.freeze

        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_block
        MUST_SELL_IN_BLOCKS = true
        POOL_SHARE_DROP = :left_block
        NEXT_SR_PLAYER_ORDER = :most_cash
        EBUY_PRES_SWAP = false
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        EBUY_CAN_TAKE_PLAYER_LOAN = true
        DISCARDED_TRAINS = :remove

        TRACK_RESTRICTION = :permissive
        TILE_RESERVATION_BLOCKS_OTHERS = :always

        ASSIGNMENT_TOKENS = {
          'B1' => '/icons/1844/B1.svg',
          'B2' => '/icons/1844/B2.svg',
          'B3' => '/icons/1844/B3.svg',
          'B4' => '/icons/1844/B4.svg',
          'B5' => '/icons/1844/B5.svg',
          'T1' => '/icons/1844/T1.svg',
          'T2' => '/icons/1844/T2.svg',
          'T3' => '/icons/1844/T3.svg',
          'T4' => '/icons/1844/T4.svg',
          'T5' => '/icons/1844/T5.svg',
        }.freeze

        MARKET = [
        ['',
         '',
         '90',
         '100',
         '110',
         '120',
         '130',
         '140',
         '155',
         '170',
         '185',
         '200',
         '220t',
         '240t',
         '260t',
         '290t',
         '320t',
         '350t'],
        ['',
         '70',
         '80',
         '90',
         '100p',
         '110',
         '120',
         '130',
         '145',
         '160',
         '175',
         '190',
         '210t',
         '230t',
         '250t',
         '280t',
         '310t',
         '340t'],
        %w[55 60 70 80 90p 100 110 120 135 150 165 180 200t 220t 240t 270t 300t 330t],
        %w[50 56 60 70 80p 90 100 110 125 140 155 170 190t 210t 230t],
        %w[45 52 57 60 70p 80 90 100 115 130 145 160],
        %w[40 50 54 58 60p 70 80 90 100x 120],
        %w[35 45 52 56 59 64 70 80],
        %w[30 40 48 54 58 60],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par_1: 'SBB starting price', type_limited: 'Regionals cannot enter').freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :blue, type_limited: :peach).freeze

        PHASES = [
          {
            name: '1',
            train_limit: { 'pre-sbb': 2, regional: 2, historical: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: '2',
            train_limit: { 'pre-sbb': 2, regional: 2, historical: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { 'pre-sbb': 2, regional: 2, historical: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '4',
            on: '4',
            train_limit: { 'pre-sbb': 2, regional: 2, historical: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '7',
            on: '8E',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            num: 13,
            distance: 2,
            price: 90,
            rusts_on: '4',
            variants: [
              {
                name: '2H',
                distance: 2,
                price: 70,
              },
            ],
            events: [{ 'type' => 'train_exports' }],
          },
          {
            name: '3',
            num: 9,
            distance: 3,
            price: 180,
            rusts_on: '6',
            variants: [
              {
                name: '3H',
                distance: 3,
                price: 150,
              },
            ],
            events: [{ 'type' => '2t_downgrade' }, { 'type' => 'company_abilities' }, { 'type' => 'buy_across' }],
          },
          {
            name: '4',
            num: 6,
            distance: 4,
            price: 300,
            rusts_on: '8E',
            variants: [
              {
                name: '4H',
                distance: 4,
                price: 260,
              },
            ],
            events: [{ 'type' => '3t_downgrade' }],
          },
          {
            name: '5',
            num: 6,
            distance: 5,
            price: 450,
            variants: [
              {
                name: '5H',
                distance: 5,
                price: 400,
              },
            ],
            events: [{ 'type' => 'close_companies' }, { 'type' => 'sbb_formation' }],
          },
          {
            name: '6',
            num: 4,
            distance: 6,
            price: 630,
            variants: [
              {
                name: '6H',
                distance: 6,
                price: 550,
              },
            ],
            events: [{ 'type' => '4t_downgrade' }, { 'type' => 'full_capitalization' }],
          },
          {
            name: '8E',
            num: 20,
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 8, 'visit' => 99 }],
            price: 960,
            variants: [
              {
                name: '8H',
                distance: 8,
                price: 700,
              },
            ],
            events: [{ 'type' => '5t_downgrade' }],
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'train_exports' => ['Train Exports', 'Next train exported at the end of each OR set'],
          '2t_downgrade' => ['2 -> 2H', '2 trains downgraded to 2H trains'],
          'company_abilities' => ['Company Abilities', 'Company special abilities can be used'],
          'buy_across' => ['Buy Across', 'Trains can be bought between corporations'],
          '3t_downgrade' => ['3 -> 3H', '3 trains downgraded to 3H trains'],
          'sbb_formation' => ['SBB Forms', 'SBB forms after the Operating Round'],
          '4t_downgrade' => ['4 -> 4H', '4 trains downgraded to 4H trains'],
          'full_capitalization' => ['Full Capitalization', 'Newly formed corporations receive full capitalization'],
          '5t_downgrade' => ['5 -> 5H', '5 trains downgraded to 5H trains'],
        ).freeze

        P4_TILE_LAYS = { 'H17' => 'OP3', 'H19' => 'OP2', 'H21' => 'OP2', 'H23' => 'OP2', 'I16' => 'OP1' }.freeze

        def privates
          @privates ||= @companies.select { |c| c.sym[0] == 'P' }
        end

        def mountain_railways
          @mountain_railways ||= @companies.select { |c| c.sym[0] == 'B' }
        end

        def unactivated_mountain_railways
          mountain_railways.select { |mr| mr.owner&.player? && mr.value.zero? }
        end

        def tunnel_companies
          @tunnel_companies ||= @companies.select { |c| c.sym[0] == 'T' }
        end

        def unactivated_tunnel_companies
          tunnel_companies.select { |tc| tc.owner&.player? && tc.value.zero? }
        end

        def pre_sbb_corporations
          # Priority ordered list of pre-sbb corporations
          @pre_sbb_corps ||= %w[NOB SCB VSB JS GB].map { |id| corporation_by_id(id) }
        end

        def fnm
          @fnm ||= corporation_by_id('FNM')
        end

        def sbb
          @sbb ||= corporation_by_id('SBB')
        end

        def gb
          @gb ||= corporation_by_id('GB')
        end

        def p4
          @p4 ||= company_by_id('P4')
        end

        def p7
          @p7 ||= company_by_id('P7')
        end

        def setup
          setup_destinations
          setup_offboard_bonuses
          mountain_railways.each { |mr| mr.owner = @bank }
          tunnel_companies.each { |tc| tc.owner = @bank }

          @eva = @depot.trains.find { |t| t.name == '5' && t.events.empty? }
          @depot.remove_train(@eva)
          @eva.reserved = true
          @eva.variant = '5H'

          @sbb_train = @depot.trains.find { |t| t.name == '5' && t.events.empty? }
          @depot.forget_train(@sbb_train)
          @sbb_train.variant = '5H'
          @sbb_train.buyable = false
          sbb.shares.select { |s| s.percent == 10 && !s.president }.each { |s| s.double_cert = true }

          @all_tiles.each { |t| t.ignore_gauge_walk = true }
          @_tiles.values.each { |t| t.ignore_gauge_walk = true }
          @hexes.each { |h| h.tile.ignore_gauge_walk = true }
          @graph.clear_graph_for_all
        end

        def setup_destinations
          @corporations.each do |c|
            next unless c.destination_coordinates

            dest_hex = hex_by_id(c.destination_coordinates)
            ability = Ability::Base.new(
              type: 'base',
              description: "Destination: #{dest_hex.location_name} (#{dest_hex.name})",
            )
            c.add_ability(ability)

            dest_hex.assign!(c)
          end
        end

        def setup_offboard_bonuses
          hex_info = @hexes.map do |hex|
            offboard = hex.tile.offboards.first
            next if !offboard || hex.tile.color != :red

            icon = offboard.tile.icons.find { |i| i.name.start_with?('bonus_') }
            [hex, offboard.groups.find { |g| g.size > 1 }, icon ? icon.name.split('_')[1].to_i : nil]
          end.compact
          group_bonus = hex_info.map { |_hex, group, bonus| group && bonus ? [group, bonus] : nil }.compact.to_h

          @hex_bonus_revenue = hex_info.map do |hex, group, bonus|
            [hex, bonus || group_bonus[group]]
          end.compact.to_h
        end

        def event_train_exports!
          @log << "-- Event: #{EVENTS_TEXT['train_exports'][1]} --"
        end

        def event_company_abilities!
          @log << "-- Event: #{EVENTS_TEXT['company_abilities'][1]} --"
        end

        def event_buy_across!
          @log << "-- Event: #{EVENTS_TEXT['buy_across'][1]} --"
        end

        def event_2t_downgrade!
          downgrade_train_type!('2', '2H')
        end

        def event_3t_downgrade!
          downgrade_train_type!('3', '3H')
        end

        def event_close_companies!
          lay_p4_overpass! unless p4.closed?
          p7.revenue = 0
          super
        end

        def event_sbb_formation!
          @log << "-- Event: #{EVENTS_TEXT['sbb_formation'][1]} --"
          @ready_to_form_sbb = true
        end

        def event_4t_downgrade!
          downgrade_train_type!('4', '4H')
        end

        def event_full_capitalization!
          @log << "-- Event: #{EVENTS_TEXT['full_capitalization'][1]} --"
          @full_capitalization = true
          @corporations.select { |corp| corp.type == :historical && !corp.floated }.each do |corp|
            next unless corp.destination_coordinates

            hex_by_id(corp.destination_coordinates).remove_assignment!(corp)
            corp.remove_ability(corp.abilities.find { |a| a.description&.start_with?('Destination') })
          end
        end

        def event_5t_downgrade!
          downgrade_train_type!('5', '5H')
        end

        def downgrade_train_type!(name, downgrade_name)
          owners = Hash.new(0)
          trains.select { |t| t.name == name }.each do |t|
            t.variant = downgrade_name
            owners[t.owner.name] += 1 if t.owner && t.owner != @depot
          end

          @log << "-- Event: #{name} trains downgrade to #{downgrade_name} trains" \
                  " (#{owners.map { |c, t| "#{c} x#{t}" }.join(', ')}) --"
        end

        def form_sbb!
          @log << '-- Event: SBB forms --'

          @stock_market.set_par(sbb, @stock_market.share_prices_with_types(%i[par_1]).first)
          sbb.floatable = true
          sbb.ipoed = true
          sbb.floated = true

          @bank.spend(400, sbb)
          @sbb_train.owner = sbb
          sbb.trains << @sbb_train
          @log << "#{sbb.name} starts with #{format_currency(400)} and a #{@sbb_train.name} train"

          previous_owners = []
          pre_sbb_corporations.each do |corp|
            @log << "#{corp.name} merging into #{sbb.name}"
            previous_owners << corp.owner

            @log << "#{sbb.name} receives #{format_currency(corp.cash)}"
            corp.spend(corp.cash, sbb) if corp.cash.positive?

            place_sbb_tokens!(corp)

            num_trains = corp.trains.size
            if num_trains.positive?
              @log << "#{sbb.name} receives #{num_trains} train#{num_trains == 1 ? '' : 's'}:" \
                      " #{corp.trains.map(&:name).join(', ')}"
              transfer(:trains, corp, sbb)
            end

            sbb_share_exchange!(corp)

            remove_destination_token!(corp)
            close_corporation(corp, quiet: true)
          end

          sbb.tokens.sort_by! { |t| t.used ? 0 : 1 }

          determine_sbb_president!(previous_owners.uniq)
        end

        def place_sbb_tokens!(corporation)
          locations = corporation.tokens.map { |token| token.used ? token.hex.full_name : 'Unused' }.join(', ')
          @log << "#{sbb.name} receives #{corporation.tokens.size} tokens: #{locations}"
          corporation.tokens.each do |token|
            sbb.tokens << Token.new(sbb, price: 100)
            next unless token.used

            if token.city.tokened_by?(sbb)
              @log << "#{sbb.name} already has a token on #{token.hex.full_name}, placing token on charter instead"
              token.remove!
            else
              token.swap!(sbb.tokens.last, check_tokenable: false)
            end
          end
        end

        def sbb_share_exchange!(corporation)
          corporation.share_holders.keys.each do |share_holder|
            sbb_shares = sbb.shares_of(sbb)
            shares = share_holder.shares_of(corporation).map do |corp_share|
              percent = corp_share.president ? 10 : 5
              share = sbb_shares.find { |sbb_share| sbb_share.percent == percent }
              sbb_shares.delete(share)
              share
            end
            next if shares.empty?

            share_holder = @share_pool if share_holder.corporation?
            bundle = ShareBundle.new(shares)
            @share_pool.transfer_shares(bundle, share_holder, allow_president_change: false)

            cash_per_share = corporation.par_price ? corporation.share_price.price - sbb.share_price.price : 0
            cash = cash_per_share * bundle.percent / 5
            msg = share_holder.name.to_s
            if cash.zero? || share_holder == @share_pool
              msg += ' receives'
            elsif cash.positive?
              msg += " receives #{format_currency(cash)} and"
              @bank.spend(cash, share_holder)
            else
              msg += " pays #{format_currency(cash.abs)} and receives"
              share_holder.spend(cash.abs, @bank, check_cash: false)
            end

            msg += " #{bundle.percent}% of #{sbb.name}"
            @log << msg
            next if !share_holder.player? || !share_holder.cash.negative?

            take_player_loan(share_holder, share_holder.cash.abs, interest: 0)
          end
        end

        def determine_sbb_president!(president_priority_order)
          player_share_percent = sbb.player_share_holders
          max_percent = player_share_percent.values.max || 0
          return if max_percent < 10

          # Determine president
          candidates = player_share_percent.select { |_, percent| percent == max_percent }.keys
          if candidates.size > 1
            candidates.sort_by! { |player| president_priority_order.index(player) || president_priority_order.size }
          end
          president = candidates.first

          # Make sure president has a 10% cert
          if (president_shares = president.shares_of(sbb)).none? { |share| share.percent == 10 }
            ten_percent_share = @share_pool.shares_of(sbb).find { |share| share.percent == 10 } ||
                                  president_priority_order[-1].shares_of(sbb).find { |share| share.percent == 10 }
            share_owner = ten_percent_share.owner
            @share_pool.transfer_shares(ShareBundle.new([ten_percent_share]), president, allow_president_change: false)
            @share_pool.transfer_shares(ShareBundle.new(president_shares.take(2)), share_owner, allow_president_change: false)
          end

          # Make sure president has the presidents cert
          if (presidents_share_owner = sbb.presidents_share.owner) != president
            @share_pool.transfer_shares(ShareBundle.new([sbb.presidents_share]), president)
            @share_pool.transfer_shares(
              ShareBundle.new([president_shares.find { |share| !share.president && share.percent == 10 }]),
              presidents_share_owner
            )
          end

          sbb.owner = president
          @log << "#{president.name} becomes the president of #{sbb.name}"
        end

        def player_value(player)
          super - (player.companies & privates).sum(&:value)
        end

        def init_stock_market
          G1844::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def initial_auction_companies
          privates
        end

        def unowned_purchasable_companies(_entity)
          @companies.select { |c| c.owner == @bank }
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Auction
              init_round_finished
              reorder_players(log_player_order: true)
              new_stock_round
            when Engine::Round::Stock
              add_interest_player_loans!
              @operating_rounds = @phase.operating_rounds
              reorder_players(log_player_order: true)
              new_operating_round
            when G1844::Round::Operating
              next_round =
                if @round.round_num < @operating_rounds
                  or_round_finished
                  -> { new_operating_round(@round.round_num + 1) }
                else
                  @turn += 1
                  or_round_finished
                  or_set_finished
                  -> { new_stock_round }
                end
              if @ready_to_form_sbb
                @post_sbb_formation_round = next_round
                new_sbb_formation_round
              else
                next_round.call
              end
            when G1844::Round::SBBFormation
              next_round = @post_sbb_formation_round
              @ready_to_form_sbb = false
              @post_sbb_formation_round = nil
              next_round.call
            end
        end

        def or_set_finished
          @depot.export! if @phase.name.to_i >= 2
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1844::Step::CompanyPendingPar,
            Engine::Step::SelectionAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1844::Step::SpecialChoose,
            G1844::Step::MountainRailwayTrack,
            G1844::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1844::Round::Operating.new(self, [
            Engine::Step::Exchange,
            G1844::Step::SpecialChoose,
            G1844::Step::SpecialTrack,
            G1844::Step::Destination,
            G1844::Step::BuyCompany,
            Engine::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            G1844::Step::DestinationCheck,
            Engine::Step::Token,
            G1844::Step::DestinationCheck,
            G1844::Step::Route,
            G1844::Step::Dividend,
            G1844::Step::BuyTrain,
            [G1844::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def new_sbb_formation_round
          @log << '-- SBB Formation Round --'
          G1844::Round::SBBFormation.new(self, [
            Engine::Step::DiscardTrain,
            G1844::Step::RemoveSBBTokens,
          ])
        end

        def next_sr_player_order
          @round.is_a?(Engine::Round::Auction) ? :least_cash : :most_cash
        end

        def can_par?(corporation, _parrer)
          return false if corporation == sbb

          super
        end

        def after_par(corporation)
          super
          return unless corporation.type == :historical

          num_tokens =
            case corporation.share_price.price
            when 100 then 5
            when 90 then 4
            when 80 then 3
            when 70 then 2
            when 60 then 1
            else 0
            end
          corporation.tokens.slice!(num_tokens..-1)
          @log << "#{corporation.name} receives #{num_tokens} token#{num_tokens > 1 ? 's' : ''}"
          return unless corporation == fnm

          @share_pool.transfer_shares(ShareBundle.new(corporation.shares_of(corporation).take(3)), @share_pool)
          @log << "3 #{corporation.name} shares moved to the market"
          float_corporation(corporation)
        end

        def float_corporation(corporation)
          return if corporation == sbb

          @log << "#{corporation.name} floats"
          multiplier =
            case corporation.type
            when :'pre-sbb' then 2
            when :regional then 5
            when :historical then @full_capitalization ? 10 : 5
            end
          @bank.spend(corporation.par_price.price * multiplier, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
        end

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def sellable_bundles(player, corporation)
          bundles = super
          return bundles if bundles.empty? || corporation.operated?

          bundles.each do |bundle|
            bundle.share_price = @stock_market.find_share_price(corporation, :down).price
          end
          bundles
        end

        def shares_for_presidency_swap(shares, num_shares)
          return super unless shares.first.corporation == sbb

          double_share = shares.find { |s| s.percent == sbb.presidents_share.percent }
          double_share ? [double_share] : shares.take(num_shares)
        end

        def after_buy_company(player, company, _price)
          super
          return if !mountain_railways.include?(company) && !tunnel_companies.include?(company)

          company.revenue = 0
          company.value = 0
        end

        def lay_p4_overpass!
          company = p4
          return if company.abilities.empty?

          owner = company.owner
          compensation = 80

          @log << "#{owner.name} must use #{company.name}" if @phase.name.to_i >= 5
          @log << "#{owner.name} (#{company.name}) lays Furka-Oberalp special tile"
          @log << "#{owner.name} receives #{format_currency(compensation)}"

          @bank.spend(compensation, owner)

          P4_TILE_LAYS.each do |hex_id, tile_name|
            hex = hex_by_id(hex_id)
            tile = @tiles.find { |t| t.name == tile_name }
            if (tunnel_path = hex.tile.paths.find { |path| path.track == :narrow })
              tile = replace_tile_code(tile, extend_tile_code(tile, narrow_track_code_for(tunnel_path.exits)))
              @_tiles[tile.id] = tile
            end

            update_tile_lists(tile, hex.tile)
            hex.lay(tile)
          end
          clear_graph

          @log << "#{company.name} closes"
          company.close!
        end

        def assign_p7_train(corporation)
          company = p7
          @log << "#{company.owner.name} (#{company.name}) assigns EVA #{@eva.name} train to #{corporation.name}"
          buy_train(corporation, @eva, :free)
          company.close!
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          if self.class::MOUNTAIN_HEXES.include?(tile.hex.id)
            return @all_tiles.select { |t| self.class::MOUNTAIN_TILES.include?(t.name) }.uniq(&:name)
          end

          super
        end

        def destinated?(entity)
          return false unless entity.coordinates
          return false unless entity.floated?

          home_node = hex_by_id(entity.coordinates).tile.cities.find { |c| c.tokened_by?(entity) || c.reserved_by?(entity) }
          destination_hex = hex_by_id(entity.destination_coordinates)
          return false if !home_node || !destination_hex
          return false unless destination_hex.assigned?(entity)
          return hex_by_id('H19').tile.paths.any? { |path| path.track == :narrow } if entity == gb

          home_node.walk(corporation: entity) do |path, _|
            return true if destination_hex == path.hex
          end

          false
        end

        def destinated!(corporation)
          remove_destination_token!(corporation)
          multiplier = corporation.type == :historical ? 5 : 2
          amount = corporation.par_price.price * multiplier
          @bank.spend(amount, corporation)
          @log << "#{corporation.name} has reached its destination and receives #{format_currency(amount)}"
        end

        def remove_destination_token!(corporation)
          hex_by_id(corporation.destination_coordinates).remove_assignment!(corporation)
        end

        def must_buy_train?(entity)
          super && entity.type != :'pre-sbb'
        end

        def can_buy_train_from_others?
          @phase.name.to_i >= 3
        end

        def hex_train?(train)
          hex_train_name?(train.name)
        end

        def hex_train_name?(name)
          name[-1] == 'H'
        end

        def express_train?(train)
          train.name[-1] == 'E'
        end

        def route_distance(route)
          hex_train?(route.train) ? route_hex_distance(route) : super
        end

        def route_hex_distance(route)
          edges = route.chains.sum { |conn| conn[:paths].each_cons(2).sum { |a, b| a.hex == b.hex ? 0 : 1 } }
          route.chains.empty? ? 0 : edges + 1
        end

        def route_distance_str(route)
          hex_train?(route.train) ? "#{route_hex_distance(route)}H" : super
        end

        def check_distance(route, visits)
          hex_train?(route.train) ? check_hex_distance(route, visits) : super
        end

        def check_hex_distance(route, _visits)
          distance = route_hex_distance(route)
          raise GameError, "#{distance} is too many hexes for #{route.train.name} train" if distance > route.train.distance
        end

        def check_other(route)
          if route.stops.any? { |stop| stop.route_revenue(route.phase, route.train).zero? }
            raise GameError, 'No Mountain Railway to visit'
          end
          return unless hex_train?(route.train)

          raise GameError, 'Cannot visit offboard hexes' if route.stops.any? { |stop| stop.tile.color == :red }
        end

        def revenue_stops(route)
          stops = super
          return stops unless express_train?(route.train)

          distance = route.train.distance.first['pay']
          return stops if stops.size <= distance

          # Prune the list of stops to improve performance
          stops_by_revenue = stops.sort_by { |stop| -1 * stop.route_revenue(route.phase, route.train) }
          stops = stops_by_revenue.slice!(0...distance)
          unless stops.find { |stop| stop.tokened_by?(route.corporation) }
            stops.pop
            tokened_stop = stops_by_revenue.find { |stop| stop.tokened_by?(route.corporation) }
            stops << tokened_stop if tokened_stop
          end
          stops.concat(stops_by_revenue.select { |stop| stop.tile.color == :red })
        end

        def revenue_for(route, stops)
          revenue = super
          revenue += 10 * stops.size if route.paths.any? { |path| path.track == :narrow }
          revenue += east_west_bonus_revenue(stops)
          revenue += north_south_bonus_revenue(stops)
          revenue
        end

        def revenue_str(route)
          stops = route.stops
          stop_hexes = stops.map(&:hex)
          str = route.hexes.map { |h| stop_hexes.include?(h) ? h&.name : "(#{h&.name})" }.join('-')
          str += ' + EW' if east_west_bonus?(route.stops)
          str += ' + NS' if north_south_bonus?(route.stops)
          str
        end

        def hex_bonus_revenue(hex)
          @hex_bonus_revenue[hex] || 0
        end

        def east_west_bonus?(stops)
          (stops.flat_map(&:groups) & %w[E W]).size == 2
        end

        def east_west_bonus_revenue(stops)
          east_west_bonus?(stops) ? stops.sum { |stop| hex_bonus_revenue(stop.hex) } : 0
        end

        def north_south_bonus?(stops)
          (stops.flat_map(&:groups) & %w[N S]).size == 2
        end

        def north_south_bonus_revenue(stops)
          north_south_bonus?(stops) ? stops.sum { |stop| hex_bonus_revenue(stop.hex) } : 0
        end

        def check_for_mountain_or_tunnel_activation(routes)
          routes.each do |route|
            route.hexes.select { |hex| self.class::MOUNTAIN_HEXES.include?(hex.id) }.each do |hex|
              (unactivated_mountain_railways.map(&:id) & hex.assignments.keys).each do |id|
                mountain_railway = company_by_id(id)
                mountain_railway.value = 150
                mountain_railway.revenue = 40
                hex.remove_assignment!(id)
                @log << "#{mountain_railway.name} has been activated"
              end
            end

            route.paths.select { |path| path.track == :narrow }.each do |path|
              (unactivated_tunnel_companies.map(&:id) & path.hex.assignments.keys).each do |id|
                tunnel_company = company_by_id(id)
                tunnel_company.value = 50
                tunnel_company.revenue = 10
                path.hex.remove_assignment!(id)
                @log << "#{tunnel_company.name} has been activated"
              end
            end
          end
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return to.color == :purple && from.paths.none? { |p| p.track == :narrow } if from.color == :purple
          return %w[14 15 619].include?(to.name) if from.hex.id == 'D15' && from.color == :yellow

          super
        end

        def create_tunnel_tile(hex, tile)
          replace_tile_code(tile, extend_tile_code(hex.tile, narrow_track_code_for(tile.exits)))
        end

        def narrow_track_code_for(exits)
          "path=a:#{exits[0]},b:#{exits[1]},track:narrow"
        end

        def extend_tile_code(tile, additional_code)
          code = tile.code + ';' + additional_code
          code = code[1..-1] if code[0] == ';'
          code
        end

        def replace_tile_code(tile, new_code)
          tile = Engine::Tile.new(
            tile.name,
            code: new_code,
            color: tile.color,
            parts: Engine::Tile.decode(new_code),
            index: tile.index,
            hidden: true,
            ignore_gauge_walk: true,
          )
          tile.ignore_gauge_walk = true
          tile
        end

        def graph_skip_paths(entity)
          entity.type == :regional ? regional_skip_paths : super
        end

        def regional_skip_paths
          @regional_skip_paths ||= @hexes.select { |hex| hex.tile.color == :red }.flat_map do |hex|
            hex.tile.paths.map { |path| [path, true] }
          end.to_h
        end
      end
    end
  end
end
