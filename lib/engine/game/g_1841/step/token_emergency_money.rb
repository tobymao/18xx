# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/emergency_money'
require_relative 'emergency_assist'

module Engine
  module Game
    module G1841
      module Step
        class TokenEmergencyMoney < Engine::Step::Base
          include Engine::Step::EmergencyMoney
          include EmergencyAssist

          def actions(entity)
            return [] if entity != active_entity && entity != active_entity&.player
            return ['sell_shares'] if can_sell_shares?(entity)

            []
          end

          def round_state
            {
              token_emr_entity: nil,
              token_emr_amount: 0,
            }
          end

          def setup
            super
            @round.token_emr_entity = nil
            @round.token_emr_amount = 0
          end

          def description
            'Token Emergency Money Raising'
          end

          def cash_crisis?
            true
          end

          def active?
            active_entity
          end

          def active_entity
            @round.token_emr_entity
          end

          def active_entities
            [@round.token_emr_entity]
          end

          def needed_cash(_entity)
            @round.token_emr_amount
          end

          def can_sell?(_entity, bundle)
            @game.emr_can_sell?(active_entity, bundle)
          end

          def issuable_shares(entity)
            return [] unless entity.corporation?

            @game.emergency_issuable_bundles(entity, needed_cash(entity))
          end

          def can_sell_shares?(entity)
            return issuable_shares(entity).any? if entity.corporation?

            entity.cash < needed_cash(entity)
          end

          def show_cash?(_entity)
            true
          end

          def available_cash(corp)
            @game.emergency_cash_before_issuing(corp, needed_cash(corp))
          end

          def available_cash_str(corp)
            str = @game.format_currency(corp.cash)
            avail = available_cash(corp)
            str += " (#{@game.format_currency(avail)} EMR cash is available)" if avail > corp.cash
            str
          end

          def issuing_corporation(corp)
            issuable_shares(corp).first&.owner || corp
          end

          def president_may_contribute?(corp)
            @game.emergency_cash_before_issuing(corp, needed_cash(corp)) < needed_cash(corp)
          end

          def issue_verb(_entity)
            'sell'
          end

          def issue_text(entity)
            bundles = issuable_shares(entity)
            owner = bundles&.first&.owner

            str = "#{owner.name} EMR Sell Shares"
            str += " (for #{entity.name})" if owner != entity
            str
          end

          def issuable_cash(entity)
            @game.emergency_issuable_cash(entity)
          end

          def owner_funds(entity)
            [needed_cash(entity) - @game.emergency_issuable_funds(entity), 0].max
          end

          def process_sell_shares(action)
            seller = action.bundle.owner
            corp = action.bundle.corporation
            raise GameError, "Cannot sell shares of #{corp.name}" unless can_sell?(action.entity, action.bundle)

            if @game.emergency_cash_before_selling(active_entity, needed_cash(active_entity)) >= needed_cash(active_entity)
              raise GameError, 'Did not need to sell shares'
            end

            @game.sell_shares_and_change_price(action.bundle, allow_president_change: @game.pres_change_ok?(corp))
            @game.update_frozen!
            sweep_cash(active_entity, seller, needed_cash(active_entity))

            if @game.emergency_cash_before_selling(active_entity, needed_cash(active_entity)) >= needed_cash(active_entity)
              @round.token_emr_entity = nil
              @round.token_emr_amount = 0
              @round.clear_cache!
            end

            @round.recalculate_order if @round.respond_to?(:recalculate_order)
          end
        end
      end
    end
  end
end
