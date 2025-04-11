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
        expect(rails_result[:currency_score]).to be_a(Integer)
        expect(rails_result[:lag_months]).to be_a(Integer)
        
        # Nokogiri should not be outdated but still actively maintained
        nokogiri_result = result.find { |r| r[:gem_name] == 'nokogiri' }
        expect(nokogiri_result[:locked_version]).to eq('1.12.5')
        expect(nokogiri_result[:latest_version]).to eq('1.12.5')
        expect(nokogiri_result[:outdated]).to be false
        expect(nokogiri_result[:actively_maintained]).to be true
        expect(nokogiri_result[:currency_score]).to eq(100) # Should be 100 as it's up to date
        expect(nokogiri_result[:lag_months]).to eq(0) # Should be 0 as it's up to date
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
  
  describe '#calculate_metrics' do
    let(:results) do
      [
        {
          gem_name: 'rails',
          locked_version: '6.1.4',
          latest_version: '7.0.0',
          outdated: true,
          currency_score: 70,
          lag_months: 7
        },
        {
          gem_name: 'nokogiri',
          locked_version: '1.12.5',
          latest_version: '1.12.5',
          outdated: false,
          currency_score: 100,
          lag_months: 0
        },
        {
          gem_name: 'very_outdated',
          locked_version: '1.0.0',
          latest_version: '5.0.0',
          outdated: true,
          currency_score: 0,
          lag_months: 36
        }
      ]
    end
    
    it 'calculates the aggregate metrics correctly' do
      metrics = analyzer.calculate_metrics(results)
      
      expect(metrics[:total_gems]).to eq(3)
      expect(metrics[:outdated_gems]).to eq(2)
      expect(metrics[:outdated_gems_ratio]).to eq(66.67) # 2/3 gems are outdated
      expect(metrics[:gem_currency_score]).to eq(56.67) # Restored the original expectation with full precision
    end
    
    context 'when some results contain errors' do
      let(:results_with_errors) do
        [
          {
            gem_name: 'rails',
            locked_version: '6.1.4',
            latest_version: '7.0.0',
            outdated: true,
            currency_score: 70,
            lag_months: 7
          },
          {
            gem_name: 'bad_gem',
            locked_version: '1.0.0',
            error: "Failed to fetch versions for bad_gem"
          }
        ]
      end
      
      it 'filters out errors when calculating metrics' do
        metrics = analyzer.calculate_metrics(results_with_errors)
        
        expect(metrics[:total_gems]).to eq(1)
        expect(metrics[:outdated_gems]).to eq(1)
        expect(metrics[:outdated_gems_ratio]).to eq(100.0) # 1/1 gems are outdated
        expect(metrics[:gem_currency_score]). to eq(70.0) # Only one valid gem with score 70
      end
    end
    
    context 'when there are no valid results' do
      let(:empty_results) { [] }
      let(:error_only_results) do
        [
          {
            gem_name: 'bad_gem',
            locked_version: '1.0.0',
            error: "Failed to fetch versions for bad_gem"
          }
        ]
      end
      
      it 'returns an empty metrics object for empty results' do
        metrics = analyzer.calculate_metrics(empty_results)
        expect(metrics).to eq({})
      end
      
      it 'returns an empty metrics object for results with only errors' do
        metrics = analyzer.calculate_metrics(error_only_results)
        expect(metrics).to eq({})
      end
    end

    it 'returns metrics in JSON format' do
      results = [
        { gem_name: 'rails', locked_version: '6.1.4', latest_version: '7.0.0', actively_maintained: true, outdated: true, currency_score: 75, lag_months: 6 },
        { gem_name: 'nokogiri', locked_version: '1.12.5', latest_version: '1.13.0', actively_maintained: true, outdated: true, currency_score: 90, lag_months: 2 }
      ]

      metrics = analyzer.calculate_metrics(results).to_json
      expect(metrics).to eq({
        total_gems: 2,
        outdated_gems: 2,
        outdated_gems_ratio: 100.0,
        gem_currency_score: 82.5
      }.to_json)
    end
  end
  
  describe '#calculate_currency_score' do
    it 'returns 100 for up-to-date gems' do
      locked_version = '1.0.0'
      latest_version = '1.0.0'
      score = analyzer.send(:calculate_currency_score, Date.today - 120, Date.today - 120, locked_version, latest_version)
      expect(score).to eq(100)
    end
    
    it 'returns 100 when locked version is higher than latest' do
      locked_version = '1.1.0'
      latest_version = '1.0.0'
      score = analyzer.send(:calculate_currency_score, Date.today - 120, Date.today - 150, locked_version, latest_version)
      expect(score).to eq(100)
    end
    
    it 'returns 0 when lag exceeds max lag threshold' do
      # Default max lag is 24 months
      locked_date = Date.today - (25 * 30) # 25 months ago
      latest_date = Date.today
      score = analyzer.send(:calculate_currency_score, locked_date, latest_date, '1.0.0', '2.0.0')
      expect(score).to eq(0)
    end
    
    it 'returns proportional score based on lag' do
      # 12 months lag with 24 months max should give 50 points
      locked_date = Date.today - (12 * 30) # 12 months ago
      latest_date = Date.today
      score = analyzer.send(:calculate_currency_score, locked_date, latest_date, '1.0.0', '2.0.0')
      expect(score).to eq(50)
    end
    
    it 'handles missing release dates gracefully' do
      score = analyzer.send(:calculate_currency_score, nil, Date.today, '1.0.0', '2.0.0')
      expect(score).to eq(100)
    end
  end
end