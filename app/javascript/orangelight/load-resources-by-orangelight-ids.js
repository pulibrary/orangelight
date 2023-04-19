
import apollo from './graphql-client.js'
import gql from 'graphql-tag'

async function loadResourcesByOrangelightIds(ids) {

  const query = gql`
    query GetResourcesByOrangelightIds($ids: [String!]!) {
      resourcesByOrangelightIds(ids: $ids) {
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
           orangelightId
         },
         ... on ScannedMap {
           manifestUrl,
           orangelightId
         },
         ... on Coin {
           manifestUrl,
           orangelightId
         }
      }
    }`

  const variables = {
    ids: ids
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

export default loadResourcesByOrangelightIds
