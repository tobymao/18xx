# frozen_string_literal: true

require_relative '../helper/type'
require_relative '../ownable'

module Engine
  module Ability
    class Base
      include Helper::Type
      include Ownable

      attr_accessor :count_this_or, :description
      attr_reader :type, :owner_type, :remove, :when, :count, :count_per_or, :start_count

      def initialize(type:, description: nil, owner_type: nil, count: nil, remove: nil,
                     count_per_or: nil, show_count: false, **opts)
        @type = type&.to_sym
        @description = description&.to_s
        @owner_type = owner_type&.to_sym
        @when = opts.delete(:when)&.to_s
        @count = count
        @count_per_or = count_per_or
        @count_this_or = 0
        @used = false
        @remove = remove&.to_s
        @start_count = @count if show_count

        setup(**opts)
      end

      def used?
        @used
      end

      def use!
        @used = true

        @count_this_or += 1 if @count_per_or

        return unless @count

        @count -= 1
        owner.remove_ability(self) unless @count.positive?
      end

      def setup(**_opts); end

      def teardown; end
    end
  end
end
