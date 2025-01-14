class Profiles::AchievementsPreviewView < ViewObjectBase
  vattr_initialize :user, :is_own_profile
  instance_cache :achievements_view

  delegate :franchise_achievements_size, to: :achievements_view
  delegate :all_franchise_achievements, to: :achievements_view

  def available?
    return false unless @user.preferences.achievements_in_profile?
    return false if @user.cheat_bot? && !@is_own_profile

    achievements_view.franchise_achievements_size.positive? ||
      achievements_view.common_achievements.size.positive? ||
      achievements_view.genre_achievements.size.positive?
  end

  def common_achievements
    achievements_view.common_achievements.shuffle.take(4).sort_by(&:sort_criteria)
  end

  def genre_achievements
    achievements_view.genre_achievements.shuffle.take(4).sort_by(&:sort_criteria)
  end

  def franchise_achievements
    all_franchise_achievements = achievements_view.user_achievements.select(&:franchise?)

    (
      all_franchise_achievements.select { |v| v.level == 1 }.shuffle +
        all_franchise_achievements.select { |v| v.level.zero? }.shuffle
    ).take(12).sort_by { |rule| [rule.level.zero? ? 1 : 0] + rule.sort_criteria }
  end

private

  def achievements_view
    Profiles::AchievementsView.new @user
  end
end
