class ChatController < ApplicationController
  def index
    @dialogs = Dialog.by_last_message
  end
end
