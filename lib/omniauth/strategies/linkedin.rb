require 'oauth'
require 'omniauth'
require 'base64'
require 'openssl'

module OmniAuth
  module Strategies
    # Authentication strategy for connecting by [exchanging LinkedIn JSAPI for REST API 
    # OAuth Tokens](http://developer.linkedin.com/documents/exchange-jsapi-tokens-rest-api-oauth-tokens).
    class LinkedIn
      include OmniAuth::Strategy
      class NoSecureCookieError < StandardError; end
      class InvalidSecureCookieError < StandardError; end

      args [:api_key, :secret_key]

      option :name, 'linkedin'

      option :api_key, nil
      option :secret_key, nil

      option :fields, ["id", "email-address", "first-name", "last-name", "headline", "industry", "picture-url", "public-profile-url", "location"]

      option :scope, 'r_basicprofile r_emailaddress'

      uid { raw_info['id'] }

      info do
        {
          :name => user_name,
          :email => raw_info['emailAddress'],
          :nickname => user_name,
          :first_name => raw_info['firstName'],
          :last_name => raw_info['lastName'],
          :location => raw_info['location'],
          :description => raw_info['headline'],
          :image => raw_info['pictureUrl'],
          :urls => {
            'public_profile' => raw_info['publicProfileUrl']
          }
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get("/v1/people/~:(#{options.fields.join(',')})?format=json").body)
      end

      attr_accessor :access_token

      def callback_phase 
        if request_contains_secure_cookie?
          # We should already have an oauth2 token from secure cookie. 
          # Need to exchange it for an oauth token for REST API
          client = OAuth::Consumer.new(options.api_key, options.secret_key, 
            :site => 'https://api.linkedin.com',
            :http_method        => :post,
            :request_token_path => '/uas/oauth/requestToken',
            :authorize_path     => '/uas/oauth/authorize',
            :access_token_path  => '/uas/oauth/accessToken'
          )
          self.access_token = client.get_access_token(nil, {}, {:xoauth_oauth2_access_token => secure_cookie['access_token']})
          super
        else
          raise NoSecureCookieError, 'must pass a `linkedin_oauth_XXX` cookie'
        end
      end

      private

      def request_contains_secure_cookie?
        secure_cookie && secure_cookie['access_token']
      end

      def secure_cookie
        @secure_cookie ||= raw_secure_cookie && parse_secure_cookie(raw_secure_cookie)
      end

      def raw_secure_cookie
        request.cookies["linkedin_oauth_#{options.api_key}"]
      end

      def parse_secure_cookie(cookie)
        payload = JSON.parse cookie
        if validate_signature(options.secret_key, payload)
          payload
        else
          raise InvalidSecureCookieError, 'secure cookie signature validation fails'
        end
      end

      def validate_signature(secret, payload)
        valid = false
        if payload['signature_version'] == '1'
          if payload['signature_order'].present? and payload['signature_order'].is_a?(Array)
            plain_msg = payload['signature_order'].map {|key| payload[key]}.join('')
            if payload['signature_method'] == 'HMAC-SHA1'
              signature = Base64.encode64(OpenSSL::HMAC.digest('sha1', secret, plain_msg)).chomp
              if signature == payload['signature']
                valid = true
              end
            end
          end
        end
        valid
      end

      def user_name
        name = "#{raw_info['firstName']} #{raw_info['lastName']}".strip
        name.empty? ? nil : name
      end

    end

  end
end
OmniAuth.config.add_camelization 'linkedin', 'LinkedIn'