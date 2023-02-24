# frozen_string_literal: true

developer_users_attrs = Rails.application.credentials.dig(:admin, :developers).map do |email|
  {
    email: email,
    password: Rails.application.credentials.dig(:admin, :developer_password),
    roles_attributes: [{ name: 'developer' }, { name: 'staff' }]
  }
end

staff_users_attrs = Rails.application.credentials.dig(:admin, :staff)&.map do |email|
  {
    email: email,
    password: Rails.application.credentials.dig(:admin, :staff_password),
    roles_attributes: [{ name: 'staff' }]
  }
end

bot_attrs = {
  email: "bot@#{Rails.application.credentials.dig(:app, :host)}",
  password: Rails.application.credentials.dig(:admin, :developer_password),
  username: "#{Rails.application.credentials.dig(:app, :name)} Bot",
  roles_attributes: [{ name: 'bot' }]
}

users_attrs = developer_users_attrs + staff_users_attrs + [bot_attrs]

users_attrs.each do |attrs|
  pp [:user, attrs[:email], attrs]

  user = User.find_or_initialize_by(email: attrs[:email])
  user.update!(attrs)
end
