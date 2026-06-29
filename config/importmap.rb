# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin '@rails/actioncable', to: '@rails--actioncable.js' # @8.1.300
pin 'channels', to: 'channels/consumer.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
