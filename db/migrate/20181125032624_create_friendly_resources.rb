# frozen_string_literal: true

##
# Specifies creation of a table friendly_resources.
class CreateFriendlyResources < ActiveRecord::Migration[5.2]
  def change
    create_table :friendly_resources do |t|
      t.string   :name
      t.integer  :ip_address, limit: 8
      t.timestamps
    end
  end
end
