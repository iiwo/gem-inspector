# Coding pattern preferences

– Always prefer simple solutions  
– Avoid duplication of code whenever possible, which means checking for other areas of the codebase that might already have similar code and functionality  
– Write code that takes into account the different environments: dev, test, and prod  
– You are careful to only make changes that are requested or you are confident are well understood and related to the change being requested  
– When fixing an issue or bug, do not introduce a new pattern or technology without first exhausting all options for the existing implementation. And if you finally do this, make sure to remove the old implementation afterwards so we don’t have duplicate logic.  
– Keep the codebase very clean and organized  
– Avoid writing scripts in files if possible, especially if the script is likely only to be run once  
– Avoid having files over 200–300 lines of code. Refactor at that point.  
– Mocking data is only needed for tests, never mock data for dev or prod  
– Never add stubbing or fake data patterns to code that affects the dev or prod environments  
– Never overwrite my .env file without first asking and confirming

# rspec general preferences
- use rspec >= 3.10 syntax
- use this example for correct syntax (but do not limit usege to just the methods in this example):
```ruby
# spec/my_class_spec.rb

RSpec.describe MyClass do
  # Define subject with a constructor argument set by `let`
  subject { described_class.new(name) }

  let(:name) { "Test User" }
  
  # Using a spy to track method calls
  let(:fake_dependency) { spy("Dependency") }

  before(:each) do
    # Stub the action method to return "done" using `and_return`
    allow(fake_dependency).to receive(:action).and_return("done")
    # Replace the dependency method on subject with the fake_dependency
    allow(subject).to receive(:dependency).and_return(fake_dependency)
  end

  # One-liner expectation to ensure `perform` is defined
  it { is_expected.to respond_to(:perform) }

  describe "#perform" do
    context "when dependency works" do
      it "calls the dependency's action and returns its result" do
        result = subject.perform
        expect(result).to eq("done")
        # Verify that `action` was actually called on fake_dependency
        expect(fake_dependency).to have_received(:action)
      end
    end

    context "when dependency fails" do
      it "raises an error" do
        allow(fake_dependency).to receive(:action).and_raise(StandardError)
        expect { subject.perform }.to raise_error(StandardError)
      end
    end
  end
end

```