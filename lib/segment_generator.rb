# Class for grouping the messages delimiter
class HL7::Message::Delimiter
  attr_accessor :item, :element

  def initialize(element_delim, item_delim, segment_delim)
    @element = element_delim
    @item = item_delim
    @segment = segment_delim
  end
end

# Methods for creating segments in Message
class HL7::Message::SegmentGenerator

  attr_reader :element, :last_seg
  attr_reader :delimiter

  attr_accessor :seg_parts, :seg_name

  def initialize(element, last_seg, delimiter)
    @element = element
    @last_seg = last_seg
    @delimiter = delimiter

    @seg_parts = HL7::MessageParser.split_by_delimiter( element,
                                                        delimiter.element )
  end

  def get_symbol_from_name
    seg_name.to_s.strip.length > 0 ? seg_name.to_sym : nil
  end

  def valid_segments_parts?
    return true if seg_parts && seg_parts.length > 0

    if HL7.ParserConfig[:empty_segment_is_error]
      text_error = "empty segment is an error per configuration setting"
      raise HL7::ParseError.new(text_error)
    else
      return false
    end
  end

  def build
    klass = get_segment_class
    new_seg = klass.new( element, [delimiter.element, delimiter.item] )
    new_seg
  end

  def get_segment_class
    segment_to_search = @seg_name.to_sym
    segment_to_search = @seg_name if RUBY_VERSION < "1.9"

    if HL7::Message::Segment.constants.index(segment_to_search)
      eval("HL7::Message::Segment::%s" % @seg_name)
    else
      HL7::Message::Segment::Default
    end
  end
end