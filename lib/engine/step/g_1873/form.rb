# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1873
      class Form < Base
        attr_reader :auctioning, :last_president, :buyer

        MERGE_ACTION = %w[merge]

        def actions(entity)
          return [] unless entity == owner

          MERGE_ACTION
        end

        def merge_name
          'Merge'
        end

        def description
          'Select Private Mines'
        end

        def blocks
          true
        end

        def skip!
          puts "Form::skip!"
          super
        end

        def round_state
          super.merge(
            {
              pending_forms: [],
            }
          )
        end

        def active?
          !@round.pending_forms.empty?
        end

        def buyer
          @round.pending_forms.first[:corporation]
        end

        def owner
          @round.pending_forms.first[:owner]
        end

        def target_mines
          @round.pending_forms.first[:targets]
        end

        def show_other_players
          false
        end

        # if turn 1: first mine must be mine 12
        # else if HW corp, mines must be open private von-harzer mines
        # else all open private mines
        def mergeable
          if @game.turn == 1 && target_mines.empty?
            [@game.mine_12]
          elsif @game.corporation_info[buyer][:vor_harzer]
            @game.open_private_mines.select { |pm| @game.minor_info[pm][:vor_harzer] } - [target_mines.first]
          else
            @game.open_private_mines - [target_mines.first]
          end
        end

        def process_merge(action)
          mine = action.minor
          @log << "#{buyer.id} acquires #{mine.full_name} "\
            "(face value #{@game.format_currency(@game.minor_info[mine][:value])})"

          if target_mines.empty?
            target_mines << mine
          else
            target_mines << mine
            finalize_formation
          end
        end

        def finalize_formation
          # move shares to former owners of mines
          buyer.ipo_shares.each_with_index do |share, idx|
            @game.share_pool.transfer_shares(
               share.to_bundle,
               target_mines[idx].owner,
               spender: target_mines[idx].owner,
               receiver: buyer,
               price: 0
             )
            president_text = idx.zero? ? " and becomes president of #{buyer.id}" : ""
            @log << "#{target_mines[idx].owner.name} receives a share of #{buyer.id}#{president_text}"
          end

          # share price is average of mine values
          average = (target_mines.sum { |m| @game.minor_info[m][:value] } / 2).to_i
          price = @game.stock_market.market.first.select { |p| p.price <= average }.max_by { |p| p.price }
          @game.stock_market.set_par(buyer, price)
          @log << "#{buyer.id} share price is set to #{@game.format_currency(price.price)}"

          target_mines.each { |m| m.owner = buyer }

          @round.pending_forms.pop
        end
      end
    end
  end
end
