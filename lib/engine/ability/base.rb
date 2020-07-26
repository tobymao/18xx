# frozen_string_literal: true

require_relative '../helper/type'
require_relative '../ownable'

module Engine
  module Ability
    class Base
      include Helper::Type
      include Ownable

      attr_accessor :description
      attr_reader :type, :owner_type, :remove, :when, :count

      def initialize(type:, description: nil, owner_type: nil, count: nil, remove: nil, **opts)
        @type = type&.to_sym
        @description = description&.to_s
        @owner_type = owner_type&.to_sym
        @when = opts.delete(:when)&.to_s
        @count = count
        @used = false
        @remove = remove&.to_s

        setup(**opts)
      end

      def used?
        @used
      end

      def use!
        @used = true
        return unless @count

        @count -= 1
        owner.remove_ability(self) unless @count.positive?
      end

      def setup(**_opts); end

      def teardown; end
    end
  end
end
