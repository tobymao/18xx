# frozen_string_literal: true

module SpecHelpers
  LoadedGameFixture = Struct.new(:loose, :strict, :data)

  def load_game_fixture(title, id)
    game_path = title.gsub(/(.)([A-Z])/, '\1_\2').downcase
    fixture_path = File.join(['spec', 'fixtures', game_path, "#{id}.json"])
    data = JSON.parse(File.read(fixture_path))
    players = data['players'].map { |p| p['name'] }
    game_klass = Engine::GAMES_BY_TITLE[title]
    LoadedGameFixture.new(
      game_klass.new(players, id: data['id'], actions: data['actions']),
      game_klass.new(players, id: data['id'], actions: data['actions'], strict: true),
      data
    )
  end
end
