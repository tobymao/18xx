# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18OE
      module Step
        class MergeOffer < Engine::Step::Base
          def round_state
            super.merge(merge_offer: nil)
          end

          def active?
            !!@round.merge_offer
          end

          def blocks?
            active?
          end

          def active_entities
            return [] unless active?

            [asking? ? asked.owner : minor.owner]
          end

          def context_entities
            [minor]
          end

          def active_context_entity
            minor
          end

          def override_entities
            return [] unless active?

            @round.merge_offer[:presidents]
          end

          def actions(entity)
            return [] unless active?
            return %w[choose pass] if asking? && entity == asked.owner
            return ['choose'] if !asking? && entity == minor.owner

            []
          end

          def choice_available?(entity)
            active_entities.include?(entity)
          end

          def choices
            return { 'merge_offer' => asked.name } if asking?

            @round.merge_offer[:offers].to_h { |major| [major.id, major.name] }
          end

          def choice_name
            return "Offer to merge #{minor.name} into" if asking?

            "Merge #{minor.name} into"
          end

          def description
            'Merger Offer'
          end

          def pass_description
            'Decline'
          end

          def hide_corporations?
            true
          end

          def start!(minor, action)
            queue = @game.merge_offer_majors(minor)
            @round.merge_offer = {
              minor: minor,
              action: action,
              queue: queue,
              presidents: queue.map(&:owner).uniq,
              offers: [],
            }
            advance!
          end

          def process_choose(action)
            if asking?
              raise GameError, 'Cannot make that offer' unless action.choice == 'merge_offer'

              major = @round.merge_offer[:queue].shift
              @round.merge_offer[:offers] << major
              @log << "#{major.name} offers for #{minor.name}"
              advance!
            else
              major = @round.merge_offer[:offers].find { |offered| offered.id == action.choice }
              raise GameError, "#{action.choice} has not offered for #{minor.name}" unless major

              resolve!(major)
            end
          end

          def process_pass(action)
            major = @round.merge_offer[:queue].shift
            @log << "#{action.entity.name} declines to offer #{major.name} for #{minor.name}"
            advance!
          end

          private

          def minor
            @round.merge_offer[:minor]
          end

          def asking?
            !@round.merge_offer[:queue].empty?
          end

          def asked
            @round.merge_offer[:queue].first
          end

          def advance!
            return if asking?

            offers = @round.merge_offer[:offers]
            return resolve!(offers.first) if offers.size == 1
            return unless offers.empty?

            settle_without_offers!
          end

          def settle_without_offers!
            offer = @round.merge_offer
            @round.merge_offer = nil
            @log << "No offers for #{offer[:minor].name}"
            if offer[:action].choice == 'offer_or_abandon'
              @game.abandon_minor!(offer[:minor])
            else
              @round.merge_minor = offer[:minor]
              buy_step.track_action(offer[:action], offer[:minor])
            end
          end

          def resolve!(major)
            offer = @round.merge_offer
            @round.merge_offer = nil
            buy_step.track_action(offer[:action], offer[:minor])
            merge_step.merge!(offer[:minor], major)
          end

          def buy_step
            @round.steps.find { |step| step.is_a?(G18OE::Step::BuySellParShares) }
          end

          def merge_step
            @round.steps.find { |step| step.is_a?(G18OE::Step::MergeMinor) }
          end
        end
      end
    end
  end
end
