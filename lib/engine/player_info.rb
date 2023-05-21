# frozen_string_literal: true

module Engine
  # Information about an players status
  class PlayerInfo
    attr_reader :round_name, :turn, :round_no, :value

    def initialize(round_name, turn, round_no, player_value)
      @round_name = round_name
      @turn = turn
      @round_no = round_no
      @value = player_value
    end

    def round
      if %w[AR MR OR DEV].include?(round_name)
        "#{round_name} #{turn}.#{round_no}"
      else
        "#{round_name} #{turn}"
      end
    end
  end
end
