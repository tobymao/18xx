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
              old_price = corp.share_price
              sold_out_stock_movement(corp) if sold_out?(corp)
              @game.log_share_price(corp, old_price)
            end

            @game.log << 'First stock round is finished - any unsold Pre-State Railways, Coal Railways, ' \
                         ' and Montain Railways are removed from the game'
            coordinates = nil
            @game.companies.each do |c|
              next if c.owner&.player? || c.closed?

              if @game.mountain_railway?(c)
                @game.log << "Mountain Railway #{c.name} closes"
                c.close!
                next
              end

              minor = @game.minor_by_id(c.id)
              if @game.pre_staatsbahn?(minor)
                coordinates = minor.coordinates if @game.primary_pre_state?(minor)
                # Private is a control of a pre-staatsbahn
                state = @game.associated_state_railway(c)
                if @game.primary_pre_state?(minor)
                  # President share in Staatsbahn still need to be reserved as the
                  # presidency will be transfered to a player that owns 20% or more
                  @game.log << "Pre-Staatsbahn #{minor.name} closes; presidency share in #{state.name} is still reserved "\
                               "and will be given to a player with 20%% or more after #{state.name} is formed."
                else
                  @game.log << "Pre-Staatsbahn #{minor.name} closes; "\
                               "corresponding share in #{state.name} is no longer reserved"

                  state.shares.find { |s| !s.president && s.buyable == false }.buyable = true
                end

                close_minor(minor)
                c.close!

                if @game.associated_pre_state_railways(state).all?(&:removed)
                  @game.log << "Staatsbahn #{state.name} reserves a token location"
                  tile = @game.hex_by_id(coordinates).tile
                  # Put in the right city in Wien/Budapest
                  city = @game.get_city_number_for_staatsbahn_reservation(state)
                  tile.cities[city].add_reservation!(state)
                  state.coordinates = coordinates
                end

                next
              end

              # Private is a control of a Coal Railway
              regional = @game.associated_regional_railway(minor)
              @game.log << "Coal Railway #{minor.name} closes; #{regional.name}'s presidency share "\
                           'is no longer reserved'

              close_minor(minor)
              c.close!

              # Put in a neutral token to stop it being tokened
              coordinates = minor.coordinates
              hex = hex_by_id(minor.coordinates)
              hex.tile.cities[0].place_token(@game.neutral, @game.neutral.next_token)

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
