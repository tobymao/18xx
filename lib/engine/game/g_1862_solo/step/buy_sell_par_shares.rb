# frozen_string_literal: true

require_relative '../../g_1862/step/buy_sell_par_shares'

module Engine
  module Game
    module G1862Solo
      module Step
        class BuySellParShares < G1862::Step::BuySellParShares
          ACTIONS = %w[buy_company choose pass].freeze

          def actions(entity)
            return [] unless entity == current_entity

            actions = ACTIONS.dup
            actions << 'sell_shares' if can_sell_any?(entity)
            actions
          end

          def round_state
            super.merge(
              {
                bought_shares: [],
                companies_pending_par: [],
                chartered_par: false,
              }
            )
          end

          def can_buy_company?(player, company)
            return false if company.value.zero?

            @game.ipo_rows.flatten.include?(company) && available_cash(player) >= company.value
          end

          # Cannot sell shares you have bought this SR
          def can_sell?(_entity, bundle)
            bundle.shares.none? { |s| @round.bought_shares.include?(s) }
          end

          def choice_available?(_entity)
            true
          end

          def choices
            []
          end

          def choice_name
            nil
          end

          def companies_pending_par
            @round.companies_pending_par
          end

          def get_par_prices(entity, _corp)
            @game.repar_prices.select { |p| p.price * 3 <= entity.cash }
          end

          def general_input_renderings_ipo_row(_entity, company, index)
            renderings = []
            return renderings if @game.ipo_rows[index].empty?

            share = company.treasury

            @game.all_rows_indexes.each do |i|
              next if i == index || @game.ipo_rows[i].empty?
              next unless company.treasury.corporation == @game.ipo_rows[i].first.treasury.corporation

              renderings << ["move##{company.id}##{i}", "Move to IPO Row #{i + 1}"]
            end

            renderings << ["remove##{company.id}", "Remove #{company.name} from IPO Row #{index + 1}"]

            if share.corporation.share_price
              renderings << ["buy##{company.id}", "Buy #{company.name} for #{@game.company_value(company)}"]
            elsif @game.can_par_corporations?
              renderings << ["par_unchartered##{company.id}", 'Par unchartered']
              renderings << ["par_chartered##{company.id}", 'Par chartered']
            end

            renderings
          end

          # Need to have false here as we are solo player
          def bought?
            false
          end

          def process_choose(action)
            choice = action.choice
            if choice.start_with?('buy')
              action_buy(choice)
            elsif choice.start_with?('deal')
              action_deal(choice)
            elsif choice.start_with?('move')
              action_move(choice)
            elsif choice.start_with?('par_chartered')
              action_par_chartered(choice)
            elsif choice.start_with?('par_unchartered')
              action_par_unchartered(choice)
            elsif choice.start_with?('remove')
              action_remove(choice)
            else
              raise GameError, "Unknown choice #{choice}"
            end

            track_action(action, @game.players.first)
          end

          def process_pass(action)
            @game.log << "#{action.entity.name} passes"
            action.entity.pass!
          end

          private

          def action_buy(choice)
            company = get_company_from_choice(choice)
            price = @game.company_value(company)
            share = company.treasury
            corporation = share.corporation
            owner = @game.bank
            player = @game.players.first

            @game.ipo_rows[@game.ipo_row_index[company]].delete(company)
            buy_shares(player, ShareBundle.new([share]), allow_president_change: false)

            player.spend(price, owner)

            if !corporation.floated? && player.shares_by_corporation[corporation].size >= 3
              @game.chartered[corporation] ? float_chartered_corporation(corporation) : float_unchartered_corporation(corporation)
            end

            cleanup_company(company)
          end

          def action_deal(choice)
            @game.remove_corporation(@game.random_corporation, 'due to deal action')
            index = choice.split('#').last.to_i
            @game.deal_to_ipo_row(index)
            card_text = @game.cards_to_deal == 1 ? 'card is' : 'cards are'
            @log << "#{@game.cards_to_deal} #{card_text} added to IPO Row #{index + 1}"
          end

          def action_move(choice)
            parts = choice.split('#')
            raise GameError, "Incorrect choice format #{choice}" unless parts.size == 3

            id = parts[1]
            index = parts[2].to_i
            company = get_company(id)
            @game.ipo_rows[@game.ipo_row_index[company]].delete(company)
            @game.ipo_rows[index].prepend(company)
            @game.ipo_row_index[company] = index
            @log << "#{company.name} moves to top of IPO Row #{index + 1}"
          end

          def action_par_chartered(choice)
            company = get_company_from_choice(choice)
            @round.companies_pending_par << company
            @round.chartered_par = true
            cleanup_company(company)
          end

          def action_par_unchartered(choice)
            company = get_company_from_choice(choice)
            @round.companies_pending_par << company
            @round.chartered_par = false
            cleanup_company(company)
          end

          def action_remove(choice)
            company = get_company_from_choice(choice)
            @log << "#{company.name} drops from IPO Row #{@game.ipo_row_index[company] + 1}"
            cleanup_company(company)
            share = company.treasury
            corporation = share.corporation
            @game.remove_corporation(corporation, 'as share dropped')
          end

          def get_company_from_choice(choice)
            id = choice.split('#').last
            get_company(id)
          end

          def get_company(id)
            company = @game.company_by_id(id)
            raise GameError, "Company with ID #{id} not found in IPO rows" unless company

            company
          end

          def cleanup_company(company)
            @round.bought_shares << company.treasury
            @game.ipo_rows[@game.ipo_row_index[company]].delete(company)
            company.close!
          end

          def float_chartered_corporation(corporation)
            float_corporation(corporation, 'Chartered', 10)

            total_token_cost = @game.class::CHARTERED_TOKEN_COST * 3
            @log << "#{corporation.name} buys 3 tokens and pays #{total_token_cost}"
            corporation.spend(total_token_cost, @game.bank)
          end

          def float_unchartered_corporation(corporation)
            float_corporation(corporation, 'Non-chartered', 5)

            @round.buy_tokens = corporation
            @log << "#{corporation.name} must buy tokens"
            @round.clear_cache!
          end

          def float_corporation(corporation, type, shares)
            corporation.floated = true

            cash = corporation.par_price.price * shares
            @log << "#{type} #{corporation.name} floats and receives #{cash}"
            @game.bank.spend(cash, corporation)

            @game.assign_first_permit(corporation)
          end
        end
      end
    end
  end
end
