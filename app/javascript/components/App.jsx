import React from "react";
import Routes from "../routes";
import {QueryClient, QueryClientProvider} from 'react-query'

const queryClient = new QueryClient()

export default _props => (
  <QueryClientProvider client={queryClient}>
    <>{Routes}</>
  </QueryClientProvider>
);
