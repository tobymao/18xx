# frozen_string_literal: true

require_relative '../helper/type'

module Engine
  module Automation
    class Base
      include Helper::Type

      attr_reader :id, :disabled

# {enabled_action_id:101, type:'buy_until_float', entity:'SR', disabled: "Exited stock round"}
#
#
      def self.from_h(h, game)
        new(id: h['id'], disabled: h['disabled'], **h_to_args(h, game))
      end

      def self.description
        type
      end

      def self.h_to_args(_h, _game)
        {}
      end

      def self.split(klass)
        klass.name.split('::')
      end

      def initialize(id:, disabled:false)
        @id = id # Marker of where this is processed up to
        @disabled = disabled
      end

      def [](field)
        to_h[field]
      end

      def to_h
        {
          'type' => type,
          'id' => @id,
          'disabled' => @disabled,
          **args_to_h,
        }.reject { |_, v| v.nil? }
      end

      def args_to_h
        {}
      end

      def copy(game)
        self.class.from_h(to_h, game)
      end

      def run(game)
        begin
          precondition(game)
          _run(game)
        rescue GameError => a
          @disabled = a.to_s
        end
      end
    end
  end
end
