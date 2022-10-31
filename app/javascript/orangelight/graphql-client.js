import 'unfetch/polyfill'
import { ApolloClient } from '@apollo/client/core'
import { HttpLink } from '@apollo/client/core'
import { InMemoryCache } from '@apollo/client/cache'

const uri = window.Global.graphql.uri
const httpLink = new HttpLink({
  uri: uri
})

const fragmentMatcher = new InMemoryCache({
  introspectionQueryResultData: {
    __schema: {
      types: [
        {
          kind: "INTERFACE",
          name: "Resource",
          possibleTypes: [
            { name: "ScannedResource" },
            { name: "ScannedMap" },
            { name: "Coin" }
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
