require "csv"

class IndexFileCreator
  ADDRESS_COLUMN_NUMBERS = {
    PREFECTURE_KANA_COLUMN_NUMBER:   3,
    MUNICIPALITY_KANA_COLUMN_NUMBER: 4,
    STREET_KANA_COLUMN_NUMBER:       5,
    PREFECTURE_COLUMN_NUMBER:        6,
    MUNICIPALITY_COLUMN_NUMBER:      7,
    STREET_COLUMN_NUMBER:            8
  }.freeze

  def initialize(input_filepath:, output_filepath:)
    @input_filepath = input_filepath
    @output_filepath = output_filepath
    @indexes_hash = Hash.new { |hash, key| hash[key] = [] }
  end

  def create
    CSV.read(@input_filepath).each_with_index do |line, index|
      read_line(line, index)
    end

    write(@indexes_hash)
  end

  private

  def read_line(line, index)
    ADDRESS_COLUMN_NUMBERS.values.each do |column_number|
      column = line[column_number]
      make_hash(column, index)
    end
  end

  def make_hash(column, index)
    column.each_char.each_cons(2).each do |chars|
      @indexes_hash[chars.join].append(index)
    end
  end

  def write(hash)
    CSV.open(@output_filepath, 'w') do |file|
      hash.each do |word, indexes|
        file << indexes.unshift(word)
      end
    end
  end
end
