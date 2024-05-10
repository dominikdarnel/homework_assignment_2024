class TestDataGenerator
  class << self
    def call
      return if Rails.env.production?
      return if Company.exists? || Deal.exists?

      ActiveRecord::Base.connection.execute('SET cte_max_recursion_depth = 4294967295')

      puts 'Inserting 200k comapnies...'
      ActiveRecord::Base.connection.execute(companies_sql)
      puts '200k companies successfully inserted.'

      puts 'Inserting 1M deals...'
      ActiveRecord::Base.connection.execute(deals_sql)
      puts '1M deals successfully inserted.'

      ActiveRecord::Base.connection.execute('SET cte_max_recursion_depth = 1000')
    end

    private

    def companies_sql
      <<-SQL.squish
        INSERT INTO companies (id, name, employee_count, industry, created_at, updated_at)
        WITH RECURSIVE counter(n) AS(
            SELECT 1 AS n
            UNION ALL
            SELECT n + 1 FROM counter WHERE n < 200000
        )
        SELECT
          counter.n,
          CONCAT('Company - ', counter.n),
          FLOOR(10 + RAND() * (500 - 10)), /* random number between 10 and 500 */
          ELT(1 + FLOOR(RAND() * 5), 'Healthcare', 'Aviation & Aerospace', 'Photography', 'Technology', 'Banking'), /* list of random industries */
          TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, NOW() - INTERVAL 2 WEEK, NOW() - INTERVAL 1 WEEK)), NOW() - INTERVAL 2 WEEK), /* random timestamp ranging from 1 week ago to 2 weeks ago */
          TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, NOW() - INTERVAL 1 WEEK, NOW())), NOW() - INTERVAL 1 WEEK) /* random timestamp ranging from current time to 1 weeks ago */
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
          FLOOR(1 + RAND() * 200000), /* random number from 1 to 200000 to match the already existing company ids */
          TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, NOW() - INTERVAL 2 WEEK, NOW() - INTERVAL 1 WEEK)), NOW() - INTERVAL 2 WEEK), /* random timestamp ranging from 1 week ago to 2 weeks ago */
          TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, NOW() - INTERVAL 1 WEEK, NOW())), NOW() - INTERVAL 1 WEEK) /* random timestamp ranging from current time to 1 weeks ago */
        FROM counter;
      SQL
    end
  end
end
