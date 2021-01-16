# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1824
      class Stock < Stock
        attr_reader :reverse

        def description
          'First Stock Round'
        end

        def self.title
          'Hepp'
        end

        def setup
          @reverse = true

          super

          @entities.reverse!
        end

        def select_entities
          @game.players.reverse
        end

        def next_entity_index!
          if @entity_index == @game.players.size - 1
            @reverse = false
            @entities = @game.players
          end
          return super unless @reverse

          @entity_index = (@entity_index - 1) % @entities.size
        end

        def finish_round
          @game.log << 'First stock round is finished - any unsold Pre-State Railways, Coal Railways, ' \
            ' and Montain Railways are removed from the game'

          @game.purchasable_unsold_companies.select { |c| @game.mountain_railway?(c) }.each do |m|
            @game.log << "Mountain Railway #{m.name} closes"
            m.close!
          end

          @game.purchasable_unsold_companies.each do |p|
            pre_state = @game.minor_by_id(p.id)
            state = @game.associated_state_railway(p)
            @game.log << "Pre-Staatsbahn Railway #{pre_state.name} closes; "\
              "unreserved corresponding share in #{state.name} is no longer reserved"

            # Remove home city reservation
            remove_reservation(pre_state)

            # Remove home token
            pre_state.tokens.first.remove!

            pre_state.close!
            p.close!
          end

          @game.corporations.select { |c| @game.coal_railway?(c) }.reject(&:floated?).each do |c|
            regional = @game.associated_regional_railway(c)
            @game.log << "#{c.name} closes; #{regional.name}'s presidency share is no longer reserved"

            # Remove home mine reservation
            remove_reservation(c)
            c.close!

            # Make reserved share of associated corporation unreserved
            regional.shares.find(&:president).buyable = true
            regional.floatable = true
            @game.abilities(regional, :base) do |ability|
              regional.remove_ability(ability)
            end
          end
        end

        private

        def remove_reservation(corporation)
          hex = @game.hex_by_id(corporation.coordinates)
          tile = hex.tile
          cities = tile.cities
          city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
          city.remove_reservation!(corporation)
        end
      end
    end
  end
end
