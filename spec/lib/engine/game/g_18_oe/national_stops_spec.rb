# frozen_string_literal: true

require 'spec_helper'
require_relative 'route_helpers'

describe 'G18OE national stops (§11.3.10)' do
  include_context 'with 18OE route helpers'

  def revenue(name = 'UK')
    allow(game).to receive(:entity_track_rights_zone).and_return(name)
    game.national_revenue(corp)
  end

  def city_stops(name = 'UK')
    revenue(name).city_stops
  end

  def city_stop(hex_id, name = 'UK')
    city_stops(name).find { |stop| stop.first.id == hex_id }
  end

  def town_stops(hex_id, name = 'UK')
    revenue(name).town_stops.select { |stop| stop.first.id == hex_id }
  end

  def city_linked(hex_id, name = 'UK')
    city_stop(hex_id, name).last
  end

  def towns_linked(hex_id, name = 'UK')
    town_stops(hex_id, name).map(&:last)
  end

  def double_town_code(*exits)
    "double_town=revenue:10,axis:0,revenue_loc:1.5|4.5;#{exits.map { |exit| "path=a:#{exit},b:_0" }.join(';')}"
  end

  describe 'zone of border towns and cities' do
    it 'puts Linz and Innsbruck in Austria-Hungary' do
      expect(%w[R51 S46].map { |id| game.region_for_hex(game.hex_by_id(id)) }).to eq(%w[AH AH])
    end

    it 'puts Genève and Lausanne in Prussia-Hanover-Saxony-Switzerland' do
      expect(game.region_for_hex(game.hex_by_id('T37'))).to eq('PHS')
    end

    it 'puts Andorra in France' do
      expect(game.region_for_hex(game.hex_by_id('X25'))).to eq('FR')
    end

    it 'keeps Nancy, Dresden and Jassy in their zones' do
      expect(%w[Q38 O52 S76].map { |id| game.region_for_hex(game.hex_by_id(id)) }).to eq(%w[FR PHS BRS])
    end

    it 'puts Palma in Spain' do
      expect(game.region_for_hex(game.hex_by_id('AB27'))).to eq('SP')
    end
  end

  describe 'stops' do
    it 'makes Birmingham one city stop holding its three cities' do
      train = game.trains.find { |t| t.name == '3' }
      game.buy_train(corp, train, :free)
      stops = city_stops.select { |stop| stop.first.id == 'K26' }
      best = game.hex_by_id('K26').tile.cities.map { |city| city.route_base_revenue(game.phase, train) }.max

      expect(stops.size).to eq(1)
      expect(stops.first[1]).to eq(best)
    end

    it 'makes Leeds and Sheffield two town stops' do
      expect(town_stops('J29').size).to eq(2)
    end
  end

  describe 'printed track' do
    it 'links Liverpool and Manchester' do
      expect(city_linked('J25')).to be(true)
      expect(city_linked('J27')).to be(true)
    end

    it 'links Dublin through the drawn ferry track to Liverpool' do
      expect(city_linked('I20')).to be(true)
    end
  end

  describe 'a town tile on a hex with no track' do
    it 'leaves Inverness and the Scottish Highlands unlinked until Inverness has track to them' do
      expect(city_linked('D25')).to be(false)
      expect(towns_linked('E26')).to eq([false])

      lay_code!('E26', 'town=revenue:10;path=a:2,b:_0')

      expect(city_linked('D25')).to be(true)
      expect(towns_linked('E26')).to eq([true])
    end
  end

  describe 'a double town' do
    it 'leaves both towns unlinked when its track faces nothing' do
      lay_code!('J29', double_town_code(3, 0))

      expect(towns_linked('J29')).to eq([false, false])
    end

    it 'links both towns when its track meets Manchester' do
      lay_code!('J29', double_town_code(3, 1))

      expect(towns_linked('J29')).to eq([true, true])
    end
  end

  describe 'ferries' do
    it 'leaves London unlinked while the Calais ferry ends at a city with no track' do
      lay_code!('N31', 'city=revenue:20')

      expect(city_linked('M28')).to be(false)
    end

    it 'links London once the ferry reaches a city with track facing it' do
      lay_code!('N31', 'city=revenue:20;path=a:1,b:_0')

      expect(city_linked('M28')).to be(true)
    end

    it 'counts London for the United Kingdom and Calais for France' do
      expect(city_stops('UK').map { |stop| stop.first.id }).to include('M28')
      expect(city_stops('UK').map { |stop| stop.first.id }).not_to include('N31')
      expect(city_stops('FR').map { |stop| stop.first.id }).to include('N31')
    end

    it 'links Edinburgh to Bergen across the ferry whose end is offshore' do
      expect(city_linked('G26')).to be(true)
    end

    it 'never links across a sea crossing between two ports' do
      expect(city_linked('H21')).to be(false)
      lay_code!('H21', 'city=revenue:20;path=a:4,b:_0')

      expect(city_linked('H21')).to be(false)
    end
  end

  describe 'port stubs on a shared sea hex' do
    it 'does not link Trieste and Venezia through the junction of their port arrows' do
      lay_code!('V51', 'city=revenue:20;path=a:1,b:_0')
      lay_code!('V47', 'city=revenue:20;path=a:4,b:_0')

      expect(city_linked('V51', 'AH')).to be(false)
      expect(city_linked('V47', 'IT')).to be(false)
    end
  end

  describe 'a ferry-only red zone' do
    it 'links Casablanca once Tangier-side track faces the AE6 ferry' do
      expect(city_linked('AF5', 'SP')).to be(false)

      lay_code!('AD7', 'city=revenue:20;path=a:0,b:_0')

      expect(city_linked('AF5', 'SP')).to be(true)
    end
  end

  describe 'stops on the same hex (R13)' do
    it 'does not link a double town to itself through its internal path' do
      lay_code!('J29', double_town_code(3, 0))

      expect(towns_linked('J29')).to eq([false, false])
    end

    it 'does not link a city to another city on its own hex' do
      lay_code!('K26', 'city=revenue:0;city=revenue:0;city=revenue:0;path=a:_0,b:_1')

      expect(city_linked('K26')).to be(false)
    end
  end

  describe 'a city whose only track runs to a port' do
    it 'is unlinked' do
      lay_code!('AD9', 'city=revenue:20;path=a:0,b:_0')

      expect(city_linked('AD9', 'SP')).to be(false)
    end
  end

  describe 'a red zone reached only by sea' do
    def north_africa
      city_linked('AD1', 'SP')
    end

    def malaga_stub!
      lay_code!('AD9', 'city=revenue:20;path=a:0,b:_0')
    end

    it 'is unlinked with no track to its sea zone' do
      expect(north_africa).to be(false)
    end

    it 'is linked when a city has track to a port arrow on the same sea zone' do
      malaga_stub!

      expect(north_africa).to be(true)
    end

    it 'is linked when a city connects through a town to a port arrow on the same sea zone' do
      lay_code!('AC8', 'city=revenue:20;path=a:1,b:_0')
      lay_code!('AC6', double_town_code(4, 1))

      expect(north_africa).to be(true)
    end

    it 'is unlinked when only the town has track to the port and no city connects' do
      lay_code!('AC6', double_town_code(4, 1))

      expect(north_africa).to be(false)
    end

    context 'with an offshore port on the same sea zone' do
      before do
        original = game.method(:port_sea_zone)
        allow(game).to receive(:port_sea_zone) do |hex_id, exit|
          hex_id == 'Z1' && exit == :offshore ? 'Strait of Gibraltar' : original.call(hex_id, exit)
        end
      end

      it 'does not count the port of a city with no track' do
        lay_code!('Z1', 'city=revenue:20')

        expect(north_africa).to be(false)
      end

      it 'counts the port of a city that has track' do
        expect(north_africa).to be(true)
      end
    end

    it 'is unlinked when the only port arrow is on another sea zone' do
      lay_code!('Z27', 'city=revenue:20;path=a:4,b:_0')

      expect(north_africa).to be(false)
    end
  end
end
