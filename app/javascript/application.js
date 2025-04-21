// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Initialize Alpine.js only once
if (window.Alpine && !window.alpineInitialized) {
  window.Alpine.start()
  window.alpineInitialized = true
}

// Re-initialize Alpine.js components on Turbo navigation
document.addEventListener("turbo:load", () => {
  if (window.Alpine) {
    window.Alpine.initTree(document.body)
  }
})
