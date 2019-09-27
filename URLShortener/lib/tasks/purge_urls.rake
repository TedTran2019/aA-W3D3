namespace :purge_urls do
  desc "Purge stale urls from shortened_urls table"
  task clear_urls: :environment do
    puts "Purging old unvisited urls from non-premium users..."
    ShortenedUrl.prune(10)
  end
end