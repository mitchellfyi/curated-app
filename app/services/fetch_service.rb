# frozen_string_literal: true

class FetchService < ApplicationService
  extend ActiveSupport::Concern
  include ApplicationHelper

  FETCH_INTERVAL = 3.months
  FETCH_FEED_INTERVAL = 60.minutes
  FETCH_DOMAIN_INTERVAL = 3.seconds

  included do
    scope :ready_to_fetch, lambda {
      status_published
        .where('fetched_at < ? OR fetched_at IS NULL', fetch_interval.ago)
        .where.not(url: nil)
        .order(created_at: :asc)
    }

    scope :fetched, lambda {
      status_published
        .where.not(url: nil, fetched_body: nil, fetched_at: nil)
        .order(updated_at: :desc)
    }

    scope :fetched_by_url, lambda { |resource|
      fetched
        .where(url: resource.url)
        .where.not(id: resource.id)
    }

    scope :recently_fetched_domain, lambda { |resource|
      fetched
        .where.not(id: resource.id)
        .where('url ILIKE ? AND fetched_at > ?', "%#{resource.domain}%", FETCH_DOMAIN_INTERVAL.ago)
    }

    scope :new_fetched_items_for_tenant, lambda { |tenant|
      status_published
        .where('tenant_id = ? OR tenant_id IS NULL', tenant.id)
        .where('last_fetched_items_count > 0')
    }

    before_validation :set_fetch_interval
    before_update :reset_fetched_at, if: %i[url_changed? fetched_at_nil?]
    after_save_commit :enqueue_fetch_job, if: :ready_to_fetch?
  end

  def set_fetch_interval
    self.fetch_interval ||= (format_html? ? FETCH_INTERVAL : FETCH_FEED_INTERVAL).iso8601
  end

  def enqueue_fetch_job(options = {})
    ResourceFetchJob.set({ queue: :high }.merge(options)).perform_later(self) if ready_to_fetch?
  end

  def reset_fetched_at
    self.fetched_at = nil
  end

  def ready_to_fetch?
    status_published? && url.present? && votes? &&
      (fetched_at.blank? || fetched_at < ActiveSupport::Duration.parse(fetch_interval).ago)
  end

  def new_fetched_items?
    status_published? && last_fetched_items_count.positive?
  end

  def fetch!
    return unless ready_to_fetch?

    unless already_fetched?
      return enqueue_fetch_job(wait: DOMAIN_FETCH_INTERVAL) if recently_fetched_domain?

      update!(fetched_at: Time.now.utc)

      page = MetaInspector.new(url, {
                                 faraday_http_cache: { store: ActiveSupport::Cache.lookup_store(:file_store, '/tmp/cache') },
                                 connection_timeout: 5, read_timeout: 5, retries: 3,
                                 encoding: 'UTF-8',
                                 allow_non_html_content: true
                               })

      raise StandardError, 'Response body is blank.' if page.to_s.blank?
    end

    response = already_fetched&.fetched_response || page.response
    meta = already_fetched&.fetched_meta || parse_meta(page)
    body = already_fetched&.fetched_body || compress(page.to_s)

    return unless modified_at.blank? || body != fetched_body

    options = parse_rss(response, body, meta) if format_rss?

    update!({
      modified_at: Time.now.utc,
      fetched_at: Time.now.utc,
      fetched_response: response,
      fetched_meta: meta,
      fetched_body: body,
      fetch_attempts: 0
    }.merge(options || {}))
  rescue StandardError => e
    Airbrake.notify(e, {
                      id: id,
                      url: url,
                      response: response,
                      meta: meta,
                      body: body
                    })

    update!({
              fetch_attempts: fetch_attempts + 1,
              fetched_errors: fetched_errors.concat([e.try(:message) || e]),
              status: fetch_attempts > 2 ? :error : status
            })

    status_error? ? (raise e) : nil
  end

  def parse_meta(page)
    page.to_hash.merge({
                         untracked_url: page.untracked_url,
                         canonicals: page.canonicals,
                         best_image: page.images.best,
                         best_feed: page.feeds.first.try(:[], :href)
                       })
  end

  def parse_rss(_response, body, meta)
    @feed = FeedManager.Feed.new(body, self)
    raise StandardError, 'Cannot parse feed items.' unless @feed.valid?

    # TODO: if the last time we fetched this was a while ago, maybe increase the fetch interval?
    return unless modified_at.blank? ||
                  modified_at < feed.meta.last_modified ||
                  (
                    new_fetched_items.size.positive? &&
                    merged_new_and_fetched_items != fetched_items
                  )

    enqueue_sourcing_job if new_fetched_items?

    {
      modified_at: feed&.modified_at,
      fetched_meta: meta.merge({ feed: feed&.meta }),
      fetched_items: merged_new_and_fetched_items,
      last_fetched_items_count: new_fetched_items.size,
      fetched_items_count: merged_new_and_fetched_items.size
    }
  end

  def already_fetched
    @already_fetched ||= self.class.fetched_by_url(self).first
  end

  def already_fetched?
    already_fetched.present?
  end

  def recently_fetched_domain
    @recently_fetched_domain ||= self.class.recently_fetched_domain(self)
  end

  def recently_fetched_domain?
    recently_fetched_domain.any?
  end

  def fetched_items
    return [] if fetched_items.blank?

    @fetched_items ||= fetched_items
                       .map { |entry| FeedService::Entry.new(entry, self) }
  end

  def new_fetched_items
    @feed ||= parse_feed(decompress(fetched_body))

    @new_fetched_items ||= feed.entries.reject do |item|
      fetched_items.include?(item.guid)
    end
  end

  def merged_new_and_fetched_items
    @merged_new_and_fetched_items ||= fetched_items
                                      .concat(newfetched_items)
                                      .uniq(&:guid)
                                      .sort_by(&:published_at)
                                      .reverse
                                      .first(500)
  end

  def enqueue_sourcing_job
    CollectionCreateItemsFromSourceJob.set(wait: 1.minute).perform_later(tenant, self)
  end

  def url
    fetched_meta[:untracked_url] || fetched_meta.dig(:feed, :url) || self[:url]
  end

  def domain
    PublicSuffix.parse(URI.parse(url).host).domain if url.present?
  end
end
