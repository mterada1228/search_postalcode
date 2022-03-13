require "./index_file_creator.rb"

IndexFileCreator.new(input_filepath: ARGV[0], output_filepath: ARGV[1]).create
