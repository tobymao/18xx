# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      module Step
        module MinorMerger
          def merge_targets(player, minor)
            return [] unless @game.phase.available?('3')
            return [] if minor.type != :minor || !minor.floated? || minor.owner != player

            @game.corporations.select do |corporation|
              corporation.type == :major &&
                corporation.floated? &&
                corporation.president?(player) &&
                !@round.merged_majors.include?(corporation) &&
                merge_share(corporation)
            end
          end

          def merge_share(major)
            major.treasury_shares.find { |share| !share.president } ||
              @game.share_pool.shares_by_corporation[major].first
          end
        end
      end
    end
  end
end
