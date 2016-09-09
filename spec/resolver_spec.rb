require 'spec_helper'

include Conjur::Policy

describe Resolver do
  let(:fixture) { YAML.load(File.read(filename), filename) }
  let(:account) { fixture['account'] || "the-account" }
  let(:ownerid) { fixture['ownerid'] || "rspec:user:default-owner" }
  let(:policy) { Conjur::Policy::YAML::Loader.load(fixture['policy']) }
  let(:resolve) {
    Resolver.resolve(policy, account, ownerid)
  }
  before {
    allow(Conjur).to receive(:configuration).and_return double(:configuration, account: account)
  }
  subject { resolve.to_yaml }
  
  shared_examples_for "verify resolver" do
    it "matches expected YAML" do
      expect(subject).to eq(fixture['expectation'])
    end
  end

  shared_examples_for "verify error" do
    it "raises the expected error" do
      expect { subject }.to raise_error(fixture['error'])
    end
  end
    
  fixtures_dir = File.expand_path("resolver-fixtures", File.dirname(__FILE__))
  Dir.chdir(fixtures_dir) do
    files = if env = ENV['POLICY_FIXTURES']
      env.split(',')
    else
      Dir['*.yml']
    end

    files.each do |file_example_name|
      describe file_example_name do
        let(:filename) { File.expand_path(file_example_name, fixtures_dir) }
        if file_example_name =~ /-error.yml/
          it_should_behave_like "verify error"
        else
          it_should_behave_like "verify resolver"
        end
      end
    end
  end
end
