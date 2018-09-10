import 'unfetch/polyfill'
import { ApolloClient } from 'apollo-client'
import { createHttpLink } from 'apollo-link-http'
import { InMemoryCache, IntrospectionFragmentMatcher } from 'apollo-cache-inmemory'

const uri = window.Global.graphql.uri
const httpLink = createHttpLink({
  uri: uri
})

const fragmentMatcher = new IntrospectionFragmentMatcher({
  introspectionQueryResultData: {
    __schema: {
      types: [
        {
          kind: "INTERFACE",
          name: "Resource",
          possibleTypes: [
            { name: "ScannedResource" },
            { name: "ScannedMap" }
          ],
        },
      ],
    },
  }
})

const client = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache({ fragmentMatcher })
})

export default client
