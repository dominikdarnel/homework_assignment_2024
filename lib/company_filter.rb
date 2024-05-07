class CompanyFilter
  class << self
    def call(scope, params)
      scope = with_necessary_joins(scope)
      scope = by_company_name(scope, params[:company_name])
      scope = by_industry(scope, params[:industry])
      scope = by_minimum_employee_count(scope, params[:minimum_employee_count])
      scope = by_maximum_deal_amount(scope, params[:maximum_deal_amount])
      scope
    end
  
    private

    def with_necessary_joins(scope)
      scope.joins(:deals).preload(:deals)
    end
  
    def by_company_name(scope, company_name)
      return scope if company_name.blank?
  
      scope.where('companies.name LIKE ?', ApplicationRecord.sanitize_sql_like(company_name) + '%')
    end
  
    def by_industry(scope, industry)
      return scope if industry.blank?
  
      scope.where('companies.industry LIKE ?', ApplicationRecord.sanitize_sql_like(industry) + '%')
    end
  
    def by_minimum_employee_count(scope, minimum_employee_count)
      return scope if minimum_employee_count.blank?
  
      scope.where('companies.employee_count >= ?', minimum_employee_count)
    end
  
    def by_maximum_deal_amount(scope, maximum_deal_amount)
      return scope if maximum_deal_amount.blank?
  
      scope.where('deals.amount <= ?', maximum_deal_amount)
    end
  end
end
