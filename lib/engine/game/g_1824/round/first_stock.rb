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
            # It is (barely) possible BH has been sold out - handle stock movement for that
            @game.corporations.select { |c| c.type == :major && c.floated? }.sort.each do |corp|
              sold_out_stock_movement(corp) if sold_out?(corp)
            end

            @game.log << 'First stock round is finished - any unsold Pre-State Railways, Coal Railways, ' \
                         ' and Montain Railways are removed from the game'

            @game.companies.each do |company|
              next if company.closed? || company.owned_by_player?

              company.close!

              if @game.mountain_railway?(company)
                # Rule VI.3, bullet 10: Mountain Railways not bought are removed from the game
                @game.log << "Mountain Railway #{company.name} closes"
                next
              end

              minor = @game.corporation_by_id(company.sym)

              if company.meta[:type] == :coal
                # Rule VI.3, bullet 10: Coal company close
                # 1. Close company representing the coal company
                # 2. Close connected minor
                # 3. Remove reservation of presidency share for connected Regional Railway, and make it floatable
                associated_regional_railway = @game.get_associated_regional_railway(minor)
                @game.log << "Coal Railway #{company.sym} closes; #{associated_regional_railway.name} becomes a "\
                             "Regional Railway without an associated Coal Railway: president's share is no longer reserved"

                minor.close!
                associated_regional_railway.remove_reserve_for_all_shares!
                next
              end

              # There is no implementation for close of a major Pre-Staatbahn - this is a weird corner case
              if company.sym.end_with?('1')
                raise GameError, 'The weird case of unsold SD1, KK1, UG1 is not supported. Please reconsider. They are good!'
              end

              # Rule VI.3, bullet 10: Pre-State Railways not bought are removed from the game
              # # Make reserved share of associated corporation unreserved
              # regional.shares.find(&:president).buyable = true
              # regional.floatable = true
              # # Preestatsbahn closes
              # 1. Close company representing the pre-staatsbahn
              # 2. Close connected Preestatsbahn Minor
              # 3. Remove reservation of starting city
              # 4. Remove reservation of shares in connected national
              # 5. Do not make national floatable - still need phase to do that
              @game.log << "Pre-staatsbahn #{company.sym} closes and reservations are removed"
              remove_city_reservation(minor)
              remove_share_reservation(@game.corporation_by_id(company.sym[0..-2]))
              minor.close!
            end

            # The closed entities are removed from the game
            @game.companies.reject!(&:closed?)
            @game.corporations.reject!(&:closed?)
          end

          private

          def remove_city_reservation(minor)
            hex = @game.hex_by_id(minor.coordinates)
            tile = hex.tile
            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(minor) } || cities.first
            city.remove_reservation!(minor)
            minor.tokens.first.remove!
          end

          def remove_share_reservation(national)
            national.unreserve_one_share!
          end
        end
      end
    end
  end
end
