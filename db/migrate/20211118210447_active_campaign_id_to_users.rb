class ActiveCampaignIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :active_campaign_id, :integer
  end
end
