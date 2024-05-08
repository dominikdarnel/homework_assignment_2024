require 'rails_helper'

RSpec.describe Api::V1::CompaniesController do
  describe '#index' do
    context 'when no filters are applied' do
      it 'returns 200 status' do  
        get :index
  
        expect(response).to have_http_status(:ok)
      end

      it 'returns a json' do
        company = create(:company)
  
        get :index
  
        expect(response.content_type).to include('application/json')
      end

      it 'lists companies in response' do
        company_one = create(:company)
        company_two = create(:company)
  
        get :index

        parsed_response = JSON.parse(response.body).map { |c| c['id'] }

        expect(parsed_response).to contain_exactly(company_one.id, company_two.id)
      end

      it 'returns company attributes with summed deal amounts' do
        company = create(
          :company,
          name: 'name',
          industry: 'industry',
          employee_count: 1
        )

        create(:deal, amount: 10, company: company)
        create(:deal, amount: 5, company: company)

        get :index

        parsed_response = JSON.parse(response.body)
        expected_response_body = [
          {
            'id' => company.id,
            'name' => 'name',
            'industry' => 'industry',
            'employee_count' => 1,
            'total_deal_amount' => 15
          }
        ]

        expect(parsed_response).to eq(expected_response_body)
      end
    end

    context 'when a filter is applied' do
      it 'returns filtered companies' do
        params = {
          company_name: 'Ap'
        }

        company_one = create(:company, name: 'Apple Inc.')
        company_two = create(:company, name: 'App Devs Ltd.')
        company_three = create(:company, name: 'Google Inc.')

        get :index, params: params

        parsed_response = JSON.parse(response.body).map { |c| c['id'] }

        expect(parsed_response).to contain_exactly(company_one.id, company_two.id)
      end
    end

    context 'when a company does not have any deals' do
      it 'total deals returns 0 instead of nil' do
        company = create(
          :company,
          name: 'name',
          industry: 'industry',
          employee_count: 1
        )

        get :index

        parsed_response = JSON.parse(response.body)
        expected_response_body = [
          {
            'id' => company.id,
            'name' => 'name',
            'industry' => 'industry',
            'employee_count' => 1,
            'total_deal_amount' => 0
          }
        ]

        expect(parsed_response).to eq(expected_response_body)
      end
    end

    context 'when an error happens' do
      before do
        allow(CompanyFilterQuery).to receive(:call).and_raise(StandardError)
      end

      it 'returns 500 status' do
        get :index

        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns error json' do
        get :index

        parsed_response = JSON.parse(response.body).symbolize_keys

        expect(parsed_response).to eq({error: 'Something went wrong.'})
      end
    end
  end
end
