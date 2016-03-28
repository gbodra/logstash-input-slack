# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "socket"
require "ftw"

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
    server = TCPServer.new(@ip, @port)
    loop do
      #TODO (Gustavo): Create a Ruby gem to handle http requests
      Thread.start(server.accept) do |client|
        method, path = client.gets.split
        headers = {}
        while line = client.gets.split(' ', 2)
          break if line[0] == ""
          headers[line[0].chop] = line[1].strip
        end
        #TODO (Gustavo): Create a logstash codec to parse POST messages
        data = client.read(headers["Content-Length"].to_i)
        body = data.split(/\r\n+/)
        post_parameters = Hash[body.map {|it| it.split("=",2)}]

        if defined? @secret_token && post_parameters["token"]
          if not @secret_token == post_parameters["token"]
            @logger.info("Dropping invalid Slack message")
            drop = true
          end
        end

        if not drop
          decorate(event)
          output_queue << event
        end

        client.puts "Accepted!"
        client.close
      end # Thread.start
    end # loop
  end # def run

  def close
  end # def close

end # class LogStash::Inputs::Slack
