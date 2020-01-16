# frozen_string_literal: true

module View
  class Round < Snabberb::Component
    needs :game, store: true

    def process_action(action)
      @game.process_action(action)
      store(:game, @game)
    end
  end
end
