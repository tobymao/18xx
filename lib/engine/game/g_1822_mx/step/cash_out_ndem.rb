# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1822MX
      module Step
        class CashOutNdem < Engine::Step::Base
          def actions(_entity)
            return ['pass'] if players_hold_shares?

            []
          end

          def auto_actions(entity)
            return [Engine::Action::Pass.new(entity)] if players_hold_shares?

            super
          end

          def process_pass(_action)
            ndem = @game.corporation_by_id('NDEM')
            @game.players.each do |p|
              next unless ndem.player_share_holders.include?(p) && ndem.player_share_holders[p].positive?

              shares = p.shares_of(ndem)
              @game.share_pool.sell_shares(ShareBundle.new(shares), allow_president_change: false) unless shares.empty?
            end
          end

          def ndem_closing?
            @game.ndem_state == :closing && current_entity.id == 'NDEM'
          end

          def players_hold_shares?
            ndem = @game.corporation_by_id('NDEM')
            @game.players.each do |p|
              return true if ndem.player_share_holders.include?(p) && ndem.player_share_holders[p].positive?
            end
            false
          end

          def active?
            ndem_closing? && players_hold_shares?
          end

          def blocking?
            ndem_closing? && players_hold_shares?
          end

          def description
            'Cashing out NdeM'
          end
        end
      end
    end
  end
end
