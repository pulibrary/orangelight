import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import vue from '@vitejs/plugin-vue';
import { resolve } from 'path'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    vue()
  ],
  resolve: {
    alias: {
      'vue': 'vue/dist/vue.esm-bundler',
      '@assets': resolve(__dirname, 'app/assets'),
    },
  },
  css: {
    preprocessorOptions: {
      scss: {
        loadPaths: ["./app/assets/stylesheets", "./node_modules"],
      }
    }
  }
})
