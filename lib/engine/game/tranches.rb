# frozen_string_literal: true

module Engine
  module Game
    module Tranches
      attr_reader :tranches, :current_tranch_index

      # Setup tranches given an array of arrays where every open company slot
      # is nil. If a tranch should start filled just send the corporation
      # instance instead of nil.
      #
      # One simple example could be 2 tranches of 2 companies each:
      # init_tranches([[nil, nil], [nil, nil]])
      def init_tranches(initial_tranches = [])
        @tranches = initial_tranches
        @current_tranch_index = @tranches.find_index { |tranch| tranch.any?(&:nil?) } || 0
      end

      # Return the current tranch row
      def current_tranch
        @tranches[@current_tranch_index]
      end

      # Did we fill up every company slot?
      def tranches_full?
        return true unless @tranches

        @current_tranch_index >= @tranches.size
      end

      # Returns the index in the current tranch that is open, or nil if
      # nothing is open
      def current_tranch_slot_index
        return nil unless @tranches && current_tranch

        current_tranch.find_index(nil)
      end

      # Adds this corporation into the next open slot without validation
      def add_corporation_to_tranches(corporation)
        # Does the current slot have a spot?
        slot = current_tranch_slot_index
        current_tranch[slot] = corporation

        # Move up our current_tranch if this filled up our current one
        @current_tranch_index += 1 unless current_tranch_slot_index

        current_tranch
      end

      # Does the current tranch have an open spot?
      def current_tranch_open?
        return false if tranches_full?

        !!current_tranch_slot_index
      end

      # A company is sold out if there are no shares in the market or treasury
      def corporation_sold_out?(corporation)
        (corporation.shares_of(corporation) + share_pool.shares_of(corporation)).empty?
      end

      # Returns true if all of the previous tranch row of companies have
      # operator, or have sold out.
      def previous_tranch_all_sold_out_or_operated?
        return true unless @tranches
        return true if @current_tranch_index.zero?

        prev_tranch = @tranches[@current_tranch_index - 1]

        return true unless prev_tranch

        prev_tranch.all? do |corporation|
          corporation and (corporation.operated? or corporation_sold_out?(corporation))
        end
      end

      # Is a company able to be opened right now?
      def tranch_available?
        current_tranch_open? and previous_tranch_all_sold_out_or_operated?
      end
    end
  end
end
