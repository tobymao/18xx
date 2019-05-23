require 'component'
require 'view/auction_companies'
require 'view/entity_order'
require 'view/player'

module View
  class Game < Component
    def initialize(game: game)
      @game = game
      @round = @game.round
    end

    def render_round
      h(:div, "Round: #{@round.class.name}")
    end

    def render_action
      c(AuctionCompanies, round: @round)
    end

    def render
      players = @game.players.map { |player| c(Player, player: player) }

      h(:div, [
        h(:div, 'Game test 1889'),
        c(EntityOrder, round: @round),
        render_round,
        *players,
        render_action,
      ])
    end
  end
end
