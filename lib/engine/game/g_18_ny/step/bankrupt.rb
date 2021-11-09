# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G18NY
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def process_bankrupt(action)
            corp = action.entity
            player = corp.owner

            @log << "-- #{player.name} goes bankrupt and remaining shares placed in the bank pool --"

            # President's shares are placed in the bank pool
            player.shares_by_corporation(sorted: true).each do |corporation, shares|
              next if shares.empty?

              bundle = ShareBundle.new(shares)
              @game.share_pool.transfer_shares(bundle, @game.share_pool, allow_president_change: true)

              next unless corporation.owner == player && corporation.share_price.price.positive?

              @log << "-- #{corporation.name} enters receivership (it has no president) --"
              corporation.owner = @game.share_pool
              @game.round.force_next_entity!
            end

            if player.companies.any?
              # TODO: companies should be buyable
              @log << "#{player.name}'s companies close: #{player.companies.map(&:sym).join(', ')}"
              player.companies.dup.each(&:close!)
            end

            @log << "#{@game.format_currency(player.cash)} is transferred from "\
                    "#{player.name} to #{corp.name}"
            player.spend(player.cash, corp) if player.cash.positive?

            @game.corporations.dup.each do |corporation|
              if corporation.share_price&.type == :close
                @game.close_corporation(corporation)
                corporation.close!
              end
            end

            @game.declare_bankrupt(player)
          end
        end
      end
    end
  end
end
