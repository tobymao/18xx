# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'private_exchange'

module Engine
  module Game
    module G1858
      module Step
        class PrivateClosure < Engine::Step::Base
          include PrivateExchange

          def actions(entity)
            return [] unless entity == current_entity
            return [] if exchange_corporations(entity).empty?

            %w[choose pass]
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

          def log_skip(_entity); end

          def skip!
            @game.close_private(current_entity)
            pass!
          end

          def choice_available?(_entity)
            true
          end

          def choice_name
            "Exchange #{current_entity.id} for a share"
          end

          def choices
            choices = []
            exchange_corporations(current_entity).each do |corporation|
              choices << choice_text(corporation, 'treasury') if corporation.num_treasury_shares.positive?
              choices << choice_text(corporation, 'market') if corporation.num_market_shares.positive?
            end
            choices
          end

          def choice_text(corporation, share_location)
            "#{corporation.id} #{share_location} share"
          end

          # Returns a hash with two items:
          #   corporation: the corporation object
          #   location: a string, either 'treasury' or 'market'
          def decode_choice(choice_text)
            /(?<corp_id>.*) (?<location>.*) share/ =~ choice_text
            {
              corporation: @game.corporations.find { |corp| corp.id == corp_id },
              location: location,
            }
          end

          def share_chosen(corporation, share_location)
            if share_location == 'treasury'
              corporation.shares.first
            else
              @game.share_pool.shares_by_corporation[corporation].first
            end
          end

          def process_choose(action)
            choice = decode_choice(action.choice)
            corporation = choice[:corporation]
            share_location = choice[:location]
            minor = action.entity
            company = @game.private_company(minor)
            player = company.owner

            share = share_chosen(corporation, share_location)
            exchange_for_share(share, corporation, minor, player)

            if share_location == 'treasury'
              acquire_private(corporation, minor)
              claim_token(corporation, minor)
            else
              company.owner = @game.bank
              player.companies.delete(company)
            end
            @game.close_private(company)
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
