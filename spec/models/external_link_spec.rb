describe ExternalLink do
  describe 'associations' do
    it { is_expected.to belong_to :entry }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :entry }
    it { is_expected.to validate_presence_of :kind }
    it { is_expected.to validate_presence_of :source }
    it { is_expected.to validate_presence_of :url }
    # it { is_expected.to validate_uniqueness_of(:url).scoped_to(:entry_id, :entry_type, :source) }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in(*Types::ExternalLink::Kind.values) }
    it { is_expected.to enumerize(:source).in(*Types::ExternalLink::Source.values) }
  end

  describe 'instance methods' do
    describe '#url=' do
      let(:external_link) { build :external_link, url: 'zzz' }
      it { expect(external_link.url).to eq 'http://zzz' }
    end

    describe '#visible?' do
      let(:external_link) { build :external_link, kind: kind }

      context 'visible' do
        let(:kind) do
          (
            Types::ExternalLink::Kind.values - Types::ExternalLink::INVISIBLE_KINDS
          ).sample
        end
        it { expect(external_link).to be_visible }
      end

      context 'invisible' do
        let(:kind) { Types::ExternalLink::INVISIBLE_KINDS.sample }
        it { expect(external_link).to_not be_visible }
      end
    end

    describe '#disabled?' do
      let(:external_link) { build :external_link, url: url }
      let(:url) { 'https://ya.ru' }

      it { expect(external_link).to_not be_disabled }

      context 'NONE url' do
        let(:url) { ['http://NONE', 'https://NONE', 'NONE'].sample }
        it { expect(external_link).to be_disabled }
      end
    end

    describe '#label' do
      let(:external_link) { build :external_link, kind, url: url }
      subject { external_link.label }

      context 'not wikipedia' do
        let(:kind) { :official_site }
        let(:url) { 'zzz' }
        it { is_expected.to eq external_link.kind_text }
      end

      context 'wikipedia' do
        let(:kind) { :wikipedia }

        context 'ru' do
          let(:url) { 'https://ru.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          it { is_expected.to eq 'Википедия' }
        end

        context 'en' do
          let(:url) { 'https://en.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          it { is_expected.to eq 'Wikipedia' }
        end

        context 'ja' do
          let(:url) { 'https://ja.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          it { is_expected.to eq 'ウィキペディア' }
        end

        context 'zh' do
          let(:url) { 'https://zh.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          it { is_expected.to eq '维基百科' }
        end

        context 'other variants' do
          let(:url) { 'https://ru.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          it { is_expected.to eq external_link.kind_text }
        end
      end
    end
  end
end
