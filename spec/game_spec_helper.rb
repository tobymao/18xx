# frozen_string_literal: true

require 'find'

require_relative './spec_helper'

def fixture_at_action(action_id = 1)
  group_descriptions = group_descriptions(RSpec.current_example)

  # assume a top-level `describe Engine::Game::G18<Something>::Game`
  game_class = Object.const_get(group_descriptions[-1])
  game_title = game_class.title

  # rubocop:disable Style/MultilineBlockChain
  # find a `describe` str that is a fixture's filename
  game_file = group_descriptions[..-2].lazy.map do |description|
    Find.find("#{FIXTURES_DIR}/#{game_title}").find { |f| File.basename(f) == "#{description}.json" }
  end.find { |f| !f.nil? }
  # rubocop:enable Style/MultilineBlockChain

  Engine::Game.load(game_file, at_action: action_id).maybe_raise!
end

def group_descriptions(test)
  descriptions = []
  group = test.metadata[:example_group]
  until group.nil?
    descriptions << group[:description]
    group = group[:parent_example_group]
  end
  descriptions
end
