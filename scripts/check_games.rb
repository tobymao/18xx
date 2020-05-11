# frozen_string_literal: true

Dir['./models/**/*.rb'].sort.each { |file| require file }
require './lib/engine'

games = Game.eager(:user, :players, :actions).where(status: 'new').invert.all
errored = false

_ = games.each do |game|
  engine = Engine::Game::G1889.new(game.ordered_players.map(&:name))
  actions = game.actions.map(&:to_h)
  begin
    actions.each { |x| engine = engine.process_action(x) }
  rescue Engine::GameError => e
    puts '# gameid, action_id, reason' unless errored
    errored = true
    puts "#{game.id},#{engine.current_action_id - 1}/#{actions.size},#{e}"
  end
end
