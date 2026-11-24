# frozen_string_literal: true

require './spec/spec_helper'

module Engine
  module Part
    describe RevenueCenter do
      subject { RevenueCenter.new('0') }

      describe '#parse_revenue' do
        it 'parses an integer' do
          expect(subject.parse_revenue('20')).to eq(
            yellow: 20,
            green: 20,
            brown: 20,
            gray: 20,
            diesel: 20,
          )
        end

        it 'parses revenue for different colors and diesels' do
          actual = subject.parse_revenue('yellow_20|brown_40|diesel_80')
          expected = { yellow: 20, brown: 40, diesel: 80 }

          expect(actual).to eq(expected)
        end

        it 'parses revenue for all different colors' do
          actual = subject.parse_revenue('yellow_30|green_40|brown_50|gray_70')
          expected = { yellow: 30, green: 40, brown: 50, gray: 70 }

          expect(actual).to eq(expected)
        end

        it 'parses revenue keyed by grouped phase names, with box styles' do
          actual = subject.parse_revenue('I/II_10+yellow+green|III_30+#98ff98|V_0')
          expected_styles = [
            { phase: :I, label: 'I/II', colors: %i[yellow green] },
            { phase: :III, label: 'III', colors: ['#98ff98'] },
          ]

          expect(actual).to eq(I: 10, II: 10, III: 30, V: 0)
          expect(subject.revenue_to_render).to eq(I: 10, III: 30, V: 0)
          expect(subject.phase_styles).to eq(expected_styles)
        end

        it 'has no box styles when no colors are given' do
          subject.parse_revenue('I_10|II_20')
          expect(subject.phase_styles).to be_nil
        end
      end

      describe '#route_base_revenue' do
        let(:train) { double(name: '4') }
        let(:diesel) { double(name: 'D') }

        def phase(name, tiles = %i[yellow green])
          double(name: name, tiles: tiles)
        end

        it 'uses the latest available tile color for color-keyed revenue' do
          subject.parse_revenue('brown_20|gray_90')
          expect(subject.route_base_revenue(phase('3'), train)).to eq(0)
          expect(subject.route_base_revenue(phase('5', %i[yellow green brown]), train)).to eq(20)
        end

        it 'uses the phase name for phase-keyed revenue' do
          subject.parse_revenue('I/II_10|III_30|diesel_50')
          expect(subject.route_base_revenue(phase('II'), train)).to eq(10)
          expect(subject.route_base_revenue(phase('III'), train)).to eq(30)
          expect(subject.route_base_revenue(phase('III'), diesel)).to eq(50)
        end

        it 'raises when phase-keyed revenue does not cover the phase' do
          subject.parse_revenue('I_10|III_30')
          expect { subject.route_base_revenue(phase('II'), train) }.to raise_error(GameError, /phase II/)
        end
      end
    end
  end
end
