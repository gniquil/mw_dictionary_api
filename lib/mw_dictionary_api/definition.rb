module MWDictionaryAPI
  class Definition

    attr_reader :entry, :sense_number, :verbal_illustration, :cross_reference, :text

    def initialize(dt: nil, sn: "1", prev_sn: nil)
      @dt = dt
      
      # prev_definition = entry.definitions[-1]
      @sense_number = construct_sense_number(sn, prev_sn)

      @verbal_illustration = (@dt.at_css("vi").nil?) ? nil : @dt.at_css("vi").content

      @cross_reference = []
      @dt.css("sx").each do |sx|
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
      if previous_sn.nil?
        current_sn.gsub(" ", "")
      else
        if current_sn =~ /^\d+/
          current_sn.gsub(" ", "")
        elsif current_sn =~ /^\(\d+\)/
          if previous_sn =~ /\(\d+\)$/
            previous_sn.gsub(/\(\d+\)$/, "") + current_sn
          else
            previous_sn + current_sn
          end
        else
          if previous_sn =~ /[a-z]+$/
            previous_sn.gsub(/[a-z]+$/, "") + current_sn.gsub(" ", "")
          elsif previous_sn =~ /[a-z]+\(\d+\)$/
            previous_sn.gsub(/[a-z]+\(\d+\)$/, "") + current_sn
          else
            current_sn.gsub(" ", "")
          end
        end
      end
    end
  end
end
