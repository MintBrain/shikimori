class ExternalLink < ApplicationRecord
  belongs_to :entry, polymorphic: true, touch: true
  validates :entry, :source, :kind, :url, presence: true

  validates :url,
    uniqueness: { scope: %i[entry_id entry_type source] }

  enumerize :kind,
    in: Types::ExternalLink::Kind.values,
    predicates: { prefix: true }

  enumerize :source,
    in: Types::ExternalLink::Source.values,
    predicates: { prefix: true }

  WIKIPEDIA_LABELS = {
    ru: 'Википедия',
    en: 'Wikipedia',
    ja: 'ウィキペディア',
    zh: '维基百科'
  }

  NO_URL = 'NONE'

  def url= value
    if value.present?
      super Url.new(value).with_protocol.to_s
    else
      super
    end
  end

  def visible?
    !source_hidden? &&
      !Types::ExternalLink::INVISIBLE_KINDS.include?(kind.to_sym)
  end

  def disabled?
    url&.ends_with? NO_URL
  end

  def label
    if kind_wikipedia? && url =~ %r{/(?<lang>ru|en|ja|zh)\.wikipedia\.org/}
      WIKIPEDIA_LABELS[$LAST_MATCH_INFO[:lang].to_sym] || kind_text
    else
      kind_text
    end
  end
end
