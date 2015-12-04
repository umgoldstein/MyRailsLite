require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      cookie = req.cookies.find {|c| c.name == '_rails_lite_app'}
        if cookie
          @value = JSON.parse(cookie.value)
        else
          @value = {}
        end
    end

    def [](key)
      @value[key]
    end

    def []=(key, val)
      @value[key]=val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      cookie = WEBrick::Cookie.new('_rails_lite_app',(JSON.generate(@value)))
      res.cookies << cookie
    end
  end
end
