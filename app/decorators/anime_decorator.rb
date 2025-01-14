class AnimeDecorator < AniMangaDecorator
  instance_cache :files, :coubs, :next_episode_at

  # новости
  def news_topic_views
    object
      .news_topics
      .where(locale: h.locale_from_host)
      .includes(:forum)
      .limit(NEWS_PER_PAGE)
      .order(:created_at)
      .map { |topic| Topics::TopicViewFactory.new(false, false).build topic }
      .map { |topic_view| format_menu_topic topic_view, :created_at }
  end

  # скриншоты
  def screenshots limit = nil
    return [] if Copyright::SCREENSHOTS.include?(id)
    # return [] unless h.ignore_copyright?
    return [] if censored?

    # return [] if forbidden?

    @screenshots ||= {}
    @screenshots[limit] ||=
      if object.respond_to? :screenshots
        object.screenshots.limit limit
      else
        []
      end
  end

  # видео
  def videos limit = nil
    return [] if Copyright::VIDEOS.include?(id)

    # return [] unless h.ignore_copyright?
    # return [] if forbidden?

    @videos ||= {}
    @videos[limit] ||=
      if object.respond_to? :videos
        object.videos.limit limit
      else
        []
      end
  end

  def files
    AniMangaDecorator::Files.new object
  end

  def coubs
    Coubs::Fetch.call(tags: coub_tags, iterator: nil)
  end

  # дата выхода следующего эпизода
  def next_episode_at with_broadcast = true
    if ongoing? || anons?
      calendars = anime_calendars
        .where(episode: [episodes_aired + 1, episodes_aired + 2])
        .to_a

      date =
        if calendars[0].present? && calendars[0].start_at > Time.zone.now
          calendars[0].start_at

        elsif calendars[1].present?
          calendars[1].start_at
        end

      date || object.next_episode_at || (next_broadcast_at if with_broadcast)
    end
  end

  # для анонса перебиваем дату анонса на дату с анимекалендаря,
  # если таковая имеется
  def aired_on
    anons? && next_episode_at(false) ? next_episode_at(false) : object.aired_on
  end

  # тип элемента для schema.org
  def itemtype
    'http://schema.org/Movie'
  end

  def sorted_fansubbers
    @sorted_fansubbers ||= object.fansubbers
      .map { |name| fix_group_name name }
      .sort_by { |name| group_name_sort_criteria name }
  end

  def sorted_fandubbers
    @sorted_fandubbers ||= object.fandubbers
      .map { |name| fix_group_name name }
      .sort_by { |name| group_name_sort_criteria name }
  end

private

  def next_broadcast_at
    if broadcast_at && broadcast_at > 1.week.ago
      broadcast_at < 1.hour.ago ? broadcast_at + 1.week : broadcast_at
    end
  end

  def fix_group_name name
    name.gsub(/\.(?:tv|ru|com|net|online|su)/i, '')
  end

  def group_name_sort_criteria name
    name.downcase.gsub(/[^a-zа-я]/i, '')
  end
end
