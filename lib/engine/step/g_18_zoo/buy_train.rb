# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G18ZOO
      class BuyTrain < Engine::Step::BuyTrain
        def setup
          super

          # @log << "setup called for #{entities} in #{@round}"
          @any_train_brought = false
        end

        def actions(entity)
          # 1846 and a few others minors can't buy trains
          return [] if entity.minor?

          # TODO: This needs to check it actually needs to sell shares.
          return ['sell_shares'] if entity == current_entity&.owner

          return [] if entity != current_entity
          # TODO: Not sure this is right
          return %w[sell_shares buy_train] if president_may_contribute?(entity)
          return %w[buy_train buy_company choose sell_shares pass] if can_buy_train?(entity)

          []
        end

        def choices
          ['Close SMS', 'Pass']
        end

        def choice_name
          'Close SMS to optionally lay/upgrade and/or token on any coastal city'
        end

        def process_choose(action)
          corp = action.entity

          if action.choice == 'Close SMS'
            @log << "#{corp.id} closes SMS"
            @sms.close!
            corp.sms_hexes = @game.sms_hexes
          end
          @passed = true
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] unless entity.num_ipo_shares

          []
          # bundles_for_corporation(entity, entity)
          # .select { |bundle| bundle.shares.size == 1 && @share_pool.fit_in_bank?(bundle) }
        end

        def buy_train_action(action, entity = nil)
          entity ||= action.entity
          old_train = action.train.owned_by_corporation?

          super

          if !@any_train_brought && !old_train
            prev = entity.share_price.price
            @game.stock_market.move_right(entity)
            @game.log_share_price(entity, prev, '(new-train bonus)')
            @any_train_brought = true
          end

          return unless @game.new_train_brought

          prev = entity.share_price.price
          @game.stock_market.move_right(entity)
          @game.log_share_price(entity, prev, '(new-phase bonus)')
          @game.new_train_brought = false
        end
      end
    end
  end
end
