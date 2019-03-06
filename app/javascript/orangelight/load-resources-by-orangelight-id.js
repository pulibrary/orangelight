import apollo from './graphql-client.js'
import gql from 'graphql-tag'

async function loadResourcesByOrangelightId(id) {

  const query = gql`
    query GetResourcesByOrangelightId($id: String!) {
      resourcesByOrangelightId(id: $id) {
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
         },
         ... on Coin {
           manifestUrl
         }
      }
    }`

  const variables = {
    id: id
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

export default loadResourcesByOrangelightId
