
require_relative '../postalcode_searcher.rb'

RSpec.describe PostalcodeSearcher do
  let(:index_filepath) { 'spec/tmp/index.csv' }
  let(:addresses_filepath) { 'spec/tmp/addresses.csv' }
  let(:output_filepath) { 'spec/tmp/output.csv' }

  before do
    CSV.open(index_filepath, "w") do |csv|
      index_file_rows.each do |row|
        csv << row
      end
    end

    CSV.open(addresses_filepath, "w") do |csv|
      addresses_file_rows.each do |row|
        csv << row
      end
    end
  end

  after do
    File.delete(index_filepath)
    File.delete(addresses_filepath)
    File.delete(output_filepath)
  end

  subject do
    described_class.new(
      search_address: search_address,
      index_filepath: index_filepath,
      addresses_filepath: addresses_filepath,
      output_filepath: output_filepath).search
  end

  context '検索ワードに空白が含まれる場合' do
    let(:index_file_rows) do
      [
        ['東京', '0'],
        ['京都', '0'],
        ['都世', '0'],
        ['世田', '0'],
        ['田谷', '0'],
        ['谷区', '0'],
      ]
    end
    let(:addresses_file_rows) do 
      [
        ['', '', '123456', '', '', '', '', '東京都世田谷区', '']
      ]
    end
    let(:search_address) { '東京都 世田谷区' }

    it '空白が除外された検索ワードに一致する検索結果が得られる' do
      subject
      expect(CSV.read(output_filepath)).to eq(
        [
          ['123456', '', '東京都世田谷区', ''],
        ]
      )
    end
  end

  context '検索ワードの長さが偶数で、2文字ずつのワードに区切れる場合' do
    let(:index_file_rows) do
      [
        ['東京', '0'],
        ['京都', '0'],
        ['都江', '0'],
        ['江東', '0'],
        ['東区', '0'],
      ]
    end
    let(:addresses_file_rows) do 
      [
        ['', '', '987654', '', '', '', '', '東京都江東区', '']
      ]
    end
    let(:search_address) { '東京都江東区' }

    it '検索ワードに一致する検索結果が得られる' do
      subject
      expect(CSV.read(output_filepath)).to eq(
        [
          ['987654', '', '東京都江東区', ''],
        ]
      )
    end
  end

  context '検索ワードの長さが奇数で、2文字ずつのワードに区切れない場合' do
    let(:index_file_rows) do
      [
        ['東京', '0'],
        ['京都', '0'],
        ['都世', '0'],
        ['世田', '0'],
        ['田谷', '0'],
        ['谷区', '0'],
      ]
    end
    let(:addresses_file_rows) do 
      [
        ['', '', '123456', '', '', '', '', '東京都世田谷区', '']
      ]
    end
    let(:search_address) { '東京都世田谷区' }

    it '検索ワードに一致する検索結果が得られる' do
      subject
      expect(CSV.read(output_filepath)).to eq(
        [
          ['123456', '', '東京都世田谷区', ''],
        ]
      )
    end
  end

  context '検索ワードに一致しない場合' do
    let(:index_file_rows) do
      [
        ['東京', '0'],
        ['京都', '0'],
        ['都世', '0'],
        ['世田', '0'],
        ['田谷', '0'],
        ['谷区', '0'],
      ]
    end
    let(:addresses_file_rows) do 
      [
        ['', '', '123456', '', '', '', '', '東京都世田谷区', '']
      ]
    end
    let(:search_address) { '東京都豊島区' }

    it '検索結果が得られない' do
      subject
      expect(CSV.read(output_filepath)).to eq([])
    end
  end

  context '検索ワードを部分的に含む場合' do
    let(:index_file_rows) do
      [
        ['東京', '0', '1'],
        ['京都', '0', '1'],
        ['都世', '0'],
        ['世田', '0'],
        ['田谷', '0'],
        ['谷区', '0'],
        ['都江', '1'],
        ['江東', '1'],
        ['東区', '1'],
      ]
    end
    let(:addresses_file_rows) do 
      [
        ['', '', '123456', '', '', '', '', '東京都世田谷区', ''],
        ['', '', '987654', '', '', '', '', '東京都江東区', '']
      ]
    end
    let(:search_address) { '東京都' }

    it '検索ワードを部分的に含む検索結果が得られる' do
      subject
      expect(CSV.read(output_filepath)).to eq(
        [
          ['123456', '', '東京都世田谷区', ''],
          ['987654', '', '東京都江東区', ''],
        ]
      )
    end
  end

  context '検索ワードが空文字の場合' do
    let(:index_file_rows) do
      [
        ['東京', '0'],
        ['京都', '0'],
        ['都世', '0'],
        ['世田', '0'],
        ['田谷', '0'],
        ['谷区', '0'],
      ]
    end
    let(:addresses_file_rows) do 
      [
        ['', '', '123456', '', '', '', '', '東京都世田谷区', '']
      ]
    end
    let(:search_address) { '' }

    it '検索結果が得られない' do
      subject
      expect(CSV.read(output_filepath)).to eq([])
    end
  end

  context '検索ワードを含む郵便番号が複数ある場合' do
    let(:index_file_rows) do
      [
        ['aa', '0'],
        ['bb', '1'],
        ['cc', '2'],
      ]
    end
    let(:addresses_file_rows) do 
      [
        ['', '', '123456', '', '', '', '', 'aa', ''],
        ['', '', '123456', '', '', '', '', 'bb', ''],
        ['', '', '987654', '', '', '', '', 'cc', '']
      ]
    end
    let(:search_address) { 'bb' }

    it '郵便番号が重複するレコードは結合されて出力される' do
      subject
      expect(CSV.read(output_filepath)).to eq([
        ['123456', '', 'aa', '', '', 'bb', '']
      ])
    end
  end
end
