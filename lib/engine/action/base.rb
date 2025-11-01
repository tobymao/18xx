# frozen_string_literal: true

require_relative '../helper/type'

module Engine
  module Action
    class Base
      include Comparable
      include Helper::Type

      attr_reader :entity
      attr_accessor :id, :user, :created_at, :auto_actions, :step

      # Array<Symbol> - initialize's keyword arguments that don't have a default
      # value; if any given values are nil, raise an ActionError in `from_h()`
      # to avoid a less-helpful nil-pointer error later on
      REQUIRED_ARGS = [].freeze

      def self.from_h(h, game)
        entity = game.get(h['entity_type'], h['entity']) || Player.new(nil, h['entity'])

        args = h_to_args(h, game)
        validate_args!(h, args)

        obj = new(entity, **args)
        obj.user = h['user'] if entity.player && h['user'] != entity.player&.id
        obj.created_at = h['created_at'] || Time.now
        obj.auto_actions = (h['auto_actions'] || []).map { |auto_h| Base.action_from_h(auto_h, game) }
        obj.step = h['step']
        obj
      end

      def self.action_from_h(h, game)
        Object
        .const_get("Engine::Action::#{Action::Base.type(h['type'])}")
        .from_h(h, game)
      end

      def self.h_to_args(_h, _game)
        {}
      end

      def self.validate_args!(h, args)
        self::REQUIRED_ARGS.each do |arg|
          if args[arg].nil?
            raise ActionError,
                  "Cannot create #{name}, h_to_args() returned nil :#{arg} from action #{h['id']}"
          end
        end
      end

      def self.split(klass)
        klass.name.split('::')
      end

      def initialize(entity)
        @entity = entity
        @created_at = Time.now
        @auto_actions = []
      end

      def [](field)
        to_h[field]
      end

      def clear_cache
        @_h = nil
      end

      def to_h
        @_h ||= {
          'type' => type,
          'entity' => entity.id,
          'entity_type' => type_s(entity),
          'id' => @id,
          'user' => @user,
          'created_at' => @created_at.to_i,
          'auto_actions' => @auto_actions.empty? ? nil : @auto_actions.map(&:to_h),
          'step' => @step,
          **args_to_h,
        }.reject { |_, v| v.nil? }
      end

      def args_to_h
        {}
      end

      def pass?
        false
      end

      def copy(game)
        self.class.from_h(to_h, game)
      end

      def free?
        false
      end

      def <=>(other)
        # some actions are generated internally and don't have an id, fall back to timestamp.
        id && other.id ? (id <=> other.id) : (Time.at(created_at) <=> Time.at(other.created_at))
      end

      def to_json(*args)
        to_h.to_json(*args)
      end
    end
  end
end
