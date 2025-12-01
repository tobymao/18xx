# frozen_string_literal: true

require 'rspec'

RSpec::Matchers.define :be_assigned_to do |expected|
  match do |actual|
    expected.assigned?(actual.id)
  end
end

RSpec::Matchers.define :have_available_hexes do |expected|
  match do |game|
    available = game.hexes.select do |hex|
      game.active_step.available_hex(game.current_entity, hex)
    end
    @actual = available.map(&:id).sort
    @expected = expected.sort
    values_match? @expected, @actual
  end

  failure_message do |actual|
    "expected game's available hexes #{actual} would be #{@expected}"
  end
end
