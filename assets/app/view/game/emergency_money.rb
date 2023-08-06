# frozen_string_literal: true

require 'view/game/corporation'
require 'view/game/sell_shares'

module View
  module Game
    module EmergencyMoney
      def render_emergency_money_raising(player)
        children = []
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }
        player.shares_by_corporation.each do |corporation, shares|
          next if shares.empty? || @game.sellable_bundles(player, corporation).empty?

          corp = [h(Corporation, corporation: corporation)]
          corp << h(SellShares, player: player, corporation: corporation)

          children << h(:div, props, corp.compact)
        end

        if @game.round.actions_for(entity).include?('sell_company')
          player.companies.each do |company|
            comp = [h(Company, company: company)]
            comp << render_sell_company(player, company)
            children << h(:div, props, comp.compact)
          end
        end

        if @game.round.actions_for(entity).include?('bankrupt') &&
           @game.can_go_bankrupt?(player, @corporation)
          b_options = @game.bankruptcy_options(player)
          if b_options.empty?
            children << render_bankruptcy
          else
            b_options.each { |o| children << render_bankruptcy_option(o) }
          end
        end
        children
      end

      def render_sell_company(player, company)
        price = @game.company_sale_price(company)
        buy = lambda do
          process_action(Engine::Action::SellCompany.new(
            player,
            company: company,
            price: price
          ))
        end

        h(:button, { on: { click: buy } }, "Sell #{company.sym} to Bank for #{@game.format_currency(price)}")
      end

      def render_bankruptcy
        resign = lambda do
          process_action(Engine::Action::Bankrupt.new(entity))
        end

        props = {
          style: {
            width: 'max-content',
          },
          on: { click: resign },
        }

        h(:button, props, 'Declare Bankruptcy')
      end

      def render_bankruptcy_option(option)
        resign = lambda do
          process_action(Engine::Action::Bankrupt.new(entity, option: option))
        end

        props = {
          style: {
            width: 'max-content',
          },
          on: { click: resign },
        }

        h(:button, props, @game.bankruptcy_button_text(option))
      end

      private

      def entity
        @game.round.active_step.current_entity
      end
    end
  end
end
