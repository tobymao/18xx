# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18ChristmasEve
      module Step
        class BuySellParGiftShares < Engine::Step::BuySellParShares
          def description
            'Sell/Buy/Sell Shares and/or Gift Certs'
          end

          def round_state
            super.merge!(
              {
                presidencies_gifted: [],
              }
            )
          end

          def actions(entity)
            return [] unless entity == current_entity

            actions = super
            actions << 'choose' if can_gift_any?
            actions << 'pass' if !actions.empty? && !actions.include?('pass')
            actions
          end

          def choice_available?(entity)
            return false if !@game.sellable_turn? || !entity.corporation?

            entity_choices(entity) != {}
          end

          def entity_choices(entity)
            return {} if !entity&.corporation? || !entity&.president?(current_entity)

            choices = {}

            # Cert only
            # If we own 20%, then we've only got the pres cert to gift
            if current_entity.percent_of(entity) != 20
              cert_choices = @game.players
                .map.with_index { |p, i| [p, i] }
                .reject { |p, _i| p == current_entity }
                .select { |p, _i| p.percent_of(entity).zero? }
                .to_h { |p, i| ["cert_#{i}_#{entity.id}", "Cert to #{p.name}"] }
            end

            # We can only give the pres cert if it would mean that player has most/equal most shares
            president_possible = current_entity.percent_of(entity) <= 40 &&
              @game.players.reject { |p| p == current_entity }.none? { |p| p.percent_of(entity) > 20 }
            if president_possible
              pres_choices = @game.players
                .map.with_index { |p, i| [p, i] }
                # Co prez can't be gifted twice in a round
                .reject { |p, _i| p == current_entity || @round.presidencies_gifted&.include?(entity) }
                .select { |p, _i| p.percent_of(entity).zero? }
                .to_h { |p, i| ["prez_#{i}_#{entity.id}", "Presidency to #{p.name}"] }
            end

            choices.merge(cert_choices || {}).merge(pres_choices || {})
          end

          def can_gift_any?
            @game.sellable_turn? && @game.corporations.any? { |e| !entity_choices(e).empty? }
          end

          def choice_name
            'Gift'
          end

          def gift(presidents_cert, receiving_player, corp)
            type = presidents_cert ? 'presidency' : 'cert'
            @log << "#{current_entity.name} gifts #{type} of #{corp.id} to #{receiving_player.name}"
            if presidents_cert
              @game.share_pool.transfer_shares(corp.presidents_share.to_bundle, receiving_player)
              @round.presidencies_gifted.append(corp)
            else
              share = current_entity.shares_by_corporation[corp].find { |i| !i.president }
              @game.share_pool.transfer_shares(share.to_bundle, receiving_player)
            end
          end

          def process_choose(action)
            type_of_cert, player_index, corporation_id = action.choice.split('_')
            player = @game.players[player_index.to_i]
            corp = @game.corporations.find { |c| c.id == corporation_id }
            gift(type_of_cert == 'prez', player, corp)
            @round.current_actions << action
          end
        end
      end
    end
  end
end
