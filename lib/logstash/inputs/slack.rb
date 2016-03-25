# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket"

# Read events from Slack

class LogStash::Inputs::Slack < LogStash::Inputs::Base
  config_name "slack"

  # The ip to listen on
  config :ip, :validate => :string, :default => "0.0.0.0"

  # The port to listen on
  config :port, :validate => :number, :required => true

  # Your Slack Token for the webhook
  config :secret_token, :validate => :string, :required => false

  # If Secret is defined, we drop the events that don't match.
  # Otherwise, we'll just add a invalid tag
  config :drop_invalid, :validate => :boolean

  def register
    require "ftw"
  end # def register

  public
  def run(output_queue)
    @server = FTW::WebServer.new(@ip, @port) do |request, response|
      body = request.read_body

      event = LogStash::Event.new("message" => body)

      decorate(event)
      output_queue << event

      response.status = 200
      response.body = "Accepted!"
    end
    @server.run
  end # def run

  def close
    @server.stop
  end # def close

end # class LogStash::Inputs::Slack
