class AddLearningWorkflowFieldsToDialogs < ActiveRecord::Migration[8.1]
  def up
    add_column :dialogs, :goal, :text
    add_column :dialogs, :workflow_state, :string
    add_column :dialogs, :topic_slug, :string
    add_column :dialogs, :current_conspect_prompt, :text

    execute <<~SQL
      UPDATE dialogs
      SET workflow_state = 'collecting_info'
      WHERE workflow_state IS NULL
    SQL

    change_column_default :dialogs, :workflow_state, from: nil, to: "collecting_info"
    change_column_null :dialogs, :workflow_state, false
  end

  def down
    remove_column :dialogs, :current_conspect_prompt
    remove_column :dialogs, :topic_slug
    remove_column :dialogs, :workflow_state
    remove_column :dialogs, :goal
  end
end
