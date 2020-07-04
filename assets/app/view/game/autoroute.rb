module View
  module Game
    class Autoroute
      def self.calculate(game, corporationId)
        corp = game.corporation_by_id(corporationId)
        corp.trains
      end
    end
  end
end
