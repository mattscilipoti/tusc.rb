class String
  def truncate(maximum_length, omission: '…', mode: :right)
    case mode
    when :right, 'right'
      truncate_right(maximum_length, omission: omission)
    when :middle, 'middle'
      truncate_middle(maximum_length, omission)
    else
      raise ArgumentError, "Unsupported mode (#{mode}), expected [:middle, :right]."
    end
  end

  # File activesupport/lib/active_support/core_ext/string/filters.rb, line 66
  def truncate_right(truncate_at, options = {})
    return dup unless length > truncate_at

    omission = options[:omission] || '…'
    length_with_room_for_omission = truncate_at - omission.length
    stop = if options[:separator]
             rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
           else
             length_with_room_for_omission
      end

    +"#{self[0, stop]}#{omission}"
  end

  # Truncates the middle, leaving portions from start & end
  # see https://stackoverflow.com/a/62713671
  def truncate_middle(maximum_length = 3, separator = '…')
    return '' if maximum_length.zero?
    return self if length <= maximum_length

    middle_length = length - maximum_length + separator.length
    edges_length = (length - middle_length) / 2.0
    left_length = edges_length.ceil
    right_length = edges_length.floor

    left_string = left_length.zero? ? '' : self[0, left_length]
    right_string = right_length.zero? ? '' : self[-right_length, right_length]

    "#{left_string}#{separator}#{right_string}"
  end
end
