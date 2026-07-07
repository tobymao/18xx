# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative 'entities'
require_relative 'share_pool'
require_relative '../../round/operating'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G1835
      class Game < Game::Base
        attr_accessor :draft_finished, :pr_can_form, :conversion_choice_during_or
        attr_reader :preussen_may_float

        include_meta(G1835::Meta)
        include CitiesPlusTownsRouteDistanceStr
        include G1835::Entities
        include G1835::Map

        CURRENCY_FORMAT_STR = '%sM'
        # game end current or, when the bank is empty
        GAME_END_CHECK = { bank: :current_or }.freeze
        # bankrupt is allowed, player leaves game
        BANKRUPTCY_ALLOWED = true

        BANK_CASH = 12_000
        PAR_PRICES = {
          'PR' => 154,
          'BY' => 92,
          'SX' => 88,
          'BA' => 84,
          'WT' => 84,
          'HE' => 84,
          'MS' => 80,
          'OL' => 80,
        }.freeze
        CERT_LIMIT = { 3 => 19, 4 => 15, 5 => 12, 6 => 11, 7 => 9 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 475, 5 => 390, 6 => 340, 7 => 310 }.freeze
        # money per initial share sold
        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false
        BUY_SHARE_FROM_OTHER_PLAYER = true

        TOKEN_PLACEMENT_ON_TILE_LAY_ENTITY = :owner

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        MARKET = [['', '', '', ''] + %w[132 148 166 186 208 232 258 286 316 348 382 418],
                  ['', ''] + %w[98 108 120 134 150 168 188 210 234 260 288 318 350 384],
                  %w[82 86 92p 100 110 122 136 152 170 190 212 236 262 290 320],
                  %w[78 84p 88p 94 102 112 124 138 154p 172 192 214], %w[72 80p 86 90 96 104 114 126 140],
                  %w[64 74 82 88 92 98 106],
                  %w[54 66 76 84 90]].freeze

        PHASES = [
          {
            name: '1.1',
            on: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: ['two_tile_lays'],
            operating_rounds: 1,
          },
          {
            name: '1.2',
            on: '2+2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: ['two_tile_lays'],
            operating_rounds: 1,
          },
          {
            name: '2.1',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains lay_or_upgrade],
            operating_rounds: 2,
          },
          {
            name: '2.2',
            on: '3+3',
            train_limit: { major: 4, minor: 2 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains lay_or_upgrade],
            operating_rounds: 2,
          },
          {
            name: '2.3',
            on: '4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains lay_or_upgrade],
            operating_rounds: 2,
          },
          {
            name: '2.4',
            on: '4+4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains lay_or_upgrade],
            operating_rounds: 2,
          },
          {
            name: '3.1',
            on: '5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains lay_or_upgrade],
            operating_rounds: 3,
          },
          {
            name: '3.2',
            on: '5+5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains lay_or_upgrade],
            operating_rounds: 3,
          },
          {
            name: '3.3',
            on: '6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains lay_or_upgrade],
            operating_rounds: 3,
          },
          {
            name: '3.4',
            on: '6+6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains lay_or_upgrade],
            operating_rounds: 3,
          },
        ].freeze

        def self.plus_train_distance(distance)
          [{ 'nodes' => ['town'], 'pay' => distance, 'visit' => distance },
           { 'nodes' => %w[city offboard town], 'pay' => distance, 'visit' => distance }]
        end

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 9 },
                  { name: '2+2', distance: plus_train_distance(2), price: 120, rusts_on: '4+4', num: 4 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 4 },
                  { name: '3+3', distance: plus_train_distance(3), price: 270, rusts_on: '6+6', num: 3 },
                  { name: '4', distance: 4, price: 360, num: 3, events: [{ 'type' => 'pr_can_form' }] },
                  { name: '4+4', distance: plus_train_distance(4), price: 440, num: 1, events: [{ 'type' => 'pr_must_form' }] },
                  {
                    name: '5',
                    distance: 5,
                    price: 500,
                    num: 2,
                    events: [{ 'type' => 'forced_pr_exchange' }, { 'type' => 'close_companies' }],
                  },
                  { name: '5+5', distance: plus_train_distance(5), price: 600, num: 1 },
                  { name: '6', distance: 6, price: 600, num: 2 },
                  { name: '6+6', distance: plus_train_distance(6), price: 720, num: 4 }].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'pr_can_form' => ['Optional Preußen Formation', 'Preußen can choose to form now or at beginning of SR/OR'],
          'pr_must_form' => ['Preußen Formation', 'Preußen forms immediately'],
          'forced_pr_exchange' => ['Forced Preußen exchange',
                                   'Remaining Preußen privates and minors will be exchanged for Preußen shares']
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_trains' => ['Buy trains', 'Can buy trains from other corporations'],
          'two_tile_lays' => ['Two tile lays', 'Major corporations may lay 2 yellow tiles, minor corporations lay 1 yellow tile'],
          'lay_or_upgrade' => ['Lay or upgrade', 'Corporations may lay 1 tile or upgrade 1 tile']
        ).freeze

        LAYOUT = :pointy

        SELL_MOVEMENT = :down_block

        HOME_TOKEN_TIMING = :float

        CORPORATION_BLOCKS = [%w[BY SX], %w[BA WT HE PR], %w[MS OL]].freeze

        LAY_OR_UPGRADE = [{ lay: true, upgrade: true }].freeze
        TWO_LAYS = [{ lay: true, upgrade: false }, { lay: true, upgrade: false }].freeze

        def setup
          # Restore original safe share placement to keep the IPO dropdown pristine
          prussian.shares.last(7).each { |s| s.buyable = false }
          prussian.shares.first.buyable = false

          # Override ipo_percent on the Prussian instance so the UI tracks the 40% public market
          def prussian.ipo_percent
            shares.select(&:buyable).sum(&:percent)
          end

          @corporations.each do |corp|
            corp.shares.reject(&:president).each { |share| share.double_cert = (share.percent == 20) }
          end

          @draft_finished = false

          @draft_round_num = 1
          @preussen_may_float = false

          @corporations.select { |corp| corp.type == :major }.each do |corp|
            @stock_market.set_par(corp, @stock_market.par_prices.find { |share_price| share_price.price == PAR_PRICES[corp.id] })
          end

          corporation_by_id('BY').ipoed = true
          corporation_by_id('SX').ipoed = true
          corporation_by_id('MS').forced_share_percent = 10
          corporation_by_id('OL').forced_share_percent = 10

          @corporation_blocks = CORPORATION_BLOCKS.map { |block| block.map { |c| corporation_by_id(c) } }
        end

        def company_header(company)
          return 'MINOR' if '123456'.include?(company.sym)
          return 'SHARE' if company.sym == 'BY_D'

          'PRIVATE COMPANY'
        end

        def init_share_pool
          G1835::SharePool.new(self)
        end

        def ensure_clemens_round_defined!
          return if self.class.const_defined?(:ClemensDraftRound)

          klass = Class.new(G1835::Round::Draft) do
            def setup
              super
              @clemens_turn = 0
              @entity_index = current_clemens_index
            end

            def current_entity
              entities[current_clemens_index]
            end

            def current_clemens_index
              num_players = entities.size
              return 0 if num_players.zero?

              if @clemens_turn < num_players
                # Reverse phase: passes from last down to first
                num_players - 1 - @clemens_turn
              elsif @clemens_turn < 2 * num_players
                # Forward snake phase: first player goes twice, climbs back to last
                @clemens_turn - num_players
              else
                # Standard clockwise iteration phase for the remainder of the draft
                (@clemens_turn - (2 * num_players)) % num_players
              end
            end

            def next_entity_index!
              @clemens_turn += 1
              @entity_index = current_clemens_index
            end
          end

          self.class.const_set(:ClemensDraftRound, klass)
        end

        def init_round
          if @optional_rules&.include?(:clemens)
            ensure_clemens_round_defined!
            self.class::ClemensDraftRound.new(self, [G1835::Step::Draft])
          else
            G1835::Round::Draft.new(self, [G1835::Step::Draft])
          end
        end

        def new_draft_round
          if @optional_rules&.include?(:clemens)
            ensure_clemens_round_defined!
            self.class::ClemensDraftRound.new(self, [G1835::Step::Draft])
          else
            G1835::Round::Draft.new(self, [G1835::Step::Draft])
          end
        end

        def next_round!
          return super if @draft_finished

          clear_programmed_actions
          @round =
            case @round
            when G1835::Round::Draft
              reorder_players
              new_operating_round(@draft_round_num)
            when G1835::Round::Operating
              @draft_round_num += 1
              new_draft_round
            end
        end

        def operating_round(round_num)
          G1835::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G1835::Step::MinorExchange,
            Engine::Step::DiscardTrain,
            Engine::Step::SpecialTrack,
            Engine::Step::HomeToken,

            G1835::Step::SpecialToken,
            Engine::Step::Track,
            Engine::Step::HomeToken,
            Engine::Step::Token,
            Engine::Step::Route,
            G1835::Step::Dividend,
            G1835::Step::BuyTrain,
          ], round_num: round_num)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1835::Step::MinorExchange,
            G1835::Step::BuySellParShares,
          ])
        end

        def bundles_for_corporation(share_holder, corporation, shares: nil)
          return super if share_holder.player? && corporation.type == :major

          []
        end

        def maybe_ipo_next_block(corporation)
          block = @corporation_blocks.find { |corporation_block| corporation_block.include?(corporation) }
          all_in_block_sold = block.all? { |corp| corp.shares.select(&:buyable).empty? }
          return unless all_in_block_sold
          return if block == @corporation_blocks.last

          next_block = @corporation_blocks[@corporation_blocks.index(block) + 1]
          @log << 'All shares of the current block have been sold.'\
                  " The next block is now available, starting with #{next_block.first.name}"
          next_block.each { |corp_to_ipo| corp_to_ipo.ipoed = true }
        end

        def cert_limit(player = nil)
          return @cert_limit unless player

          @cert_limit + @corporations.count { |corporation| corporation.type == :major && player.percent_of(corporation) >= 80 }
        end

        def corporation_available?(corp)
          return false unless corp.ipoed

          if corp == prussian
            ba = corporation_by_id('BA')
            return !ba.shares.any?(&:president)
          end

          block = @corporation_blocks.find { |corporation_block| corporation_block.include?(corp) }
          index_in_block = block.index(corp)
          return true if index_in_block.zero?

          block[index_in_block - 1].floated?
        end

        def can_par?(_corporation, _parrer)
          false
        end

        def sorted_corporations
          ipoed, others = corporations.partition(&:ipoed)
          floated, not_floated = ipoed.partition(&:floated)
          floated.sort + not_floated + others
        end

        def revenue_for(route, stops)
          super + (hamburg_ferry?(route) ? -10 : 0)
        end

        def revenue_str(route)
          str = super
          str += " (#{format_currency(-10)} Hamburg ferry)" if hamburg_ferry?(route)
          str
        end

        def hamburg_hex
          @hamburg_hex ||= hex_by_id('C11')
        end

        def hamburg_ferry?(route)
          return false unless hamburg_hex.tile.color == :brown
          return false unless route.hexes.include?(hamburg_hex)

          north_edge_used = route.paths.any? { |path| path.tile.hex == hamburg_hex && [2, 3, 4].intersect?(path.exits) }
          south_edge_used = route.paths.any? { |path| path.tile.hex == hamburg_hex && [0, 1, 5].intersect?(path.exits) }
          north_edge_used && south_edge_used
        end

        def tile_lays(entity)
          return TWO_LAYS if entity.type == :major && @phase.status.include?('two_tile_lays')

          LAY_OR_UPGRADE
        end

        def operating_order
          order = super
          order.reject!(&:minor?) if @optional_rules&.include?(:clemens) && !corporation_by_id('BY').floated?
          order
        end

        def payout_companies
          # omit paying out companies if any Prussian conversion could happen. Payout is then handled by MinorExchange
          # after all choices have been made
          super unless any_conversion_choice_available?
        end

        def can_buy_train_from_others?
          @phase.status.include?('can_buy_trains')
        end

        def any_conversion_choice_available?
          # Owner of 2 has the choice to form the PR
          return true if @pr_can_form && !prussian.floated?

          # PR has already been formed and not all minors/companies have been converted yet
          prussian.floated? && !prussian_exchangeables.reject(&:closed?).empty?
        end

        def prussian
          @pr ||= corporation_by_id('PR')
        end

        def berlin_potsdamer_bahn
          @berlin_potsdamer_bahn ||= minor_by_id('2')
        end

        def prussian_exchangeables
          @prussian_exchangeables ||= minors + prussian_companies
        end

        def prussian_companies
          @prussian_companies ||= %w[BB HB].map { |id| company_by_id(id) }
        end

        def entity_can_use_company?(entity, company)
          # Explicitly forbid minor companies from using private company powers
          return false if entity.minor?

          super
        end

        def preprocess_action(action)
          case action
          when Action::LayTile
            # Direct map-driven hostile closure check for Ostbayrische Bahn (OBB)
            obb = company_by_id('OBB')
            if obb && !obb.closed? && %w[M15 M17].include?(action.hex.id)
              # Check if the OTHER hex has track before this one gets laid
              other_hex_id = action.hex.id == 'M15' ? 'M17' : 'M15'
              if hex_by_id(other_hex_id).tile.color != :white
                obb.close!
                @log << "#{obb.name} closes because both target hexes have been built on."
                @round.clear_cache!
              end
            end

            # Direct map-driven hostile closure check for Pfalzbahnen (PB)
            pb = company_by_id('PB')
            if pb && !pb.closed? && action.hex.id == 'L6' && pb.all_abilities.none? { |a| a.type == :token }
              pb.close!
              @log << "#{pb.name} closes because its track has been laid and token power is spent."
              @round.clear_cache!
            end
          end

          super
        end

        def action_processed(action)
          super
          case action
          when Action::LayTile
            if action.hex.id == 'L6'
              @log << "[DEBUG L6] LayTile processed on L6. Active step: #{@round.active_step.class.name}"

              ba = corporation_by_id('BA')
              if ba
                @log << "[DEBUG L6] Baden status - Floated?: #{ba.floated?}, Has tokens?: #{!!ba.tokens.first}, Token used?: #{ba.tokens.first&.used}"
              else
                @log << '[DEBUG L6] Baden corporation (BA) not found!'
              end

              if ba && ba.floated? && ba.tokens.first && !ba.tokens.first.used
                if @round.respond_to?(:pending_tokens)
                  @log << "[DEBUG L6] pending_tokens exists. Current pending queue size: #{@round.pending_tokens.size}"

                  if @round.pending_tokens.any? { |p| p[:entity] == ba }
                    @log << '[DEBUG L6] Baden is already present in the pending_tokens queue.'
                  else
                    @log << "#{ba.name} must immediately choose city for home token on L6"

                    if @round.active_step.is_a?(Engine::Step::Track)
                      @log << "[DEBUG L6] Reverting track step laid_tiles count from #{@round.active_step.laid_tiles.size}"
                      @round.active_step.laid_tiles.pop
                    end

                    @round.pending_tokens << {
                      entity: ba,
                      hexes: [action.hex],
                      token: ba.tokens.first,
                    }
                    @round.clear_cache!
                    @log << '[DEBUG L6] Baden token pushed to pending_tokens successfully.'
                  end
                else
                  @log << '[DEBUG L6] Round does not respond to pending_tokens!'
                end
              else
                @log << '[DEBUG L6] Baden conditional check failed (either not floated or token already used).'
              end
            end
          when Action::PlaceToken

            nf = company_by_id('NF')
            if nf && !nf.closed? && action.city.hex.id == 'L14'
              nf.close!
              @log << "#{nf.name} closes because its special station marker has been placed."
              @round.clear_cache!
            end
            pb = company_by_id('PB')
            if pb && !pb.closed? && pb.all_abilities.none? { |a| a.type == :token } && pb.all_abilities.none? do |a|
                 a.type == :tile_lay
               end
              pb.close!
              @log << "#{pb.name} closes as both special tile and token actions are complete."
              @round.clear_cache!
            end
          end
        end

        def ability_usable?(ability)
          if ability.type == :token && ability.owner.sym == 'PB'
            ba = corporation_by_id('BA')
            return false unless ba&.floated? && ba.tokens.first&.used
          end
          super
        end

        def place_home_token(corporation)
          return unless corporation.next_token
          return if corporation.tokens.first&.used

          hex = hex_by_id(corporation.coordinates)
          tile = hex&.tile

          if !tile || (tile.reserved_by?(corporation) && !tile.paths.empty?) || (corporation.id == 'BA' && @round.respond_to?(:pending_tokens))
            if @round.respond_to?(:pending_tokens) && @round.pending_tokens.any? { |p| p[:entity] == corporation }
              @round.clear_cache!
              return
            end

            hexes = hex ? [hex] : home_token_locations(corporation)
            return unless hexes

            @log << "#{corporation.name} must choose city for home token"
            @round.pending_tokens << {
              entity: corporation,
              hexes: hexes,
              token: corporation.find_token_by_type,
            }

            @round.clear_cache!
            return
          end

          cities = tile&.cities || []
          city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
          token = corporation.find_token_by_type

          same_hex_allowed = multiple_tokens_allowed_on_home_hex?
          if city && city.tokenable?(corporation, tokens: token, same_hex_allowed: same_hex_allowed)
            @log << "#{corporation.name} places a token on #{hex.name}"
            city.place_token(corporation, token, same_hex_allowed: same_hex_allowed)
          elsif home_token_can_be_cheater && city
            @log << "#{corporation.name} places a token on #{hex.name}"
            city.place_token(corporation, token, cheater: true)
          end
        end

        def graph_for(entity, type = nil)
          return nil if entity.player?
          return nil if entity.company? && !abilities(entity, :tile_lay) && !abilities(entity, :token)

          super
        end

        def event_pr_can_form!
          @log << "-- Event: #{EVENTS_TEXT['pr_can_form'][1]} --"
          @pr_can_form = true
          @conversion_choice_during_or = true
        end

        def event_pr_must_form!
          return if berlin_potsdamer_bahn.closed?

          @log << "-- Event: #{EVENTS_TEXT['pr_must_form'][1]} --"
          form_prussian!
        end

        def event_forced_pr_exchange!
          @log << "-- Event: #{EVENTS_TEXT['forced_pr_exchange'][1]} --"
          minors.reject(&:closed?).each do |minor|
            merge_minor!(minor)
          end
          prussian_companies.reject(&:closed?).each do |company|
            merge_company!(company)
          end
        end

        def form_prussian!
          @log << "#{prussian.id} forms"
          prussian.floatable = true
          prussian.floated = true

          merge_minor!(berlin_potsdamer_bahn)
        end

        def merge_company!(company, allow_president_change: true)
          exchange_prussian_share(allow_president_change, 10, company.owner)
          company.close!
        end

        def merge_minor!(minor, allow_president_change: true)
          @log << "#{minor.name} merges into #{prussian.name}"

          owner = minor.owner
          exchange_share_percentage = %w[2 4].include?(minor.id) ? 10 : 5

          exchange_prussian_share(allow_president_change, exchange_share_percentage, owner, president: minor.id == '2')

          if minor.cash.positive?
            @log << "#{prussian.name} receives #{format_currency(minor.cash)} from #{minor.name}'s treasury"
            minor.spend(minor.cash, prussian)
          end

          unless minor.trains.empty?
            trains_str = "#{minor.trains.map(&:name).join(', ')} train#{minor.trains.size > 1 ? 's' : ''}"
            @log << "#{prussian.name} receives #{trains_str}"
            minor.trains.dup.each { |t| buy_train(prussian, t, :free) }
          end

          # Preußen already has a token in Berlin and the rules forbid having more than one token per hex
          unless minor.id == '5'
            token = minor.tokens.first

            # make sure the first token (= home token) gets used or other methods might behave unexpectedly later, e.g.
            # "maybe_place_home_token" called when buying shares
            new_token = minor.id == '2' ? prussian.tokens.first : Token.new(prussian)
            prussian.tokens << new_token

            token.swap!(new_token, check_tokenable: false)

            @log << "#{prussian.name} receives token (#{new_token.used ? new_token.city.hex.id : 'charter'})"
          end

          close_minor!(minor)

          graph.clear_graph_for(prussian)
        end

        def close_minor!(minor)
          minor.tokens.each(&:remove!)
          minor.close!
        end

        def exchange_prussian_share(allow_president_change, exchange_share_percentage, owner, president: false)
          @log << "#{owner.name} receives a #{exchange_share_percentage}% share of #{prussian.name}"
          exchange_share = if president
                             prussian.shares.first
                           else
                             prussian.reserved_shares.find do |share|
                               share.percent == exchange_share_percentage
                             end
                           end
          raise GameError, 'Preußen director not owned by Preußen anymore' if president && !exchange_share.president

          exchange_share.buyable = true
          @share_pool.transfer_shares(ShareBundle.new(exchange_share), owner, allow_president_change: allow_president_change)
        end

        def share_flags(shares)
          'h' * shares.count { |share| share.percent == 5 }
        end
      end
    end
  end
end

module Engine
  class Player
    def logo
      nil
    end

    def simple_logo
      nil
    end

    def tokens_by_type(*)
      []
    end

    def all_abilities
      []
    end
  end
end
