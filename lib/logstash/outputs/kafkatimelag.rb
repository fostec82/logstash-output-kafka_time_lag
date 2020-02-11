# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"

class LogStash::Outputs::KafkaTimeLag < LogStash::Outputs::Base

  config_name "kafkatimelag"

  # Replace the message with this value.
  config :kafka_topic_producer, :validate => :string
  config :kafka_consumer_group_producer, :validate => :string
  config :kafka_append_time_producer, :validate => :string
  config :logstash_kafka_read_time_producer, :validate => :string
  config :kafka_topic_aggregate, :validate => :string
  config :kafka_consumer_group_aggregate, :validate => :string
  config :kafka_append_time_aggregate, :validate => :string
  config :logstash_kafka_read_time_aggregate, :validate => :string

  concurrency :single

  public
  def register
    # Add instance variables
  end # def register

  public
  def receive(event)

    File.open("/tmp/event.txt", "w") { |f| f.write event.to_json }

    kafka_topic_producer = event.sprintf(@kafka_topic_producer)
    kafka_consumer_group_producer = event.sprintf(@kafka_consumer_group_producer)
    kafka_append_time_producer = event.sprintf(@kafka_append_time_producer)
    logstash_kafka_read_time_producer = event.sprintf(@logstash_kafka_read_time_producer)

    kafka_topic_aggregate = event.sprintf(@kafka_topic_aggregate)
    kafka_consumer_group_aggregate = event.sprintf(@kafka_consumer_group_aggregate)
    kafka_append_time_aggregate = event.sprintf(@kafka_append_time_aggregate)
    logstash_kafka_read_time_aggregate = event.sprintf(@logstash_kafka_read_time_aggregate)

    # Calculate lag values
    kafka_aggregate_lag_ms = logstash_kafka_read_time_aggregate.to_i - kafka_append_time_aggregate.to_i
    kafka_producer_lag_ms = logstash_kafka_read_time_producer.to_i - kafka_append_time_producer.to_i
    kafka_total_lag_ms = logstash_kafka_read_time_aggregate.to_i - kafka_append_time_producer.to_i

    # Get current time for influxdb timestamp
    kafka_logstash_influx_metric_time = (Time.now.to_f * (1000*1000*1000)).to_i

    #{}"payload" => "chris_kafka_aiad2_lag,topic_aggregate=%{kafka_topic_aggregate},consumer_group_aggregate=%{kafka_consumer_group_aggregate},topic_producer=%{kafka_topic_producer},consumer_group_producer=%{kafka_consumer_group_producer} kafka_total_lag_ms=%{kafka_total_lag_ms},kafka_aggregate_lag_ms=%{kafka_aggregate_lag_ms},kafka_producer_lag_ms=%{kafka_producer_lag_ms}  %{kafka_logstash_influx_metric_time}"

    metrics_string = "kafka_lag_time,topic_aggregate=#{kafka_topic_aggregate},consumer_group_aggregate=#{kafka_consumer_group_aggregate},topic_producer=#{kafka_topic_producer},consumer_group_producer=#{kafka_consumer_group_producer} kafka_total_lag_ms=#{kafka_total_lag_ms},kafka_aggregate_lag_ms=#{kafka_aggregate_lag_ms},kafka_producer_lag_ms=#{kafka_producer_lag_ms} #{kafka_logstash_influx_metric_time}"

    File.open("/tmp/output.txt", "w") { |f| f.write metrics_string }

    return "Event received"

  end # def filter

end # class LogStash::Filters::Influxdb
