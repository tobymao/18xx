# frozen_string_literal: true

require_relative 'scripts_helper'

# return first game (and action) found where the given block (which takes an
# Engine::Game object `game` as its argument) returns `true`
#
# For example, to find all 1822PNW games where
# https://github.com/tobymao/18xx/issues/9266 is reproducible:
#
#   find_game(all: true, title: '1822PNW') do |game|
#     p11 = game.company_by_id('P11')
#     seattle = game.hex_by_id('H11')
#     portland = game.hex_by_id('O8')
#
#     p11.owner&.corporation? && (p11.owner.type == :major) &&
#       (seattle.tile.color == :white || portland.tile.color == :white)
#   end
#
# Arguments:
#
#   all - if true, find all games instead of just one match
#   process_actions - if false, only check the games at initial setup
#   strict - forwarded to `Engine::Game.load()`
#   page_size - how many games to fetch from the DB at once
#   **kwargs - forwarded to the DB query for games; recommended to include `id` or `title`
def find_game(all: false, process_actions: true, strict: true, page_size: 100, **kwargs)
  pin_key = Sequel.pg_jsonb_op(:settings).has_key?('pin') # rubocop:disable Style/PreferredHashMethods
  where_kwargs = {
    pin_key => false,
    :status => %w[active finished],
  }.merge(kwargs)

  selected_ids = DB[:games].order(:id).where(**where_kwargs).select(:id).all.map { |g| g[:id] }
  puts "Found #{selected_ids.size} games to evaluate."

  matches = []

  selected_ids.each_slice(page_size) do |ids|
    puts "Loading #{ids.size} games from the DB..."

    Game.eager(:user, :players, :actions).where(id: ids).all.each do |db_game|
      puts "Checking game #{db_game.id}..."

      game = Engine::Game.load(db_game, strict: strict, at_action: 0)
      if yield(game)
        puts '    found match at initialization'
        match = { game: game.id, action: 0 }
        return match unless all

        matches << match
        next
      end
      next unless process_actions

      game.instance_variable_get(:@raw_all_actions).each do |action|
        game.process_to_action(action['id'])

        next unless yield(game)

        puts "    found match at action #{action['id']}"
        match = { game: game.id, action: action['id'] }
        return match unless all

        matches << match
        break
      end
    end
  end

  matches
end
