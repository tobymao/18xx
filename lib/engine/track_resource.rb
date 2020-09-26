# frozen_string_literal: true

module Engine
  # Any TrackResource can occur only once in the paths ofn a
  # corporation's routes.
  class TrackResource
    attr_reader :hex, :edge_num, :lane

    def initialize(hex, edge_num, lane = nil)
      @hex = hex
      @edge_num = edge_num
      @lane = lane
    end

    def name
      @hex.id
    end

    def eql?(other)
      @hex == other.hex && @edge_num == other.edge_num && @lane == other.lane
    end

    def hash
      [@hex, @edge_num, @lane].hash
    end
  end
end
