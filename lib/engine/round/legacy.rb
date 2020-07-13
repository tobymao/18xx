# frozen_string_literal: true

require_relative '../action/message'
require_relative '../game_error'
require_relative '../share_bundle'

module Engine
  module Round
    class Legacy
      attr_reader :entities, :current_entity

      def initialize(entities, game:, **_kwargs)
        @game = game
        @entities = entities
        @log = game.log
        @current_entity = @entities.first
        @round_num = 1
      end

      def active_step
        self
      end

      def setup; end

      def name
        raise NotImplementedError
      end

      def description
        raise NotImplementedError
      end

      def pass_description
        raise NotImplementedError
      end

      def current_player
        current_entity.player
      end

      def active_entities
        [@current_entity] + crowded_corps
      end

      def next_entity
        index = @entities.find_index(@current_entity) + 1
        index < @entities.size ? @entities[index] : @entities[0]
      end

      def turn_round_num
        [@game.turn, @round_num]
      end

      def pass(action)
        action.entity.pass!
      end

      def process_action(action)
        entity = action.entity
        return @log << action if action.is_a?(Action::Message)
        raise GameError, 'Game has ended' if @game.finished

        if action.is_a?(Action::EndGame)
          @log << '-- Game ended by player --'
          return @game.end_game!
        end

        raise GameError, "It is not #{entity.name}'s turn" unless can_act?(entity)

        if action.pass?
          log_pass(entity)
          pass(action)
          pass_processed(action)
        else
          _process_action(action)
          action_processed(action)
        end
        change_entity(action)
        action_finalized(action)
      end

      def finished?
        @game.finished || @entities.all?(&:passed?)
      end

      def can_act?(entity)
        active_entities.include?(entity)
      end

      def auction?
        false
      end

      def stock?
        false
      end

      def operating?
        false
      end

      def can_assign?
        false
      end

      def can_lay_track?
        false
      end

      def can_run_routes?
        false
      end

      def can_place_token?
        false
      end

      def ambiguous_token
        nil
      end

      def connected_hexes
        {}
      end

      def available_hex(hex)
        connected_hexes[hex]
      end

      def connected_paths
        {}
      end

      def connected_nodes
        {}
      end

      def reachable_hexes
        {}
      end

      def sellable_bundles(player, corporation)
        bundles = player.bundles_for_corporation(corporation)
        bundles.select { |bundle| can_sell?(bundle) }
      end

      def did_sell?(_corporation, _entity)
        false
      end

      def crowded_corps
        @game.corporations.select do |c|
          c.trains.reject(&:obsolete).size > @game.phase.train_limit
        end
      end

      def discard_train(action)
        train = action.train
        @game.depot.reclaim_train(train)
        @log << "#{action.entity.name} discards #{train.name}"
      end

      # returns true if user must choose home token
      def place_home_token(corporation)
        @game.place_home_token(corporation)
      end

      private

      def lay_tile(action)
        entity = action.entity
        tile = action.tile
        hex = action.hex
        rotation = action.rotation
        old_tile = hex.tile

        tile.rotate!(rotation)

        raise GameError, "#{old_tile.name} is not upgradeable to #{tile.name}" unless old_tile.upgrades_to?(tile)

        @game.tiles.delete(tile)
        @game.tiles << old_tile unless old_tile.preprinted

        hex.lay(tile)

        @game.graph.clear
        check_track_restrictions!(old_tile, tile) unless @game.loading

        free = false

        entity.abilities(:tile_lay) do |ability|
          next if !ability.hexes.include?(hex.id) || !ability.tiles.include?(tile.name)

          free = ability.free
        end

        terrain = old_tile.terrain
        cost =
          if free
            0
          else
            border, border_types = border_cost(tile)
            terrain += border_types if border.positive?
            @game.tile_cost(old_tile, entity) + border
          end

        entity.spend(cost, @game.bank) if cost.positive?

        @log << "#{action.entity.name}"\
          "#{cost.zero? ? '' : " spends #{@game.format_currency(cost)} and"}"\
          " lays tile ##{tile.name}"\
         " with rotation #{rotation} on #{hex.name}"

        return unless terrain.any?

        @game.all_companies_with_ability(:tile_income) do |company, ability|
          if terrain.include?(ability.terrain)
            # If multiple borders are connected bonus counts each individually
            income = ability.income * terrain.find_all { |t| t == ability.terrain }.size
            @bank.spend(income, company.owner)
            @log << "#{company.owner.name} earns #{@game.format_currency(income)}"\
            " for #{ability.terrain} tile with #{company.name}"
          end
        end
      end

      def border_cost(tile)
        hex = tile.hex
        types = []

        total_cost = tile.borders.dup.sum do |border|
          next 0 unless (cost = border.cost)

          edge = border.edge
          neighbor = hex.neighbors[edge]
          next 0 if !hex.targeting?(neighbor) || !neighbor.targeting?(hex)

          types << border.type
          tile.borders.delete(border)
          neighbor.tile.borders.map! { |nb| nb.edge == hex.invert(edge) ? nil : nb }.compact!

          cost
        end
        [total_cost, types]
      end

      def payout_companies
        @game.companies.select(&:owner).each do |company|
          owner = company.owner
          next unless (revenue = company.revenue).positive?

          @game.bank.spend(revenue, owner)
          @log << "#{owner.name} collects #{@game.format_currency(revenue)} from #{company.name}"
        end
      end

      def log_pass(entity)
        @log << "#{entity.name} passes"
      end

      # methods to override
      def _process(_action)
        raise NotImplementedError
      end

      def change_entity(_action)
        @current_entity = next_entity
      end

      def pass_processed(_action); end

      def action_processed(_action); end

      def action_finalized(_action); end

      # Returns if a share can be gained by an entity respecting the cert limit
      # This works irrespective of if that player has sold this round
      # such as in 1889 for exchanging Dougo
      #
      def can_gain?(bundle, entity)
        return if !bundle || !entity

        corporation = bundle.corporation
        corporation.holding_ok?(entity, bundle.percent) &&
        (!corporation.counts_for_limit || entity.num_certs < @game.cert_limit)
      end

      def check_track_restrictions!(old_tile, new_tile)
        old_paths = old_tile.paths
        changed_city = false
        used_new_track = old_paths.empty?

        new_tile.paths.each do |np|
          next unless connected_paths[np]

          op = old_paths.find { |path| path <= np }
          used_new_track = true unless op
          changed_city = true if op&.node && op.node.max_revenue != np.node.max_revenue
        end

        case @game.class::TRACK_RESTRICTION
        when :permissive
          true
        when :restrictive
          raise GameError, 'Must use new track' unless used_new_track
        when :semi_restrictive
          raise GameError, 'Must use new track or change city value' if !used_new_track && !changed_city
        else
          raise
        end
      end
    end
  end
end
