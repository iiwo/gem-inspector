require "spec_helper"

RSpec.describe GemInspector::Parser do
  describe ".parse" do
    context "when the file doesn't exist" do
      it "raises an error" do
        expect {
          GemInspector::Parser.parse("nonexistent_file.lock")
        }.to raise_error(GemInspector::Error, /not found/)
      end
    end
    
    context "with a valid Gemfile.lock" do
      before do
        # Create a mock Gemfile.lock for testing
        @lockfile_path = "spec/fixtures/Gemfile.lock"
        FileUtils.mkdir_p(File.dirname(@lockfile_path))
        
        File.write(@lockfile_path, <<~LOCKFILE)
          GEM
            remote: https://rubygems.org/
            specs:
              rake (13.0.6)
              rspec (3.12.0)
                rspec-core (~> 3.12.0)
                rspec-expectations (~> 3.12.0)
                rspec-mocks (~> 3.12.0)
              rspec-core (3.12.1)
                rspec-support (~> 3.12.0)
              rspec-expectations (3.12.2)
                diff-lcs (>= 1.2.0, < 2.0)
                rspec-support (~> 3.12.0)
              rspec-mocks (3.12.5)
                diff-lcs (>= 1.2.0, < 2.0)
                rspec-support (~> 3.12.0)
              rspec-support (3.12.0)

          PLATFORMS
            ruby

          DEPENDENCIES
            rake (~> 13.0)
            rspec (~> 3.0)

          BUNDLED WITH
             2.4.10
        LOCKFILE
      end
      
      after do
        FileUtils.rm_f(@lockfile_path)
      end
      
      it "extracts gem names and versions" do
        gems = GemInspector::Parser.parse(@lockfile_path)
        
        expect(gems).to include(
          { name: "rake", version: "13.0.6" },
          { name: "rspec", version: "3.12.0" },
          { name: "rspec-core", version: "3.12.1" },
          { name: "rspec-expectations", version: "3.12.2" },
          { name: "rspec-mocks", version: "3.12.5" },
          { name: "rspec-support", version: "3.12.0" }
        )
      end
    end
  end
end
