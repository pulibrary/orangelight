import apollo from './graphql-client.js'
import gql from 'graphql-tag'

async function loadResourcesByFiggyIds(ids) {

  const query = gql`
    query GetResourcesByFiggyIds($ids: [ID!]!) {
      resourcesByFiggyIds(ids: $ids) {
         id,
         thumbnail {
           iiifServiceUrl,
           thumbnailUrl
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

export default loadResourcesByFiggyIds
