# frozen_string_literal: true

require 'time'

print DateTime.strptime(ARGV[0], '%Y-%m-%d_%H.%M.%S').strftime('%s')
