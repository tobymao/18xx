# frozen_string_literal: true

module Engine
  # Information about an players status
  class PlayerInfo
    attr_reader :round_name, :turn, :round_no, :value

    def initialize(round_name, turn, round_no, player)
      @round_name = round_name
      @turn = turn
      @round_no = round_no
      @value = player.value
    end

    def round
      "#{round_name} #{turn}.#{round_no}"
    end
  end
end
