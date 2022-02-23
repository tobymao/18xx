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
            @game.corporations.dup.each do |c|
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

            @game.close_corporation(corporation)
            corporation.close!
            @game.corporations << @game.reset_corporation(corporation)
          end
        end
      end
    end
  end
end
