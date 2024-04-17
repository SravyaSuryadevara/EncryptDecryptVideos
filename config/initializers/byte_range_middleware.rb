# config/initializers/byte_range_middleware.rb

class ByteRangeMiddleware
    def initialize(app)
      @app = app
    end
  
    def call(env)
      status, headers, response = @app.call(env)
  
      if headers['Content-Type']&.start_with?('video/') && status == 200
        headers['Accept-Ranges'] = 'bytes'
      end
  
      [status, headers, response]
    end
  end
  
  Rails.application.config.middleware.insert_before 0, ByteRangeMiddleware
  