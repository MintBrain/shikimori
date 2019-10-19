describe Api::V1::PeopleController, :show_in_doc do
  describe '#show' do
    before { get :show, params: { id: person.id }, format: :json }

    context 'person' do
      let(:person) { create :person }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json; charset=utf-8'
      end
    end

    context 'seyu' do
      let(:person) { create :person, seyu: true }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json; charset=utf-8'
      end
    end
  end

  describe '#search' do
    let!(:person_1) { create :person, name: 'asdf' }
    let!(:person_2) { create :person, name: 'zxcv' }

    before do
      allow(Autocomplete::Person).to receive(:call) do |params|
        params[:scope].where(id: person_1.id)
      end
    end
    before { get :search, params: { q: 'asd' }, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end
end
