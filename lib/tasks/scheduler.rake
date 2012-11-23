namespace :scheduler do
  task :send_fb_notifications => :environment do

    total = FbNotify.count(:conditions => {:notified => false})
    puts "Total #{total} notifications needs to be sent"

    # Chose 10 notifications which were created more than 10 minutes ago
    items = FbNotify.all(:limit => 10, :conditions => ["notified = ? and created_at < ?", false, Time.now - 10.minutes])
    puts "Selected some #{items.length} notifications"

    items.each {|i| i.notify}

  end

end
