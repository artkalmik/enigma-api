namespace :db do
  desc 'Check if database exists'
  task exists: :environment do
    begin
      ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      exit 1
    else
      exit 0
    end
  end
end 