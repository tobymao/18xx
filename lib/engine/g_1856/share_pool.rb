# frozen_string_literal: true

require_relative '../game_error'
require_relative '../share_pool'

module Engine
  module G1856
    class SharePool < SharePool
      def buy_shares(entity, shares, exchange: nil, exchange_price: nil, swap: nil)
        bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)

        if !@game.class::CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT && shares.owner.player?
          raise GameError, 'Cannot buy share from player'
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
        else # Except for this else statement everything in this method is the same as in the super
          escrow = corporation.capitalization == :escrow
          receiver = (escrow || incremental) && bundle.owner.corporation? ? bundle.owner : @bank
          transfer_shares(
            bundle,
            entity,
            spender: entity == self ? @bank : entity,
            receiver: receiver,
            price: price,
            swap: swap,
            swap_to_entity: swap ? self : nil
          )
        end

        @game.float_corporation(corporation) unless floated == corporation.floated?
      end

      def transfer_shares(bundle, to_entity,
                          spender: nil,
                          receiver: nil,
                          price: nil,
                          allow_president_change: true,
                          swap: nil,
                          swap_to_entity: nil)
        corporation = bundle.corporation
        owner = bundle.owner
        previous_president = bundle.president
        price ||= bundle.price

        corporation.share_holders[owner] -= bundle.percent
        corporation.share_holders[to_entity] += bundle.percent

        if swap
          # Need to handle this separately as transfer and swap
          # might be between different pair (ie player buy from IPO
          # and the player's swap share end up in Market)
          corporation.share_holders[swap.owner] -= swap.percent
          corporation.share_holders[swap_to_entity] += swap.percent
          move_share(swap, swap_to_entity)
        end

        spender.spend(price, receiver) if spender && receiver && price.positive?
        # This line is the only difference from super
        corporation.escrow_share_buy! if corporation.capitalization == :escrow && receiver == corporation
        bundle.shares.each { |s| move_share(s, to_entity) }

        return unless allow_president_change

        # check if we need to change presidency
        max_shares = corporation.player_share_holders.values.max

        majority_share_holders = corporation
          .player_share_holders
          .select { |_, p| p == max_shares }
          .keys

        return if majority_share_holders.any? { |player| player == previous_president }

        president = majority_share_holders
          .select { |p| p.percent_of(corporation) >= corporation.presidents_percent }
          .min_by { |p| previous_president == self ? 0 : distance(previous_president, p) }
        return unless president

        corporation.owner = president
        @log << "#{president.name} becomes the president of #{corporation.name}"

        # skip the president's share swap if the iniator is already the president
        # or there was no previous president. this is because there is no one to swap with
        return if owner == president || !previous_president

        presidents_share = bundle.presidents_share || previous_president.shares_of(corporation).find(&:president)

        # Bail out if there is no president's share in the prior president's bundle.
        # This happens during 1856 nationalization sometimes
        return unless presidents_share

        # take two shares away from the current president and give it to the
        # previous president if they haven't sold the president's share
        # give the president the president's share
        # if the owner only sold half of their president's share, take one away
        swap_to = previous_president.percent_of(corporation) >= presidents_share.percent ? previous_president : self

        change_president(presidents_share, swap_to, president)

        return unless bundle.partial?

        difference = bundle.shares.sum(&:percent) - bundle.percent
        num_shares = difference / corporation.share_percent
        num_shares.times { move_share(shares_of(corporation).first, owner) }
      end
    end
  end
end
