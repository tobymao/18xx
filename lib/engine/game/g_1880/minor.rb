# frozen_string_literal: true

require_relative '../../minor'
require_relative '../../share_holder'

module Engine
  module Game
    module G1880
      class Minor < Engine::Minor
        include ShareHolder
        def num_shares_of(corporation, ceil: true)
          num = percent_of(corporation).to_f / corporation.share_percent
          ceil ? num.ceil : num
        end

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

        def hide_shares?
          false
        end
      end
    end
  end
end
