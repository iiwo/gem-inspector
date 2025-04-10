# gem-inspector/spec/gem_inspector_spec.rb

require 'spec_helper'
require 'gem_inspector'

RSpec.describe GemInspector do
  it 'has a version number' do
    expect(GemInspector::VERSION).not_to be nil
  end

  it 'performs a basic functionality check' do
    # This is a placeholder for a general functionality test.
    # You can add specific tests to verify the overall behavior of the gem.
    expect(true).to eq(true)
  end
end