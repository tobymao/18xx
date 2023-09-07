# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/token_merger'
require_relative '../../g_1822/step/minor_acquisition'

module Engine
  module Game
    module G1822Africa
      module Step
        class MinorAcquisition < Engine::Game::G1822::Step::MinorAcquisition
          def can_acquire?(entity)
            return false if !entity.corporation? || (entity.corporation? && entity.type != :major)

            !potentially_mergeable(entity).empty?
          end

          def potentially_mergeable(entity)
            # Mergable ignoring connections
            minors = @game.corporations.select do |minor|
              minor.type == :minor && minor.floated? && !pay_choices(entity, minor).empty?
            end

            if @game.phase.status.include?('can_acquire_minor_bidbox')
              bidbox_minors = @game.bidbox.select { |c| @game.minor?(c) }
              available_minors = bidbox_minors.map { |c| @game.find_corporation(c) }.reject do |minor|
                pay_choices(entity, minor).empty?
              end
              minors.concat(available_minors) if available_minors
            end

            minors
          end
        end
      end
    end
  end
end
