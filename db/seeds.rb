# Create 10 events and 5 attendees for each event
10.times do |i|
    event = Event.create!(
      title: "Event #{i + 1}",
      description: "This is a description for Event #{i + 1}.",
      date: DateTime.now + (i + 1).days,
      recurrence: ['daily', 'weekly', 'monthly'].sample,
    )
  
    # Add 5 attendees to each event
    5.times do |j|
      Attendee.create!(
        name: "Attendee #{j + 1} for Event #{i + 1}",
        email: "attendee#{j + 1}@event#{i + 1}.com",
        rsvp: [false].sample,
        event: event
      )
    end
  end
  
  puts "10 events and attendees created successfully!"
  