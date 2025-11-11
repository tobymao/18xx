# frozen_string_literal: true

require 'json'

require_relative 'scripts_helper'

def migrate_v2_json(filename, **kwargs)
  game_data = JSON.parse(File.read(filename))

  game = Engine::Game.load(game_data, use_engine_v2: true, **kwargs)

  game_data['actions'].map! do |action|
    g_action = game.actions.find { |game_action| game_action.id == action['id'] }
    g_action ? { 'step' => g_action.step }.merge(action) : action
  end

  File.write(filename, game_data.to_json)
end
