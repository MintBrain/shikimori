describe ModerationPolicy do
  let(:policy) { ModerationPolicy.new user, :ru, moderation_filter }
  let(:moderation_filter) { true }

  describe '#reviews_count' do
    before do
      allow(Review)
        .to receive_message_chain(:pending, :where, :size)
        .and_return(reviews_count)
    end
    let(:reviews_count) { 1 }
    let(:user) { build :user, :review_moderator }

    it { expect(policy.reviews_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.reviews_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.reviews_count).to eq 0 }
    end

    context 'no moderation filter' do
      let(:moderation_filter) { false }

      context 'not moderator' do
        let(:user) { build :user, :user }
        it { expect(policy.reviews_count).to eq 1 }
      end

      context 'no user' do
        let(:user) { nil }
        it { expect(policy.reviews_count).to eq 1 }
      end
    end
  end

  describe '#collections_count' do
    before do
      allow(Collection)
        .to receive_message_chain(:pending, :published, :where, :size)
        .and_return(collections_count)
    end
    let(:collections_count) { 1 }
    let(:user) { build :user, :collection_moderator }

    it { expect(policy.collections_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.collections_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.collections_count).to eq 0 }
    end

    context 'no moderation filter' do
      let(:moderation_filter) { false }

      context 'not moderator' do
        let(:user) { build :user, :user }
        it { expect(policy.collections_count).to eq 1 }
      end

      context 'no user' do
        let(:user) { nil }
        it { expect(policy.collections_count).to eq 1 }
      end
    end
  end

  describe '#abuses_total_count, #abuses_abuses_count, #abuses_pending_count' do
    before do
      allow(AbuseRequest)
        .to receive_message_chain(:abuses, :size)
        .and_return(abuse_abuses_count)

      allow(AbuseRequest)
        .to receive_message_chain(:pending, :size)
        .and_return(abuses_pending_count)
    end
    let(:abuse_abuses_count) { 1 }
    let(:abuses_pending_count) { 2 }
    let(:user) { build :user, :forum_moderator }

    it do
      expect(policy.abuses_total_count).to eq 3
      expect(policy.abuses_abuses_count).to eq 1
      expect(policy.abuses_pending_count).to eq 2
    end

    context 'not moderator' do
      let(:user) { build :user, :user }
      it do
        expect(policy.abuses_total_count).to eq 0
        expect(policy.abuses_abuses_count).to eq 0
        expect(policy.abuses_pending_count).to eq 0
      end
    end

    context 'no user' do
      let(:user) { nil }
      it do
        expect(policy.abuses_total_count).to eq 0
        expect(policy.abuses_abuses_count).to eq 0
        expect(policy.abuses_pending_count).to eq 0
      end
    end
  end

  describe '#all_content_versions_count' do
    before do
      allow(Moderation::VersionsItemTypeQuery)
        .to receive_message_chain(:call, :pending, :size)
        .and_return(versions_count)
    end
    let(:versions_count) { 1 }
    let(:user) { build :user, :version_moderator }

    it { expect(policy.all_content_versions_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.all_content_versions_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.all_content_versions_count).to eq 0 }
    end
  end

  describe '#texts_versions_count' do
    before do
      allow(Moderation::VersionsItemTypeQuery)
        .to receive_message_chain(:call, :pending, :size)
        .and_return(versions_count)
    end
    let(:versions_count) { 1 }
    let(:user) { build :user, :version_texts_moderator }

    it { expect(policy.texts_versions_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.texts_versions_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.texts_versions_count).to eq 0 }
    end
  end

  describe '#content_versions_count' do
    before do
      allow(Moderation::VersionsItemTypeQuery)
        .to receive_message_chain(:call, :pending, :size)
        .and_return(content_versions_count)
    end
    let(:content_versions_count) { 1 }
    let(:user) { build :user, :version_moderator }

    it { expect(policy.content_versions_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.content_versions_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.content_versions_count).to eq 0 }
    end
  end

  describe '#fansub_versions_count' do
    before do
      allow(Moderation::VersionsItemTypeQuery)
        .to receive_message_chain(:call, :pending, :size)
        .and_return(fansub_versions_count)
    end
    let(:fansub_versions_count) { 1 }
    let(:user) { build :user, :version_fansub_moderator }

    it { expect(policy.fansub_versions_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.fansub_versions_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.fansub_versions_count).to eq 0 }
    end
  end
end
