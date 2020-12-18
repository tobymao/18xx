# frozen_string_literal: true

require_relative 'corporation'

module Engine
  module G1849
    class Corporation < Corporation
      attr_accessor :next_to_par, :closed_recently

      def can_par?(_entity)
        !@ipoed && @next_to_par && !@closed_recently
      end
    end
  end
end
