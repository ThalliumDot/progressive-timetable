const environment = require('./environment')
const webpack = require('webpack')
const merge = require('webpack-merge')


module.exports = merge(environment.toWebpackConfig(), {
  plugins: [
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: '"production"'
      }
    })
  ]
})
