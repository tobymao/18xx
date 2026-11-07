# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../action/merge'
require_relative '../../../step/share_buying'

module Engine
  module Game
    module G18OE
      module Step
        class MergeMinor < Engine::Step::Base
          include Engine::Step::ShareBuying

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
            @game.merge_targets(mergeable_entity.owner, mergeable_entity)
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

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity
            return true if exchange

            super
          end

          def process_merge(action)
            minor = @round.merge_minor
            major = action.corporation
            raise GameError, 'No minor is merging' unless minor
            raise GameError, "#{action.entity.name} is not the merging minor" unless action.entity == minor
            raise GameError, "#{minor.name} cannot merge into #{major&.name}" unless mergeable_entities.include?(major)

            merge!(minor, major)
          end

          def merge!(minor, major)
            share = @game.merge_share(major)
            cash_recipient = share&.owner == major ? major : @game.bank
            if share
              @log << "#{minor.name} merges into #{major.name}"
              @log << "#{minor.owner.name} exchanges #{minor.name} for a 10% share of #{major.name}"
              buy_shares(minor.owner, share.to_bundle, exchange: true)
            else
              @log << "#{minor.name} merges into #{major.name} by track connection; #{minor.owner.name} receives no share"
            end
            transfer_treasury(minor, cash_recipient)
            @round.merge_trains = { corporation: major, trains: move_trains!(minor, major) }
            @game.add_minor_charter!(minor, major)
            @game.minor_regional_order.delete(minor)
            @round.merged_majors << major
            @round.pending_acquisition = { minor: minor, corporation: major }
            @round.merge_minor = nil
            @round.steps.find { |step| step.is_a?(MergeToken) }.resolve_forced!
          end

          private

          def transfer_treasury(source, destination)
            return unless source.cash.positive?

            @log << "#{destination.name} takes #{@game.format_currency(source.cash)} from #{source.name} remaining cash"

            source.spend(source.cash, destination)
          end

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
