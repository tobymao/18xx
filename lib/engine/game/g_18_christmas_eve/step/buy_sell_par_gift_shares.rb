require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18ChristmasEve
      module Step
        class BuySellParGiftShares < Engine::Step::BuySellParShares
          def description
            'Sell/Buy/Sell Shares and/or Gift Certs'
          end

          def actions(entity)
            return [] unless entity == current_entity
            actions = super
            actions << 'choose' if can_gift_any?
            actions
          end

          def choice_available?(entity)
            return false unless @game.sellable_turn? && entity.corporation?
            @choices = gift_choices(entity)
            @choices != {}
          end

          def gift_choices(entity)
            return {} unless entity.corporation? &&  entity&.president?(current_entity)

            choices = {}
            # Cert only
            # If we own 20%, then we've only got the pres cert to gift
            if current_entity.percent_of(entity) != 20 then
              choices.merge!(Hash[@game.players
                .map.with_index { |p, i| [p, i]}
                .select { |p, i| p != current_entity }
                .select { |p, i| p.percent_of(entity) == 0 }
                .map { |p, i| ["cert_#{i}_#{entity.id}", "Cert to #{p.name}"]}
              ])
            end

            # We can only give the pres cert if it would mean that player has most/equal most shares
            # (meaning, no player presently has >20%)
            president_possible = @game.players.none? {|p| p.percent_of(entity) > 20}
            if president_possible then
              choices.merge!(Hash[@game.players
                .map.with_index { |p, i| [p, i]}
                .select { |p, i| p != current_entity }
                .select { |p, i| p.percent_of(entity) == 0 }
                .map { |p, i| ["prez_#{i}_#{entity.id}", "Presidency to #{p.name}"]}
                ])
            end

            choices
          end

          def can_gift_any?
            @game.sellable_turn? && @game.corporations.any? { |e| gift_choices(e).any? }
          end

          def choice_name
            "Gift"
          end

          def choices
            @choices
          end

          def gift(presidents_cert, receiving_player, corp)
            type = presidents_cert ? "presidency" : "cert"
            @log << "#{current_entity.id} gifts #{type} of #{corp.id} to #{receiving_player.name}"
            if presidents_cert then
              @game.share_pool.transfer_shares(corp.presidents_share.to_bundle, receiving_player)
            else
              share = current_entity.shares_by_corporation[corp].find {|i| !i.president }
              @game.share_pool.transfer_shares(share.to_bundle, receiving_player)
            end
          end

          def process_choose(action)
            type_of_cert, player_index, corporation_id = action.choice.split('_')
            player = @game.players[player_index.to_i]
            corp = @game.corporations.find { |corp| corp.id == corporation_id }
            gift(type_of_cert == 'prez', player, corp)
            @round.current_actions << action
          end
        end
      end
    end
  end
end
