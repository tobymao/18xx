# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G18Neb
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def process_bankrupt(action)
            entity = action.entity
            player = entity.corporation? ? entity.owner : entity

            @log << "-- #{player.name} goes bankrupt and remaining shares placed in the bank pool --"

            if entity.corporation?
              @log << "#{@game.format_currency(player.cash)} is transferred from "\
                      "#{player.name} to #{entity.name}"
              player.spend(player.cash, entity) if player.cash.positive?
            end

            # Bankrupt player sells all normally allowed shares
            player.shares_by_corporation(sorted: true).each do |corporation, _|
              next unless corporation.share_price # if a corporation has not parred
              next unless (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))

              @game.sell_shares_and_change_price(bundle, movement: :none)
            end

            # Bankrupt player corporations are closed and available again to be started
            player.shares_by_corporation(sorted: true).each do |corporation, shares|
              next if shares.empty?

              @game.close_corporation(corporation)
            end

            # Companies are discarded
            unless player.companies.empty?
              @log << "#{player.name}'s companies are discarded: #{player.companies.map(&:sym).join(', ')}"
              player.companies.dup.each(&:close!)
            end

            @game.declare_bankrupt(player)
            player.set_cash(0, @game.bank)
          end
        end
      end
    end
  end
end
