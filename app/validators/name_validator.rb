class NameValidator < ActiveModel::EachValidator
  BANNED_NICKNAMES = %w[
    Youtoome
  ]
  PREDEFINED_PATHS = %i[
    about
    achievements
    animes
    api
    contests
    country
    dashboards
    development
    faye
    for_right_holders
    forum
    ignores
    info
    mangas
    oauth
    oauth2
    ongoings
    podcast
    polls
    privacy
    ranobe
    redirect
    styles
    tableau
    terms
    user_agent
    users
  ]
  FORBIDDEN_NAMES = /
    \A(?:
      #{Forum::VARIANTS.join '|'} |
      #{PREDEFINED_PATHS.join '|'} |
      #{BANNED_NICKNAMES.join '|'}
    )\Z | (?:
      \.
      (?:#{FixName::ALL_EXTENSIONS.join('|')})
    \Z)
  /mix

  def validate_each record, attribute, value
    return unless value.is_a? String

    is_taken = value.match?(FORBIDDEN_NAMES) ||
      presence(record, value, Club, :name) ||
      presence(record, value, User, :nickname)

    if is_taken
      message = options[:message] ||
        I18n.t('activerecord.errors.messages.taken')
      record.errors[attribute] << message
    end

    if Banhammer.instance.abusive? value
      message = options[:message] ||
        I18n.t('activerecord.errors.messages.abusive')
      record.errors[attribute] << message
    end
  end

private

  def presence record, value, klass, field
    query = record.is_a?(klass) ? klass.where.not(id: record.id) : klass
    query
      .where(
        "#{postgres_word_normalizer field} = #{postgres_word_normalizer '?'}",
        value
      )
      .any?
  end

  def postgres_word_normalizer text
    <<~SQL.squish
      translate(
        lower(unaccent(#{text})),
        'абвгдеёзийклмнопрстуфхць',
        'abvgdeezijklmnoprstufхc`'
      )
    SQL
  end
end
