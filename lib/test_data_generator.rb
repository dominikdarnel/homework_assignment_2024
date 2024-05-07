class TestDataGenerator
  class << self
    def call
      return if Rails.env.production?
      return if Company.exists? || Deal.exists?

      ActiveRecord::Base.connection.execute('SET cte_max_recursion_depth = 4294967295')
      ActiveRecord::Base.connection.execute(companies_sql)
      ActiveRecord::Base.connection.execute(deals_sql) 
      ActiveRecord::Base.connection.execute('SET cte_max_recursion_depth = 1000')
    end

    private

    def companies_sql
      <<-SQL.squish
        INSERT INTO companies (id, name, employee_count, created_at, updated_at)
        WITH RECURSIVE counter(n) AS(
            SELECT 1 AS n
            UNION ALL
            SELECT n + 1 FROM counter WHERE n < 200000
        )
        SELECT
          counter.n,
          CONCAT('Company - ', counter.n),
          FLOOR(10 + RAND() * (500 - 10)), /* random number between 10 and 500 */
          CURTIME(),
          CURTIME()
        FROM counter;
      SQL
    end

    def deals_sql
      <<-SQL.squish
        INSERT INTO deals (id, name, amount, status, company_id, created_at, updated_at)
        WITH RECURSIVE counter(n) AS(
            SELECT 1 AS n
            UNION ALL
            SELECT n + 1 FROM counter WHERE n < 1000000
        )
        SELECT
          counter.n,
          CONCAT('Deal - ', counter.n),
          FLOOR(10 + RAND() * (50000 - 100)), /* random number between 100 and 50000 */
          ELT(1 + FLOOR(RAND() * 3), 'pending', 'won', 'lost'), /* select random statuses */
          FLOOR(1 + RAND() * 200000), /* random number from 1 to 200000 to much the already existing company ids */
          CURTIME(),
          CURTIME()
        FROM counter;
      SQL
    end
  end
end
