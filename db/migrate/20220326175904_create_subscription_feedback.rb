class CreateSubscriptionFeedback < ActiveRecord::Migration[6.0]
  def change
    create_table :subscription_feedbacks do |t|
      t.text :feedback
      t.belongs_to :user
    end
  end
end
