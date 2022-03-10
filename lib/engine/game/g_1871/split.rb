# frozen_string_literal: true

# lib/split.rb

module Engine
  module Game
    module G1871
      class Split
        attr_reader :state, :corporation, :branch

        def initialize(game, log, corporation)
          @game = game
          @log = log
          @corporation = corporation
          @state = :pick_branch
        end

        def description
          case @state
          when :pick_branch
            "Splitting #{@corporation.full_name} - Choosing Branch"
          when :pick_par
            "Splitting #{@corporation.full_name} - Choosing Par"
          when :pick_trains
            "Splitting #{@corporation.full_name} - Choosing Trains"
          end
        end

        def active_entity
          case @state
          when :pick_branch
            :player
          when :pick_par, :pick_trains
            :branch
          end
        end

        def prompt
          case @state
          when :pick_branch
            'Start'
          when :pick_par
            'Choose Par'
          when :pick_trains
            'Choose Trains'
          end
        end

        def branch=(branch)
          @branch = branch
          @state = :pick_par
        end

        def par=(_share_price)
          @state = :pick_trains
        end

        def done_assigning_trains
          @log << 'Done assigning trains'
          @state = :pick_tokens
        end

        def assign_train(train)
          @corporation.trains.delete(train)
          train.owner = @branch
          @branch.trains << train

          done_assigning_trains if @corporation.trains.empty?
        end

        def active?
          !!@state
        end
      end
    end
  end
end
