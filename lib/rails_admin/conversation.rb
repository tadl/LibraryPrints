# lib/rails_admin/config/actions/conversation.rb
require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class Conversation < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :visible? do
          bindings[:abstract_model].model == ::PrintJob && authorized?
        end

        register_instance_option :link_icon do
          'fa fa-comments'
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :route_fragment do
          'conversation'
        end

        register_instance_option :route_action do
          :conversation
        end

        register_instance_option :controller do
          proc do
            @print_job    = @abstract_model.model.find(params[:id])
            @conversation = @print_job.conversation || @print_job.build_conversation

            if request.post?
              body            = params.dig(:conversation, :message_body)
              staff_only_flag = params.dig(:conversation, :staff_note_only) == '1'

              msg = @conversation.messages.create!(
                body:            body,
                author:          current_staff_user,
                staff_note_only: staff_only_flag
              )

              # only email patron when not a staff-only note
              unless staff_only_flag
                ::PrintJobMailer.with(message: msg).notify_patron.deliver_later
              end

              # Turbo-stream replace the messages list and reset the form
              render turbo_stream: [
                turbo_stream.replace(
                  'messages',
                  partial: 'rails_admin/main/conversation_messages',
                  locals: { conversation: @conversation }
                ),
                turbo_stream.replace(
                  'conversation_form',
                  partial: 'rails_admin/main/conversation_form',
                  locals: { print_job:   @print_job,
                            conversation: @conversation }
                )
              ]
            else
              render @action.template_name
            end
          end
        end
      end
    end
  end
end
