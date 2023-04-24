# frozen_string_literal: true

require_relative '../helper/type'
require_relative '../ownable'

module Engine
  module Ability
    class Base
      include Helper::Type
      include Ownable

      attr_accessor :count_this_or, :description, :desc_detail
      attr_reader :type, :owner_type, :remove, :when, :count, :count_per_or, :start_count, :passive,
                  :on_phase, :use_across_ors

      def initialize(type:, description: nil, desc_detail: nil, owner_type: nil, count: nil, remove: nil,
                     use_across_ors: nil, count_per_or: nil, passive: nil, on_phase: nil, **opts)
        @type = type&.to_sym
        @description = description&.to_s
        @desc_detail = desc_detail&.to_s
        @owner_type = owner_type&.to_sym
        @when = Array(opts.delete(:when)).map(&:to_s)
        @on_phase = on_phase
        @count = count
        @count_per_or = count_per_or
        @count_this_or = 0
        @use_across_ors = use_across_ors.nil? ? true : use_across_ors
        @used = false
        @remove = remove&.to_s
        @start_count = @count
        @passive = passive.nil? ? @when.empty? : passive

        setup(**opts)
      end

      def used?
        @used
      end

      def use!(**_kwargs)
        @used = true

        @count_this_or += 1 if @count_per_or

        return unless @count

        @count -= 1
        owner.remove_ability(self) unless @count.positive?
      end

      def use_up!
        use! while @count.positive?
      end

      def setup(**_opts); end

      def teardown; end

      def when?(*times)
        !(@when & times).empty?
      end
    end
  end
end
