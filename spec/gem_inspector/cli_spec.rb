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
    let(:results) { [{ gem_name: 'rails', locked_version: '6.1.4', latest_version: '7.0.0', actively_maintained: true, outdated: true }] }
    
    before do
      # Stub out Thor's options
      allow(cli).to receive(:options).and_return({
        input: 'spec/fixtures/Gemfile.lock',
        output: 'report.csv',
        active_threshold: 24,
        verbose: false
      })
      
      # Stub dependencies
      allow(GemInspector::GemfileParser).to receive(:new).and_return(parser)
      allow(GemInspector::Analyzer).to receive(:new).and_return(analyzer)
      allow(GemInspector::CsvExporter).to receive(:new).and_return(exporter)
      
      # Stub method calls
      allow(parser).to receive(:parse).and_return(gems)
      allow(analyzer).to receive(:analyze).with(gems).and_return(results)
      allow(exporter).to receive(:export).with(results, 'report.csv').and_return('report.csv')
      
      # Capture output
      @original_stdout = $stdout
      $stdout = StringIO.new
    end
    
    after do
      $stdout = @original_stdout
    end
    
    it 'parses gems, analyzes them, and exports the results' do
      cli.analyze
      
      expect(parser).to have_received(:parse)
      expect(analyzer).to have_received(:analyze).with(gems)
      expect(exporter).to have_received(:export).with(results, 'report.csv')
      expect($stdout.string).to include("Analysis complete!")
    end
    
    context 'with verbose output' do
      before do
        allow(cli).to receive(:options).and_return({
          input: 'spec/fixtures/Gemfile.lock',
          output: 'report.csv',
          active_threshold: 24,
          verbose: true
        })
      end
      
      it 'includes additional information in the output' do
        cli.analyze
        
        expect($stdout.string).to include("Found #{gems.size} gems in Gemfile.lock")
      end
    end
  end
end