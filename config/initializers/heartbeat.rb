Thread.new do
  loop do
    sleep 1.seconds
    ActiveSupport::Notifications.instrument('heartbeat', nil)
  end
end