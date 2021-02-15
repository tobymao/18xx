# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TrainBorrow < Base
      attr_reader :train_types, :from_depot, :from_market

      def setup(train_types:, from_depot:, from_market:)
        @train_types = train_types
        @from_depot = from_depot
        @from_market = from_market
      end
    end
  end
end
