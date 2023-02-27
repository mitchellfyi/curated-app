# frozen_string_literal: true

Dir[Rails.root.join('db', 'seeds', 'accounts', '*.yml')].each do |filename|
  pp [:accounts, filename]

  attrs = YAML.load_file(filename).deep_symbolize_keys

  account = Account.find_or_initialize_by(name: attrs[:name])
  account.update!(attrs)
end
