require 'pusher'

Pusher.app_id = ApplicationConfig['PUSHER_APP_ID']
Pusher.key = ApplicationConfig['PUSHER_KEY']
Pusher.secret = ApplicationConfig['PUSHER_SECRET']
Pusher.cluster = 'us2'
Pusher.logger = Rails.logger
