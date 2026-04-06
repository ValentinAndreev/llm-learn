class DialogsController < ApplicationController
  def index
    dialogs = Dialog.by_last_message
    render json: dialogs.map { |d| { id: d.id, title: d.title, updated_at: d.updated_at.iso8601 } }
  end

  def destroy
    dialog = Dialog.find(params[:id])
    dialog.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def update
    dialog = Dialog.find(params[:id])
    title = params.dig(:dialog, :title).to_s.strip

    if title.empty?
      render json: { error: "Title can't be blank" }, status: :unprocessable_entity
      return
    end

    if dialog.update(title: title)
      render json: { id: dialog.id, title: dialog.title, updated_at: dialog.updated_at.iso8601 }
    else
      render json: { error: dialog.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
