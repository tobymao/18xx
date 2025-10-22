# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1822PNW::Game do
  describe 165_580 do
    it 'does not include associated minors for majors that were started '\
       'directly as valid choices for P20' do
      game = fixture_at_action(926)

      actual = game.active_step.p20_targets
      expected = [game.corporation_by_id('1')]

      expect(actual).to eq(expected)
    end
  end

  describe 'merger_high_value_minors' do
    it 'can only par at $100' do
      game = fixture_at_action(156)

      m6 = game.corporation_by_id('6')
      m18 = game.corporation_by_id('18')

      expect(m6.owner.value).to eq(1920)
      expect(game.active_step.valid_par_prices(m6, m18)).to eq([100])
    end

    it 'merging 6 and 18 will give the president 6 shares and all their cash' do
      game = fixture_at_action(158)

      m6 = game.corporation_by_id('6')
      m18 = game.corporation_by_id('18')
      ornc = game.corporation_by_id('ORNC')

      expect(m6.owner.value).to eq(1920)
      expect(game.active_step.choice_name).to eq('Choose number of shares to make up minors value of $670')
      expect(game.active_step.choices).to eq({ '6' => 'Player 1 receives 6 shares and $31' })
      expect(m6.cash).to eq(0)
      expect(m18.cash).to eq(0)
      expect(ornc.cash).to eq(31)
    end

    it 'president lost value after merge, the major has no cash left' do
      game = fixture_at_action(160)

      m6 = game.corporation_by_id('6')
      m18 = game.corporation_by_id('18')
      ornc = game.corporation_by_id('ORNC')

      expect(m6.closed?).to eq(true)
      expect(m18.closed?).to eq(true)
      expect(ornc.owner.value).to eq(1881)
      expect(ornc.cash).to eq(0)
    end
  end

  describe 'mill_ski_coal' do
    it 'does not allow mill or ski companies to use the coal hex' do
      # https://boardgamegeek.com/thread/3533826/article/46291488#46291488
      game = fixture_at_action(592)

      mill = game.company_by_id('P15')
      ski = game.company_by_id('P17')
      coal_hex = game.hex_by_id('J17')

      # coal tile is on the hex
      expect(coal_hex.tile.name).to eq('PNW4')

      assign_step = game.round.step_for(mill, 'assign')
      expect(assign_step.available_hex_mill(mill, coal_hex)).to eq(false)
      expect(assign_step.available_hex_ski(ski, coal_hex)).to eq(false)
    end
  end

  describe '179700' do
    context '17 closes' do
      it 'its home is not reserved by SPS' do
        game = fixture_at_action(967)

        m17 = game.corporation_by_id('17')
        sps = game.corporation_by_id('SPS')
        portland = game.hex_by_id('O8').tile.cities[0]

        expect(sps.tokens.count(&:used)).to eq(0)
        expect(portland.available_slots).to eq(0)
        expect(portland.reserved_by?(m17)).to eq(true)
        expect(portland.reserved_by?(sps)).to eq(false)
        expect(m17.closed?).to eq(false)

        # finish the SR, closing 17 from bidbox 1
        game.process_to_action(968)

        expect(sps.tokens.count(&:used)).to eq(0)
        expect(portland.available_slots).to eq(1)
        expect(portland.reserved_by?(m17)).to eq(false)
        expect(portland.reserved_by?(sps)).to eq(false)
        expect(m17.closed?).to eq(true)
      end

      it 'when SPS starts with a full home city, its token goes into an extra slot' do
        game = fixture_at_action(1301)

        gnr = game.corporation_by_id('GNR')
        sps = game.corporation_by_id('SPS')
        portland = game.hex_by_id('O8').tile.cities[0]

        expect(game.current_entity).to eq(gnr)
        expect(portland.available_slots).to eq(0)
        expect(portland.slots(all: true)).to eq(4)
        expect(portland.tokened_by?(sps)).to eq(false)

        game.process_to_action(1302)

        expect(game.current_entity).to eq(sps)
        expect(portland.available_slots).to eq(0)
        expect(portland.slots(all: true)).to eq(5)
        expect(portland.tokened_by?(sps)).to eq(true)
      end
    end
  end
end
