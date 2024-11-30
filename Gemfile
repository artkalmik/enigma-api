source "https://rubygems.org"

ruby "3.2.2"

# Rails основа
gem "rails", "~> 7.1.0"
gem "puma", ">= 5.0"
gem "pg", "~> 1.1"

# API и сериализация
gem "rack-cors"
gem "fast_jsonapi"
gem "oj"

# Аутентификация и авторизация
gem "devise"
gem "devise-jwt"
gem "pundit"

# Блокчейн и криптография
gem "eth"
gem "rbnacl"

# Хранение и кэширование
gem "redis"
gem "mongo"
gem "ipfs-api"

# Фоновые задачи
gem "sidekiq"
gem "sidekiq-scheduler"

# Мониторинг и логирование
gem "sentry-ruby"
gem "sentry-rails"
gem "lograge"

group :development, :test do
  gem "debug"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "database_cleaner"
  gem "rubocop"
  gem "brakeman"
  gem "bundler-audit"
end

group :development do
  gem "web-console"
end


