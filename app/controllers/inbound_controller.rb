# app/controllers/inbound_controller.rb
class InboundController < ActionController::API
  # pull in the Rails CSRF protection callbacks
  include ActionController::RequestForgeryProtection

  # use the normal exception strategy everywhere…
  protect_from_forgery with: :exception

  # …but turn it off for Mailgun’s inbound webhook
  skip_before_action :verify_authenticity_token, only: :mailgun

  # POST /inbound/mailgun
  def mailgun
    recipient   = params[:recipient]        # e.g. "make+TOKEN@make.tadl.org"
    body        = params['body-plain']      # plain-text part of the email
    from_header = params[:from]             # e.g. "Alice <alice@example.com>"

    # 1) extract conversation token
    token = recipient[/\Amake\+([^@]+)@/, 1]
    return head :bad_request unless token

    # 2) find the conversation
    conversation = Conversation.find_by(conversation_token: token)
    return head :not_found unless conversation

    # 3) parse out actual email address of sender
    #    Mailgun gives `"Name <email@domain>"` in `params[:from]`
    from_email = Mail::Address.new(from_header).address rescue nil
    return head :bad_request unless from_email

    # 4) ensure that this email belongs to the patron on this conversation’s job
    job    = conversation.job
    patron = job.patron
    unless patron.email.downcase == from_email.downcase
      return head :unauthorized
    end

    # 5) build the inbound message
    conversation.messages.create!(
      body:        body,
      author:      patron
    )

    head :ok
  end
end
