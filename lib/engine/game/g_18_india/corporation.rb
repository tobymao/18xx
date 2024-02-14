# frozen_string_literal: true

module Engine
  module Game
    module G18India
      class Corporation < Engine::Corporation
        def initialize(sym:, name:, **opts)
          super
          return unless sym == 'GIPR' # Modify for GIPR differences

          # Create replacement first share such that president: == false (allow sale to market / prevent receivership)
          replacement = Share.new(self, owner: @ipo_owner, president: false, percent: 10, index: 0)
          @ipo_owner.shares_by_corporation[self] << replacement
          @ipo_owner.shares_by_corporation[self].delete(@presidents_share)

          # Add 3 exchange tokens to GIPR
          ability = Ability::Base.new(
            type: 'exchange_token',
            description: 'Exchange tokens: 3',
            count: 3
          )
          add_ability(ability)
        end

        def book_value
          # sum of cash and all assets
          cash + @companies.sum(&:value) + value_of_trains + value_of_owned_shares
        end

        def book_value_per_share
          book_value / 10.0.ceil
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
