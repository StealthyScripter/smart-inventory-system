namespace :accounts do
  desc "Backfill account model records from legacy users, suppliers, and supplier users"
  task backfill: :environment do
    AccountBackfill.call
    puts "Account backfill complete."
  end
end
