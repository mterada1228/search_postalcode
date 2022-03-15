require './postalcode_searcher.rb'

PostalcodeSearcher.new(
  search_address:     ARGV[0],
  index_filepath:     ARGV[1],
  addresses_filepath: ARGV[2],
).search
