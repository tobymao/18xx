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
            @order_notified = false
            @reverse = true
            @turn = 1

            setup_pre_log_text

            super

            setup_post_log_text

            @entities.reverse!

            @remembered_cities = Hash.new { |h, k| h[k] = 0 }
          end

          def setup_pre_log_text
            @game.log << 'Player order is reversed during the first turn'
          end

          def setup_post_log_text
            @game.log << 'After First Stock Round is finished any unsold Pre-State Railways, Coal Railways, '\
                         'and Mountain Railways will be removed from the game'
          end

          def select_entities
            return super unless @reverse

            @game.players.reverse
          end

          def next_entity_index!
            do_handle_next_entity_index if @entity_index == @game.players.size - 1

            super
          end

          def do_handle_next_entity_index
            @reverse = false
            @entities = @game.players
            @game.log << 'Player order is from now on normal' unless @order_notified
            @order_notified = true
          end

          def finish_round_text
            'First SR is finished - any unsold Pre-State Railways, Coal Railways, or Montain Railways are removed from the game'
          end

          def finish_round
            # It is (barely) possible BH has been sold out - handle stock movement for that
            @game.corporations.select { |c| c.type == :major && c.floated? }.sort.each do |corp|
              sold_out_stock_movement(corp) if sold_out?(corp)
            end

            @game.log << finish_round_text if finish_round_text

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

              # Rule VI.3, bullet 10: Pre-State Railways not bought are removed from the game
              # 1. Close company representing the pre-staatsbahn
              # 2. Close connected Preestatsbahn Minor
              # 3. Remove reservation of starting city
              # 4. Remove reservation of shares in connected national
              # 5. Do not make national floatable - float happens when national formed
              national = get_staatsbahn(company)
              @game.log << "Pre-staatsbahn #{company.sym} closes and reservations are removed, "\
                           "and token is moved to #{national.name}'s charter"
              remove_city_reservation(minor)
              remove_share_reservation(national, company)
              minor.close!
              @game.return_token(national)
            end

            # In case if no pre-staatsbahn of a color was sold, the staatsbahn need to have home location set as it will
            # have no tokens on board when forming.
            @game.corporations.select { |c| @game.staatsbahn?(c) && c.reserved_shares.none? }.each do |corp|
              minor = get_primary_pre_staatsbahn(corp)
              add_city_reservation(corp, minor)
            end

            # The closed entities are removed from the game
            @game.companies.reject!(&:closed?)
            @game.corporations.reject!(&:closed?)
          end

          private

          def get_staatsbahn(company)
            @game.corporation_by_id(company.sym[0..-2])
          end

          def get_primary_pre_staatsbahn(corp)
            @game.corporation_by_id(corp.id + '1')
          end

          def primary_pre_staatsbahn?(company)
            company.sym[2] == '1'
          end

          def remove_city_reservation(minor)
            hex = @game.hex_by_id(minor.coordinates)
            tile = hex.tile
            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(minor) } || cities.first
            city.remove_reservation!(minor)
            minor.tokens.first.remove!

            # Remember the city in case staatsbahn need to reserve it later
            @remembered_cities[minor] = city
          end

          def add_city_reservation(corp, minor)
            corp.coordinates = minor.coordinates

            # This city was unreserved when pre-staatsbahn closed, and we remembered it for later use (ie now)
            city = @remembered_cities[minor]

            # TODO: When testing this with unsold KK, KK reservation does not appear until Wien is upgraded to
            # brown. Why? Need to investigate further.
            city.add_reservation!(corp, minor.city)
            @game.log << "#{corp.name} reserves city in #{city.hex.id} as home token location"
          end

          def remove_share_reservation(national, company)
            if primary_pre_staatsbahn?(company)
              national.unreserve_president_share!
            else
              national.unreserve_one_share!
            end
          end
        end
      end
    end
  end
end
