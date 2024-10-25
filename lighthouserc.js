module.exports = {
  ci: {
    assert: {
      assertions: {
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.73 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 19000 }],
        'errors-in-console': ['error', { maxLength: 10 }],
      },
    },
    collect: {
      url: [
        'http://localhost:2999', // The catalog home page
        'http://localhost:2999/catalog/99122304923506421', // A show page
      ],
      startServerCommand:
        'BIBDATA_BASE=https://bibdata.princeton.edu bundle exec rails server -p 2999',
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
