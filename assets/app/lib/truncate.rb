# frozen_string_literal: true

# https://apidock.com/rails/String/truncate

class String
  def truncate(truncate_at = 15, options = {})
    return dup unless length > truncate_at

    omission = options[:omission] || '...'
    length_with_room_for_omission = truncate_at - omission.length
    stop = if options[:separator]
             rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
           else
             length_with_room_for_omission
           end

    "#{self[0, stop]}#{omission}"
  end
end
