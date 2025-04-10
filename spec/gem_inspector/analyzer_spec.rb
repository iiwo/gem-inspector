require 'gem_inspector/analyzer'
require 'webmock/rspec'
require 'date'

RSpec.describe GemInspector::Analyzer do
  let(:analyzer) { described_class.new }
  let(:rubygems_client) { instance_double('GemInspector::RubygemsClient') }

  before do
    allow(GemInspector::RubygemsClient).to receive(:new).and_return(rubygems_client)
  end

  describe '#analyze' do
    context 'when given valid gems hash' do
      let(:gems) do
        {
          'rails' => '6.1.4',
          'nokogiri' => '1.12.5'
        }
      end

      # Use a recent date that is within the active threshold (default 24 months)
      let(:recent_date) { (Date.today - 365).iso8601 } # 1 year ago
      
      let(:rails_data) do
        {
          locked_version_data: { "number" => "6.1.4", "built_at" => "2021-06-24" },
          latest_version: { "number" => "7.0.0", "built_at" => recent_date }
        }
      end

      let(:nokogiri_data) do
        {
          locked_version_data: { "number" => "1.12.5", "built_at" => "2021-09-01" },
          latest_version: { "number" => "1.12.5", "built_at" => recent_date }
        }
      end

      before do
        allow(rubygems_client).to receive(:get_gem_data).with('rails', '6.1.4').and_return(rails_data)
        allow(rubygems_client).to receive(:get_gem_data).with('nokogiri', '1.12.5').and_return(nokogiri_data)
      end

      it 'returns an array of analyzed gem data' do
        result = analyzer.analyze(gems)
        
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        
        # Rails should be outdated and actively maintained
        rails_result = result.find { |r| r[:gem_name] == 'rails' }
        expect(rails_result[:locked_version]).to eq('6.1.4')
        expect(rails_result[:latest_version]).to eq('7.0.0')
        expect(rails_result[:outdated]).to be true
        expect(rails_result[:actively_maintained]).to be true
        
        # Nokogiri should not be outdated but still actively maintained
        nokogiri_result = result.find { |r| r[:gem_name] == 'nokogiri' }
        expect(nokogiri_result[:locked_version]).to eq('1.12.5')
        expect(nokogiri_result[:latest_version]).to eq('1.12.5')
        expect(nokogiri_result[:outdated]).to be false
        expect(nokogiri_result[:actively_maintained]).to be true
      end
    end

    context 'when an error occurs with a gem' do
      let(:gems) do
        {
          'rails' => '6.1.4',
          'bad_gem' => '1.0.0'
        }
      end

      # Use a recent date that is within the active threshold (default 24 months)
      let(:recent_date) { (Date.today - 365).iso8601 } # 1 year ago

      before do
        allow(rubygems_client).to receive(:get_gem_data).with('rails', '6.1.4').and_return({
          locked_version_data: { "number" => "6.1.4", "built_at" => "2021-06-24" },
          latest_version: { "number" => "7.0.0", "built_at" => recent_date }
        })
        allow(rubygems_client).to receive(:get_gem_data).with('bad_gem', '1.0.0')
          .and_raise(GemInspector::Error, "Failed to fetch versions for bad_gem")
      end

      it 'includes the error in the result for that gem but continues processing' do
        allow(analyzer).to receive(:warn) # Suppress warning output in test

        result = analyzer.analyze(gems)
        
        expect(result.size).to eq(2)
        
        # Rails should be processed normally
        rails_result = result.find { |r| r[:gem_name] == 'rails' }
        expect(rails_result[:locked_version]).to eq('6.1.4')
        
        # bad_gem should have error info
        bad_gem_result = result.find { |r| r[:gem_name] == 'bad_gem' }
        expect(bad_gem_result[:locked_version]).to eq('1.0.0')
        expect(bad_gem_result[:error]).to eq("Failed to fetch versions for bad_gem")
      end
    end
  end
end