# frozen_string_literal: true

Game.where(title: '18ZOO', status: %w[active finished]).each do |game|
  new_title =
    if game.players.size < 4
      '18ZOO - Map A'
    else
      '18ZOO - Map D'
    end
  game.title = new_title
  game.save
end
