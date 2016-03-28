# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/slack"

describe LogStash::Inputs::Slack do

  context "when starts the server" do

    let(:plugin) { LogStash::Plugin.lookup("input", "slack").new( {"port" => 9999, "secret_token" => "XXXXXXXXXXXXXXXXXX"} ) }

    it "should register and close without errors" do
      expect { plugin.register }.to_not raise_error
    end

    #it "should run without errors" do
    #  expect { plugin.run(nil) }.to_not raise_error
    #end
  end
end
