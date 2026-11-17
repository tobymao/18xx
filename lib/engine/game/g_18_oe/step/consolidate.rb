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

          def help
            return super if @converting || @converted

            player = current_entity
            regionals = @game.corporations.select { |c| c.type == :regional && c.president?(player) }
            requirements = []
            if over_certificate_limit?(player)
              requirements << "Get down to the certificate limit (#{@game.cert_limit(player)}): sell shares or close privates"
            end
            requirements << "Convert to a major: #{regionals.map(&:name).join(', ')}" unless regionals.empty?
            requirements.concat(minor_consolidation_help(player, regionals))
            return [] if requirements.empty?

            heading = if @round.current_actions.empty?
                        "#{player.name} cannot pass until:"
                      else
                        "#{player.name} may end this turn, but cannot pass on a later turn until:"
                      end
            [heading] + requirements
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

          def minor_consolidation_help(player, regionals)
            groups = owned_minors(player).group_by do |minor|
              if !@game.merge_targets(player, minor).empty?
                @game.merge_offer_majors(minor).empty? ? :merge : :offer_or_merge
              else
                regionals.empty? ? :offer_or_abandon : :convert
              end
            end
            groups.map do |requirement, minors|
              names = minors.map(&:name).join(', ')
              case requirement
              when :merge
                "Merge into one of their majors: #{names}"
              when :offer_or_merge
                "Merge into one of their majors or offer to other players: #{names}. "\
                'If no one offers, they choose which of their majors it merges into.'
              when :offer_or_abandon
                "Offer to other players: #{names}. If no one offers, it is abandoned."
              when :convert
                "Convert a regional, then merge or offer: #{names}"
              end
            end
          end

          def offer_request?(action)
            target = action.target
            %w[offer_or_merge offer_or_abandon].include?(action.choice) && target&.corporation? && target.type == :minor
          end

          def offer_allowed?(target, choice)
            @game.loading || entity_choices(target).key?(choice)
          end

          def offer_choices(player, minor)
            return {} unless @round.current_actions.empty?

            if can_merge?(player, minor)
              @game.merge_offer_majors(minor).empty? ? {} : { 'offer_or_merge' => 'Offer' }
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
