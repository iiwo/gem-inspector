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
            outdated: true,
            currency_score: 80,
            lag_months: 2
          },
          {
            gem_name: 'nokogiri',
            locked_version: '1.10.10',
            locked_release_date: '2020-01-01',
            latest_version: '1.12.5',
            latest_release_date: '2021-09-01',
            actively_maintained: true,
            outdated: true,
            currency_score: 30,
            lag_months: 20
          }
        ]
      end

      it 'creates a CSV file with the correct headers and data' do
        exporter.export(data, output_file)

        csv_content = CSV.read(output_file, headers: true)
        expect(csv_content.headers).to eq(['Gem Name', 'Locked Version', 'Locked Release Date', 'Latest Version', 
                                           'Latest Release Date', 'Actively Maintained', 'Outdated', 'Currency Score', 'Lag (months)'])
        expect(csv_content.size).to eq(2)

        expect(csv_content[0]['Gem Name']).to eq('rails')
        expect(csv_content[0]['Locked Version']).to eq('6.1.4')
        expect(csv_content[0]['Locked Release Date']).to eq('2021-07-12')
        expect(csv_content[0]['Latest Version']).to eq('6.1.5')
        expect(csv_content[0]['Latest Release Date']).to eq('2021-09-15')
        expect(csv_content[0]['Actively Maintained']).to eq('yes')
        expect(csv_content[0]['Outdated']).to eq('yes')
        expect(csv_content[0]['Currency Score']).to eq('80')
        expect(csv_content[0]['Lag (months)']).to eq('2')

        expect(csv_content[1]['Gem Name']).to eq('nokogiri')
        expect(csv_content[1]['Locked Version']).to eq('1.10.10')
        expect(csv_content[1]['Locked Release Date']).to eq('2020-01-01')
        expect(csv_content[1]['Latest Version']).to eq('1.12.5')
        expect(csv_content[1]['Latest Release Date']).to eq('2021-09-01')
        expect(csv_content[1]['Actively Maintained']).to eq('yes')
        expect(csv_content[1]['Outdated']).to eq('yes')
        expect(csv_content[1]['Currency Score']).to eq('30')
        expect(csv_content[1]['Lag (months)']). to eq('20')
      end
      
      context 'with metrics data' do
        let(:metrics) do
          {
            total_gems: 2,
            outdated_gems: 2,
            outdated_gems_ratio: 100.0,
            gem_currency_score: 55.0
          }
        end
        
        it 'includes metrics summary at the top of the CSV' do
          exporter.export(data, output_file, metrics)
          
          # Read the file as a plain CSV
          rows = CSV.read(output_file)
          
          # Check metrics summary section
          expect(rows[0][0]).to eq('Gem Metrics Summary')
          expect(rows[1][0]).to eq('Total Gems')
          expect(rows[1][1]).to eq('2')
          expect(rows[2][0]).to eq('Outdated Gems')
          expect(rows[2][1]).to eq('2')
          expect(rows[3][0]).to eq('Outdated Gems Ratio (%)')
          expect(rows[3][1]).to eq('100.0')
          expect(rows[4][0]).to eq('Overall Gem Currency Score')
          expect(rows[4][1]).to eq('55.0')
          expect(rows[5]).to be_empty # Empty separator row
          
          # Check that the data is still there after the metrics
          # The headers should be on row 6 now
          expect(rows[6]).to include('Gem Name', 'Currency Score', 'Lag (months)')
          
          # First gem data should be on row 7
          expect(rows[7][0]).to eq('rails')
          expect(rows[7][7]).to eq('80') # Currency Score column
        end
      end
    end

    context 'when given empty data' do
      it 'creates a CSV file with only headers' do
        exporter.export([], output_file)

        csv_content = CSV.read(output_file, headers: true)
        expect(csv_content.size).to eq(0)
      end
    end
    
    context 'when data contains errors' do
      let(:data_with_errors) do
        [
          {
            gem_name: 'rails',
            locked_version: '6.1.4',
            latest_version: '7.0.0',
            actively_maintained: true,
            outdated: true,
            currency_score: 80,
            lag_months: 2
          },
          {
            gem_name: 'bad_gem',
            locked_version: '1.0.0',
            error: "Failed to fetch data"
          }
        ]
      end
      
      it 'skips entries with errors' do
        exporter.export(data_with_errors, output_file)
        
        csv_content = CSV.read(output_file, headers: true)
        expect(csv_content.size).to eq(1) # Only one valid entry
        expect(csv_content[0]['Gem Name']).to eq('rails')
      end
    end
  end
end