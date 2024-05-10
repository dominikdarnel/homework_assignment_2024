# Pipeline CRM Homework Assignment
The goal of this Ruby on Rails & React homework assignment is to assess your ability to resolve issues and implement new functionality in a scalable and simple manner while utilizing best practices within each domain.

This repository mocks a CRM in the simplest of terms by demonstrating the one to many relationship of Companies to Deals and visualizng various attributes of each to our users.

Unfortunately, the current implementation is (intentionally) naive and not working as expected in several ways.  

Your primary task with this homework assignment is to resolve the user stories below.

## Expected Level of Investment
*Estimated time to completion: 3-4 hours*

## User Stories
- [x] The frontend is not properly fetching data, i.e. filters aren't being sent, requests are being sent too often, non-successful response codes aren't being handled, etc.
- [x] The backend is taking too long to return the expected data, i.e.  filters aren't being applied, too much data is being returned, db performance isn't optimized, etc.
- [x] The confidence in our current functionality and ability to deploy additional changes is extremely low.  Help us increase our confidence in an automated way.
- [x] The confidence in our security posture is also very low.  Help us increase our confidence that we are running a securely designed application.

## Assumptions

Assumptions to make regarding the user story for this service:

- The service is not write-intensive, but is read-intensive.
- The seed data is quite minimal. Assume the production system could have thousands (or millions) of records.

## Instructions
#### Installation
- `bundle install`
- `yarn install`
- `bundle exec rails db:setup`

#### Running the App
- `bin/dev`

#### Running tests
- `rspec spec`

#### Submission
- Clone the repository
- Setup a new repository with the source code
- Implement solution
- Push your solution to a new branch
- Create a Pull Request within the new repository
- When you're ready, share a link to the Pull Request with us 
 

## FAQ
#### How will I be evaluated?

Some of the things we will look at in our evaluation:
- **Functional correctness** - Does the solution function correctly and meet the requirements of the User Stories.
- **Code quality** - How you reason about making sure code is readable and maintainable.
- **Testing** - How you reason about what to test and how to test it.
- **Performance** - How you can identify performance bottlenecks and reason around solving them.
- **System design** - How you reason about concepts like reusability, separation of concerns and various abstractions.

In this we also try to understand how you solve problems generally and how you communicate your solutions. Problem solving and communication are both things we value highly.

Finally, we encourage candidates to focus on quality over quantity. Feel free to add notes/comments/etc highlighting what you would expand or improve given more time.

#### Why did you pick this stack?
This is the stack that the majority of our platform is written in.

#### Can I change things in the existing code?
Of course! The existing code is simply to serve as a simple foundation.  Feel free to modify in any way you prefer.

#### Can I use additional libraries/frameworks?
You're free to use whatever you want. The important thing is that you can explain why you made the decision.

#### Asking for Help
You can reach out to Alan at [first name]@pipelinecrm.com for any questions about this homework assignment. We encourage you to ask for help if you're blocked or are unsure about requirements, but consider time-boxing your troubleshooting to 20 minutes before reaching out to us.



# Notes on User Stories

## User Story #1

> The frontend is not properly fetching data, i.e. filters aren't being sent, requests are being sent too often, non-successful response codes aren't being handled, etc.

**Identified problems**

- heavy computation handled in UI, instead of DB: `company.deals.reduce((sum, deal) => sum + deal.amount, 0)`
- filter form values were not being sent in the URL
- response errors were not handled
- loading states were not handled
- caching was not used to reduce outgoing requests
- form fields were stored in individual states (it is not necessary at the moment)

**Implemented solutions**
- deal amount aggregation is moved to the DB, see `Api::V1::CompaniesController#companies_scope`
- `react-query` is used to handle Server State: fetching companies, caching, error/loading state handling etc.
- findividual form field states were removed, combined them into a single `queryString` state

**What could be improved**
- Next button is not disabled on the last page (the server does not provide pagination info)
- `Home.jsx` could have been refactored, child components could have been broken out, e.g. `FilterForm`, `Paginator`, `DataTable`, etc.
- Styling

## User Story #2

