# frozen_string_literal: true

require 'find'
require 'singleton'

class FixtureCache
  include Singleton

  # clear_cache should be passed as true by tests that process different actions
  # or otherwise mutate the game state in any way that deviates from the state
  # arising from processing the fixture normally
  def fixture_at_action(action = 1, clear_cache: false)
    descriptions = group_descriptions(RSpec.current_example)
    title = game_title_for_test(descriptions)
    file = game_file_for_test(descriptions, title)

    @cache ||= {}
    @cache.clear if @cache.size.positive? && !@cache.include?(title)
    @cache[title] ||= {}

    data = @cache.dig(title, file, :data)
    unless data
      data = JSON.parse(File.read(file))
      @cache[title][file] = { data: data }
    end

    game = @cache.dig(title, file, :game)
    if game && ((game.last_processed_action || 0) <= action)
      game.process_to_action(action)
    else
      game = Engine::Game.load(data, at_action: action, strict: true)
      @cache[title][file][:game] = game
    end
    @cache[title][file].delete(:game) if clear_cache

    game.maybe_raise!
  end

  private

  # the top level describe needs to be the Game class, e.g.,
  # `describe Engine::Game::G1889::Game`
  def game_title_for_test(descriptions)
    game_class = Object.const_get(descriptions[-1])
    game_class.title
  end

  # one of the `describe` or `context` strings needs to match the fixture ID
  def game_file_for_test(descriptions, title)
    dir = Engine.meta_by_title(title).fixture_dir_name
    test_files_for_title = Find.find("#{FIXTURES_DIR}/#{dir}")
    filenames = descriptions[0..-2].lazy.map do |description|
      test_files_for_title.find { |f| File.basename(f) == "#{description}.json" }
    end
    filenames.find { |f| !f.nil? }
  end

  # returns array of strings or objects containing the `it`/`context`/`describe`
  # string (or object), from `it` to the top-level describe
  def group_descriptions(test)
    descriptions = []
    group = test.metadata[:example_group]
    until group.nil?
      descriptions << group[:description]
      group = group[:parent_example_group]
    end
    descriptions
  end
end
