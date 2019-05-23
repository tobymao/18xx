# frozen_string_literal: true

require 'engine/round/private_auction'
require 'engine/round/stock'

module Engine
  module Round
    class Handler
      attr_accessor :current, :next

      def initialize(players, companies, bank)
        @players = players
        @current = PrivateAuction.new(@players, companies: companies, bank: bank)
        @next = Stock.new(@players)
      end

      def process_action(action)
        @current.process_action(action)
      end

      def finish!(phase)
        @current = @next
        @next =
          case @current
          when Stock
            Operating.new(@players)
          when Operating
            num = @current.num
            num < phase.operating_rounds ? Operating.new(@players, num: num + 1) : Stock.new(@players)
          else
            raise "Unexected round type #{@current}"
          end
      end
    end
  end
end
