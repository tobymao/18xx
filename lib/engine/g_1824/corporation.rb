# frozen_string_literal: true

require_relative 'corporation'

module Engine
  module G1824
    class Corporation < Corporation
      def can_par?(_entity)
        super && !all_abilities.find { |a| a.type == :no_buy }
      end
    end
  end
end
