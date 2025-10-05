# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G1837
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def process_bankrupt(action)
            entity = action.entity
            player = entity.owner

            @log << "-- #{player.name} goes bankrupt and remaining shares placed in the bank pool --"

            unless player.companies.empty?
              @log << "#{player.name}'s companies close: #{player.companies.map(&:sym).join(', ')}"
              player.companies.dup.each(&:close!)
            end

            # President sells all normally allowed shares
            player.shares_by_corporation(sorted: true).each do |corporation, _|
              next unless corporation.share_price # if a corporation has not parred
              next unless (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))

              @game.sell_shares_and_change_price(bundle)
            end

            # Remaining shares are placed in the bank pool. Coal companies and minors merge immediately,
            # unless the presidency is transferred (UG1 and UG3).
            player.shares_by_corporation(sorted: true).each do |corporation, shares|
              next if shares.empty?

              bundle = ShareBundle.new(shares)
              @game.share_pool.transfer_shares(bundle, @game.share_pool, allow_president_change: true)
              next if corporation.owner != player

              corporation.owner = @game.share_pool
              if corporation.type == :minor
                @log << "#{corporation.name} is forced to merge immediately"
                @game.merge_minor!(corporation, @game.exchange_target(corporation))
              else
                @log << "-- #{corporation.name} is directorless --"
              end
            end

            if entity.corporation? && player.cash.positive?
              @log << "#{player.name}'s remaining cash (#{@game.format_currency(player.cash)}) is "\
                      "transferred to #{entity.name}"
              player.spend(player.cash, entity)
            end

            @game.declare_bankrupt(player)
            player.set_cash(0, @game.bank)

            @round.bankrupting_corporations << entity
          end

          def round_state
            super.merge(bankrupting_corporations: [])
          end
        end
      end
    end
  end
end
