# frozen_string_literal: true
#
module Engine
  module Game
    module G1835
      module Step
        class ChoiceFloatPreussen < Engine::Step::SpecialChoose
          CHOICES = { :form => 'form', :fold_in => 'fold_in', :decline => 'decline' }.freeze

          def active_entities
            #LOGGER.debug("ChoiceFloatPreussen::active_entities")
            return [] unless @game.preussen_may_float

            [@game.minor_by_id('2').owner]
          end

          def blocks?
            #LOGGER.debug("ChoiceFloatPreussen::blocks?")
            @game.preussen_may_float
          end

          def active?
            #LOGGER.debug("ChoiceFloatPreussen::active?")
            active_entities.any?
          end

          def choices
            {CHOICES[:form] => 'Form Preußen',
             CHOICES[:decline] => CHOICES[:decline],}
          end

          def choice_name
            'Form Preußen?'
          end

          def actions(entity)
            #LOGGER.debug("ChoiceFloatPreussen::actions?")
            return [] unless entity == current_entity

            ['choose']
          end

          def process_choose_ability(action)
            #LOGGER.debug("ChoiceFloatPreussen::process_choose_ability?")
            super
          end

          def exchange_target(entity = current_entity)
            @game.corporation_by_id('PR')
            #@game.exchange_target(entity)
          end

          def process_choose(action)
            entity = action.entity
            target = exchange_target(entity)
            choice = action.choice
            if CHOICES[:form] == choice
              @log << "#{entity} opts to form #{target.id}"
              target.floated = true
              prussian_president_share = @game.share_by_id('PR_0')
              if prussian_president_share.owner.player?
                LOGGER.debug("PR president already owned, swapping")
                to_swap = @game.corporation_by_id('PR').shares.find {|share| share.percent == 10 && share.buyable == false}
                LOGGER.debug("Swapping share to #{to_swap}")
                previous_owner_of_president_share = prussian_president_share.owner
                #to_swap.owner = previous_owner_of_president_share
                #prussian_president_share.owner = entity
                #@game.corporation_by_id('PR').owner = entity
                @game.share_pool.transfer_shares(ShareBundle.new(prussian_president_share), entity, swap: to_swap, swap_to_entity: previous_owner_of_president_share)
              else
                LOGGER.debug("PR president still owned by PR")
              end

              pass!
            end
          end
        end
      end
    end
  end
end
