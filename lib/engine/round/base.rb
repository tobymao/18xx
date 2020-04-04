# frozen_string_literal: true

require 'engine/game_error'

module Engine
  module Round
    class Base
      attr_reader :entities, :current_entity

      def initialize(entities, game:, **_kwargs)
        @game = game
        @entities = entities
        @log = game.log
        @current_entity = @entities.first
      end

      def description
        raise NotImplementedError
      end

      def current_player
        @current_entity.player
      end

      def active_entities
        [@current_entity]
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
        raise GameError, "It is not #{entity.name}'s turn" unless can_act?(entity)

        if action.pass?
          @log << "#{entity.name} passes"
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
        @entities.all?(&:passed?)
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

      private

      def sell_and_change_price(shares, share_pool, stock_market)
        share_pool.sell_shares(shares)
        corporation = shares.first.corporation
        prev = corporation.share_price.price
        shares.each do |share|
          stock_market.move_down(corporation)
          stock_market.move_down(corporation) if share.president
        end
        log_share_price(corporation, prev)
      end

      def lay_tile(action)
        tile = action.tile
        hex = action.hex
        rotation = action.rotation
        @game.tiles.reject! { |t| tile.equal?(t) }
        @game.tiles << hex.tile unless hex.tile.preprinted
        tile.rotate!(rotation)
        hex.lay(tile)
        @log << "#{action.entity.name} lays tile #{tile.name} with rotation #{rotation} on #{hex.name}"
      end

      def log_share_price(entity, from)
        @log << "#{entity.name}'s share price changes from $#{from} to $#{entity.share_price.price} "
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
    end
  end
end
