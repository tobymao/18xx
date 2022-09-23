# frozen_string_literal: true

require 'json'
require_relative 'bus'

module UserStats
  K = 40.0
  K_NEW = 60.0
  YEARS_INCLUDED = 4
  BATCH_SIZE = 1000

  def self.calculate_stats
    user_stats = Hash.new { |hash, key| hash[key] = Hash.new([1200, 0]) }
    on_or_after = Date.today - (365.25 * YEARS_INCLUDED)

    Game.eager(:players).where(status: %w[finished archived], manually_ended: false)
                        .where { finished_at >= on_or_after }
                        .order(:finished_at)
                        .paged_each(rows_per_fetch: BATCH_SIZE) do |game|
      calculate_game_stats(game, user_stats)
    end

    store_stats(user_stats)
  end

  def self.calculate_game_stats(game, player_stats)
    elo_change = Hash.new { |hash, key| hash[key] = Hash.new(0) }
    game.result.each do |player, score|
      elo_change[player]['overall'] = elo_change_for(player, score, 'overall', game, player_stats)
      elo_change[player][game.title] = elo_change_for(player, score, game.title, game, player_stats)
    end

    game.result.keys.each do |player|
      update_stats(player, elo_change[player], 'overall', player_stats)
      update_stats(player, elo_change[player], game.title, player_stats)
    end
  end

  def self.elo_change_for(player, score, category, game, stats)
    elo, num_plays = stats[player][category]
    k = k_for(num_plays)
    elo_change = 0

    game.result.each do |opponent, opp_score|
      next if player == opponent

      opp_elo = stats[opponent][category][0]
      s =
        if score > opp_score
          1.0
        elsif score == opp_score
          0.5
        else
          0.0
        end
      ea = 1 / (1.0 + (10.0**((opp_elo - elo) / 400.0)))
      elo_change += (k * (s - ea)).round
    end

    elo_change
  end

  def self.k_for(num_plays)
    num_plays <= 30 ? K_NEW : K
  end

  def self.update_stats(player, elo_change, category, stats)
    old_elo, plays = stats[player][category]
    stats[player][category] = [old_elo + elo_change[category], plays + 1]
  end

  def self.store_stats(stats)
    Bus.store_keys(stats.to_h { |user_id, data| [Bus::USER_STATS % user_id.to_i, JSON.dump(data)] })
  end
end
