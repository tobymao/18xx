# frozen_string_literal: true

module Engine
  module Game
    module G18India
      class Corporation < Engine::Corporation

        def initialize(sym:, name:, **opts)
          super

        end

        def book_value
          #sum of cash and all assets
          cash + @companies.sum(&:value) + value_of_trains + value_of_owned_shares
        end

        def book_value_per_share
          book_value / 2.0.ceil
        end

        def total_value_per_share
          share_price + book_value_per_share
        end

        def value_of_trains
          trains.select { |t| t.owner == self }.sum(&:price)
        end

        def value_of_owned_shares
          shares.select { |s| s.owner == self }.sum(&:price)
        end

        def mangaged_company?
          !presidents_share.owned_by_player?
        end

      end
    end
  end
end
