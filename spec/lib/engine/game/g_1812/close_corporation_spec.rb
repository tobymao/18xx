# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1812::Game do
  def new_game(num_players)
    described_class.new(%w[a b c d].take(num_players))
  end

  def majors(game)
    game.corporations.select { |c| c.type == :major }
  end

  describe 'station markers' do
    it 'gives each major 3 station markers with 4 players' do
      expect(majors(new_game(4)).map { |c| c.tokens.size }.uniq).to eq([3])
    end

    [2, 3].each do |num_players|
      it "gives each major 4 station markers with #{num_players} players" do
        expect(majors(new_game(num_players)).map { |c| c.tokens.size }.uniq).to eq([4])
      end
    end
  end

  describe 'closing a major' do
    let(:game) { new_game(4) }
    let(:major) { majors(game).first }
    let(:replacement) { game.corporation_by_id(major.id) }

    it 'closes when its price reaches the closing space' do
      game.par_corporation(major, game.stock_market.market.first.find { |sp| sp.price == 40 })
      game.stock_market.move_left(major)
      game.send(:close_corporations_in_close_cell!)

      expect(major).to be_closed
      expect(replacement).not_to be_closed
    end

    it 'returns its loans to the bank' do
      game.take_loan(major, game.loans.first)

      expect { game.close_corporation(major) }.to change { game.loans.size }.by(1)
    end

    it 'replaces it with a new corporation that can be started again' do
      shares = major.shares.map(&:id)
      game.close_corporation(major)

      expect(replacement).not_to equal(major)
      expect(replacement).not_to be_closed
      expect(game.corporations.select { |c| c.id == major.id }).to eq([replacement])
      expect(shares.map { |id| game.share_by_id(id).corporation }.uniq).to eq([replacement])
      expect(replacement.tokens.size).to eq(3)
    end

    it 'keeps the 60% holding limit in a 2-player game' do
      game = new_game(2)
      major = majors(game).first
      game.close_corporation(major)

      expect(game.corporation_by_id(major.id).max_ownership_percent).to eq(60)
    end
  end
end
