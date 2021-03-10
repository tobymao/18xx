# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module OperativePowers
        def rabbits
          @rabbits ||= company_by_id('RABBITS')
        end

        def moles
          @moles ||= company_by_id('MOLES')
        end

        def ancient_maps
          @ancient_maps ||= company_by_id('ANCIENT_MAPS')
        end

        def hole
          @hole ||= company_by_id('HOLE')
        end

        def on_diet
          @on_diet ||= company_by_id('ON_DIET')
        end

        def sparkling_gold
          @sparkling_gold ||= company_by_id('SPARKLING_GOLD')
        end

        def that_is_mine
          @that_is_mine ||= company_by_id('THAT_IS_MINE')
        end

        def work_in_progress
          @work_in_progress ||= company_by_id('WORK_IN_PROGRESS')
        end

        def corn
          @corn ||= company_by_id('CORN')
        end

        def two_barrels
          @two_barrels ||= company_by_id('TWO_BARRELS')
        end

        def two_barrels_used_this_or?(entity)
          entity&.corporation? &&
            @game.two_barrels.owner == entity &&
            @game.two_barrels.all_abilities[0].count_this_or.positive?
        end

        def a_squeeze
          @a_squeeze ||= company_by_id('A_SQUEEZE')
        end

        def bandage
          @bandage ||= company_by_id('BANDAGE')
        end

        def wings
          @wings ||= company_by_id('WINGS')
        end

        def a_spoonful_of_sugar
          @a_spoonful_of_sugar ||= company_by_id('A_SPOONFUL_OF_SUGAR')
        end

        def rabbits_in_use?
          rabbits.all_abilities[0].count_this_or == 1
        end
      end
    end
  end
end
