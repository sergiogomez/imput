# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( signin.css reports.css jquery-dynamic-selectable.js time.js rows.js reports.js projects.js timers.js email.css dashboard.js tasks.js Chart.min.js Chart.StackedBar.js ChartNew.js Chart.Colours.js)
