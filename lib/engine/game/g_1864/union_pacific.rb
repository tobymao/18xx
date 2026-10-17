# frozen_string_literal: true

module Engine
  module Game
    module G1864
      module UnionPacific
        CONSIST_DECKS = {
          'E1' => { '4' => %w[4],   '5' => %w[4 5],   '6' => %w[5 6], '7' => %w[6 7], '8' => %w[7 8] },
          'E2' => { '4' => %w[3 3], '5' => %w[3 3 4], '6' => %w[4],   '7' => %w[4 6], '8' => %w[6 8] },
          'E3' => { '4' => %w[4 4], '5' => %w[5],     '6' => %w[4 4], '7' => %w[6 6], '8' => %w[8 2+2] },
          'E4' => { '4' => %w[3],   '5' => %w[3 3],   '6' => %w[5],   '7' => %w[6],   '8' => %w[7] },
          'F1' => { '4' => %w[3 4], '5' => %w[4 4],   '6' => %w[4 5], '7' => %w[4 6], '8' => %w[7 2+2] },
          'F2' => { '4' => %w[3 4], '5' => %w[3 4],   '6' => %w[4 6], '7' => %w[5 7], '8' => %w[5+5E] },
          'F3' => { '4' => %w[3 4], '5' => %w[4],     '6' => %w[5 5], '7' => %w[7],   '8' => %w[5 7] },
          'F4' => { '4' => %w[3],   '5' => %w[3 5],   '6' => %w[6],   '7' => %w[5 6], '8' => %w[8] },
        }.freeze

        PHASES_WITH_CONSISTS = %w[4 5 6 7 8].freeze

        def setup_union_pacific!
          @union_pacific = @national = @future_corporations.find { |c| c.type == :national }
          @national_reservations = []
          @corporations << @future_corporations.delete(@union_pacific)
          @union_pacific.ipoed = true
          @union_pacific.floated = true
          @union_pacific.capitalization = :none
          par_corporation(@union_pacific, stock_market.market.flatten.compact.find { |sp| sp.price == 80 })
          @union_pacific.ipo_shares.each { |share| share.buyable = false }
          place_home_token(@union_pacific)
          setup_up_tile_reservations!
        end

        def deal_up_consists!
          decks = CONSIST_DECKS.values
          @up_consist = PHASES_WITH_CONSISTS.to_h do |phase|
            [phase, decks[rand % decks.size][phase]]
          end
          @up_revealed = []
          update_up_consist_description!
        end

        def add_up_train!(name)
          if (train = @depot.upcoming.find { |t| t.name == name && t.unlimited })
            @depot.remove_train(train)
          else
            prototype = self.class::TRAINS.find { |t| t[:name] == name }
            index = prototype[:num] + @union_pacific.trains.count { |t| t.name == name }
            train = Train.new(**prototype.except(:events), index: index)
          end
          train.buyable = false
          train.owner = @union_pacific
          @union_pacific.trains << train
        end

        def after_phase_change(name)
          super
          reveal_up_consist!(name) if @up_consist&.key?(name)
        end

        def reveal_up_consist!(phase_name)
          names = @up_consist[phase_name]
          return unless names

          @union_pacific.trains.clear
          names.each { |name| add_up_train!(name) }
          @up_revealed << phase_name
          @log << "#{@union_pacific.name} reveals its Phase #{phase_name} consist: #{names.join(', ')}"
          update_up_consist_description!
        end

        def train_by_id(id)
          super || @union_pacific.trains.find { |train| train.id == id }
        end

        def up_consist_visible?(phase_name)
          @optional_rules&.include?(:open_consists) || @up_revealed.include?(phase_name)
        end

        def update_up_consist_description!
          @union_pacific.all_abilities.select { |a| a.type == :description }.each do |ability|
            @union_pacific.remove_ability(ability)
          end

          detail = PHASES_WITH_CONSISTS.map do |phase|
            trains = up_consist_visible?(phase) ? @up_consist[phase].join(', ') : 'hidden'
            current = phase == @up_revealed.last ? ' (current)' : ''
            "Phase #{phase}: #{trains}#{current}"
          end

          @union_pacific.add_ability(Engine::Ability::Description.new(
            type: 'description',
            description: 'Train Consist',
            desc_detail: detail.join("\n"),
          ))
        end

        def up_operating?
          !!@up_started
        end

        def event_up_operates!
          @up_pending = true
        end

        def start_up_operations!
          @up_started = true if @up_pending
        end

        def up_without_president!
          old_price = @union_pacific.share_price
          @stock_market.move_right(@union_pacific)
          @log << "#{@union_pacific.name} has no owner and does not operate"
          log_share_price(@union_pacific, old_price)
        end

        def up_share_buyers(corporation)
          case corporation.type
          when :minor
            owner = corporation.owner
            owner&.player? ? [{ player: owner, shares: 1 }] : []
          when :major
            @players.rotate(@players.index(corporation.owner) || 0).filter_map do |player|
              entitled = (player.num_shares_of(corporation) / 2.0).floor
              { player: player, shares: entitled } if entitled.positive?
            end
          else
            []
          end
        end

        def event_up_ipo_purchasable!
          @union_pacific.reserved_shares.each { |share| share.buyable = true }
          @log << "#{@union_pacific.name} shares may now be purchased from the IPO"
        end
      end
    end
  end
end
