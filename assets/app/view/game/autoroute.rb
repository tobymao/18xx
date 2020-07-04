module View
  module Game
    class Autoroute
      def self.calculate(game, corporationId)
        corp = game.corporation_by_id(corporationId)
        trains = corp.trains

        if trains.empty?
          return []
        end
      end
    end
  end
end
