# @Reference https://www.dennisokeeffe.com/blog/2022-03-09-part-7-testing-with-rspec-and-factory-bot
FactoryBot.define do
    # Defines a factory for the attendee model
    factory :attendee do
      # default valu for the 'name' attribute of the attendee
      name { "John Doe" }
      # default valu for the 'email' attribute of the attendee
      email { "john@example.com" }
      # default valu for the 'rsvp' attribute of the attendee
      rsvp { false }
      # attendee is associated with the event and uses the event factory to create a related event for the attendee
      event
    end
  end
