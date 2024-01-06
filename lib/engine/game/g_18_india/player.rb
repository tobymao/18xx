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

        def init_hand(new_hand)
          return [] unless new_hand
          @hand = new_hand
        end

        def remove_unselected_for_draft
          draft = []
          cards = self.hand.dup
          cards.each do |card|
            if card.owner == nil
              draft << card
              hand.delete(card)
            end
          end
          draft
        end

        def value
          # modify to include book value
          # @cash + shares.select { |s| s.corporation.ipoed }.sum(&:price) + @companies.sum(&:value)
          super
        end
=begin 
=end
      end
    end
  end
end
