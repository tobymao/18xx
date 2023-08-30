# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'private_exchange'

module Engine
  module Game
    module G1858
      module Step
        class PrivateClosure < Engine::Step::Base
          include PrivateExchange

          def setup
            minor = current_entity
            @round.minor = minor
            @round.approvals = @game.corporations.select(&:floated).to_h do |corporation|
              approval = corporation.owner == minor.owner ? :approved : :pending
              [corporation, approval]
            end
          end

          def actions(entity)
            return [] unless entity == current_entity

            %w[choose pass]
          end

          def auto_actions(entity)
            return unless exchange_corporations(entity).empty?

            [Engine::Action::Pass.new(entity)]
          end

          def description
            'Exchange Private Companies'
          end

          def pass_description
            "Sell #{current_entity.id} to bank"
          end

          def process_pass(action)
            @game.close_private(action.entity)
          end

          def choice_available?(_entity)
            true
          end

          def choice_name
            "Exchange #{current_entity.id} for a share"
          end

          def choice_explanation
            [
              'To exchange for a treasury share you need the approval of the ' \
              'public company’s president.',

              'If a public company has both ' \
              'treasury and market shares available, then you can only ' \
              'exchange for a market share if you have first requested the ' \
              'exchange for a treasury share. An asterisk on the button ' \
              'indicates a public company that has market shares that will ' \
              'become available if a request for a treasury share is denied.',

              'If a public company only has ' \
              'market shares available then you do not need approval.',
            ]
          end

          def choices
            choices = {}
            exchange_corporations(current_entity).each do |corporation|
              if corporation.num_treasury_shares.positive?
                # Should we indicate whether there are market shares that would
                # be available after a request for a treasury share is denied?
                market_shares = corporation.num_market_shares.positive? &&
                                  @round.approvals[corporation] == :pending
                add_choice(choices, corporation, 'treasury', market_shares)
              end

              # The private can only be swapped for a market share if:
              #   - there are no treasury shares of that public company
              #     available, or
              #   - the public company's president has refused a request to
              #     exchange the private for a treasury share, or
              #   - the private and public companies are owned by the same
              #     player.
              next if corporation.num_market_shares.zero?
              next if corporation.num_treasury_shares.positive? &&
                      @round.approvals[corporation] != :denied &&
                      corporation.owner != current_entity.owner

              add_choice(choices, corporation, 'market', false)
            end
            choices
          end

          def add_choice(choices, corporation, location, footnote)
            k = { 'corporation' => corporation.id, 'from' => location }
            v = "#{corporation.id} #{location} share#{footnote ? '*' : ''}"
            choices[k] = v
          end

          def share_chosen(corporation, share_location)
            if share_location == 'treasury'
              corporation.shares.first
            else
              @game.share_pool.shares_by_corporation[corporation].first
            end
          end

          def process_choose(action)
            choice = action.choice
            corporation = @game.corporation_by_id(choice['corporation'])
            share_location = choice['from']
            minor = action.entity
            company = @game.private_company(minor)
            player = company.owner

            if share_location == 'market' &&
                corporation.num_treasury_shares.positive? &&
                @round.approvals[corporation] == :pending
              raise GameError, 'Cannot exchange for a treasury share unless ' \
                               'a request for a treasury share has been denied.'
            end

            if share_location == 'treasury' &&
                @round.approvals[corporation] != :approved
              log_request(corporation, minor)
              @round.pending_approval = corporation
            else
              share = share_chosen(corporation, share_location)
              treasury_share = (share_location == 'treasury')
              exchange_for_share(share, corporation, minor, player, treasury_share)

              unless treasury_share
                company.owner = @game.bank
                player.companies.delete(company)
              end
              @game.close_private(company)
            end
          end

          def exchange_corporations(minor)
            @game.corporations.select do |corporation|
              @game.corporation_private_connected?(corporation, minor) &&
                (corporation.num_treasury_shares.positive? ||
                 corporation.num_market_shares.positive?)
            end
          end
        end
      end
    end
  end
end
