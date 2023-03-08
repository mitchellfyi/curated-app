# frozen_string_literal: true

# job / industry / work
# brand / product / company / business
# people
# events/holidays
# life
# travel / food / music / art / sports / nature / animals / plants

Dir[Rails.root.join('db', 'seeds', 'Collections', '*.yml')].each do |filename|
  pp [:collections, filename]

  attrs = YAML.load_file(filename).deep_symbolize_keys

  delete attrs[:domain] if Rails.env.production?

  collection = Collection.find_or_initialize_by(name: attrs[:name])
  collection.update!(attrs)
end
