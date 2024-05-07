class Api::V1::CompaniesController < ApplicationController
  def index
    scope = Company.all.order(created_at: :desc)
    companies = CompanyFilter.call(scope, params).page(params[:page])
    render json: companies.as_json(include: :deals)
  end
end
