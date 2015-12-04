require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}
      @params.merge!(route_params)
      if req.body
        @params.merge!(parse_www_encoded_form(req.body))
      elsif req.query_string
        @params.merge!(parse_www_encoded_form(req.query_string))
      end
    end

    def [](key)
      @params[key.to_s] || @params[key.to_sym]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # [["user[address][street]", "main"], ["user[address][zip]", "89436"]]
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      hash = {}

      values = URI::decode_www_form(www_encoded_form)
      values.each do |first, last|

        first = parse_key(first)
        last = parse_key(last)
        if first.length == 1 && last.length == 1
          hash[first[0]] = last[0]
        else

          until first.empty?
            new_hash = {}

            if last.empty?
              hash[first.pop] = hash
            else
              new_hash[first.pop] = last.pop
              if hash[first.last]
                hash[first.pop][new_hash.keys[0]] = new_hash.values[0]
              else
                hash[first.pop] = new_hash
              end
            end
          end
        end
      end

      hash
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
