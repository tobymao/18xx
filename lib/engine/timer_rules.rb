# frozen_string_literal: true

module Engine
  class TimerRules
    STARTING_BANK_SECONDS = 300       # 300 seconds (5 minutes)[cite: 6]
    COMPANY_TURN_BONUS_SECONDS = 30   # +30 seconds awarded BEFORE a company operates[cite: 6]
    STOCK_ROUND_BONUS_SECONDS = 60    # +60 seconds awarded BEFORE a stock round starts[cite: 6]

    def self.initial_bank
      STARTING_BANK_SECONDS[cite: 6]
    end

    # Hook called BEFORE a new stock round starts
    def self.apply_round_bonus!(game, round_type)
      return unless round_type == :stock[cite: 6]

      # Use the game's current round object instance or turn/round numbers to create a stable unique key
      current_round = game.round[cite: 6]
      return if current_round.instance_variable_get(:@round_bonus_applied)[cite: 6]

      current_round.instance_variable_set(:@round_bonus_applied, true)[cite: 6]

      game.players.each do |player|
        [cite: 6]
        current_time = player.instance_variable_get(:@thinking_time_ms) || STARTING_BANK_SECONDS[cite: 6]
        player.instance_variable_set(:@thinking_time_ms,
                                     current_time + STOCK_ROUND_BONUS_SECONDS)[cite: 6]
      end[cite: 6]
      warn "=== [TIMER RULES] === Awarded Stock Round Bonus (+#{STOCK_ROUND_BONUS_SECONDS}s) to all players."[cite: 6]
    end

    # Hook called BEFORE a specific company operating turn begins
    def self.apply_company_turn_bonus!(operator)
      return if operator.nil? || operator.player?[cite: 6]
      return unless (actor = operator.owner) && actor.player?[cite: 6]
      return if operator.instance_variable_get(:@or_bonus_applied_this_turn)

      operator.instance_variable_set(:@or_bonus_applied_this_turn, true)

      current_time = actor.instance_variable_get(:@thinking_time_ms) || STARTING_BANK_SECONDS[cite: 6]
      actor.instance_variable_set(:@thinking_time_ms, current_time + COMPANY_TURN_BONUS_SECONDS)[cite: 6]
      warn "=== [TIMER RULES] === Awarded Pre-Operation Turn Bonus (+#{COMPANY_TURN_BONUS_SECONDS}s) to #{actor.name} for #{operator.name}"[cite: 6]
    end
  end
end
