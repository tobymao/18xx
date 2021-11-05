# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../step/programmer'

module Engine
  module Game
    module G1873
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include Engine::Step::Programmer

          def setup
            super
          end

          def actions(entity)
            return [] if entity.company? || entity == @game.mhe
            return [] if entity != current_entity
            return [] if entity.minor? && !entity.owner
            return [] if entity.corporation? && entity.receivership?

            rval = []
            rval << 'buy_train' if can_really_buy_train?(entity)
            rval << 'scrap_train' if can_scrap_train?(entity)
            rval << 'pass' if !rval.empty? && !compulsory_buy?(entity)
            rval
          end

          def description
            @game.concession_pending?(current_entity) ? 'Buy Compulsory Train' : 'Buy Trains'
          end

          def pass_description
            if @acted
              'Done (Trains)'
            elsif @game.concession_pending?(current_entity)
              'Pass (Trains) Warning: Compulsory Train Required'
            else
              'Skip (Trains)'
            end
          end

          def log_skip(entity)
            super if !entity.minor? || entity.owner
          end

          def skip!
            if @game.concession_pending?(current_entity)
              @log << "#{current_entity.name} has not purchased its compulsory train"
              @game.insolvent!(current_entity)
            elsif current_entity == @game.mhe
              @game.mhe_buy_train
            else
              return super
            end

            pass!
          end

          def pass!
            if @game.concession_pending?(current_entity)
              @log << "#{current_entity.name} has not purchased its compulsory train"
              @game.insolvent!(current_entity)
            end

            super
          end

          # annoyingly needed because super process_buy_train checks this to see to automatically pass!
          def can_buy_train?(entity = nil, _shell = nil)
            can_really_buy_train?(entity) || can_scrap_train?(entity)
          end

          def can_really_buy_train?(entity = nil)
            entity ||= current_entity

            # indie mines can't buy 1Ms
            return false if entity.minor? && !@game.phase.available?('2')

            # FIXME: need to correct for entity-specific variants?
            # FIXME: this is lazy and computationally expensive
            !buyable_trains(entity).empty?
          end

          def compulsory_buy?(entity)
            return false if !@game.concession_pending?(entity) || !entity.cash.positive?

            depot_trains = @depot.depot_trains.reject do |dt|
              dt.price > entity.cash || (entity == @game.nwe && dt.distance < 2) || @game.diesel?(dt)
            end

            !depot_trains.empty?
          end

          def minor_distance(entity)
            entity.trains.find { |t| @game.train_is_machine?(t) }&.distance || 1
          end

          def public_mine_min_distance(entity)
            @game.public_mine_mines(entity).map { |m| minor_distance(m) }.min
          end

          def buyable_depot_trains(entity)
            @depot.depot_trains.reject do |t|
              t.variants.values.all? { |v| v[:price] > entity.cash }
            end
          end

          def buyable_trains(entity)
            depot_trains = buyable_depot_trains(entity)
            other_trains = @depot.other_trains(entity)
            other_trains = [] if entity.cash.zero?
            other_trains.reject! { |ot| illegal_other_buy?(ot, entity) }
            depot_trains.reject! { |dt| illegal_depot_buy?(dt, entity) }

            switchers = if (sp = @game.switcher_price) && !@game.concession_pending?(entity)
                          entity.cash >= sp ? [@game.next_switcher] : []
                        else
                          []
                        end

            (depot_trains + switchers + other_trains).compact
          end

          def illegal_concession_buy?(train, entity)
            @game.concession_pending?(entity) &&
              (@game.train_is_switcher?(train) ||
               @game.diesel?(train) ||
               (train.distance < 2 && entity == @game.nwe))
          end

          def illegal_depot_buy?(train, entity)
            return true if illegal_concession_buy?(train, entity)
            return false if @game.train_is_switcher?(train)

            # indie mines can't buy same size machine
            (entity.minor? && train.distance <= minor_distance(entity)) ||
              # public mines have to have at least one mine with a smaller machine
              (@game.public_mine?(entity) && train.distance <= public_mine_min_distance(entity)) ||
              # only RRs can have a diesel - but only one
              ((@game.entity_has_diesel?(entity) || !@game.railway?(entity)) && @game.diesel?(train))
          end

          def illegal_other_buy?(train, entity)
            return true if illegal_concession_buy?(train, entity)

            # can't ever buy machines across
            @game.train_is_machine?(train) ||
              # only RRs can have a diesel - but only one
              (@game.diesel?(train) && (@game.entity_has_diesel?(entity) || !@game.railway?(entity))) ||
              # can't ever buy from MHE
              train.owner == @game.mhe ||
              # Indie or Public mines can't buy actual trains
              (@game.any_mine?(entity) && @game.train_is_train?(train)) ||
              # Public mines can't buy switchers from itself
              (train.owner.owner && @game.public_mine?(train.owner.owner) && train.owner.owner == entity) ||
              # RR with concession pending must buy an actual train
              (@game.concession_pending?(entity) && !@game.train_is_train?(train)) ||
              # entity selling train must be able to
              !@game.can_sell_train?(train)
          end

          def buyable_train_variants(train, entity)
            return [] unless buyable_trains(entity).any? { |bt| bt.variants[bt.name] }

            variants = train.variants.values
            variants.reject! do |v|
              (v[:name].include?('M') && (@game.railway?(entity) || !train.from_depot?)) ||
                (v[:name].include?('T') && @game.any_mine?(entity))
            end
            return variants unless train.from_depot?

            variants.reject! { |v| entity.cash < v[:price] }
            variants
          end

          def can_scrap_train?(entity)
            if entity.minor?
              @game.switcher(entity)
            elsif @game.public_mine?(entity)
              @game.public_mine_mines(entity).any? { |m| @game.switcher(m) }
            else
              # RRs can voluntarily scrap switchers
              # and any trains, except diesels, if they have at least two
              return true if entity.trains.any? { |t| @game.train_is_switcher?(t) }
              return true if !entity.trains.empty? && entity == @game.qlb # QLB can have 0 trains

              entity.trains.count { |t| @game.train_is_train?(t) } > 1
            end
          end

          def scrappable_trains(entity)
            if entity.minor?
              # indie mines can only voluntarily scrap switchers
              [@game.switcher(entity)].compact
            elsif @game.public_mine?(entity)
              # public mines can only voluntarily scrap switchers
              @game.public_mine_mines(entity).map { |m| @game.switcher(m) }.compact
            else
              # RRs can voluntarily scrap switchers
              # and any trains if they have at least two (the NWE can't scrap a train
              # if the only one left would be a 1T)
              switchers = entity.trains.select { |t| @game.train_is_switcher?(t) }
              trains = entity.trains.select { |t| @game.train_is_train?(t) }
              trains = [] if trains.one? && entity != @game.qlb
              if entity == @game.nwe && trains.size == 2 && trains.any? { |t| t.name == '1T' }
                trains.select! { |t| t.name == '1T' }
              end
              (trains + switchers).compact
            end
          end

          def process_buy_train(action)
            entity = action.entity
            train = action.train
            slots = action.slots

            raise GameError, 'Illegal depot train buy' if train.owner == @game.depot && illegal_depot_buy?(train, entity)
            if train.owner != @game.depot && illegal_other_buy?(train, entity)
              raise GameError, 'Illegal train buy from another company'
            end

            raise GameError, "Can only spend a maximum of #{train.price * 2} for this train" if action.price > train.price * 2

            @game.concession_unpend!(entity) if @game.concession_pending?(entity) && (entity != @game.nwe || train.distance > 1)

            scrap_mine_train(entity, action.train) if entity.minor?

            old_owner = train.owner

            super

            maint_due = @game.train_maintenance(train.name)
            if maint_due.positive? && action.extra_due
              # seller must pay maintenance
              old_owner = old_owner.owner if @game.public_mine?(old_owner.owner)
              raise GameError, 'Seller has insufficient funds to pay maintenance' if old_owner.cash < maint_due

              old_owner.spend(maint_due, @game.bank)
              @log << "#{old_owner.name} pays #{@game.format_currency(maint_due)} for maintenance"
            elsif maint_due.positive?
              # buyer must pay maintenance
              raise GameError, 'Buyer has insufficient funds to pay maintenance' if entity.cash < maint_due

              entity.spend(maint_due, @game.bank)
              @log << "#{entity.name} pays #{@game.format_currency(maint_due)} for maintenance"
            end

            allocate_machines!(entity, train, slots) if @game.train_is_machine?(train) && @game.public_mine?(entity)
            allocate_switcher!(entity, train, slots) if @game.train_is_switcher?(train) && @game.public_mine?(entity)
          end

          def process_scrap_train(action)
            entity = action.entity
            train = action.train

            raise GameError, 'Cannot scrap a Machine voluntarily' if @game.train_is_machine?(train)

            if @game.train_is_train?(train) && @game.railway?(entity) && entity.trains.one?
              raise GameError, 'Cannot scrap last train'
            end

            @game.scrap_train(train)
          end

          def scrap_mine_train(entity, new_train)
            if @game.train_is_switcher?(new_train)
              @game.scrap_train(entity.trains.find { |t| @game.train_is_switcher?(t) })
            else
              @game.scrap_train(entity.trains.find { |t| @game.train_is_machine?(t) })
            end
          end

          def scrap_info(train)
            "Maintenance: #{@game.format_currency(@game.train_maintenance(train.name))}"
          end

          def scrap_button_text(_train)
            'Scrap'
          end

          def spend_minmax(entity, train)
            [1, [train.price * 2, entity.cash].min]
          end

          def real_owner(entity)
            @game.public_mine?(entity.owner) ? entity.owner.owner : entity.owner
          end

          # we just added a machine to a public mine, we have to replicate and move it
          # to a set of its subsidiary mines
          # Up to N of size N machines will be distributed
          def allocate_machines!(entity, bought_train, slots)
            entity.trains.delete(bought_train)
            submines = @game.public_mine_mines(entity)
            slots_needed = submines.count { |m| minor_distance(m) < bought_train.distance }
            num_to_fill = [slots_needed, bought_train.distance].min

            raise GameError, "Need to select #{num_to_fill} target mines for machines" if !slots || num_to_fill != slots.size

            trains = @game.replicate_machines(bought_train, num_to_fill)
            slots.each do |slot|
              if minor_distance(submines[slot]) >= bought_train.distance
                raise GameError, 'Must select a mine with machine size less than new machine size'
              end

              @game.add_train_to_slot(entity, slot, trains.shift)
            end
          end

          # we just added a switcher to a public mine, we have to move it to one of its
          # subsidiary mines
          def allocate_switcher!(entity, bought_train, slots)
            entity.trains.delete(bought_train)

            raise GameError, 'Need to select exactly one target mine for switcher' if !slots || !slots.one?

            @game.add_train_to_slot(entity, slots.first, bought_train)
          end

          def slot_view(entity)
            return unless @game.public_mine?(entity)

            'submines'
          end

          def extra_due(train)
            @game.train_maintenance(train.name).positive?
          end

          def extra_due_text(train)
            "Maint Due: #{@game.format_currency(@game.train_maintenance(train.name))}"
          end

          def extra_due_prompt
            'Seller Pays:'
          end

          def checkbox_prompt
            'Select mines to receive purchased machines or switcher using checkboxes:'
          end

          def ebuy_president_can_contribute?(_corporation)
            false
          end

          def president_may_contribute?(_corporation, _active_shell)
            false
          end

          def auto_actions(entity)
            programmed_auto_actions(entity)
          end

          def activate_program_independent_mines(entity, program)
            available_actions = actions(entity)
            return unless available_actions.include?('pass')
            return unless entity.minor?
            return unless program.skip_buy

            [Action::Pass.new(entity)]
          end
        end
      end
    end
  end
end
