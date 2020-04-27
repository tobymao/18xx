# frozen_string_literal: true

require 'json'

data = JSON.parse(File.open('/Users/toby/Desktop/g_1889.json'))

hexes = data['map']['hexes'].flat_map do |hex|
  hex['hexes']
end

hexes.sort_by! { |c| [c[0], c[1..-1].to_i] }

puts hexes.to_s
