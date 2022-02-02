# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1824
      module Round
        class FirstStock < Engine::Round::Stock
          attr_reader :reverse

          def description
            'First Stock Round'
          end

          def setup
            @game.log << 'After First Stock Round is finished any unsold Pre-State Railways, Coal Railways, '\
                         'and Mountain Railways will be removed from the game'
            @reverse = true

            super

            @entities.reverse!
          end

          def select_entities
            return super unless @reverse

            @game.players.reverse
          end

          def next_entity_index!
            if @entity_index == @game.players.size - 1
              @reverse = false
              @entities = @game.players
              @game.log << 'Player order is from now on normal'
            end

            super
          end

          def finish_round
            # It is possible a regional has been sold out - handle stock movement for that

            @game.corporations.select { |c| @game.regional?(c) && c.floated? }.sort.each do |corp|
              prev = corp.share_price.price
              sold_out_stock_movement(corp) if sold_out?(corp)
              @game.log_share_price(corp, prev)
            end

            @game.log << 'First stock round is finished - any unsold Pre-State Railways, Coal Railways, ' \
                         ' and Montain Railways are removed from the game'

            @game.companies.each do |c|
              next if c.owner&.player? || c.closed?

              if @game.mountain_railway?(c)
                @game.log << "Mountain Railway #{c.name} closes"
                c.close!
                next
              end

              minor = @game.minor_by_id(c.id)
              if @game.pre_staatsbahn?(minor)
                # Private is a control of a pre-staatsbahn
                state = @game.associated_state_railway(c)
                @game.log << "Pre-Staatsbahn #{minor.name} closes; "\
                             "corresponding share in #{state.name} is no longer reserved"

                close_minor(minor)
                c.close!
                next
              end

              # Private is a control of a Coal Railway
              regional = @game.associated_regional_railway(minor)
              @game.log << "Coal Railway #{minor.name} closes; #{regional.name}'s presidency share "\
                           'is no longer reserved'

              close_minor(minor)
              c.close!

              # Make reserved share of associated corporation unreserved
              regional.shares.find(&:president).buyable = true
              regional.floatable = true
            end
          end

          private

          def close_minor(minor)
            # Remove home city reservation
            remove_reservation(minor)

            # Remove home token
            minor.tokens.first.remove!
            minor.close!
            minor.removed = true
          end

          def remove_reservation(minor)
            hex = @game.hex_by_id(minor.coordinates)
            tile = hex.tile
            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(minor) } || cities.first
            city.remove_reservation!(minor)
          end
        end
      end
    end
  end
end
