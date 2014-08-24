class StreamsController < ApplicationController
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['X-Accel-Buffering'] = 'no'

    # Subscribe the current user to message notifications.
    message_monitor = ActiveSupport::Notifications.subscribe('message') do |name, start, finish, id, payload|
        @payload = payload
    end

    # Subscribe to the heartbeat
    @heartbeat = false
    heartbeat_monitor = ActiveSupport::Notifications.subscribe('heartbeat') do |name, start, finish, id, payload|
        @heartbeat = true
    end

    # Loop until the heartbeat dies.
    loop do
      sleep 0.1.seconds
      response.stream.write "event: message\ndata: #{@payload} \n\n" unless @payload == nil
      if @heartbeat
        response.stream.write "event: heartbeat\ndata: \n\n"
        @heartbeat = false
      end
      @payload = nil
    end

    # Make sure that the stream is closed and the current process is unsubscribed.
    rescue IOError
    ensure
      ActiveSupport::Notifications.unsubscribe(message_monitor)
      ActiveSupport::Notifications.unsubscribe(heartbeat_monitor)
      response.stream.close
      p "stream closed"
  end

end
