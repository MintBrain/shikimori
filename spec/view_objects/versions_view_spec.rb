describe VersionsView do
  let(:view) { VersionsView.new }

  include_context :timecop, '2016-03-18 15:00:00'

  let!(:version_1) do
    create :version, :taken,
      created_at: 15.hours.ago,
      updated_at: 1.minute.ago
  end
  let!(:version_2) do
    create :version, :pending,
      created_at: 30.hours.ago,
      updated_at: 2.minutes.ago
  end
  let!(:version_3) do
    create :version, :accepted,
      created_at: 50.hours.ago,
      updated_at: 3.minutes.ago
  end
  let!(:version_4) do
    create :version, :deleted,
      created_at: 55.hours.ago,
      updated_at: 4.minutes.ago
  end

  let!(:moderator) { create :user, :version_texts_moderator }

  before do
    allow(view.h)
      .to receive(:params)
      .and_return type: 'texts', created_on: created_on
  end

  context 'no processed date' do
    let(:created_on) { nil }
    it do
      expect(view.processed.map(&:object)).to eq [version_1, version_3, version_4]
      expect(view.postloader?).to eq false
      expect(view.pending).to have(1).item
      expect(view.moderators).to eq [moderator]
    end
  end

  context 'with processed date' do
    let(:created_on) { 2.days.ago.to_date.to_s }
    it do
      expect(view.processed.map(&:object)).to eq [version_3, version_4]
      expect(view.postloader?).to eq false
      expect(view.pending).to have(1).item
      expect(view.moderators).to eq [moderator]
    end
  end
end
