# frozen_string_literal: true

module SpecHelpers
  LoadedGameFixture = Struct.new(:title, :players, :id, :data) do
    def loose_game
      @loose_game ||= new_game(true)
    end

    def strict_game
      @strict_game ||= new_game(false)
    end

    def new_game(strict)
      game_klass.new(players, id: id, actions: data['actions'], strict: strict)
    end

    def game_klass
      ::Engine::GAMES_BY_TITLE[title]
    end
  end

  def load_game_fixture(title, id)
    game_path = title.gsub(/(.)([A-Z])/, '\1_\2').downcase
    fixture_path = File.join(['spec', 'fixtures', game_path, "#{id}.json"])
    data = JSON.parse(File.read(fixture_path))
    players = data['players'].map { |p| p['name'] }
    LoadedGameFixture.new(title, players, id, data)
  end
end
