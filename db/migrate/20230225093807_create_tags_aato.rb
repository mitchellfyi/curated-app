# frozen_string_literal: true

# This migration comes from acts_as_taggable_on_engine (originally 1)
class CreateTagsAato < ActiveRecord::Migration[7.0]
  def change
    create_table ActsAsTaggableOn.tags_table, id: :uuid do |t|
      t.jsonb :data, null: false, default: {}

      t.belongs_to :tenant, polymorphic: true, type: :uuid
      t.belongs_to :scope, polymorphic: true, type: :uuid
      t.belongs_to :creator, polymorphic: true, type: :uuid

      t.string :name
      t.string :slug, index: true

      t.integer :status, null: false, default: 0
      t.datetime :published_at

      t.integer :visibility, null: false, default: 0

      t.integer :tag_list_count, null: false, default: 0

      t.datetime :deleted_at
      t.timestamps
    end

    create_table ActsAsTaggableOn.taggings_table, id: :uuid do |t|
      t.belongs_to :tag, foreign_key: { to_table: ActsAsTaggableOn.tags_table }, type: :uuid

      t.belongs_to :taggable, polymorphic: true, type: :uuid
      t.belongs_to :tagger, polymorphic: true, type: :uuid

      t.string :context

      t.jsonb :data, null: false, default: {}

      t.belongs_to :tenant, polymorphic: true, type: :uuid
      t.belongs_to :creator, polymorphic: true, type: :uuid

      t.belongs_to :user, type: :uuid
      t.belongs_to :role, type: :uuid

      t.string :name
      t.string :slug, index: true

      t.integer :status, null: false, default: 0
      t.datetime :published_at

      t.integer :visibility, null: false, default: 0

      t.datetime :deleted_at
      t.timestamps
    end

    add_index ActsAsTaggableOn.taggings_table, %i[taggable_id taggable_type context],
              name: 'taggings_taggable_context_idx'
    add_index ActsAsTaggableOn.taggings_table, :context
    add_index ActsAsTaggableOn.taggings_table, %i[tagger_id tagger_type], name: 'taggings_tagger_idy'
    add_index ActsAsTaggableOn.taggings_table, %i[taggable_id taggable_type tagger_id context],
              name: 'taggings_taggable_tagger_idy'
  end
end
