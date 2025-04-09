require "spec_helper"

RSpec.describe GemInspector::Analyzer do
  describe ".analyze" do
    let(:gem_name) { "example_gem" }
    let(:locked_version) { "1.0.0" }
    let(:active_threshold) { 24 }
    
    context "when the gem is outdated and not actively maintained" do
      let(:gem_data) do
        [
          {
            "number" => "1.0.0",
            "built_at" => (Date.today - 1000).to_s,
            "prerelease" => false
          },
          {
            "number" => "2.0.0",
            "built_at" => (Date.today - 800).to_s,
            "prerelease" => false
          }
        ]
      end
      
      it "correctly identifies the gem as outdated and not maintained" do
        result = GemInspector::Analyzer.analyze(gem_name, locked_version, gem_data, active_threshold)
        
        expect(result[:name]).to eq(gem_name)
        expect(result[:locked_version]).to eq(locked_version)
        expect(result[:latest_version]).to eq("2.0.0")
        expect(result[:outdated]).to eq("yes")
        expect(result[:actively_maintained]).to eq("no")
      end
    end
    
    context "when the gem is up to date and actively maintained" do
      let(:gem_data) do
        [
          {
            "number" => "1.0.0",
            "built_at" => (Date.today - 30).to_s,
            "prerelease" => false
          }
        ]
      end
      
      it "correctly identifies the gem as up to date and maintained" do
        result = GemInspector::Analyzer.analyze(gem_name, locked_version, gem_data, active_threshold)
        
        expect(result[:name]).to eq(gem_name)
        expect(result[:locked_version]).to eq(locked_version)
        expect(result[:latest_version]).to eq("1.0.0")
        expect(result[:outdated]).to eq("no")
        expect(result[:actively_maintained]).to eq("yes")
      end
    end
    
    context "when there are prerelease versions" do
      let(:gem_data) do
        [
          {
            "number" => "1.0.0",
            "built_at" => (Date.today - 100).to_s,
            "prerelease" => false
          },
          {
            "number" => "2.0.0.beta",
            "built_at" => Date.today.to_s,
            "prerelease" => true
          }
        ]
      end
      
      it "ignores prerelease versions" do
        result = GemInspector::Analyzer.analyze(gem_name, locked_version, gem_data, active_threshold)
        
        expect(result[:latest_version]).to eq("1.0.0")
        expect(result[:outdated]).to eq("no")
      end
    end
  end
end
