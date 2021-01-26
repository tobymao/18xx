# frozen_string_literal: true

require_relative '../company'

module Engine
  module G1822
    class Company < Company
      attr_reader :type, :removed, :header_name, :header_color, :header_text_color

      def initialize(game, **opts)
        @type = opts[:type]&.to_sym || :private
        @header_name = opts[:header_name] || 'PRIVATE COMPANY'
        @header_color = game.registered_color(opts[:header_color]) || :yellow
        @header_text_color = opts[:header_text_color] || :black
        @removed = false

        super(**opts)

        @min_price = (@type == :concession || @type == :minor ? @value : 0)
        @max_price = 1000
      end
    end
  end
end
