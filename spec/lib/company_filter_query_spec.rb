require 'rails_helper'

RSpec.describe CompanyFilterQuery do
  describe '.call' do
    context 'when params has a company_name filter' do
      it 'returns filtered companies with names starting with param' do
        params = {
          company_name: 'Ap'
        }

        company_one = create(:company, name: 'Apple Inc.')
        company_two = create(:company, name: 'App Devs Ltd.')
        company_three = create(:company, name: 'Google Inc.')
        
        result = CompanyFilterQuery.call(params)

        expect(result).to contain_exactly(company_one, company_two)
      end
    end

    context 'when params has industry filter' do
      it 'returns filtered companies with industries starting with param' do
        params = {
          industry: 'Art'
        }

        company_one = create(:company, industry: 'Arts')
        company_two = create(:company, industry: 'Artificial Intelligence')
        company_three = create(:company, industry: 'Engineering')
        
        result = CompanyFilterQuery.call(params)

        expect(result).to contain_exactly(company_one, company_two)
      end
    end

    context 'when params has minimum_employee_count filter' do
      it 'returns filtered companies with employee_count greater or equal than param' do
        params = {
          minimum_employee_count: 5
        }

        company_one = create(:company, employee_count: 10)
        company_two = create(:company, employee_count: 5)
        company_three = create(:company, employee_count: 1)
        
        result = CompanyFilterQuery.call(params)

        expect(result).to contain_exactly(company_one, company_two)
      end
    end

    context 'when params has maximum_deal_amount filter' do
      it 'returns filtered companies with its deal amounts less or equal than param' do
        params = {
          maximum_deal_amount: 5
        }

        company_one = create(:company)
        create(:deal, amount: 1, company: company_one)

        company_two = create(:company)
        create(:deal, amount: 5, company: company_two)

        company_three = create(:company)
        create(:deal, amount: 10, company: company_three)
        
        result = CompanyFilterQuery.call(params)

        expect(result).to contain_exactly(company_one, company_two)
      end
    end

    context 'when all the filters are used' do
      it 'returns filtered companies' do
        params = {
          company_name: 'Ap',
          industry: 'Art',
          minimum_employee_count: 5,
          maximum_deal_amount: 5
        }

        company_one = create(
          :company,
          name: 'Apple Inc.',
          industry: 'Arts',
          employee_count: 10
        )
        create(:deal, amount: 1, company: company_one)

        company_two = create(
          :company,
          name: 'App Devs Ltd.',
          industry: 'Artificial Intelligence',
          employee_count: 5
        )
        create(:deal, amount: 1, company: company_two)

        company_three = create(
          :company,
          name: 'Google Inc.',
          industry: 'Engineering',
          employee_count: 1
        )
        create(:deal, amount: 10, company: company_three)

        result = CompanyFilterQuery.call(params)

        expect(result).to contain_exactly(company_one, company_two)
      end
    end

    context 'without filters' do
      it 'returns companies without filtering' do
        params = {}
      
        company_one = create(:company)
        
        result = CompanyFilterQuery.call(params)
  
        expect(result).to contain_exactly(company_one)
      end
    end

    context 'with injected scope' do
      it 'returns companies with that scope' do
        params = {}
        scope = Company.left_joins(:deals).select(:id)
        company_one = create(:company)
        
        result = CompanyFilterQuery.call(params, scope)
  
        expect(result).to contain_exactly(Company.new(id: company_one.id))
      end
    end
  end
end
