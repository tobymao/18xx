# frozen_string_literal: true

module Engine
  module Game
    module G18India
      class Corporation < Engine::Corporation

        attr_reader :managers_share

        def initialize(sym:, name:, **opts)
          super

          # Create Manager's Share (a 0% share that is used to track current manager, can not be sold)
          @managers_share = Share.new(self, owner: @ipo_owner, president: true, percent: 0, index: 'M', cert_size: 0)
          @managers_share.counts_for_limit = false
          @ipo_owner.shares_by_corporation[self] << @managers_share
          old_president = @presidents_share
          @presidents_share = @managers_share
          @floatable = false # corp can't float until there is a manager or president

          return unless sym == 'GIPR' # Modify for GIPR differences

          # Create replacement first share such that president: == false (allow sale to market / prevent receivership)
          replacement = Share.new(self, owner: @ipo_owner, president: false, percent: 10, index: 0)
          @ipo_owner.shares_by_corporation[self] << replacement
          @ipo_owner.shares_by_corporation[self].delete(old_president)

          # Add 3 exchange tokens to GIPR
          ability = Ability::Base.new(
            type: 'exchange_token',
            description: 'Exchange tokens: 3',
            count: 3
          )
          add_ability(ability)
        end

        def make_manager(player)
          @ipo_owner.shares_by_corporation[self].delete(@managers_share)
          player.shares_by_corporation[self] << @managers_share
          @managers_share.owner = player
          self.owner = player
          @floatable = true # Corp may float now that there is a (potential) manager
        end

        def change_to_directed_corp(share, player)
          @presidents_share = share
          # adjust shareholders
          share_holders[@ipo_owner] -= share.percent
          share_holders[player] += share.percent
          # transfer share to player and player pays corp
          @ipo_owner.shares_by_corporation[self].delete(@presidents_share)
          player.shares_by_corporation[self] << @presidents_share
          @presidents_share.owner = player
          player.spend(share.price, self)
          self.owner = player
          # remove Manager's Share
          mgr_share_owner = @managers_share.owner
          mgr_share_owner.shares_by_corporation[self].delete(@managers_share)
          @floatable = true # Corp may float now that there is a director
          @floated = true # Director's share floats corp
        end

        def manager_count
          @managers_share.owner.num_shares_of(self)
        end

        def pres_cert_count
          @presidents_share.owner.num_shares_of(self)
        end

        def manager_need_directors_share?
          return false if @presidents_share.owner == @managers_share.owner

          manager_count >= pres_cert_count
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
          presidents_share.percent == 0
        end
      end
    end
  end
end
