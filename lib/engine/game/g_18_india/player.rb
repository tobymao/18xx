# frozen_string_literal: true

require_relative '../../player'

module Engine
  module Game
    module G18India
      class Player < Engine::Player
        attr_accessor :hand

        def initialize(id, name)
          @hand = []
          super
        end

        def value
          # modify to include book value
          # @cash + shares.select { |s| s.corporation.ipoed }.sum(&:price) + @companies.sum(&:value)
          super
        end
      end
    end
  end
end
