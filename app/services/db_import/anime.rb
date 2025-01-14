class DbImport::Anime < DbImport::ImportBase
  SPECIAL_FIELDS = %i[
    image synopsis
    genres studios related recommendations characters
    external_links
  ]
  IGNORED_FIELDS = %i[members favorites]

private

  def assign_synopsis synopsis
    super unless anidb_synopsis?
  end

  def assign_genres genres
    entry.genre_ids = genres.map { |v| find_or_create_genre(v).id }

    unless :is_censored.in? desynced_fields
      entry.is_censored = (entry.respond_to?(:rating_rx?) && entry.rating_rx?) ||
        entry.genres.any?(&:censored?)
    end
  end

  def find_or_create_genre data
    AnimeGenresRepository.instance.find_by_mal_id data[:id]
  rescue ActiveRecord::RecordNotFound
    Genre.create! mal_id: data[:id], name: data[:name], kind: :anime
  end

  def assign_studios studios
    entry.studio_ids = studios.map { |v| find_or_create_studio(v).id }
  end

  def find_or_create_studio data
    StudiosRepository.instance.find data[:id]
  rescue ActiveRecord::RecordNotFound
    Studio.create! id: data[:id], name: data[:name]
  end

  def assign_related related
    DbImport::Related.call entry, related
  end

  def assign_recommendations similarities
    DbImport::Similarities.call entry, similarities
  end

  def assign_external_links external_links
    DbImport::ExternalLinks.call entry, external_links
  end

  def assign_characters data
    if data[:characters].any? || data[:staff].any?
      DbImport::PersonRoles.call entry, data[:characters], data[:staff]
    end
  end

  def anidb_synopsis?
    entry.all_external_links.any? do |external_link|
      external_link.kind_anime_db? && external_link.imported_at.present?
    end
  end
end
