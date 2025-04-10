require 'csv'
require 'gem_inspector/csv_exporter'

RSpec.describe GemInspector::CsvExporter do
  let(:output_file) { 'spec/fixtures/test_output.csv' }
  let(:exporter) { GemInspector::CsvExporter.new }

  describe '#export' do
    context 'when given valid data' do
      let(:data) do
        [
          {
            gem_name: 'rails',
            locked_version: '6.1.4',
            locked_release_date: '2021-07-12',
            latest_version: '6.1.5',
            latest_release_date: '2021-09-15',
            actively_maintained: true,
            outdated: true
          },
          {
            gem_name: 'nokogiri',
            locked_version: '1.10.10',
            locked_release_date: '2020-01-01',
            latest_version: '1.12.5',
            latest_release_date: '2021-09-01',
            actively_maintained: true,
            outdated: true
          }
        ]
      end

      it 'creates a CSV file with the correct headers and data' do
        exporter.export(data, output_file)

        csv_content = CSV.read(output_file, headers: true)
        expect(csv_content.headers).to eq(['Gem Name', 'Locked Version', 'Locked Release Date', 'Latest Version', 'Latest Release Date', 'Actively Maintained', 'Outdated'])
        expect(csv_content.size).to eq(2)

        expect(csv_content[0]['Gem Name']).to eq('rails')
        expect(csv_content[0]['Locked Version']).to eq('6.1.4')
        expect(csv_content[0]['Locked Release Date']).to eq('2021-07-12')
        expect(csv_content[0]['Latest Version']).to eq('6.1.5')
        expect(csv_content[0]['Latest Release Date']).to eq('2021-09-15')
        expect(csv_content[0]['Actively Maintained']).to eq('yes')
        expect(csv_content[0]['Outdated']).to eq('yes')

        expect(csv_content[1]['Gem Name']).to eq('nokogiri')
        expect(csv_content[1]['Locked Version']).to eq('1.10.10')
        expect(csv_content[1]['Locked Release Date']).to eq('2020-01-01')
        expect(csv_content[1]['Latest Version']).to eq('1.12.5')
        expect(csv_content[1]['Latest Release Date']).to eq('2021-09-01')
        expect(csv_content[1]['Actively Maintained']).to eq('yes')
        expect(csv_content[1]['Outdated']).to eq('yes')
      end
    end

    context 'when given empty data' do
      it 'creates a CSV file with only headers' do
        exporter.export([], output_file)

        csv_content = CSV.read(output_file, headers: true)
        expect(csv_content.size).to eq(0)
      end
    end
  end
end