import apollo from './graphql-client.js'
import gql from 'graphql-tag'

async function loadResourcesByBibId(bibId) {

  const query = gql`
    query GetResourcesByBibId($bibId: String!) {
      resourcesByBibid(bibId: $bibId) {
         id,
         thumbnail {
           iiifServiceUrl,
           thumbnailUrl
         },
         url,
         members {
           id
         },
         ... on ScannedResource {
           manifestUrl
         },
         ... on ScannedMap {
           manifestUrl
         }
      }
    }`

  const variables = {
    bibId: bibId
  }

  try {
    const response = await apollo.query({
      query, variables
    })
    return response.data
  } catch(err) {
    console.error(err)
    return null
  }
}

export default loadResourcesByBibId
