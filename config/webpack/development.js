const environment = require('./environment')
const merge = require('webpack-merge')

module.exports = merge(environment.toWebpackConfig(), {
  resolve: {
    alias: {
      vue: 'vue/dist/vue.js',
    }
  }
})
