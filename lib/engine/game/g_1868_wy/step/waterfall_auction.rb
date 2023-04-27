# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G1868WY
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def help
            if @choosing
              "#{@choosing_player.name} won the auction for #{@auctioned_company.name}, now chooses one of:"
            else
              @game.corp_stacks_str_arr
            end
          end

          def setup
            super

            if @game.optional_rules.include?(:p2_p6_choice)
              choice_companies = @game.class::COMPANY_CHOICES.values.flatten
              @companies.reject! { |c| choice_companies.include?(c.id) }
            end

            @passed_on_cheapest = {}
          end

          def actions(entity)
            @choosing ? ['bid'] : super
          end

          def active_entities
            @choosing ? [@choosing_player] : super
          end

          def available
            @choosing ? @company_choices : @companies
          end

          def may_purchase?(company)
            @choosing ? @company_choices.include?(company) : super
          end

          def remove_cheapest!
            reasons = []
            reasons << 'passed' if @passed_on_cheapest.value?('pass')
            reasons << 'bid on other companies' if @passed_on_cheapest.value?('bid')
            reason = "all players #{reasons.join(' or ')}"
            @log << "#{@cheapest.name} is removed (#{reason})"

            @cheapest.close!
            @companies.delete(@cheapest)
            @cheapest = @companies.first

            resolve_bids unless @bids[@cheapest].empty?
          end

          def resolve_bids_for_company(company)
            super unless @choosing
          end

          def buy_company(player, company, price)
            if @choosing
              company.owner = player
              player.companies << company
              @log << "#{player.name} chooses #{company.name}, closing the other #{@auctioned_company.sym} companies"
              @choosing = false
              @choosing_player = nil
              @company_choices.each { |c| c.close! unless c == company }
              @company_choices = nil
              @auctioned_company.close!
              @auctioned_company = nil

              @game.setup_strikebreakers! if company == @game.strikebreakers_private

              return
            end

            super

            if (companies = @game.isr_company_choices[company.sym])
              @auctioned_company = company
              @choosing = true
              @choosing_player = player
              @company_choices = companies
            end

            company.revenue = 0 if company == @game.lhp_private
            @game.setup_strikebreakers! if company == @game.strikebreakers_private

            @cheapest = @companies.first
            @passed_on_cheapest = {}
          end

          def maybe_all_passed!
            return if @auctioning || @choosing

            # can't just use `@round.entities.all?(&:passed?)` here since bids
            # on companies other than the cheapest count as "passing" on the
            # cheapest
            return unless @round.entities - @passed_on_cheapest.keys == []

            all_passed!
          end

          def all_passed!
            case @cheapest
            when @game.hell_on_wheels
              unless @passed_on_cheapest.value?('bid')
                remove_cheapest!
                @passed_on_cheapest = {}
              end
            when @game.durant
              increase_discount!(@game.ames_bros, 10) if @bids[@game.ames_bros].empty?
              increase_discount!(@game.durant, 10)
              @passed_on_cheapest = {}
            else
              remove_cheapest!
              @passed_on_cheapest = {}
            end

            entities.each(&:unpass!)
          end

          def process_bid(action)
            if action.company == @cheapest
              @passed_on_cheapest = {}
            elsif !(@auctioning || @choosing)
              @passed_on_cheapest[action.entity] = 'bid'
            end

            if @choosing
              action.entity.unpass!
              placement_bid(action)
            else
              super
            end

            maybe_all_passed!
          end

          def process_pass(action)
            @passed_on_cheapest[action.entity] = 'pass' unless @auctioning
            super
            maybe_all_passed!
          end
        end
      end
    end
  end
end
