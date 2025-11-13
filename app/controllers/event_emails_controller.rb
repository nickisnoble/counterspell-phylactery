class EventEmailsController < ApplicationController
  allow_unauthenticated_access

  def show
    @event = Event.find_by_slug!(params[:event_id])
    @event_email = @event.event_emails.find(params[:id])

    render Views::EventEmails::Show.new(event: @event, event_email: @event_email)
  end
end
