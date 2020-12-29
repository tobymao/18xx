# frozen_string_literal: true

require_relative '../corporation'

module Engine
  module G1856
    class Corporation < Corporation
      attr_accessor :escrow
      attr_reader :all_shares
      CAPITALIZATION_STRS = {
        full: 'Full',
        incremental: 'Incremental',
        escrow: 'Escrow',
      }.freeze
      def initialize(game, sym:, name:, **opts)
        @game = game
        @started = false
        @escrow = nil
        @log = @game.log
        super(sym: sym, name: name, **opts)
        @all_shares = shares_by_corporation[self].dup
        @capitalization = nil
      end

      # ~Ab~RE-using floated? to represent whether or not a corporation has operated
      def floated?
        @started || (@capitalization == :full && percent_of(self) <= 100 - percent_to_float)
      end

      def floatable?
        percent_of(self) <= 100 - percent_to_float
      end

      def float!
        @started = true
      end

      def can_buy?
        false
      end

      def can_par?
        self == @game.national ? !@ipoed : super
      end

      def par!
        @capitalization = _capitalization_type
        @escrow = 0 if @capitalization == :escrow
      end

      def capitalization_type_desc
        CAPITALIZATION_STRS[@capitalization || _capitalization_type]
      end

      def release_escrow!
        @log << "Releasing #{@game.format_currency(@escrow)} from escrow for ${@name}"
        @cash += @escrow
        @escrow = nil
        @capitalization = :incremental
      end

      # Issue more shares
      # THIS DOES NOT WORK IF THE PRESIDENCY IS HELD BY A PLAYER
      def issue_shares!
        if total_shares == 10 # was 10 share
          @log << "#{@name} shares are 5% shares"

          @all_shares.each_with_index do |share, index|
            share.percent = index.zero? ? 10 : 5
            share.cert_size = index.zero? ? 1 : 0.5
          end
        end

        @log << "#{@name} issues 10 more shares"
        num_shares = @all_shares.count
        # Yes, this can create 50 5% shares in one corp. 1891 does this. It is weird
        10.times do |i|
          new_share = Share.new(self, percent: 5, index: num_shares + i, cert_size: 0.5)
          @all_shares << new_share
          shares_by_corporation[self] << new_share
        end
      end

      # This is invoked BEFORE the share is moved out of the corporation
      def escrow_share_buy!
        # Take in money normally when buying the first 50% of stock
        return if percent_of(self) > 50

        # Otherwise everything goes to escrow..
        @escrow += @par_price.price
        @cash -= @par_price.price
      end

      def _capitalization_type
        # TODO: escrow
        return :escrow if @game.phase.status.include? :escrow
        return :incremental if @game.phase.status.include? :incremental
        return :full if @game.phase.status.include? :fullcap

        # This shouldn't happen
        raise NotImplementedError
      end

      # As long as this is only used in core code for display we can re-use it
      def percent_to_float
        return 20 if @game.phase.status.include?(:facing_2)
        return 30 if @game.phase.status.include?(:facing_3)
        return 40 if @game.phase.status.include?(:facing_4)
        return 50 if @game.phase.status.include?(:facing_5)
        return 60 if @game.phase.status.include?(:facing_6)

        # This shouldn't happen
        raise NotImplementedError
      end
    end
  end
end
