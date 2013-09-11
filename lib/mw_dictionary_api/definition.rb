module MWDictionaryAPI
  class Definition

    attr_reader :sense_number, :verbal_illustration, :cross_reference, :text, :api_type

    def initialize(dt: nil, sn: "1", prev_sn: nil, api_type: "sd4")
      @dt = dt
      @api_type = api_type
      
      @sense_number = construct_sense_number(sn, prev_sn)

      @verbal_illustration = @dt.at_css("vi").content if @dt.at_css("vi")

      @cross_reference = []
      @dt.xpath("sx").each do |sx|
        @cross_reference << sx.content
      end

      dt_without_vi = @dt.dup
      dt_without_vi.css("vi").remove
      @text = dt_without_vi.content.strip
    end

    def to_hash
      {
        "sense_number" => @sense_number,
        "cross_reference" => @cross_reference,
        "verbal_illustration" => @verbal_illustration,
        "text" => text
      }
    end

    def construct_sense_number(current_sn, previous_sn)
      current_sn = current_sn.gsub(" ", "")

      return current_sn if previous_sn.nil?

      if current_sn =~ /^\d+/ # starts with a digit
        current_sn
      elsif current_sn =~ /^[a-z]+/ # starts with a alphabet
        m = /^(\d+)/.match(previous_sn)
        (m) ? m[1] + current_sn : current_sn
      else # starts with a bracket ( e.g. (1)
        m = /^(\d+)*([a-z]+)*/.match(previous_sn)
        m[1..2].select { |segment| !segment.nil? }.join("") + current_sn
      end
    end

  end
end
