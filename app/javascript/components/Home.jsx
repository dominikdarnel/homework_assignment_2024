import React, { useState } from "react";
import {useQuery} from 'react-query'

const fetchFilteredCompanies = async ({queryKey}) => {
  const [_, queryString, page] = queryKey
  const url = `/api/v1/companies?${queryString}&page=${page}`;
  const res = await fetch(url)      
  return res.json();
}

export default () => {
  const [queryString, setQueryString] = useState('')
  const [page, setPage] = useState(1)

  const {
    data: companies,
    error,
    isFetching,
    isLoading,
    isError
  } = useQuery(['companies', queryString, page], fetchFilteredCompanies, {keepPreviousData: true})

  const handleSubmit = (event) => {
    event.preventDefault()

    const formData = new FormData(event.currentTarget)
    const fieldValues = Object.fromEntries(formData.entries())

    let queryString = new URLSearchParams(fieldValues).toString()
    setQueryString(queryString)
  }

  const handleReset = (_event) => {
    setPage(1)
    setQueryString('')
  }

  const handleNext = () => {
    setPage(old => old + 1)
  }

  const handlePrevious = () => {
    setPage(old => Math.max(old - 1, 0))
  }

  return (
    <div className="vw-100 primary-color d-flex align-items-center justify-content-center">
      <div className="jumbotron jumbotron-fluid bg-transparent">
        <div className="container secondary-color">
          <h1 className="display-4">Companies</h1>

          <form onSubmit={handleSubmit} onReset={handleReset}>
            <label htmlFor="company-name">Company Name</label>
            <div className="input-group mb-3">
              <input type="text" className="form-control" name="company_name" id="company-name" />
            </div>

            <label htmlFor="industry">Industry</label>
            <div className="input-group mb-3">
              <input type="text" className="form-control" name='industry' id="industry" />
            </div>

            <label htmlFor="min-employee">Minimum Employee Count</label>
            <div className="input-group mb-3">
              <input type="text" className="form-control" name='minimum_employee_count' id="min-employee" />
            </div>

            <label htmlFor="min-amount">Minimum Deal Amount</label>
            <div className="input-group mb-3">
              <input type="text" className="form-control" name='minimum_deal_total' id="min-amount" />
            </div>

            <button type="reset" className="btn btn-primary">
              Reset
            </button>
            <button type="submit" className="btn btn-primary">
              Apply
            </button>
          </form>

          <table className="table">
            <thead>
              <tr>
                <th scope="col">Name</th>
                <th scope="col">Industry</th>
                <th scope="col">Employee Count</th>
                <th scope="col">Total Deal Amount</th>
              </tr>
            </thead>
            <tbody>
              
            {isLoading ? (
              <tr><td>Loading...</td></tr>
            ) : isError ? (
              <tr><td>Error: {error.message}</td></tr>
            ) : (companies?.map((company) => (
                <tr key={company.id}>
                  <td>{company.name}</td>
                  <td>{company.industry}</td>
                  <td>{company.employee_count}</td>
                  <td>{company.total_deal_amount}</td>
                </tr>
              )))}
            </tbody>
          </table>
          
          <span>Current page: {page}</span>
          <button className="btn btn-secondary" onClick={handlePrevious} disabled={page === 1}>Previous</button>
          <button className="btn btn-secondary" onClick={handleNext}>Next</button>
          {isFetching ? <span> Loading...</span> : null}{' '}
        </div>
      </div>
    </div>
  )
};
