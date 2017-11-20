class RenamePasswordInAccounts < ActiveRecord::Migration
  def change
    change_table :accounts, bulk: true do |t|
      t.string :encrypted_password, :confirmation_token
    end
  end
end
