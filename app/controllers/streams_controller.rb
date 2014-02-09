class StreamsController < ApplicationController
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    # @payload = nil

    # Subscribe the current user to message notifications.
    ActiveSupport::Notifications.subscribe('message') do |name, start, finish, id, payload|
        @payload = payload
    end

    # Separate thread creates a heartbeat to "ping" the user every few seconds.  When a user closes
    # their window and the thread tries to send it a heartbeat event, the loop will error out and
    # cause the thread to die.
    heartbeat = Thread.new do
        loop do
          sleep 10.seconds
          response.stream.write "event: heartbeat\n"
        end
    end

    # Loop until the heartbeat dies.
    while heartbeat.alive?
      sleep 0.1.seconds
      response.stream.write "event: message\ndata: #{@payload} \n\n" unless @payload == nil
      @payload = nil
    end

    # Make sure that the stream is closed and the current process is unsubscribed.
    rescue IOError
    ensure
      ActiveSupport::Notifications.unsubscribe('messages')
      response.stream.close
      p "stream closed"
  end

end
