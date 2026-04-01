# frozen_string_literal: true

require_relative '../g_1880/corporation'

module Engine
  module Game
    module G1880Romania
      class Corporation < G1880::Corporation
        def all_abilities
          all_abilities = @companies.flat_map(&:all_abilities) + @abilities
          if owner.respond_to?(:companies)
            all_abilities += owner.companies&.flat_map do |c|
              next [] unless assigned?(c.id)

              c.all_abilities.select { |a| a.when.to_s.include?('owning_player') }
            end
          end
          all_abilities
        end
      end
    end
  end
end
