# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1873
      module Step
        class Form < Engine::Step::Base
          MERGE_ACTION = %w[merge].freeze

          def actions(entity)
            return [] if entity != owner && entity != buyer

            MERGE_ACTION
          end

          def merge_name(_entity = nil)
            'Merge'
          end

          def description
            'Select Private Mines'
          end

          def blocks?
            !@round.pending_forms.empty?
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

          def merge_action
            'Merge'
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

          def mergeable_entity
            buyer
          end

          def merge_in_progress?
            buyer
          end

          def ipo_type(_corp)
            ''
          end

          def mergeable_type(corporation)
            "Mines that can be formed into Public Mining Company #{corporation.name}:"
          end

          # first mine must be owned by player doing the formation
          #
          # if turn 1: first mine must be mine 12
          # else if HW corp, mines must be open private von-harzer mines
          # else all open private mines
          def mergeable_entities
            available_mines = if target_mines.empty?
                                @game.mergeable_private_mines(buyer).select { |m| m.owner == owner }
                              else
                                @game.mergeable_private_mines(buyer) - [target_mines.first[:mine]]
                              end

            if @game.turn == 1 && target_mines.empty?
              available_mines.select { |m| m == @game.mine_12 }
            elsif @game.corporation_info[buyer][:vor_harzer]
              available_mines.select { |pm| @game.minor_info[pm][:vor_harzer] }
            else
              available_mines
            end
          end

          def process_merge(action)
            mine = action.minor
            @log << "#{buyer.id} acquires #{mine.full_name} "\
                    "(face value #{@game.format_currency(@game.minor_info[mine][:value])})"

            # new corp gets formerly independent mines and their cash
            # machines and switchers stay with mines
            old_owner = mine.owner
            @game.add_mine(buyer, mine)

            target_mines << { mine: mine, owner: old_owner }
            finalize_formation unless target_mines.one?
          end

          def finalize_formation
            # move shares to former owners of mines
            buyer.ipo_shares.each_with_index do |share, idx|
              @game.share_pool.transfer_shares(
                 share.to_bundle,
                 target_mines[idx][:owner],
                 spender: target_mines[idx][:owner],
                 receiver: buyer,
                 price: 0
               )
              president_text = idx.zero? ? " and becomes president of #{buyer.id}" : ''
              @log << "#{target_mines[idx][:owner].name} receives a share of #{buyer.id}#{president_text}"
            end

            # share price is average of mine values
            average = (target_mines.sum { |m| @game.minor_info[m[:mine]][:value] } / 2).to_i
            price = @game.stock_market.market.first.select { |p| p.price <= average }.max_by(&:price)
            @game.stock_market.set_par(buyer, price)
            @log << "#{buyer.id} share price is set to #{@game.format_currency(price.price)}"

            buyer.ipoed = true

            @round.pending_forms.pop
          end
        end
      end
    end
  end
end
