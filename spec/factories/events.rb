# @Reference https://www.dennisokeeffe.com/blog/2022-03-09-part-7-testing-with-rspec-and-factory-bot
FactoryBot.define do
    # Defines a factory for the event model
    factory :event do
      # default valu for the 'title' attribute of the event
      title { "Tech Conference" }
      # default valu for the 'description' attribute of the event
      description { "A conference about new tech trends." }
      # default valu for the 'date' attribute of the event
      date { Date.today }
      # default valu for the 'location' attribute of the event
      location { "Convention Center" }
      # default valu for the 'recurrence' attribute of the event
      recurrence { "weekly" }
    end
  end
  