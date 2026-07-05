# frozen_string_literal: true

module Engine
  class TimerRules
    STARTING_BANK_SECONDS = 300       # 300 seconds (5 minutes)
    COMPANY_TURN_BONUS_SECONDS = 30   # +30 seconds awarded globally BEFORE an OR starts
    STOCK_ROUND_BONUS_SECONDS = 60    # +60 seconds awarded globally BEFORE a SR starts

    def self.initial_bank
      STARTING_BANK_SECONDS
    end

    # Hook called BEFORE a new round starts (Handles both SR and OR initialization)
    def self.apply_round_bonus!(game, round_type)
      return unless %i[stock operating].include?(round_type)

      # Use the game's current round object instance to guarantee idempotency during rehydration loops
      current_round = game.round
      return if current_round.instance_variable_get(:@round_bonus_applied)

      current_round.instance_variable_set(:@round_bonus_applied, true)

      bonus_seconds = round_type == :stock ? STOCK_ROUND_BONUS_SECONDS : COMPANY_TURN_BONUS_SECONDS

      bonus_ms = bonus_seconds * 1000

      game.players.each do |player|
        current_time = player.instance_variable_get(:@thinking_time_ms) || (STARTING_BANK_SECONDS * 1000)
        player.instance_variable_set(:@thinking_time_ms, current_time + bonus_ms)
      end
      warn "=== [TIMER RULES] === Awarded #{round_type.to_s.upcase} Round Start Bonus (+#{bonus_seconds}s) to all players."
    end

    # Deprecated per-company hook since OR bonus is now distributed globally at round start
    def self.apply_company_turn_bonus!(operator); end
  end
end
