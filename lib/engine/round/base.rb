# frozen_string_literal: true

require_relative '../action/message'
require_relative '../game_error'
require_relative '../share_bundle'

module Engine
  module Round
    class Base
      attr_reader :entities, :current_entity, :end_game

      def initialize(entities, game:, **_kwargs)
        @game = game
        @entities = entities
        @log = game.log
        @current_entity = @entities.first
        @end_game = false
      end

      def log_new_round
        @log << "-- #{name} #{game.turn} --"
      end

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
        @current_entity.player
      end

      def active_entities
        [@current_entity] + crowded_corps
      end

      def next_entity
        index = @entities.find_index(@current_entity) + 1
        index < @entities.size ? @entities[index] : @entities[0]
      end

      def pass(action)
        action.entity.pass!
      end

      def process_action(action)
        entity = action.entity
        if action.is_a?(Action::EndGame)
          @end_game = true
          @log << '-- Game ended by owner --'
          return
        end
        return @log << action if action.is_a?(Action::Message)
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
        @end_game || @entities.all?(&:passed?)
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

      def can_lay_track?
        false
      end

      def can_run_routes?
        false
      end

      def can_place_token?
        false
      end

      def layable_hexes
        {}
      end

      def upgradeable_tiles(hex)
        potential_tiles(hex).map do |tile|
          tile.rotate!(0) # reset tile to no rotation since calculations are absolute
          tile.legal_rotations = legal_rotations(hex, tile)
          next if tile.legal_rotations.empty?

          tile.rotate!
          tile
        end.compact
      end

      def sellable_bundles(player, corporation)
        shares = player
          .shares_of(corporation)
          .sort_by(&:price)

        bundles = shares.flat_map.with_index do |share, index|
          bundle = shares.take(index + 1)
          percent = bundle.sum(&:percent)
          bundles = [Engine::ShareBundle.new(bundle, percent)]
          bundles.insert(0, Engine::ShareBundle.new(bundle, percent - 10)) if share.president
          bundles
        end

        bundles.select { |bundle| can_sell?(bundle) }
      end

      def did_sell?(_corporation, _entity)
        false
      end

      def crowded_corps
        train_limit = @game.phase.train_limit
        @game.corporations.select { |c| c.trains.size > train_limit }
      end

      def discard_train(action)
        train = action.train
        @game.depot.reclaim_train(train)
        @log << "#{action.entity.name} discards #{train.name}"
      end

      private

      def potential_tiles(hex)
        colors = @game.phase.tiles
        @game
          .tiles
          .select { |tile| colors.include?(tile.color) }
          .uniq(&:name)
          .select { |t| hex.tile.upgrades_to?(t) }
      end

      def sell_and_change_price(bundle, share_pool, stock_market)
        share_pool.sell_shares(bundle)
        corporation = bundle.corporation
        prev = corporation.share_price.price
        bundle.num_shares.times { stock_market.move_down(corporation) }
        log_share_price(corporation, prev)
      end

      def lay_tile(action)
        entity = action.entity
        tile = action.tile
        hex = action.hex
        rotation = action.rotation
        old_tile = hex.tile

        @game.tiles.reject! { |t| tile.equal?(t) }
        @game.tiles << old_tile unless old_tile.preprinted

        tile.rotate!(rotation)
        hex.lay(tile)

        abilities =
          if entity.respond_to?(:companies)
            entity.companies.flat_map(&:all_abilities)
          else
            []
          end

        cost = old_tile.upgrade_cost(abilities)
        entity.spend(cost, @game.bank) if cost.positive?

        @log << "#{action.entity.name}"\
          "#{cost.zero? ? '' : " spends #{@game.format_currency(cost)} and"}"\
          " lays tile ##{tile.name}"\
         " with rotation #{rotation} on #{hex.name}"
      end

      def payout_companies
        @game.companies.select(&:owner).each do |company|
          owner = company.owner
          next unless (revenue = company.revenue).positive?

          @game.bank.spend(revenue, owner)
          @log << "#{owner.name} collects #{@game.format_currency(revenue)} from #{company.name}"
        end
      end

      def log_share_price(entity, from)
        to = entity.share_price.price
        return unless from != to

        @log << "#{entity.name}'s share price changes from #{@game.format_currency(from)} "\
                "to #{@game.format_currency(to)}"
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
      def can_gain?(share, entity)
        return if !share || !entity

        corporation = share.corporation
        corporation.holding_ok?(entity, share.percent) &&
        (!corporation.counts_for_limit || entity.num_certs < @game.cert_limit)
      end
    end
  end
end
