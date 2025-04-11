require 'spec_helper'
require 'gem_inspector/cli'
require 'stringio'

RSpec.describe GemInspector::CLI do
  describe '#analyze' do
    let(:cli) { described_class.new }
    let(:parser) { instance_double('GemInspector::GemfileParser') }
    let(:analyzer) { instance_double('GemInspector::Analyzer') }
    let(:exporter) { instance_double('GemInspector::CsvExporter') }
    let(:gems) { { 'rails' => '6.1.4', 'nokogiri' => '1.12.5' } }
    let(:results) { [{ gem_name: 'rails', locked_version: '6.1.4', latest_version: '7.0.0', actively_maintained: true, outdated: true, currency_score: 75, lag_months: 6 }] }
    
    before do
      # Stub out Thor's options
      allow(cli).to receive(:options).and_return({
        input: 'spec/fixtures/Gemfile.lock',
        output: 'report.csv',
        active_threshold: 24,
        max_lag: 24,
        verbose: false,
        metrics: false
      })
      
      # Stub dependencies
      allow(GemInspector::GemfileParser).to receive(:new).and_return(parser)
      allow(GemInspector::Analyzer).to receive(:new).and_return(analyzer)
      allow(GemInspector::CsvExporter).to receive(:new).and_return(exporter)
      
      # Stub method calls
      allow(parser).to receive(:parse).and_return(gems)
      allow(analyzer).to receive(:analyze).with(gems).and_return(results)
      allow(exporter).to receive(:export).with(results, 'report.csv', nil).and_return('report.csv')
      
      # Capture output
      $stdout = StringIO.new unless $stdout.is_a?(StringIO)
      @original_stdout = $stdout
    end
    
    after do
      $stdout = @original_stdout
    end
    
    it 'parses gems, analyzes them, and exports the results' do
      cli.analyze
      
      expect(parser).to have_received(:parse)
      expect(analyzer).to have_received(:analyze).with(gems)
      expect(exporter).to have_received(:export).with(results, 'report.csv', nil)
      expect($stdout.string).to include("Analysis complete!")
    end
    
    context 'with verbose output' do
      before do
        allow(cli).to receive(:options).and_return({
          input: 'spec/fixtures/Gemfile.lock',
          output: 'report.csv',
          active_threshold: 24,
          max_lag: 24,
          verbose: true,
          metrics: false
        })
      end
      
      it 'includes additional information in the output' do
        cli.analyze
        
        expect($stdout.string).to include("Found #{gems.size} gems in Gemfile.lock")
      end
    end
    
    context 'with metrics option' do
      let(:metrics) { { total_gems: 2, outdated_gems: 1, outdated_gems_ratio: 50.0, gem_currency_score: 87.5 } }
      
      before do
        allow(cli).to receive(:options).and_return({
          input: 'spec/fixtures/Gemfile.lock',
          output: 'report.csv',
          active_threshold: 24,
          max_lag: 24,
          verbose: false,
          metrics: true
        })
        
        allow(analyzer).to receive(:calculate_metrics).with(results).and_return(metrics)
        allow(exporter).to receive(:export).with(results, 'report.csv', metrics).and_return('report.csv')
        allow(cli).to receive(:display_metrics).with(metrics)
      end
      
      it 'calculates and displays metrics' do
        cli.analyze
        
        expect(analyzer).to have_received(:calculate_metrics).with(results)
        expect(exporter).to have_received(:export).with(results, 'report.csv', metrics)
        expect(cli).to have_received(:display_metrics).with(metrics)
      end
    end
  end
  
  describe '#metrics' do
    let(:cli) { described_class.new }
    let(:parser) { instance_double('GemInspector::GemfileParser') }
    let(:analyzer) { instance_double('GemInspector::Analyzer') }
    let(:exporter) { instance_double('GemInspector::CsvExporter') }
    let(:gems) { { 'rails' => '6.1.4', 'nokogiri' => '1.12.5' } }
    let(:results) { [{ gem_name: 'rails', locked_version: '6.1.4', latest_version: '7.0.0', actively_maintained: true, outdated: true, currency_score: 75, lag_months: 6 }] }
    let(:metrics) { { total_gems: 2, outdated_gems: 1, outdated_gems_ratio: 50.0, gem_currency_score: 87.5 } }
    
    before do
      # Stub out Thor's options
      allow(cli).to receive(:options).and_return({
        input: 'spec/fixtures/Gemfile.lock',
        output: 'metrics_report.csv',
        active_threshold: 24,
        max_lag: 24,
        verbose: false
      })
      
      # Stub dependencies
      allow(GemInspector::GemfileParser).to receive(:new).and_return(parser)
      allow(GemInspector::Analyzer).to receive(:new).and_return(analyzer)
      allow(GemInspector::CsvExporter).to receive(:new).and_return(exporter)
      
      # Stub method calls
      allow(parser).to receive(:parse).and_return(gems)
      allow(analyzer).to receive(:analyze).with(gems).and_return(results)
      allow(analyzer).to receive(:calculate_metrics).with(results).and_return(metrics)
      allow(exporter).to receive(:export).with(results, 'metrics_report.csv', metrics).and_return('metrics_report.csv')
      allow(cli).to receive(:display_metrics).with(metrics)
      
      # Capture output
      $stdout = StringIO.new unless $stdout.is_a?(StringIO)
      @original_stdout = $stdout
    end
    
    after do
      $stdout = @original_stdout
    end
    
    it 'calculates and displays metrics' do
      cli.metrics
      
      expect(parser).to have_received(:parse)
      expect(analyzer).to have_received(:analyze).with(gems)
      expect(analyzer).to have_received(:calculate_metrics).with(results)
      expect(cli).to have_received(:display_metrics).with(metrics)
      expect(exporter).to have_received(:export).with(results, 'metrics_report.csv', metrics)
    end
    
    context 'with no output option' do
      before do
        allow(cli).to receive(:options).and_return({
          input: 'spec/fixtures/Gemfile.lock',
          output: nil,
          active_threshold: 24,
          max_lag: 24,
          verbose: false
        })
      end
      
      it 'displays metrics but does not export to CSV' do
        cli.metrics
        
        expect(cli).to have_received(:display_metrics).with(metrics)
        expect(exporter).to_not have_received(:export)
      end
    end

    it 'outputs metrics in JSON format' do
      metrics = { total_gems: 10, outdated_gems: 2, outdated_gems_ratio: 20.0, gem_currency_score: 85.5 }
      allow(cli).to receive(:display_metrics).and_wrap_original do |original_method, *args|
        original_method.call(metrics)
      end
      expect { cli.send(:display_metrics, metrics) }.to output(metrics.to_json + "\n").to_stdout
    end
  end
end