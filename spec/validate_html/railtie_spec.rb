require 'spec_helper'

RSpec.describe 'ValidateHTML::Railtie' do
  ::Dir.glob("#{__dir__}/railtie/*_spec_standalone.rb").sort.each do |path|
    it "#{path}" do
      env = { 'SIMPLECOV_COMMAND_NAME' => "RSpec #{::File.basename(path).delete_suffix('_spec_standalone.rb')}"}
      system(env, "rspec #{path}")
    end
  end
end
