class EventChannel < ApplicationCable::Channel
  def subscribed
    event = Event.find_by_slug(params[:event_id])
    stream_for event if event
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
