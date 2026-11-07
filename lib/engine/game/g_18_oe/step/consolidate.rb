# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G18OE
      module Step
        class Consolidate < G18OE::Step::BuySellParShares
          def description
            'Consolidate regionals into majors'
          end

          def actions(entity)
            actions = super
            return actions - ['pass'] if entity.corporation?
            return actions if @round.current_actions.any?
            return actions - ['pass'] if presides_regional?(entity) || owned_minors(entity).any?

            actions
          end

          def blocking?
            super || (current_entity&.player? && presides_regional?(current_entity) && @round.current_actions.empty?)
          end

          def non_private_choices_allowed?(player)
            super || !owned_minors(player).empty?
          end

          def choose_available?(entity)
            super || owned_minors(entity).any? { |minor| !offer_choices(entity, minor).empty? }
          end

          def entity_choices(target)
            if owned_minor?(current_entity, target) && @round.current_actions.empty?
              offer_choices(current_entity, target)
            else
              super
            end
          end

          def process_choose(action)
            return super unless offer_request?(action)

            target = action.target
            raise GameError, "Cannot offer #{target.name}" if target.owner != action.entity || @round.current_actions.any?
            raise GameError, "Cannot #{action.choice} #{target.name}" unless offer_allowed?(target, action.choice)

            offer_step.start!(target, action)
          end

          private

          def offer_request?(action)
            target = action.target
            %w[offer offer_or_abandon].include?(action.choice) && target&.corporation? && target.type == :minor
          end

          def offer_allowed?(target, choice)
            @game.loading || entity_choices(target).key?(choice)
          end

          def offer_choices(player, minor)
            return {} unless @round.current_actions.empty?

            if can_merge?(player, minor)
              @game.merge_offer_majors(minor).empty? ? {} : { 'offer' => 'Offer' }
            elsif presides_regional?(player)
              {}
            else
              { 'offer_or_abandon' => 'Offer' }
            end
          end

          def owned_minor?(player, corporation)
            corporation.corporation? && corporation.type == :minor && corporation.owner == player
          end

          def owned_minors(player)
            @game.corporations.select { |corporation| owned_minor?(player, corporation) }
          end

          def presides_regional?(player)
            @game.corporations.any? { |c| c.type == :regional && c.president?(player) }
          end

          def offer_step
            @round.steps.find { |step| step.is_a?(G18OE::Step::MergeOffer) }
          end
        end
      end
    end
  end
end
