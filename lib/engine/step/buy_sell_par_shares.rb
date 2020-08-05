# frozen_string_literal: true

require_relative 'base'
require_relative 'share_buying'
require_relative '../action/buy_shares'
require_relative '../action/par'

module Engine
  module Step
    class BuySellParShares < Base
      include ShareBuying

      PURCHASE_ACTIONS = [Action::BuyShares, Action::Par].freeze

      def actions(entity)
        return [] unless entity == current_entity
        return ['sell_shares'] if must_sell?(entity)

        actions = []
        actions << 'buy_shares' if can_buy_any?(entity)
        actions << 'par' if can_ipo_any?(entity)
        actions << 'sell_shares' if can_sell_any?(entity)

        actions << 'pass' if actions.any?
        actions
      end

      def log_pass(entity)
        return @log << "#{entity.name} passes" if @current_actions.empty?

        action = if bought?
                   'selling'
                 else
                   'buying'
                 end
        @log << "#{entity.name} passes #{action} shares"
      end

      def log_skip(entity)
        @log << "#{entity.name} has no valid actions and passes"
      end

      def description
        case @game.class::SELL_BUY_ORDER
        when :sell_buy_or_buy_sell
          'Buy or Sell Shares'
        when :sell_buy
          'Sell then Buy Shares'
        when :sell_buy_sell
          'Sell/Buy/Sell Shares'
        end
      end

      def pass_description
        if @current_actions.empty?
          'Pass (Share)'
        else
          'Done (Share)'
        end
      end

      def setup
        # player => corporation => :now or :prev
        # this differentiates between preventing users from buying shares they sold
        # and preventing users from selling the same shares separately in the some action
        @players_sold ||= Hash.new { |h, k| h[k] = {} }
        @players_sold.each do |_player, corps|
          corps.each { |corp, _k| corps[corp] = :prev }
        end

        @current_actions = []
      end

      # Returns if a share can be bought via a normal buy actions
      # If a player has sold shares they cannot buy in many 18xx games
      # Some 18xx games can only buy one share per turn.
      def can_buy?(entity, bundle)
        return unless bundle

        corporation = bundle.corporation
        entity.cash >= bundle.price && can_gain?(entity, bundle) &&
          !@players_sold[entity][corporation] &&
          (can_buy_multiple?(corporation) || !bought?)
      end

      def must_sell?(entity)
        entity.num_certs > @game.cert_limit ||
          !@game.corporations.all? { |corp| corp.holding_ok?(entity) }
      end

      def can_sell?(entity, bundle)
        return unless bundle

        corporation = bundle.corporation

        timing =
          case @game.class::SELL_AFTER
          when :first
            @game.turn > 1
          when :operate
            corporation.operated?
          when :p_any_operate
            corporation.operated? || corporation.president?(entity)
          else
            raise NotImplementedError
          end

        timing &&
          !(@game.class::MUST_SELL_IN_BLOCKS && @players_sold[entity][corporation] == :now) &&
          can_sell_order? &&
          @game.share_pool.fit_in_bank?(bundle) &&
          bundle.can_dump?(entity)
      end

      def can_sell_order?
        case @game.class::SELL_BUY_ORDER
        when :sell_buy_or_buy_sell
          !(@current_actions.uniq(&:class).size == 2 &&
            self.class::PURCHASE_ACTIONS.include?(@current_actions.last.class))
        when :sell_buy
          !bought?
        when :sell_buy_sell
          true
        end
      end

      def did_sell?(corporation, entity)
        @players_sold[entity][corporation]
      end

      def process_buy_shares(action)
        buy_shares(action.entity, action.bundle)
        @current_actions << action
      end

      def process_sell_shares(action)
        sell_shares(action.entity, action.bundle)
        @current_actions << action
      end

      def process_par(action)
        share_price = action.share_price
        corporation = action.corporation
        @game.game_error("#{corporation} cannot be parred") unless corporation.can_par?(action.entity)

        @game.stock_market.set_par(corporation, share_price)
        share = corporation.shares.first
        buy_shares(action.entity, share.to_bundle)
        @current_actions << action
      end

      def pass!
        super
        if @current_actions.any?
          current_entity.unpass!
        else
          current_entity.pass!
        end
      end

      def can_buy_multiple?(corporation)
        corporation.buy_multiple? &&
         @current_actions.none? { |x| x.is_a?(Action::Par) } &&
         @current_actions.none? { |x| x.is_a?(Action::BuyShares) && x.bundle.corporation != corporation }
      end

      def can_sell_any?(entity)
        @game.corporations.any? do |corporation|
          bundles = entity.bundles_for_corporation(corporation)
          bundles.any? { |bundle| can_sell?(entity, bundle) }
        end
      end

      def can_buy_any_from_market?(entity)
        @game.share_pool.shares.any? { |s| can_buy?(entity, s.to_bundle) }
      end

      def can_buy_any_from_ipo?(entity)
        @game.corporations.any? { |c| c.ipoed && can_buy?(entity, c.shares.first&.to_bundle) }
      end

      def can_buy_any?(entity)
        (can_buy_any_from_market?(entity) ||
        can_buy_any_from_ipo?(entity))
      end

      def can_ipo_any?(entity)
        !bought? && @game.corporations.any? { |c| c.can_par?(entity) && can_buy?(entity, c.shares.first&.to_bundle) }
      end

      def sell_shares(entity, shares)
        @game.game_error("Cannot sell shares of #{shares.corporation.name}") unless can_sell?(entity, shares)

        @players_sold[shares.owner][shares.corporation] = :now
        @game.sell_shares_and_change_price(shares)
      end

      def bought?
        @current_actions.any? { |x| PURCHASE_ACTIONS.include?(x.class) }
      end
    end
  end
end
