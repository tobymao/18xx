# frozen_string_literal: true

# File: scripts/test_timer_persistence.rb
# Tests the deterministic historical reduction of player thinking times.
# Run from the terminal: ruby scripts/test_timer_persistence.rb

class MockAction
  attr_reader :user_id, :created_at

  def initialize(user_id, created_at)
    @user_id = user_id
    @created_at = created_at
  end
end

class MockUser
  attr_reader :id

  def initialize(id)
    @id = id
  end
end

class MockGame
  attr_accessor :settings, :created_at, :mock_actions, :ordered_players

  def initialize
    @settings = { 'clock_initial' => 300 }
    @created_at = Time.new(2026, 7, 4, 12, 0, 0)
    @mock_actions = []
    @ordered_players = [MockUser.new(1), MockUser.new(2)]
  end

  def actions
    relation = Object.new
    game = self
    relation.define_singleton_method(:all) { game.mock_actions }
    relation.define_singleton_method(:empty?) { game.mock_actions.empty? }
    relation
  end

  # The exact method implemented in game.rb
  def player_thinking_times
    initial_time = settings['clock_initial'] || 300
    times = ordered_players.each_with_object({}) { |p, hash| hash[p.id] = initial_time.to_f }

    actions_array = actions.all
    return times.transform_values(&:to_i) if actions_array.empty?

    prev_time = created_at.to_f
    actions_array.each do |action|
      current_time = action.created_at.to_f
      delta = current_time - prev_time
      user_id = action.user_id
      times[user_id] -= delta if times.key?(user_id)
      prev_time = current_time
    end

    times.transform_values(&:to_i)
  end
end

puts '--- Running Timer Persistence Unit Tests ---'

game = MockGame.new
base_time = game.created_at

# Test 1: No actions (Should return 300 for both)
res1 = game.player_thinking_times
puts "Test 1 (No Actions): #{res1 == { 1 => 300, 2 => 300 } ? 'PASS' : 'FAIL'} => #{res1}"

# Test 2: Player 1 takes 30 seconds
game.mock_actions << MockAction.new(1, base_time + 30)
res2 = game.player_thinking_times
puts "Test 2 (P1 takes 30s): #{res2 == { 1 => 270, 2 => 300 } ? 'PASS' : 'FAIL'} => #{res2}"

# Test 3: Player 2 takes 45 seconds
game.mock_actions << MockAction.new(2, base_time + 75) # 30s + 45s
res3 = game.player_thinking_times
puts "Test 3 (P2 takes 45s): #{res3 == { 1 => 270, 2 => 255 } ? 'PASS' : 'FAIL'} => #{res3}"

# Test 4: Player 1 goes into negative time (takes 300s)
game.mock_actions << MockAction.new(1, base_time + 375) # 75s + 300s
res4 = game.player_thinking_times
puts "Test 4 (P1 negative time): #{res4 == { 1 => -30, 2 => 255 } ? 'PASS' : 'FAIL'} => #{res4}"

puts '--- Milestone Testing Complete ---'
