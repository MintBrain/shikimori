describe Animes::UpdateFranchises do
  subject(:call) { described_class.call }

  context 'no chronology' do
    let!(:anime) { create :anime, name: 'test: qweyt', franchise: 'zxc' }
    before { call }
    it { expect(anime.reload.franchise).to be_nil }
  end

  context 'has chronology' do
    let!(:anime_1) { create :anime, name: 'test: qweyt' }
    let!(:anime_2) { create :anime, name: 'testá fo' }
    let!(:anime_3) { create :anime, name: 'fofofo', franchise: franchise }
    let(:franchise) { 'zxc' }

    let!(:relation_12) { create :related_anime, source: anime_1, anime: anime_2 }
    let!(:relation_21) { create :related_anime, source: anime_2, anime: anime_1 }
    let!(:relation_23) { create :related_anime, source: anime_2, anime: anime_3 }
    let!(:relation_32) { create :related_anime, source: anime_3, anime: anime_2 }

    context 'successfull rename' do
      subject! { call }

      it do
        expect(anime_1.reload.franchise).to eq 'test'
        expect(anime_2.reload.franchise).to eq 'test'
        expect(anime_3.reload.franchise).to eq 'test'
      end
    end

    describe 'scope passed to call method' do
      subject!(:call) { described_class.new.call [anime_1, anime_2] }

      let!(:relation_23) { nil }
      let!(:relation_32) { nil }

      it do
        expect(anime_1.reload.franchise).to eq 'test'
        expect(anime_2.reload.franchise).to eq 'test'
        expect(anime_3.reload.franchise).to eq 'zxc'
      end
    end

    describe 'safe achievement franchises rename' do
      let(:franchise) { 'gintama' }

      it do
        expect { call }.to raise_error(
          "cant't rename `gintama` -> `test` because found in NekoRepository"
        )
      end
    end
  end
end
