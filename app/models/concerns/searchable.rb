module Searchable
  extend ActiveSupport::Concern
  include PgSearch::Model

  included do
    pg_search_scope :pg_full_text_search,
                    against: self::SEARCHABLE_AGAINST,
                    using: {
                      tsearch: { prefix: true, dictionary: 'simple', tsvector_column: 'tsv_body' }
                    }

    def self.full_text_search(term)
      pg_full_text_search(term).limit(self::PER_PAGE)
    end
  end
end
