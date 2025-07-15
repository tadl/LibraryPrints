class AddConversationTokenToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :conversation_token, :string
    add_index  :conversations, :conversation_token, unique: true
  end
end
