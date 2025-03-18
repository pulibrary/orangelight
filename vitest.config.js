import { defineConfig } from 'vitest/config';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  test: {
    include: ['spec/javascript/**/*.spec.js'],
    globals: true,
    environment: 'jsdom',
    setupFiles: ['source/setup-jest.js'],
  },
  plugins: [vue()],
  define: {
    Global: {
      graphql: {
        uri: 'https://figgy.princeton.edu/graphql',
      },
      figgy: {
        uri: 'https://figgy.princeton.edu',
      },
    },
  },
});
