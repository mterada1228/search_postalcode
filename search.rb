require './postalcode_searcher.rb'

if (ARGV.length == 4)
  PostalcodeSearcher.new(
    search_address:     ARGV[0],
    index_filepath:     ARGV[1],
    addresses_filepath: ARGV[2],
    output_filepath:    ARGV[3]
  ).search
else
  PostalcodeSearcher.new(
    search_address:     ARGV[0],
    index_filepath:     ARGV[1],
    addresses_filepath: ARGV[2]
  ).search
end
