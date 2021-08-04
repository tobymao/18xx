# frozen_string_literal: true

require_relative '../../../step/share_buying'

module Engine
  module Game
    module G18EU
      module MinorExchange
        include Engine::Step::ShareBuying

        def merge_minor!(minor, corporation)
          minor.tokens.first.remove!

          transfer_treasury(minor, corporation)
          transfer_trains(minor, corporation)

          @game.close_corporation(minor, quiet: false)
          minor.close!
        end

        def exchange_share(minor, corporation)
          @game.log << "#{minor.owner.name} exchanges #{minor.name} for a "\
                       "10% share of #{corporation.name}"

          buy_shares(minor.owner, corporation.ipo_shares.first.to_bundle, exchange: true)
        end

        def transfer_treasury(source, destination)
          return unless source.cash.positive?

          @game.log << "#{destination.name} takes #{@game.format_currency(source.cash)}"\
                       " from #{source.name} remaining cash"

          source.spend(source.cash, destination)
        end

        def transfer_trains(source, destination)
          return unless source.trains.any?

          transferred = @game.transfer(:trains, source, destination)

          @game.log << "#{destination.name} takes #{transferred.map(&:name).join(', ')}"\
                       " train#{transferred.one? ? '' : 's'} from #{source.name}"
        end
      end
    end
  end
end