> The backend is taking too long to return the expected data, i.e.  filters aren't being applied, too much data is being returned, db performance isn't optimized, etc.

**Identified problems**

- `companies.as_json(include: :deals)` created an N + 1 query, and includes every associated deal per company (could be millions of deals)
- `Company.all` returns all the companies in the DB, could be millions
- necessary indexes were not created
- API errors were not handled

**Implemented solutions**

- implemented filtering in `CompanyFilterQuery` class
- pagination implemented through `kaminari` gem
- necessary indexes were implemented: `index_deals_on_company_id_and_amount` 
- rescuing 500 errors were implemented in `AplicationController`

**What could be improved**

- query could be much faster, see details [here](#db-performance-indexing-possible-improvements)
- API does not return pagination metadata, so the client cannot know if it has reached the last page

## User Story #3

> The confidence in our current functionality and ability to deploy additional changes is extremely low.  Help us increase our confidence in an automated way.

**Identified problems**

- the application did not have any automated tests

**Implemented solutions**

- created backend test suite with `rspec`

**What could be improved**

- UI (or E2E) tests could be created, with either `cypress`, or `playwright`


## User Story #4

> The confidence in our security posture is also very low.  Help us increase our confidence that we are running a securely designed application.

**Identified problems**

- the application does not have any kind of authentication/authorization

**Implemented solutions**

- payed careful attention to follow Rails guidelines, so filter parameters are handled safely, avoiding the possibility of SQL injection

**What could be improved**

- autentication could be added, e.g. `Token-Based Authentication (JWT))`


## Implementation details, decisions

### DB Scale

200k companies, 1M deals, generated with the `TestDataGenerator` class, during seeding

### DB Performance, indexing, possible improvements

The query that is being produced by the server, to fulfill filtering, pagination, and aggregation requirements looks like the following:

```sql
SELECT
	companies.id,
	companies.name,
	companies.industry,
	companies.employee_count,
	COALESCE(SUM(deals.amount), 0) AS total_deal_amount
FROM
	companies
	LEFT OUTER JOIN deals ON deals.company_id = companies.id
WHERE (companies.name LIKE 'Company - 2%')
	AND(companies.industry LIKE 'Photo%')
	AND(companies.employee_count >= '300')
GROUP BY
	companies.id
ORDER BY
	companies.created_at DESC
LIMIT 10 OFFSET 0;

```

This query's performance is not as fast as it could be: currently it ranges from 90ms to 1s, under the number of records detailed above. This number is mainly dependent on how the `WHERE` clauses are being used and combined.  

This query was tested with several different indexes, but MySQL's Query Planner always chose to only use the `index_deals_on_company_id_and_amount` index. For this reason, I have not created any other indexes (to save tabble space), although it would be necessary in a real system that uses other queries.

**Possible approaches to improve query performance:**

- The query could be saved into a materialized view, updated in certain time intervals. Unfortunately MySQL does not support materialized views at the moment, to the best of my knowledge.
- Adding a pre-aggregated column (`deals_total_amount`) to the companies table could speed things up drastically. This field could be updated by DB triggers: when a new deal is inserted for a certain company, or a company's deal gets deleted or updated, that company's deals_total_amount column could be recalculated. Because we assume that this is a read heavy system, and writes are less frequent, the problem of racing conditions and DB level locking could be neglected at the moment.

## Backend

- For filtering, a custom solution was implemented, instead of a gem, like `ransack`. Under scale, it is better to have full control of the queries the server is generating.  
For this reason, `CompanyFilterQuery` was created, inspired by this article: [Thoughtbot - A Case for Query Objects in Rails](https://thoughtbot.com/blog/a-case-for-query-objects-in-rails)
- for pagination, `kaminari` was used, because of its popularity and ease of use.


## Frontend

- For handling states, `react-query` was chosen. It handles server-state perfectly, with minimal code, supporting several UI states, pagination, error handling, and caching out of the box. `Redux` was not considered, it would have been overengineering, and requires a lots of boilerplate.
- The form fields were removed from state, because of the suggestions of this article: [Kent C. Dodds - Improve the Performance of your React Forms](https://epicreact.dev/improve-the-performance-of-your-react-forms/).
