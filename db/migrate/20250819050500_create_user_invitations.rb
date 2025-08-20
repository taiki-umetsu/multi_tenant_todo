class CreateUserInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_invitations do |t|
      t.references :tenant, null: false, type: :uuid, foreign_key: true
      # 暗号化を想定してカラムサイズを510文字に設定（Userテーブルと同じ）
      t.string :email, null: false, limit: 510
      t.integer :role, null: false, default: 0 # 1=admin, 0=member
      t.string :token, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :user_invitations, [ :tenant_id, :email ], unique: true
    add_index :user_invitations, :token, unique: true
  end
end
