# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G1882
      class Operating < Operating
        def lay_tile(action)
          super

          nwr_name = 'NWR'
          nwr_tile = action.tile.icons.any? { |icon| icon.name == nwr_name }
          return if !nwr_tile || action.tile.color != :yellow

          @game.log << "#{action.entity.name} gains #{@game.format_currency(20)} for laying yellow tile in NWR area"
          @bank.spend(20, action.entity)
        end
      end
    end
  end
end
