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

          def general_input_renderings_ipo_row(_entity, company, ipo_row_number)
            renderings = []

            if @game.ipo_rows[ipo_row_number - 1].empty?
              # No company in this IPO row so 2nd part of action is nil
              renderings << ["deal###{ipo_row_number}", "Deal to #{ipo_row_title(ipo_row_number)}"]
              return renderings
            end

            @game.all_rows_indexes.each do |index|
              next if index + 1 == ipo_row_number || @game.ipo_rows[index].empty?
              next unless company.treasury.corporation == @game.ipo_rows[index].first.treasury.corporation

              choice = create_choice('move', company: company.id, from: ipo_row_number, to: index + 1)
              renderings << [choice, "Move to #{ipo_row_title(index + 1)}"]
            end

            choice = create_choice('remove', company: company.id, from: ipo_row_number)
            renderings << [choice, "Remove #{company.name}"]

            share = company.treasury
            if share.corporation.share_price
              choice = create_choice('buy', company: company.id, from: ipo_row_number)
              renderings << [choice, "Buy #{company.name} for #{@game.company_value(company)}"]
            elsif @game.can_par_corporations?
              choice = create_choice('par_unchartered', company: company.id, from: ipo_row_number)
              renderings << [choice, 'Par unchartered']
              choice = create_choice('par_chartered', company: company.id, from: ipo_row_number)
              renderings << [choice, 'Par chartered']
            end

            @game.all_rows_indexes.each do |index|
              next unless @game.ipo_rows[index].empty?

              ipo_row_number = index + 1
              choice = create_choice('deal', from: ipo_row_number)
              renderings << [choice, "Deal to #{ipo_row_title(ipo_row_number)}"]
            end

            renderings
          end

          # Need to have false here as we are solo player
          def bought?
            false
          end

          def process_choose(action)
            choice = action.choice
            if choice[:action] == 'deal'
              action_deal(choice[:from])
            else
              company = get_company(choice[:company])
              case choice[:action]
              when 'buy' then action_buy(company, choice[:from])
              when 'move' then action_move(company, choice[:from], choice[:to])
              when 'par_chartered' then action_par_chartered(company, choice[:from])
              when 'par_unchartered' then action_par_unchartered(company, choice[:from])
              when 'remove' then action_remove(company, choice[:from])
              else
                raise GameError, "Unknown choice #{choice}"
              end
            end

            track_action(action, @game.players.first)
          end

          def process_pass(action)
            @game.log << "#{action.entity.name} passes"
            action.entity.pass!
          end

          private

          def action_buy(company, from_ipo_row_number)
            index = get_ip_row_index(from_ipo_row_number)
            price = @game.company_value(company)
            share = company.treasury
            corporation = share.corporation
            owner = @game.bank
            player = @game.players.first

            @game.ipo_rows[index].delete(company)
            buy_shares(player, ShareBundle.new([share]), allow_president_change: false)

            player.spend(price, owner)

            if !corporation.floated? && player.shares_by_corporation[corporation].size >= 3
              @game.chartered[corporation] ? float_chartered_corporation(corporation) : float_unchartered_corporation(corporation)
            end

            cleanup_company(company, index)
          end

          def action_deal(ipo_row_number)
            index = get_ip_row_index(ipo_row_number)
            # This should remove corporation from all IPO rows
            @game.remove_corporation(@game.random_corporation, 'due to deal action')
            @game.deal_to_ipo_row(index)
            cards_to_deal = @game.ipo_rows[index].length
            card_text = cards_to_deal == 1 ? 'card is' : 'cards are'
            @log << "#{cards_to_deal} #{card_text} added to #{ipo_row_title(ipo_row_number)}"
          end

          def action_move(company, from_ipo_row_number, to_ipo_row_number)
            index_from = get_ip_row_index(from_ipo_row_number)
            index_to = get_ip_row_index(to_ipo_row_number)
            @game.ipo_rows[index_from].delete(company)
            @game.ipo_rows[index_to].prepend(company)
            from_title = ipo_row_title(from_ipo_row_number)
            to_title = ipo_row_title(to_ipo_row_number)
            @log << "#{company.name} moves from top of #{from_title} to top of #{to_title}"
          end

          def action_par_chartered(company, from_ipo_row_number)
            @round.companies_pending_par << company
            @round.chartered_par = true
            cleanup_company(company, get_ip_row_index(from_ipo_row_number))
            @log << "Par #{company.name} chartered with top share of #{ipo_row_title(from_ipo_row_number)}"
          end

          def action_par_unchartered(company, from_ipo_row_number)
            @round.companies_pending_par << company
            @round.chartered_par = false
            cleanup_company(company, get_ip_row_index(from_ipo_row_number))
            @log << "Par #{company.name} unchartered with top share of #{ipo_row_title(from_ipo_row_number)}"
          end

          def action_remove(company, from_ipo_row_number)
            @log << "Player selects #{company.name} for removal"
            cleanup_company(company, get_ip_row_index(from_ipo_row_number))
            share = company.treasury
            corporation = share.corporation
            @game.remove_corporation(corporation, 'as share dropped')
          end

          def get_company(id)
            company = @game.company_by_id(id)
            raise GameError, "Company with ID #{id} not found in IPO rows" unless company

            company
          end

          def get_ip_row_index(ipo_row_number)
            raise GameError, "Invalid #{ipo_row_title(ipo_row_number)}" unless ipo_row_number.to_i.positive?

            ipo_row_number.to_i - 1
          end

          def cleanup_company(company, index_from)
            @round.bought_shares << company.treasury
            @game.ipo_rows[index_from].delete(company)
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

          def ipo_row_title(ipo_row_number)
            "IPO Row #{ipo_row_number}"
          end

          def create_choice(action, company: nil, from: nil, to: nil)
            { action: action, company: company, from: from, to: to }
          end
        end
      end
    end
  end
end
