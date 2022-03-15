require_relative '../index_file_creator.rb'

RSpec.describe IndexFileCreator do
  let(:input_filepath) { 'tmp/input.csv' }
  let(:output_filepath) { 'tmp/output.csv' }
  let(:rows) do
    [
      ['', '', '', '', '', '', '', '東京都世田谷区', ''],
      ['', '', '', '', '', '', '', '東京都江東区', ''],
    ]
  end

  before do
    CSV.open(input_filepath, "w") do |csv|
      rows.each do |row|
        csv << row
      end
    end
  end

  after do
    File.delete(input_filepath)
    File.delete(output_filepath)
  end

  subject do
    described_class.new(
      input_filepath: input_filepath,
      output_filepath: output_filepath).create
  end

  it 'bi-gram アルゴリズムを用いた、住所レコードのインデックスファイルが作成される' do
    subject
    expect(CSV.read(output_filepath)).to eq(
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
    )
  end
end
