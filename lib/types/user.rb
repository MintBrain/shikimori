module Types
  module User
    ROLES = %i[
      super_moderator
      forum_moderator
      retired_moderator

      version_texts_moderator
      version_moderator
      version_fansub_moderator

      trusted_version_changer
      trusted_attached_video_changer
      not_trusted_version_changer
      review_moderator
      collection_moderator
      cosplay_moderator
      contest_moderator
      statistics_moderator

      video_super_moderator
      video_moderator
      api_video_uploader
      trusted_video_uploader
      not_trusted_video_uploader
      trusted_video_changer

      not_trusted_abuse_reporter
      censored_avatar
      censored_profile
      cheat_bot
      completed_announced_animes
      bot
      admin
    ]
    Roles = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ROLES)

    NOTIFICATION_SETTINGS = %i[
      any_anons
      any_ongoing
      any_released

      my_ongoing
      my_released
      my_episode

      private_message_email
      friend_nickname_change
      contest_event
    ]
    NotificationSettings = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NOTIFICATION_SETTINGS)
  end
end
