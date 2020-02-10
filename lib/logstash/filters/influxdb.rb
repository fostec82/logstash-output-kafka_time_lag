# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "influxparser"

class LogStash::Filters::Influxdb < LogStash::Filters::Base

  config_name "influxdb"

  # Replace the message with this value.
  config :source, :validate => :string, :default => "message"
  config :target, :validate => :string, :default => "point"
  config :parse_types, :validate => :boolean, :default => false
  config :time_format, :validate => :string, :default => nil

  public
  def register
    # Add instance variables
  end # def register

  public
  def filter(event)
    
    point = InfluxParser.parse_point(event.get(@source),{
      :parse_types => @parse_types,
      :time_format => @time_format
    })

    if point
      event.set(@target, point)
    else
      event.set(@target, {'_influxparseerror' => true })
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter

end # class LogStash::Filters::Influxdb