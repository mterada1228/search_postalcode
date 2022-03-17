require 'csv'
require 'set'

class PostalcodeSearcher
  POSTALCODE_INDEX = 0.freeze

  POSTALCODE_COLUMN_NUMBER   = 2.freeze
  PREFECTURE_COLUMN_NUMBER   = 6.freeze
  MUNICIPALITY_COLUMN_NUMBER = 7.freeze
  STREET_COLUMN_NUMBER       = 8.freeze

  def initialize(search_address:,
                 index_filepath:,
                 addresses_filepath:,
                 output_filepath: default_output)
    @address = search_address
    @indexes_hash = indexes_hash(index_filepath)
    @addresses_table = addresses_table(addresses_filepath)
    @output = output_filepath
  end

  def search
    indexes = search_indexes(devide_address(@address))
    print_postalcodes(indexes)
  end

  private

  def devide_address(address)
    address_trimmed_space = address.gsub(' ', '')
    return address_trimmed_space.scan(/\S{2}/) if address_trimmed_space.length.even?

    address_trimmed_space.scan(/\S{2}/).append("#{address_trimmed_space[-2]}#{address_trimmed_space[-1]}")
  end

  def indexes_hash(index_filepath)
    indexes_hash = Hash.new { |hash, key| hash[key] = [] }

    CSV.read(index_filepath).each do |line|
      word = line[0]
      indexes = line.slice(1, line.length - 1)
      indexes_hash[word] = indexes
    end

    indexes_hash
  end

  def addresses_table(addresses_filepath)
    CSV.read(addresses_filepath).map do |line|
      [
        line[POSTALCODE_COLUMN_NUMBER],
        line[PREFECTURE_COLUMN_NUMBER],
        line[MUNICIPALITY_COLUMN_NUMBER],
        line[STREET_COLUMN_NUMBER]
      ]
    end
  end

  def search_indexes(words)
    Set.new(words.map do |word|
      @indexes_hash[word]
    end.inject(:&))
  end

  def print_postalcodes(indexes)
    postalcodes = Set.new(postalcodes(indexes.map(&:to_i)))

    if @output == 'STDOUT'
      postalcodes.each do |postalcode|
        p printed_line(postalcode).join(', ')
      end
    else
      CSV.open(@output, 'w') do |file|
        postalcodes.each do |postalcode|
          file << printed_line(postalcode)
        end
      end
    end
  end

  def postalcodes(indexes)
    indexes.map do |index|
      @addresses_table[index][POSTALCODE_INDEX]
    end
  end

  def printed_line(postalcode)
    postalcode_hash_table[postalcode].flat_map do |addresses|
      addresses[POSTALCODE_INDEX+1..-1]
    end.unshift(postalcode)
  end

  def postalcode_hash_table
    @postalcode_hash_table ||= @addresses_table.group_by { |table| table[POSTALCODE_INDEX] }
  end

  def default_output
    'STDOUT'
  end
end
