# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree '../step'
else
  require 'require_all'
  require_rel '../step'
end

module Engine
  module Round
    class Base
      attr_reader :entities, :entity_index, :round_num, :steps

      DEFAULT_STEPS = [
        Step::EndGame,
        Step::Message,
      ].freeze

      def initialize(game, steps, **opts)
        @game = game
        @entity_index = 0
        @entities = select_entities
        @round_num = opts[:round_num] || 1

        @steps = (DEFAULT_STEPS + steps).map do |step, step_opts|
          step_opts ||= {}
          step = step.new(@game, self, **step_opts)
          step.setup
          step.round_state.each do |key, value|
            singleton_class.class_eval { attr_accessor key }
            send("#{key}=", value)
          end
          step
        end

        setup
      end

      def setup; end

      def name
        raise NotImplementedError
      end

      def select_entities
        raise NotImplementedError
      end

      def current_entity
        active_entities[0]
      end

      def description
        active_step.description
      end

      def active_entities
        active_step.active_entities
      end

      def pass_description
        active_step.pass_description
      end

      def process_action(action)
        type = action.type
        clear_cache!

        step = @steps.find do |step|
          next unless step.active?

          process = step.actions(action.entity).include?(type)
          blocking = step.blocking?
          raise GameError, "Step #{step} cannot process #{type}" if blocking && !process

          blocking || process
        end
        raise GameError, "No step found for action #{type}" unless step

        step.send("process_#{action.type}", action)

        @steps.each do |prev|
          break if prev == step
          next unless prev.sequential?
          puts "passing sequential #{prev}"

          prev.pass!
        end if step.sequential?
        action_processed(action)
      end

      def active_step
        @active_step ||= @steps.find { |step| step.active? && step.blocking? }
      end

      def finished?
        !active_step
      end

      def next_entity_index!
        @entity_index = (@entity_index + 1) % @entities.size
      end

      def reset_entity_index!
        @entity_index = 0
      end

      private

      def clear_cache!
        @active_step = nil
      end

      def action_processed(_action); end

      #def initialize(entities, game:, **_kwargs)
      #  @game = game
      #  @entities = entities
      #  @log = game.log
      #  @current_entity = @entities.first
      #  @round_num = 1
      #end

      #def name
      #  raise NotImplementedError
      #end

      #def description
      #  raise NotImplementedError
      #end

      #def pass_description
      #  raise NotImplementedError
      #end

      #def current_player
      #  current_entity.player
      #end

      #def active_entities
      #  [@current_entity] + crowded_corps
      #end

      #def next_entity
      #  index = @entities.find_index(@current_entity) + 1
      #  index < @entities.size ? @entities[index] : @entities[0]
      #end

      #def turn_round_num
      #  [@game.turn, @round_num]
      #end

      #def pass(action)
      #  action.entity.pass!
      #end

      #def process_action(action)
      #  entity = action.entity
      #  return @log << action if action.is_a?(Action::Message)
      #  raise GameError, 'Game has ended' if @game.finished

      #  if action.is_a?(Action::EndGame)
      #    @log << '-- Game ended by player --'
      #    return @game.end_game!
      #  end

      #  raise GameError, "It is not #{entity.name}'s turn" unless can_act?(entity)

      #  if action.pass?
      #    log_pass(entity)
      #    pass(action)
      #    pass_processed(action)
      #  else
      #    _process_action(action)
      #    action_processed(action)
      #  end
      #  change_entity(action)
      #  action_finalized(action)
      #end

      #def finished?
      #  @game.finished || @entities.all?(&:passed?)
      #end

      #def can_act?(entity)
      #  active_entities.include?(entity)
      #end

      #def auction?
      #  false
      #end

      #def stock?
      #  false
      #end

      #def operating?
      #  false
      #end

      #def can_assign?
      #  false
      #end

      #def can_lay_track?
      #  false
      #end

      #def can_run_routes?
      #  false
      #end

      #def can_place_token?
      #  false
      #end

      #def ambiguous_token
      #  nil
      #end

      #def connected_hexes
      #  {}
      #end

      #def connected_paths
      #  {}
      #end

      #def connected_nodes
      #  {}
      #end

      #def reachable_hexes
      #  {}
      #end

      #def upgradeable_tiles(hex)
      #  potential_tiles(hex).map do |tile|
      #    tile.rotate!(0) # reset tile to no rotation since calculations are absolute
      #    tile.legal_rotations = legal_rotations(hex, tile)
      #    next if tile.legal_rotations.empty?

      #    tile.rotate! # rotate it to the first legal rotation
      #    tile
      #  end.compact
      #end

      #def legal_rotations(hex, tile)
      #  old_paths = hex.tile.paths

      #  Engine::Tile::ALL_EDGES.select do |rotation|
      #    tile.rotate!(rotation)
      #    new_paths = tile.paths
      #    new_exits = tile.exits

      #    new_exits.all? { |edge| hex.neighbors[edge] } &&
      #      (new_exits & connected_hexes[hex]).any? &&
      #      old_paths.all? { |path| new_paths.any? { |p| path <= p } }
      #  end
      #end

      #def sellable_bundles(player, corporation)
      #  bundles = player.bundles_for_corporation(corporation)
      #  bundles.select { |bundle| can_sell?(bundle) }
      #end

      #def did_sell?(_corporation, _entity)
      #  false
      #end

      #def crowded_corps
      #  @game.corporations.select do |c|
      #    c.trains.reject(&:obsolete).size > @game.phase.train_limit
      #  end
      #end

      #def discard_train(action)
      #  train = action.train
      #  @game.depot.reclaim_train(train)
      #  @log << "#{action.entity.name} discards #{train.name}"
      #end

      ## returns true if user must choose home token
      #def place_home_token(corporation)
      #  return unless corporation.next_token # 1882

      #  hex = @game.hex_by_id(corporation.coordinates)

      #  tile = hex.tile
      #  if tile.reserved_by?(corporation) && tile.paths.any?
      #    # If the tile does not have any paths at the present time, clear up the ambiguity when the tile is laid
      #    @game.log << "#{corporation.name} must choose city for home token"
      #    # Needs further changes to support non-operate home token lay
      #    raise GameError, 'Unsupported' unless @home_token_timing == :operate

      #    return
      #  end

      #  cities = tile.cities
      #  city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
      #  token = corporation.find_token_by_type
      #  return unless city.tokenable?(corporation, tokens: token)

      #  @game.log << "#{corporation.name} places a token on #{hex.name}"
      #  city.place_token(corporation, token)
      #end

      #private

      #def potential_tiles(hex)
      #  colors = @game.phase.tiles
      #  @game
      #    .tiles
      #    .select { |tile| colors.include?(tile.color) }
      #    .uniq(&:name)
      #    .select { |t| hex.tile.upgrades_to?(t) }
      #    .reject(&:blocks_lay)
      #end

      #def sell_and_change_price(bundle, share_pool, stock_market)
      #  corporation = bundle.corporation
      #  price = corporation.share_price.price
      #  was_president = corporation.president?(bundle.owner)
      #  share_pool.sell_shares(bundle)
      #  case @game.class::SELL_MOVEMENT
      #  when :down_share
      #    bundle.num_shares.times { stock_market.move_down(corporation) }
      #  when :left_block_pres
      #    stock_market.move_left(corporation) if was_president
      #  else
      #    raise NotImplementedError
      #  end
      #  log_share_price(corporation, price)
      #end

      #def lay_tile(action)
      #  entity = action.entity
      #  tile = action.tile
      #  hex = action.hex
      #  rotation = action.rotation
      #  old_tile = hex.tile

      #  tile.rotate!(rotation)

      #  raise GameError, "#{old_tile.name} is not upgradeable to #{tile.name}" unless old_tile.upgrades_to?(tile)

      #  @game.tiles.delete(tile)
      #  @game.tiles << old_tile unless old_tile.preprinted

      #  hex.lay(tile)

      #  @game.graph.clear
      #  check_track_restrictions!(old_tile, tile) unless @game.loading

      #  free = false

      #  entity.abilities(:tile_lay) do |ability|
      #    next if !ability.hexes.include?(hex.id) || !ability.tiles.include?(tile.name)

      #    free = ability.free
      #  end

      #  terrain = old_tile.terrain
      #  cost =
      #    if free
      #      0
      #    else
      #      border, border_types = border_cost(tile)
      #      terrain += border_types if border.positive?
      #      tile_cost(old_tile, entity.all_abilities) + border
      #    end

      #  entity.spend(cost, @game.bank) if cost.positive?

      #  @log << "#{action.entity.name}"\
      #    "#{cost.zero? ? '' : " spends #{@game.format_currency(cost)} and"}"\
      #    " lays tile ##{tile.name}"\
      #   " with rotation #{rotation} on #{hex.name}"

      #  return unless terrain.any?

      #  @game.all_companies_with_ability(:tile_income) do |company, ability|
      #    if terrain.include?(ability.terrain)
      #      # If multiple borders are connected bonus counts each individually
      #      income = ability.income * terrain.find_all { |t| t == ability.terrain }.size
      #      @bank.spend(income, company.owner)
      #      @log << "#{company.owner.name} earns #{@game.format_currency(income)}"\
      #      " for #{ability.terrain} tile with #{company.name}"
      #    end
      #  end
      #end

      #def border_cost(tile)
      #  hex = tile.hex
      #  types = []

      #  total_cost = tile.borders.dup.sum do |border|
      #    next 0 unless (cost = border.cost)

      #    edge = border.edge
      #    neighbor = hex.neighbors[edge]
      #    next 0 if !hex.targeting?(neighbor) || !neighbor.targeting?(hex)

      #    types << border.type
      #    tile.borders.delete(border)
      #    neighbor.tile.borders.map! { |nb| nb.edge == hex.invert(edge) ? nil : nb }.compact!

      #    cost
      #  end
      #  [total_cost, types]
      #end

      #def tile_cost(tile, abilities)
      #  tile.upgrade_cost(abilities)
      #end

      #def payout_companies
      #  @game.companies.select(&:owner).each do |company|
      #    owner = company.owner
      #    next unless (revenue = company.revenue).positive?

      #    @game.bank.spend(revenue, owner)
      #    @log << "#{owner.name} collects #{@game.format_currency(revenue)} from #{company.name}"
      #  end
      #end

      #def log_share_price(entity, from)
      #  to = entity.share_price.price
      #  return unless from != to

      #  @log << "#{entity.name}'s share price changes from #{@game.format_currency(from)} "\
      #          "to #{@game.format_currency(to)}"
      #end

      #def log_pass(entity)
      #  @log << "#{entity.name} passes"
      #end

      ## methods to override
      #def _process(_action)
      #  raise NotImplementedError
      #end

      #def change_entity(_action)
      #  @current_entity = next_entity
      #end

      #def pass_processed(_action); end

      #def action_processed(_action); end

      #def action_finalized(_action); end

      ## Returns if a share can be gained by an entity respecting the cert limit
      ## This works irrespective of if that player has sold this round
      ## such as in 1889 for exchanging Dougo
      ##
      #def can_gain?(bundle, entity)
      #  return if !bundle || !entity

      #  corporation = bundle.corporation
      #  corporation.holding_ok?(entity, bundle.percent) &&
      #  (!corporation.counts_for_limit || entity.num_certs < @game.cert_limit)
      #end

      #def check_track_restrictions!(old_tile, new_tile)
      #  old_paths = old_tile.paths
      #  changed_city = false
      #  used_new_track = old_paths.empty?

      #  new_tile.paths.each do |np|
      #    next unless connected_paths[np]

      #    op = old_paths.find { |path| path <= np }
      #    used_new_track = true unless op
      #    changed_city = true if op&.node && op.node.max_revenue != np.node.max_revenue
      #  end

      #  case @game.class::TRACK_RESTRICTION
      #  when :permissive
      #    true
      #  when :restrictive
      #    raise GameError, 'Must use new track' unless used_new_track
      #  when :semi_restrictive
      #    raise GameError, 'Must use new track or change city value' if !used_new_track && !changed_city
      #  else
      #    raise
      #  end
      #end
    end
  end
end
