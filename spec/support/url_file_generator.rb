# frozen_string_literal: true

class UrlFileGenerator
  def initialize(noun_file:, adj_file:, base_url:)
    @noun_file = noun_file
    @adj_file = adj_file

    @base_url = base_url
  end

  # Specify number of lines for the file.
  # Half the lines will be randomly-generated searches; half will be
  # blank searches.
  # Siege selects randomly from the file if invoked with the -i option.
  def write_url_file(lines: 1_000_000)
    half = lines / 2
    File.open(OUTFILE, 'w') do |f|
      half.times do
        f.write generate_url
        f.write "\n"
      end
      half.times do
        f.write blank_search_url
        f.write "\n"
      end
    end
  end

  def generate(lines: 10)
    output = []

    lines.times do
      output << "#{generate_url}\n"
    end

    output
  end

  def blank_search_url
    "#{@base_url}/catalog?utf8=%E2%9C%93&search_field=all_fields&q="
  end

  def generate_url
    "#{@base_url}/catalog?utf8=%E2%9C%93&search_field=all_fields&q=#{random_query}"
  end

  # returns an array of 1 or 2 nouns
  def nouns
    sample = random.rand(1..2)
    noun_dict.sample(sample).map(&:chomp)
  end

  def phrase
    adj_switch = [true, false].sample
    return adjective + nouns if adj_switch

    nouns
  end

  # provide a 1 to 3 word random adjective / noun phrase, joined by `+`
  def random_query
    phrase.join("+")
  end

  # returns an array of 1 adjective
  def adjective
    [adj_dict.sample.chomp]
  end

  def noun_dict
    @noun_dict ||= File.readlines(@noun_file)
  end

  def adj_dict
    @adj_dict ||= File.readlines(@adj_file)
  end

  def random
    @random ||= Random.new
  end
end
