# frozen_string_literal: true

require_relative '../helper/type'
require_relative '../ownable'

module Engine
  module Ability
    class Base
      include Helper::Type
      include Ownable

      attr_reader :type, :owner_type, :when, :count

      def initialize(type:, owner_type: nil, count: nil, **opts)
        @type = type&.to_sym
        @owner_type = owner_type&.to_sym
        @when = opts.delete(:when)&.to_s
        @count = count
        @used = false
        setup(**opts)
      end

      def used?
        @used
      end

      def use!
        @used = true
        return unless @count

        @count -= 1
        owner.remove_ability(@type) unless @count.positive?
      end

      def setup(**_opts); end
    end
  end
end
