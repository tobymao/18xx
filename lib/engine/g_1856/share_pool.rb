# frozen_string_literal: true

require_relative '../share_pool'

module Engine
  module G1856
    class SharePool < SharePool
      def buy_shares(entity, shares, exchange: nil, exchange_price: nil, swap: nil)
        bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)

        if !@game.class::CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT && shares.owner.player?
          @game.game_error('Cannot buy share from player')
        end

        corporation = bundle.corporation
        ipoed = corporation.ipoed
        floated = corporation.floated?

        corporation.ipoed = true if bundle.presidents_share
        price = bundle.price
        par_price = corporation.par_price&.price

        if ipoed != corporation.ipoed
          @log << "#{entity.name} pars #{corporation.name} at "\
                  "#{@game.format_currency(par_price)}"
        end

        share_str = "a #{bundle.percent}% share of #{corporation.name}"
        incremental = corporation.capitalization == :incremental

        from = 'the market'
        if bundle.owner.corporation?
          from = bundle.owner == bundle.corporation ? "the #{@game.ipo_name(corporation)}" : bundle.owner.name
        elsif bundle.owner.player?
          from = bundle.owner.name
        end

        if exchange
          price = exchange_price || 0
          case exchange
          when :free
            @log << "#{entity.name} receives #{share_str}"
          when Company
            @log << if exchange_price
                      "#{entity.name} exchanges #{exchange.name} and #{@game.format_currency(price)}"\
                      " from #{from} for #{share_str}"
                    else
                      "#{entity.name} exchanges #{exchange.name} from #{from} for #{share_str}"
                    end
          end
        else
          price -= swap.price if swap
          swap_text = swap ? " + swap of a #{swap.percent}% share" : ''
          @log << "#{entity.name} buys #{share_str} "\
            "from #{from} "\
            "for #{@game.format_currency(price)}#{swap_text}"
        end

        if price.zero?
          transfer_shares(bundle, entity)
        else
          puts 'buy share', bundle, entity, price
          transfer_shares(
            bundle,
            entity,
            spender: entity == self ? @bank : entity,
            receiver: incremental && bundle.owner.corporation? ? bundle.owner : @bank,
            price: price,
            swap: swap,
            swap_to_entity: swap ? self : nil
          )
        end

        @game.float_corporation(corporation) unless floated == corporation.floated?
      end
    end
  end
end
