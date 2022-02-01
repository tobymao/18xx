# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G18GB
      class Company < Engine::Company
        attr_accessor :name, :desc, :max_price, :min_price, :revenue, :discount, :value
        attr_reader :sym, :min_auction_price, :treasury, :interval, :color, :text_color, :closed_abilities

        def initialize(sym:, name:, value:, revenue: 0, desc: '', open_abilities: [], closed_abilities: [], **opts)
          @sym = sym
          @name = name
          @value = value
          @treasury = opts[:treasury] || @value
          @desc = desc
          @revenue = revenue
          @discount = opts[:discount] || 0
          @min_auction_price = -@discount
          @closed = false
          @min_price = (@value / 2.0).ceil
          @max_price = @value * 2
          @interval = opts[:interval]
          @color = opts[:color] || :yellow
          @text_color = opts[:text_color] || :black
          @closed_abilities = closed_abilities

          init_abilities(open_abilities + [close_ability])
        end

        def close_ability
          {
            type: 'choose_ability',
            owner_type: 'player',
            when: 'any',
            choices: { "close_#{@sym}": "Close #{@name}" }
          }
        end

        def close!
          @closed = true
          @revenue = 0

          all_abilities.dup.each { |a| remove_ability(a) }
          init_abilities(@closed_abilities)
        end

      end
    end
  end
end
