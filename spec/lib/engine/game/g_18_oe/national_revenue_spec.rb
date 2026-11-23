# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE national revenue (§11.3.10)' do
  include G18OESpecHelpers

  let(:game) { new_game(%w[a b c]) }
  let(:player) { game.players[0] }
  let(:national) do
    major = start_major!(game, 'LNWR', player)
    game.form_national!(major)
    major
  end
  let(:revenue) { game.national_revenue(national) }

  def give!(name, variant = nil)
    train = game.trains.find { |t| t.name == name && !t.owner.is_a?(Engine::Corporation) }
    game.buy_train(national, train, :free)
    train.variant = variant if variant
    train
  end

  def stops(values, linked: true)
    values.map { |value| [nil, value, linked] }
  end

  def stub_zone!(city_values, unlinked_cities, town_values, unlinked_towns)
    allow(revenue).to receive(:city_stops)
      .and_return(stops(city_values) + stops([0] * unlinked_cities, linked: false))
    allow(revenue).to receive(:town_stops)
      .and_return(stops(town_values) + stops([0] * unlinked_towns, linked: false))
  end

  before { national }

  describe 'capacity (steps 1)' do
    it 'totals cities, doubled cities and towns of 4+4, 5 and 4D' do
      give!('4', '4+4')
      give!('5')
      give!('7+7', '4D')

      expect([revenue.city_capacity, revenue.doubled_capacity, revenue.town_capacity]).to eq([13, 4, 4])
    end

    it 'counts a rusted train toward capacity' do
      give!('4', '4+4')
      give!('5')
      give!('7+7', '4D')
      give!('3').rusted = true

      expect([revenue.city_capacity, revenue.town_capacity]).to eq([16, 4])
    end

    it 'does not count the Pullman toward capacity and levels it by the other trains' do
      give!('4', '4+4')
      give!('Pullman')

      expect([revenue.city_capacity, revenue.doubled_capacity, revenue.town_capacity]).to eq([4, 0, 4])
      expect(revenue.pullman_revenue).to eq(40)
    end
  end

  describe 'counting' do
    it 'follows the playbook 4.6 arithmetic' do
      give!('4', '4+4')
      give!('4', '4+4')
      give!('8+8', '5D')
      stub_zone!([100, 80, 80, 80, 80, 60, 60, 40, 30], 1, [20, 20, 20, 20, 10, 10, 10, 10], 0)

      expect([revenue.city_revenue, revenue.town_revenue, revenue.pullman_revenue, revenue.total])
        .to eq([1210, 120, 80, 1410])
    end

    it 'doubles filler in a D slot and leaves unlinked slots undoubled' do
      give!('4', '4+4')
      give!('8+8', '5D')
      stub_zone!([80, 60, 50], 1, [], 0)

      expect(revenue.filler_city_count).to eq(5)
      expect(revenue.city_revenue).to eq(810)
    end

    it 'runs a lone 5D with filler doubled' do
      give!('8+8', '5D')
      stub_zone!([80, 60, 50], 1, [], 0)

      expect(revenue.city_revenue).to eq(500)
    end

    it 'counts only the best linked stops up to capacity and ignores the rest' do
      give!('2+2')
      stub_zone!([50, 40, 30], 2, [], 0)

      expect([revenue.linked_city_values, revenue.unlinked_city_count, revenue.filler_city_count])
        .to eq([[50, 40], 0, 0])
      expect(revenue.city_revenue).to eq(90)
    end

    it 'gives a train with no town row no town revenue' do
      give!('3')
      stub_zone!([], 0, [20, 20], 0)

      expect(revenue.town_revenue).to eq(0)
    end

    it 'has no revenue without trains' do
      stub_zone!([50], 0, [20], 0)

      expect(revenue.total).to eq(0)
    end
  end

  describe 'real map' do
    it 'counts the best two linked UK cities (London and Liverpool) for a 2+2' do
      give!('2+2')

      expect(revenue.linked_city_values).to eq([30, 30])
      expect([revenue.unlinked_city_count, revenue.filler_city_count]).to eq([0, 0])
      expect(revenue.linked_town_values).to eq([])
      expect(revenue.unlinked_town_count).to eq(2)
      expect(revenue.pullman_revenue).to eq(20)
      expect(revenue.total).to eq(80)
    end
  end

  describe 'Brandt & Brandau token (§11.3.10)' do
    let(:bbe) { game.company_by_id('BBE') }

    def linked_stops
      game.clear_graph
      revenue.city_stops.select { |stop| %w[J25 J27].include?(stop.first.id) }.map(&:last)
    end

    before do
      give_company!(player, bbe)
      allow(game).to receive(:entity_track_rights_zone).and_return('UK')
    end

    it 'links Manchester and Liverpool by printed track with no token' do
      expect(linked_stops).to eq([true, true])
    end

    it 'unlinks a stop that is linked only across a token hex' do
      game.hex_by_id('J25').assign!('BBE')

      expect(linked_stops).to eq([false, false])
    end

    it 'links the stop again once the token is removed' do
      hex = game.hex_by_id('J25')
      hex.assign!('BBE')
      hex.remove_assignment!('BBE')

      expect(linked_stops).to eq([true, true])
    end

    it "unlinks even for a national presided by the private's owner" do
      national
      game.hex_by_id('J25').assign!('BBE')

      expect(national.owner).to eq(bbe.owner)
      expect(linked_stops).to eq([false, false])
    end
  end
end
