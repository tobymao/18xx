# frozen_string_literal: true

require 'argon2'
require 'net/http'
require 'uri'

require_relative 'db'
require_relative 'models'
require_relative 'models/action'
require_relative 'models/game'
require_relative 'models/game_user'
require_relative 'models/user'

raise 'You probably only want to import games into dev servers' unless ENV['RACK_ENV'] == 'development'

def create_user(player_id, name)
  return if User[id: player_id]

  params = {
    id: player_id,
    name: name,
    email: "#{name.gsub(/\s/, '_')}@example.com",
    password: 'password',
    settings: {
      notifications: 'none',
      webhook: nil,
      webhook_url: nil,
      webhook_user_id: nil,
    },
  }
  User.create(params)
rescue Sequel::ValidationFailed
  # user email already registered
  nil
end

def import_game(game_id)
  game_uri = URI.parse("https://18xx.games/api/game/#{game_id}")
  res = Net::HTTP.get_response game_uri
  game_json_string = res.body
  game_json = JSON.parse(game_json_string)

  actions_json = game_json.delete('actions')
  # Synthetic: Whether actions were included
  game_json.delete('loaded')
  players_json = game_json.delete('players')
  user_json = game_json.delete('user')

  # Create users that don't already exist
  User.unrestrict_primary_key

  players_json.each do |player_json|
    create_user(player_json['id'], player_json['name'])
  end
  create_user(user_json['id'], user_json['name'])

  User.restrict_primary_key

  # Clean up game json
  game_json['created_at'] = Time.at(game_json['created_at'])
  game_json['updated_at'] = Time.at(game_json['updated_at'])
  game_json['finished_at'] = Time.at(game_json['finished_at']) if game_json['finished_at']

  game_json['user_id'] = user_json['id']
  # Synthetic: Denormalized user-specific subset of settings
  game_json.delete('user_settings')

  game = Game[id: game_id]
  Game.unrestrict_primary_key
  if game
    # Update existing game
    game.update(game_json)

    # Filter out actions already in the database
    max_existing_action_id = Action.where(game_id: game.id).max(:action_id)
    actions_json.delete_if { |action_json| action_json['id'] <= max_existing_action_id }
  else
    # Create new game
    game = Game.create(game_json)

    # Add users
    players_json.each do |player_json|
      player_id = player_json['id']
      user = User[id: player_id]
      GameUser.create(game: game, user: user)
    end
  end
  Game.restrict_primary_key

  # Apply new actions
  actions_json.each do |action_json|
    user_id = action_json['user']
    action_id = action_json['id']
    created_at = Time.at(action_json['created_at'])

    action_json['created_at'] = created_at
    # User field is unpredictable, but this seems to match behavior reasonably well.
    action_json.delete('user') if action_json['entity_type'] == 'player' && action_json['entity'] == action_json['user']
    Action.create(
        game: game,
        user_id: user_id,
        action_id: action_id,
        action: action_json,
        created_at: created_at,
      )
  end

  game.id
end

def fix_existing_users
  DB[:users].update(password: Argon2::Password.create('password'))
end
