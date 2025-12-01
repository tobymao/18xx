# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G18NY
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def active_entities
            return [@round.cash_crisis_entity] if @round.cash_crisis_entity

            super
          end

          def process_bankrupt(action)
            entity = action.entity
            player = entity.corporation? ? entity.owner : entity

            @log << "-- #{player.name} goes bankrupt and remaining shares placed in the bank pool --"

            # President sells all normally allowed shares
            player.shares_by_corporation(sorted: true).each do |corporation, _|
              next unless corporation.share_price # if a corporation has not parred
              next unless (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))

              @game.sell_shares_and_change_price(bundle)
            end

            # President's shares are placed in the bank pool
            player.shares_by_corporation(sorted: true).each do |corporation, shares|
              next if shares.empty?

              bundle = ShareBundle.new(shares)
              @game.share_pool.transfer_shares(bundle, @game.share_pool, allow_president_change: true)

              next if corporation.owner != player || !corporation.share_price.price.positive?

              @log << "-- #{corporation.name} enters receivership (it has no president) --"
              corporation.owner = @game.share_pool
            end

            if player.companies.any?
              @log << "#{player.name}'s companies go to the bank: #{player.companies.map(&:sym).join(', ')}"
              player.companies.each { |c| c.owner = @game.bank }
              player.companies.clear
            end

            if entity.corporation?
              @log << "#{@game.format_currency(player.cash)} is transferred from "\
                      "#{player.name} to #{entity.name}"
              player.spend(player.cash, entity) if player.cash.positive?
            end

            @game.corporations.dup.each do |corporation|
              @game.close_corporation(corporation) if corporation.share_price&.type == :close
            end

            @game.declare_bankrupt(player)
            player.set_cash(0, @game.bank)

            @game.round.force_next_entity! if entity.corporation? && @round.skip_entity?(entity)
          end
        end
      end
    end
  end
end
