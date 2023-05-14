# frozen_string_literal: true

require_relative '../../../step/simple_draft'

module Engine
  module Game
    module G1847AE
      module Step
        class Draft < Engine::Step::SimpleDraft
          attr_reader :grouped_companies

          ACTIONS = %w[bid pass].freeze

          def setup
            @companies = @game.companies.select { |c| c.owner.nil? && !c.closed? }
            @companies = @companies.sort_by { |item| [item.revenue, item.value] }
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] if @acted
            return [] unless can_buy_any?(entity)

            ACTIONS
          end

          def can_buy_any?(player)
            @companies.any? { |company| player.cash >= min_bid(company) }
          end

          def active?
            true
          end

          def tiered_auction_companies
            @companies.group_by(&:revenue).values
          end

          def description
            'Draft Private Companies'
          end

          def process_bid(action, _suppress_log = false)
            action.entity.unpass!
            company = action.company
            player = action.entity
            price = action.price

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank)

            @companies.delete(company)

            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

            company.abilities.each do |ability|
              next unless ability.type == :shares

              # Give related share to the player and give money for the share to the corporation
              ability.shares.each do |share|
                @game.share_pool.buy_shares(player, share, exchange: :free)
                @game.bank.spend(share.corporation.par_price.price * share.percent / 10, share.corporation)
              end
            end

            # PLP company is only a temporary holder for the L presidency
            company.close! if company.id == 'PLP'
          end

          def process_pass(action)
            super
            action.entity.pass!
          end

          def log_skip(entity)
            @log << "#{entity.name} cannot afford any company and passes"
          end

          def skip!
            super
            current_entity.pass! unless @acted
          end
        end
      end
    end
  end
end
