class RolifyCreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table(:roles, id: :uuid) do |t|
      t.string :name
      t.belongs_to :resource, polymorphic: true, type: :uuid

      t.timestamps
    end

    create_table(:users_roles, id: false) do |t|
      t.belongs_to :user, type: :uuid
      t.belongs_to :role, type: :uuid
    end

    add_index(:roles, %i[name resource_type resource_id])
    add_index(:users_roles, %i[user_id role_id])
  end
end
