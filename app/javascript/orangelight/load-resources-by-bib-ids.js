
import apollo from './graphql-client.js'
import gql from 'graphql-tag'

async function loadResourcesByBibIds(bibIds) {

  const query = gql`
    query GetResourcesByBibIds($bibIds: [String!]!) {
      resourcesByBibids(bibIds: $bibIds) {
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
           manifestUrl,
           sourceMetadataIdentifier
         },
         ... on ScannedMap {
           manifestUrl,
           sourceMetadataIdentifier
         }
      }
    }`

  const variables = {
    bibIds: bibIds
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

export default loadResourcesByBibIds
