# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../action/merge'
require_relative '../../g_18_eu/step/minor_exchange'
require_relative 'minor_merger'

module Engine
  module Game
    module G18OE
      module Step
        class MergeMinor < Engine::Step::Base
          include MinorMerger
          include G18EU::MinorExchange

          def round_state
            super.merge(merge_trains: nil, pending_acquisition: nil)
          end

          def actions(_entity)
            merge_in_progress? ? ['merge'] : []
          end

          def description
            "Merge #{mergeable_entity.name} into a major"
          end

          def blocks?
            merge_in_progress?
          end

          def merge_in_progress?
            !!@round.merge_minor
          end

          def active_entities
            return [] unless merge_in_progress?

            [@round.merge_minor.owner]
          end

          def mergeable_entity
            @round.merge_minor
          end

          def mergeable_entities
            merge_targets(mergeable_entity.owner, mergeable_entity)
          end

          def mergeable_type(minor)
            "Majors that can absorb #{minor.name}"
          end

          def merge_action
            'Merge'
          end

          def show_other_players
            false
          end

          def can_buy?(_entity, _bundle)
            true
          end

          def process_merge(action)
            minor = @round.merge_minor
            major = action.corporation
            raise GameError, 'No minor is merging' unless minor
            raise GameError, "#{action.entity.name} is not the merging minor" unless action.entity == minor
            raise GameError, "#{minor.name} cannot merge into #{major&.name}" unless mergeable_entities.include?(major)

            from_treasury = merge_share(major).owner == major
            @log << "#{minor.name} merges into #{major.name}"
            exchange_share(minor, major, from_treasury ? major : @game.share_pool)
            transfer_treasury(minor, from_treasury ? major : @game.bank)
            @round.merge_trains = { corporation: major, trains: move_trains!(minor, major) }
            @game.merged_minors[major] << minor
            @game.minor_regional_order.delete(minor)
            @round.merged_majors << major
            @round.pending_acquisition = { minor: minor, corporation: major }
            @round.merge_minor = nil
          end

          private

          def move_trains!(minor, major)
            return [] if minor.trains.empty?

            trains = @game.transfer(:trains, minor, major)
            @log << "#{major.name} takes #{trains.map(&:name).join(', ')} from #{minor.name}"
            trains
          end
        end
      end
    end
  end
end
