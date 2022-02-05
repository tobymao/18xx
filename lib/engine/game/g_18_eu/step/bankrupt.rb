# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G18EU
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def sell_bankrupt_shares(player, corporation)
            super

            transfer_remaining_shares(player)
            fund_previous_corporation(player, corporation) unless corporation.presidents_share.owner == @game.share_pool
            maybe_restart_ownerless_corporations
          end

          def transfer_remaining_shares(player)
            player.shares.each do |share|
              @game.share_pool.transfer_shares(share.to_bundle, @game.share_pool, price: 0, allow_president_change: true)
            end
          end

          def fund_previous_corporation(player, corporation)
            @game.log << "#{corporation.name} gains #{@game.format_currency(player.cash)} from former president."
            player.spend(player.cash, corporation)
          end

          def maybe_restart_ownerless_corporations
            @game.corporations.each do |c|
              next unless c.ipoed
              next unless c.presidents_share.owner == @game.share_pool

              restart_corporation!(c)
            end
          end

          def restart_corporation!(corporation)
            @game.log << "#{corporation.name} has no president and is restarted with no compensation."

            transferred = []
            corporation.trains.dup.each do |train|
              transferred << train
              @game.depot.reclaim_train(train)
            end

            unless transferred.empty?
              @game.log << "#{corporation.name} places #{transferred.map(&:name).join(', ')}"\
                           " train#{transferred.one? ? '' : 's'} into the pool"
            end

            corporation.share_holders.keys.each do |sh|
              next if sh == corporation

              sh.shares_by_corporation[corporation].dup.each { |share| share.transfer(corporation) }
            end

            corporation.spend(corporation.cash, @game.bank) if corporation.cash.positive?
            corporation.tokens.each(&:remove!)
            corporation.share_price&.corporations&.delete(corporation)
            corporation.share_price = nil
            corporation.par_price = nil
            corporation.ipoed = false
            corporation.unfloat!
            corporation.owner = nil

            @game.bank.shares_by_corporation[corporation].sort_by!(&:id)
          end
        end
      end
    end
  end
end
