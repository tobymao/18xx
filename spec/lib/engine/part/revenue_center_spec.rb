# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/part/revenue_center'

class DummyClass
  include Engine::Part::RevenueCenter
end

module Engine
  module Part
    describe RevenueCenter do
      subject { DummyClass.new }

      describe '#parse_revenue' do
        it 'parses an integer' do
          actual = subject.parse_revenue('20')
          expected = 20

          expect(actual).to eq(expected)
        end

        it 'parses a slash-separated list of revenues' do
          actual = subject.parse_revenue('20/30/40')
          expected = [20, 30, 40]

          expect(actual).to eq(expected)
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
      end
    end
  end
end
