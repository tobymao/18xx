# frozen_string_literal: true

module Engine
  module Game
    module G1835
      module Step
        class MinorExchange < Engine::Step::Base
          ACTIONS = %w[choose].freeze
          CHOICES = { :form => 'form', :fold_in => 'fold_in', :decline => 'decline' }.freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless can_exchange?(entity)

            ACTIONS
          end

          def auto_actions(_entity)
            []
          end

          def blocking?
            @game.pr_can_form || @game.prussian.floated?
          end

          def active_entities
            if @game.pr_can_form && !@game.prussian.floated? && !@round.declined.include?(@game.berlin_potsdamer_bahn)
              return [@game.berlin_potsdamer_bahn]
            end
            return exchangeables_sorted_by_player if @game.prussian.floated?

            []
          end

          def active?
            !active_entities.empty?
          end

          def description
            'Preußen'
          end

          def can_exchange?(entity)
            return false if entity.closed?
            return true if entity == @game.berlin_potsdamer_bahn
            return false unless @game.prussian_exchangeables.include?(entity)

            @game.prussian.floated?
          end

          def form_label
            "Form #{@game.prussian.id}"
          end

          def fold_label
            "Fold into #{@game.prussian.id}"
          end

          def choice_name
            if current_entity == @game.berlin_potsdamer_bahn
              form_label
            else
              fold_label
            end
          end

          def choices
            if current_entity == @game.berlin_potsdamer_bahn
              {
                CHOICES[:form] => form_label,
                CHOICES[:decline] => CHOICES[:decline],
              }.freeze
            else
              {
                CHOICES[:fold_in] => fold_label,
                CHOICES[:decline] => CHOICES[:decline],
              }.freeze
            end
          end

          def choice_available?(_entity)
            true
          end

          def ipo_type(_entity)
            nil
          end

          def process_choose(action)
            entity = action.entity
            choice = action.choice
            if CHOICES[:form] == choice
              process_choice_form(entity)
            elsif CHOICES[:fold_in] == choice
              process_choice_fold_in(entity)
            else
              process_choice_decline(entity)
            end

            # in an OR after the choice was made for the last minor/private...
            process_after_last_choice! if active_entities.empty? && @round.operating?
          end

          def process_choice_form(entity)
            @log << "#{entity.id} opts to form #{@game.prussian.id}"
            @round.converted << entity
            @game.pr_can_form = false
            @game.form_prussian!
          end

          def process_choice_fold_in(entity)
            @round.converted << entity
            @log << "#{entity.id} opts to fold into #{@game.prussian.id}"
            if entity.type == :minor
              @game.merge_minor!(entity)
            else
              @game.merge_company!(entity)
            end
          end

          def process_choice_decline(entity)
            @round.declined << entity
            @log << if entity == @game.berlin_potsdamer_bahn
                      "#{entity.id} declines to form #{@game.prussian.id}"
                    else
                      "#{entity.id} declines to fold into #{@game.prussian.id}"
                    end
          end

          def log_skip(entity)
            @log << "#{entity.id} has no action"
          end

          def round_state
            {
              declined: [],
              converted: [],
            }
          end

          def exchangeables_sorted_by_player
            preprussians = (@game.prussian_exchangeables - @round.declined).reject(&:closed?)
            first_player = pr_formed_this_round? ? @game.prussian.owner : @game.players.first
            start_index = @game.players.index(first_player)
            players = @game.players.dup

            ordered_players = players.rotate(start_index)

            owner_positions = ordered_players.each_with_index.to_h

            preprussians.sort_by do |preprussian|
              owner_positions[preprussian.owner] || Float::INFINITY
            end
          end

          def process_after_last_choice!
            if @game.conversion_choice_during_or
              if pr_formed_this_round?
                if pr_should_operate_this_or?
                  insert_prussian!
                else
                  @log << 'Companies/Minors that were converted into PR shares have already paid out/acted this round. '\
                          'PR will therefore be skipped this OR.'
                end
              end
            else
              insert_prussian! if pr_formed_this_round?

              # Payout companies which was foregone earlier when setting up the OR
              @game.payout_companies
            end
          end

          # The rules forbid that anyone profits from a paper twice.
          # Ergo: If 2 has already operated, PR cannot operate in the same OR or the (former) owner of 2 would profit
          # from their paper twice. The only that let's the PR operate in the same OR it was formed is therefore:
          # - 1 buys the train that triggers the conversion and
          # - neither it nor the prussian companies HB and BB (since they paid out their revenue) are converted
          def pr_should_operate_this_or?
            no_prussian_company_or_minor_1_converted = !@round.converted.intersect?(@game.prussian_companies + [minor_1])
            minor_1_bought_triggering_train = minor_1 == @round.entities[@round.entity_index]
            no_prussian_company_or_minor_1_converted && minor_1_bought_triggering_train
          end

          def minor_1
            @minor_1 ||= @game.minor_by_id('1')
          end

          def pr_formed_this_round?
            @round.converted.include?(@game.berlin_potsdamer_bahn)
          end

          def insert_prussian!
            index = @round.entities.index do |entity|
              entity.type != :minor && entity.share_price.price < @game.prussian.share_price.price
            end || @round.entities.length
            @round.entities.insert(index, @game.prussian)
          end
        end
      end
    end
  end
end
