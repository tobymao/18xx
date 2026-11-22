# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      module FirstRoundInsolvency
        def setup_first_round_insolvency
          @insolvency_debts = {}
        end

        def reserved_train_name
          self.class::RESERVED_TRAIN
        end

        def reserved_train
          @depot.depot_trains.find { |train| train.name == reserved_train_name }
        end

        def reserved_train_price
          reserved_train&.price
        end

        def reserved_train_due?(entity)
          %i[minor regional].include?(entity.type) &&
            entity.floated? &&
            train_obligation_active? &&
            !fulfilled_train_obligation?(entity)
        end

        def first_round_insolvency?(entity)
          return false unless reserved_train_due?(entity)

          price = reserved_train_price
          !price.nil? && entity.cash + entity.owner.cash < price
        end

        def first_round_insolvency_choice
          self.class::FIRST_ROUND_INSOLVENCY_CHOICE
        end

        def insolvent?(corporation)
          @insolvency_debts.key?(corporation)
        end

        def insolvency_debt(corporation)
          @insolvency_debts[corporation]
        end

        def insolvency_face_value(corporation)
          return corporation.presidents_share.price if corporation.type == :regional

          company_by_id(corporation.id).value
        end

        def insolvent_purchase_price(corporation)
          insolvency_face_value(corporation) + insolvency_debt(corporation)
        end

        def restore_insolvent!(corporation)
          debt = @insolvency_debts.delete(corporation)
          @log << "#{corporation.owner.name} takes over #{corporation.name}, paying " \
                  "#{format_currency(insolvency_face_value(corporation) + debt)} " \
                  "including #{format_currency(debt)} of debt (§11.6.5)"
        end

        def close_unowned_insolvents!
          @insolvency_debts.keys.each do |corporation|
            next if corporation.owner

            @insolvency_debts.delete(corporation)
            @log << "#{corporation.name} was not bought back by the end of Consolidation (§11.6.5)"
            if corporation.type == :minor
              abandon_minor!(corporation)
            else
              @minor_regional_order.delete(corporation)
              remove_corporation_tokens!(corporation)
              close_corporation(corporation)
            end
          end
        end

        def insolvency_status_line(corporation)
          ["Insolvent: #{format_currency(insolvent_purchase_price(corporation))} due"] if insolvent?(corporation)
        end

        def insolvency_certificate_name(corporation)
          corporation.type == :minor ? 'charter' : "president's certificate"
        end

        def declare_first_round_insolvency!(entity)
          raise GameError, "#{entity.name} cannot declare first-round insolvency" unless first_round_insolvency?(entity)

          president = entity.owner
          face_value = insolvency_face_value(entity)
          moved = president.cash
          if moved.positive?
            @log << "#{president.name} moves #{format_currency(moved)} into #{entity.name}'s treasury"
            president.spend(moved, entity)
          end

          train = reserved_train
          paid = entity.cash
          unpaid = train.price - paid
          buy_train(entity, train, paid.positive? ? paid : :free)
          fulfill_train_obligation!(entity)
          @insolvency_debts[entity] = unpaid
          @log << "#{entity.name} receives a #{train.name} for #{format_currency(train.price)} " \
                  "with #{format_currency(unpaid)} unpaid"

          @share_pool.transfer_shares(entity.presidents_share.to_bundle, @share_pool, allow_president_change: false)
          entity.owner = nil
          @log << "#{entity.name}'s #{insolvency_certificate_name(entity)} goes to the Open Market"
          @bank.spend(face_value, president)
          @log << "#{president.name} receives #{format_currency(face_value)} for the #{insolvency_certificate_name(entity)}"
          @log << "#{entity.name} is dormant until a player buys it (§11.6.5)"
        end

        def check_reserved_train_funds!(entity, cost)
          return if !cost.positive? || !reserved_train_due?(entity)

          remaining = entity.cash - cost
          president_cash = entity.owner.cash
          price = reserved_train_price
          return if remaining + president_cash >= price

          raise GameError, "#{entity.name} cannot spend #{format_currency(cost)}: it would leave " \
                           "#{format_currency(remaining)} plus its president's #{format_currency(president_cash)}, " \
                           "below the #{format_currency(price)} for its reserved #{reserved_train_name} (§11.6.5)"
        end
      end
    end
  end
end
