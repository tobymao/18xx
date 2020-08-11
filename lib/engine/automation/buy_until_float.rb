# frozen_string_literal: true

require_relative 'base'

module Engine
  module Automation
    class BuyUntilFloat < Base
      attr_reader :entity

      def initialize(entity:, **args)
        super(**args)
        @entity = entity
      end

      def self.description
        'Buy stock until float (First Round Only)'
      end

      def self.h_to_args(h, game)
        entity = game.get(h['entity_type'], h['entity'])
        {
          entity: h['shares'].map { |id| game.share_by_id(id) },
        }
      end

      def args_to_h
        {
          'entity' => entity.id,
          'entity_type' => type_s(entity),
        }
      end

      def self.available(game)
        (game.turn == 1) && game.corporations.any? {|e| !e.floated? && e.ipoed }
      end

      def self.parameters(game)
        {:entity => game.corporations.select {|e| !e.floated? && e.ipoed }}
      end

      def precondition(game)
        raise GameError, 'Not first round' unless (game.turn == 1)
        raise GameError, 'Not stock round' unless (game.round.is_a?(Round::Stock))
        raise GameError, 'Floated' if (entity.floated?)
        raise GameError, 'Not IPOed' unless (entity.ipoed)
      end

      def _run(game)
        ipo_share = entity.shares.first
        action = Engine::Action::BuyShares.new(game.current_entity, shares: ipo_share)
        game.process_action(action)
      end
    end
  end
end
