# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1861
      module Step
        class Route < Engine::Step::Route
          ACTIONS = %w[run_routes].freeze

          def help
            return super unless current_entity.type == :national

            "#{current_entity.name} is the National Railway. Most of its "\
              'actions are automated, but it must have a player manually run its trains. '\
              "Please enter the best route you see for #{current_entity.name} including bonuses for private companies."
          end
        end
      end
    end
  end
end
