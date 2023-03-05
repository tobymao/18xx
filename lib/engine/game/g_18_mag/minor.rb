# frozen_string_literal: true

require_relative '../../minor'

module Engine
  module Game
    module G18Mag
      class Minor < Engine::Minor
        def all_abilities
          all_abilities = @abilities
          if owner.respond_to?(:companies)
            all_abilities += owner.companies&.flat_map do |c|
              c.all_abilities.select do |a|
                a.when.to_s.include?('owning_player')
              end
            end
          end
          all_abilities
        end
      end
    end
  end
end
