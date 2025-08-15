class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.references :tenant, null: false, type: :uuid, foreign_key: true
      # 暗号化を想定してカラムサイズを510文字に設定（通常255文字の倍）
      # 暗号化時のストレージオーバーヘッドを考慮した推奨サイズ
      t.string  :email, null: false, limit: 510
      t.string  :password_digest, null: false
      t.integer :role, null: false, default: 0 # 1=admin, 0=member
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
