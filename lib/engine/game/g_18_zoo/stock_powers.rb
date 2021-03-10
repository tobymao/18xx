# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module StockPowers
        def holiday
          @holiday ||= company_by_id('HOLIDAY')
        end

        def midas
          @midas ||= company_by_id('MIDAS')
        end

        def too_much_responsibility
          @too_much_responsibility ||= company_by_id('TOO_MUCH_RESPONSIBILITY')
        end

        def leprechaun_pot_of_gold
          @leprechaun_pot_of_gold ||= company_by_id('LEPRECHAUN_POT_OF_GOLD')
        end

        def it_is_all_greek_to_me
          @it_is_all_greek_to_me ||= company_by_id('IT_IS_ALL_GREEK_TO_ME')
        end

        def whatsup
          @whatsup ||= company_by_id('WHATSUP')
        end

        def midas_active?
          !abilities(midas, :close).nil?
        end

        def greek_to_me_active?
          !abilities(it_is_all_greek_to_me, :close).nil?
        end
      end
    end
  end
end
