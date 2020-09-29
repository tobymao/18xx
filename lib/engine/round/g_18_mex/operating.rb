# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G18MEX
      class Operating < Operating
        def skip_steps
          entity = @entities[@entity_index]
          return super if entity.minor?

          entity.trains.empty? ? handle_no_mail(entity) : handle_mail(entity)
          super
        end

        private

        def handle_no_mail(entity)
          @log << "#{entity.name} receives no mail income as no trains"
        end

        def handle_mail(entity)
          hex = @game.hex_by_id(entity.coordinates)
          income = hex.tile.city_towns.first.route_revenue(@game.phase, entity.trains.first)
          @game.bank.spend(income, entity)
          @log << "#{entity.name} receives #{@game.format_currency(income)} in mail"
        end
      end
    end
  end
end
