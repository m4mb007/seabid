// config/tailwind.config.js
module.exports = {
    content: [
      './app/views/**/*.html.erb',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js'
    ],
    theme: {
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
    plugins: [],
  }