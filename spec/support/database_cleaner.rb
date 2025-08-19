RSpec.configure do |config|
  config.before(:suite) do
    # 全ての接続に対してtruncationを実行
    DatabaseCleaner[:active_record].clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner[:active_record].strategy = :transaction
  end

  config.before(:each, type: :system) do
    # Systemテストでは全ての接続に対してtruncationを使用
    DatabaseCleaner[:active_record].strategy = :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner[:active_record].cleaning do
      example.run
    end
  end
end
