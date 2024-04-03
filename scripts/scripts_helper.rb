# frozen_string_literal: true

# database stuff
require_relative '../db'
require_relative '../models'
require_relative '../models/action'
require_relative '../models/game'
require_relative '../models/game_user'
require_relative '../models/user'
Sequel.extension :pg_json_ops

# game engine
require_relative '../lib/engine'

# can override in specific script if necessary
Engine::Logger.set_level(Logger::FATAL)
