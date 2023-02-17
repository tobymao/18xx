# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'market'
require_relative 'trains'
require_relative '../base'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1858
      class Game < Game::Base
        include_meta(G1858::Meta)
        include G1858::Map
        include G1858::Entities
        include G1858::Market
        include G1858::Trains
        include StubsAreRestricted

        attr_reader :graph_broad, :graph_metre

        GAME_END_CHECK = { bank: :current_or }.freeze
        BANKRUPTCY_ALLOWED = false

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true

        HOME_TOKEN_TIMING = :float
        TRACK_RESTRICTION = :semi_restrictive
        TILE_UPGRADES_MUST_USE_MAX_EXITS = %i[cities].freeze

        MUST_BUY_TRAIN = :never
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        EBUY_OTHER_VALUE = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = false
        EBUY_SELL_MORE_THAN_NEEDED = false
        EBUY_SELL_MORE_THAN_NEEDED_LIMITS_DEPOT_TRAIN = true
        EBUY_OWNER_MUST_HELP = true
        EBUY_CAN_SELL_SHARES = false

        MINOR_TILE_LAYS = [
          { lay: true, upgrade: false },
          { lay: true, upgrade: false, cost: 20, cannot_reuse_same_hex: true },
        ].freeze
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: true, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        def setup_preround
          # Companies need to be owned by the bank to be available for auction
          @companies.each { |company| company.owner = @bank }
        end

        def setup
          # We need three different graphs for tracing routes for entities:
          #  - @graph_broad traces routes along broad and dual gauge track.
          #  - @graph_metre traces routes along metre and dual gauge track.
          #  - @graph uses any track. This is going to include illegal routes
          #    (using both broad and metre gauge track) but will just be used
          #    by things like the auto-router where the route will get rejected.
          @graph_broad = Graph.new(self, skip_track: :narrow, home_as_token: true)
          @graph_metre = Graph.new(self, skip_track: :broad, home_as_token: true)

          @stubs = setup_stubs
        end

        # Create stubs along the routes of the private railways.
        def setup_stubs
          stubs = Hash.new { |k, v| k[v] = [] }
          @minors.each do |minor|
            next unless minor.coordinates.size > 1

            home_hexes = hexes.select { |hex| minor.coordinates.include?(hex.coordinates) }
            home_hexes.each do |hex|
              tile = hex.tile
              next unless tile.color == :white

              hex.neighbors.each do |edge, neighbor|
                next unless home_hexes.include?(neighbor)

                stub = Engine::Part::Stub.new(edge)
                tile.stubs << stub
                stubs[minor] << { tile: tile, stub: stub }
              end
            end
          end

          stubs
        end

        # Removes the stubs from the private railway's home hexes.
        def release_stubs(minor)
          stubs = @stubs[minor]
          return unless stubs

          stubs.each { |tile_stub| tile_stub[:tile].stubs.delete(tile_stub[:stub]) }
          @stubs.delete(minor)
        end

        def clear_graph_for_entity(_entity)
          @graph.clear
          @graph_broad.clear
          @graph_metre.clear
        end

        def clear_token_graph_for_entity(entity)
          clear_graph_for_entity(entity)
        end

        def init_round
          stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::HomeToken,
            G1858::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num = 1)
          @round_num = round_num
          Engine::Round::Operating.new(self, [
            G1858::Step::Track,
            G1858::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            Engine::Step::IssueShares,
          ], round_num: round_num)
        end

        # Returns the company object for a private railway given its associated
        # minor object. If passed a company then returns that company.
        def private_company(entity)
          return entity if entity.company?

          @companies.find { |company| company.sym == entity.id }
        end

        # Returns the minor object for a private railway given its associated
        # company object. If passed a minor then returns that minor.
        def private_minor(entity)
          return entity if entity.minor?

          @minors.find { |minor| minor.id == entity.sym }
        end

        # Returns true if the hex is this private railway's home hex.
        def home_hex?(operator, hex)
          operator.coordinates.include?(hex.coordinates)
        end

        def tile_lays(entity)
          entity.corporation? ? TILE_LAYS : MINOR_TILE_LAYS
        end

        def metre_gauge_upgrade(old_tile, new_tile)
          # Check if the only new track on the tile is metre gauge
          old_track = old_tile.paths.map(&:track)
          new_track = new_tile.paths.map(&:track)
          old_track.each { |t| new_track.slice!(new_track.index(t) || new_track.size) }
          new_track.uniq == [:narrow]
        end

        def upgrade_cost(tile, hex, entity, _spender)
          return 0 if tile.upgrades.empty?
          return 0 if entity.minor? && home_hex?(entity, hex)

          cost = tile.upgrades[0].cost
          return cost unless metre_gauge_upgrade(tile, hex.tile)

          discount = cost / 2
          log_cost_discount(entity, nil, discount, :terrain)
          cost - discount
        end

        def tile_cost_with_discount(_tile, _hex, entity, _spender, cost)
          return cost if @round.gauges_added.one? # First tile lay.
          return cost unless @round.gauges_added.include?([:narrow])

          discount = 10
          log_cost_discount(entity, nil, discount, :tile_lay)
          cost - discount
        end

        def log_cost_discount(entity, _ability, discount, reason = :terrain)
          return unless discount.positive?

          @log << "#{entity.name} receives a #{format_currency(discount)} " \
                  "#{reason == :terrain ? 'terrain' : 'second tile'} " \
                  'discount for metre gauge track'
        end

        def buyable_bank_owned_companies
          available_colors = [:yellow]
          available_colors << :green if @phase.status.include?('green_privates')
          @companies.select do |company|
            !company.closed? && (company.owner == @bank) &&
              available_colors.include?(company.color)
          end
        end

        def unstarted_corporation_summary
          # Don't show minors in the list of bank-owned entities, their
          # associated private company will be listed.
          unstarted = @corporations.reject(&:ipoed)
          [unstarted.size, unstarted]
        end

        def unowned_purchasable_companies(_entity)
          @companies.filter { |company| !company.closed? && company.owner == @bank }
        end

        def bank_sort(entities)
          minors, corporations = entities.partition(&:minor?)
          minors.sort_by { |m| PRIVATE_ORDER[m.id] } + corporations.sort_by(&:name)
        end

        def payout_companies
          return if private_closure_round == :in_progress

          # Private railways owned by public companies don't pay out.
          exchanged_companies = @companies.select { |company| company.owner&.corporation? }
          super(ignore: exchanged_companies.map(&:id))
        end

        def entity_can_use_company?(_entity, _company)
          # Don't show abilities buttons in a stock round for the companies
          # owned by the player.
          false
        end
      end
    end
  end
end
