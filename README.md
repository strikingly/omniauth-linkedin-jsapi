# OmniAuth LinkedIn JSAPI Strategy

[![Build Status](https://travis-ci.org/strikingly/omniauth-linkedin-jsapi.png?branch=master)](https://travis-ci.org/strikingly/omniauth-linkedin-jsapi)

A LinkedIn strategy with JSAPI token exchange for OmniAuth.

For more details, read the LinkedIn documentation: https://developer.linkedin.com/documents/exchange-jsapi-tokens-rest-api-oauth-tokens

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-linkedin-jsapi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-linkedin-jsapi

## Hello World

Register your application on LinkedIn Developer Center to get a pair of API key and secret key: https://www.linkedin.com/secure/developer

Here is a simple example to put into a Rails initializer at `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET']
end
```

Now you can send request to the OmniAuth LinkedIn URL: `/auth/linkedin`.

## Permission Scope

With the LinkedIn API, you have the ability to specify which permissions you want users to grant your application. By default, omniauth-linkedin-jsapi requests the following permissions:

    'r_basicprofile r_emailaddress'

You can configure the scope option like this:

```ruby
provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], 
         :scope => 'r_fullprofile r_emailaddress r_network'
```

## Profile Fields

When specifying which permissions you want to users to grant to your application, you will probably want to specify the array of fields that you want returned in the omniauth hash. The list of default fields is as follows:

```ruby
['id', 'email-address', 'first-name', 'last-name', 'headline', 'location', 'industry', 'picture-url', 'public-profile-url']
```

Here's an example of a possible configuration where the fields returned from the API are: id, email-address, first-name and last-name.

```ruby
provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], 
         :fields => ['id', 'email-address', 'first-name', 'last-name']
```

To see a complete list of available fields, consult the LinkedIn documentation at: https://developer.linkedin.com/documents/profile-fields

## Customize Path

Omniauth by default goes to /auth/:provider for request phase and /auth/:provider/callback for callback phase. You can customize that by specifying path_prefix:

```ruby
provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], 
         :path_prefix => '/s/v1/auth' # the request path will be /s/v1/auth/:provider and callback /s/v1/auth/:provider/callback
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push the change (`git push origin my-new-feature`)
5. Create new Pull Request
