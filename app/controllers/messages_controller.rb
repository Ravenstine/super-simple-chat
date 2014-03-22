class MessagesController < ApplicationController

  def index
  end

  def create
    ActiveSupport::Notifications.instrument('message', params.to_json)
    render nothing: true
  end

end
