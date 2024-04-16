# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G18RoyalGorge
      class SharePool < Engine::SharePool
        def buy_shares(entity, shares, exchange: nil, exchange_price: nil, swap: nil,
                       allow_president_change: true, silent: nil, borrow_from: nil,
                       discounter: nil)
          bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
          if allow_president_sale?(bundle.corporation) &&
             !@no_rebundle_president_buy &&
             bundle.presidents_share &&
             bundle.owner == self
            bundle = ShareBundle.new(bundle.shares, bundle.corporation.share_percent)
          end

          raise GameError, 'Cannot buy share from player' if bundle.owner.player? && !@game.can_gain_from_player?(entity, bundle)

          corporation = bundle.corporation
          ipoed = corporation.ipoed
          floated = corporation.floated?

          corporation.ipoed = true if bundle.presidents_share
          price = bundle.price
          par_price = corporation.par_price&.price

          if ipoed != corporation.ipoed && !silent
            @log << "#{entity.name} #{@game.ipo_verb(corporation)} #{corporation.name} at "\
                    "#{@game.format_currency(par_price)}"
          end

          share_str = "a #{bundle.percent}% share "
          share_str += "of #{corporation.name}" unless entity == corporation

          from = if bundle.owner == corporation.ipo_owner
                   "the #{@game.ipo_name(corporation)}"
                 elsif bundle.owner.corporation? && bundle.owner == corporation
                   'the Treasury'
                 elsif bundle.owner.corporation? || bundle.owner.player?
                   bundle.owner.name
                 else
                   'the market'
                 end

          if exchange
            price = exchange_price || 0
            case exchange
            when :free
              @log << "#{entity.name} receives #{share_str}" unless silent
            when Company
              unless silent
                @log << if exchange_price
                          "#{entity.name} exchanges #{exchange.name} and #{@game.format_currency(price)}"\
                            " from #{from} for #{share_str}"
                        else
                          "#{entity.name} exchanges #{exchange.name} from #{from} for #{share_str}"
                        end
              end
            end
          else
            price -= swap.price if swap
            swap_text = swap ? " + swap of a #{swap.percent}% share" : ''
            borrowed = borrow_from ? (price - entity.cash) : 0
            borrowed_text = borrowed.positive? ? " by borrowing #{@game.format_currency(borrowed)} from #{borrow_from.name}" : ''
            verb = entity == corporation ? 'redeems' : 'buys'
            unless silent
              discounter_str = discounter ? "(#{discounter.name}) " : ''
              @log << "#{entity.name} #{discounter_str}#{verb} #{share_str} "\
                      "from #{from} "\
                      "for #{@game.format_currency(price)}#{swap_text}#{borrowed_text}"
            end
          end

          if price.zero?
            transfer_shares(bundle, entity, allow_president_change: allow_president_change)
          else
            receiver = if (%i[escrow incremental].include?(corporation.capitalization) && bundle.owner.corporation?) ||
                          (bundle.owner.corporation? && !corporation.ipo_is_treasury?) ||
                          (bundle.owner.corporation? && bundle.owner != corporation) ||
                          bundle.owner.player?
                         bundle.owner
                       else
                         @bank
                       end
            transfer_shares(
              bundle,
              entity,
              spender: entity == self ? @bank : entity,
              receiver: receiver,
              price: price,
              swap: swap,
              swap_to_entity: swap ? self : nil,
              borrow_from: borrow_from,
              allow_president_change: allow_president_change
            )
          end

          @game.float_corporation(corporation) if corporation.floatable && floated != corporation.floated?
        end

        def transfer_shares(bundle, to_entity,
                            spender: nil,
                            receiver: nil,
                            price: nil,
                            allow_president_change: true,
                            swap: nil,
                            borrow_from: nil,
                            swap_to_entity: nil,
                            corporate_transfer: nil)
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

          if corporation.capitalization == :escrow && receiver == corporation
            # If another game comes around that needs to work w/ escrow capitalization
            # feel free to put this into the game logic
            if corporation.percent_of(corporation) > 50 && spender && price.positive?
              spender.spend(price, receiver) if spender && receiver
            else
              # In the bottom half of the IPO the funds "are held by the bank in escrow"
              # Record in the corporation that money is in escrow, but move *nothing*
              spender.spend(price, @bank)
              corporation.escrow += price
            end
          elsif spender && receiver && price.positive?
            spender.spend(price, receiver, borrow_from: borrow_from)
          end

          bundle.shares.each { |s| move_share(s, to_entity) }

          return unless allow_president_change

          # check if we need to change presidency
          max_shares = presidency_check_shares(corporation).values.max || 0

          # handle selling president's share to the pool
          # if partial, move shares from pool to old president
          if allow_president_sale?(corporation) && max_shares < corporation.presidents_percent && bundle.presidents_share &&
             to_entity == self
            corporation.owner = self
            @log << "President's share sold to pool. #{corporation.name} enters receivership"
            return unless bundle.partial?

            handle_partial(bundle, self, owner)
            return
          end

          # handle buying president's share from the pool
          # swap existing share for it
          if allow_president_sale?(corporation) && owner == self && bundle.presidents_share
            corporation.owner = to_entity
            @log << "#{to_entity.name} becomes the president of #{corporation.name}"
            @log << "#{corporation.name} exits receivership"
            handle_partial(bundle, to_entity, self)
            return
          end

          # skip the rest if no player can be president yet
          return if allow_president_sale?(corporation) && max_shares < corporation.presidents_percent

          majority_share_holders = presidency_check_shares(corporation).select { |_, p| p == max_shares }.keys

          return if majority_share_holders.any? { |player| player == previous_president }

          president = majority_share_holders
                        .select { |p| p.percent_of(corporation) >= corporation.presidents_percent }
                        .min_by do |p|
            if previous_president == self
              0
            else
              (if @game.respond_to?(:player_distance_for_president)
                 @game.player_distance_for_president(previous_president, p)
               else
                 distance(previous_president, p)
               end)
            end
          end
          return unless president

          corporation.owner = president
          @log << "#{president.name} becomes the president of #{corporation.name}"

          # skip the president's share swap if the new share owner is becoming president and
          # the old owner is the outgoing president and the full president's cert was just transfered
          return if to_entity == president && previous_president == owner && bundle.presidents_share && !bundle.partial?

          # skip the president's share swap if the initiator is already the president
          # or there was no previous president. this is because there is no one to swap with
          if owner == corporation &&
             !bundle.presidents_share &&
             @game.can_swap_for_presidents_share_directly_from_corporation?
            previous_president ||= corporation
          end
          return if owner == president || !previous_president

          presidents_share = bundle.presidents_share || previous_president.shares_of(corporation).find(&:president)

          # Bail out if there is no president's share in the prior president's bundle.
          # This happens during 1856 nationalization sometimes
          return unless presidents_share

          # take two shares away from the current president and give it to the
          # previous president if they haven't sold the president's share
          # give the president the president's share
          # if the owner only sold half of their president's share, take one away
          if ((owner.player? && to_entity.player?) || corporate_transfer) && bundle.presidents_share
            # special case when doing a player-to-player purchase of the president's share
            transfer_to = to_entity
            swap_to = to_entity
          else
            transfer_to = @game.sold_shares_destination(corporation) == :corporation ? corporation : self
            swap_to = previous_president.percent_of(corporation) >= presidents_share.percent ? previous_president : transfer_to
          end

          change_president(presidents_share, swap_to, president, previous_president)

          return unless bundle.partial?

          handle_partial(bundle, transfer_to, owner)
        end

        def allow_president_sale?(corporation)
          case @allow_president_sale
          when true
            true
          when ::Set
            @allow_president_sale.include?(corporation.id)
          else
            false
          end
        end
      end
    end
  end
end
