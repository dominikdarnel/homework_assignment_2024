class Api::V1::CompaniesController < ApplicationController
  def index
    companies = CompanyFilterQuery.call(params, companies_scope).page(params[:page])
    render json: companies.as_json
  end

  private

  def companies_scope
    Company.joins(:deals)
           .select('companies.id, companies.name, companies.industry, companies.employee_count', 'SUM(deals.amount) AS total_deal_amount')
           .group('companies.id')
           .order(created_at: :desc)
  end
end
