# Crepe [![Build Status][1]][2] [![Code Climate][3]][4]

The thin API stack.

[1]: https://img.shields.io/travis/crepe/crepe.svg?style=flat
[2]: https://travis-ci.org/crepe/crepe
[3]: https://img.shields.io/codeclimate/github/crepe/crepe.svg?style=flat
[4]: https://codeclimate.com/github/crepe/crepe

## Introduction

Crepe is an API micro-framework for Ruby. It is designed with speed in mind, while also providing an elegant DSL to simplify how you write your RESTful APIs.

## Resources

 * Report bugs or request new features on the [issue tracker][issues]
 * View Crepe's [documentation][documentation]
 * Join the [IRC Channel][irc] on Freenode for additional help
 * Check out the [Crepe organization][org] for plugins and utilities that extend Crepe

[documentation]: http://rdoc.info/github/crepe/crepe/master/frames
[irc]: http://webchat.freenode.net/?channels=crepe
[issues]: https://github.com/crepe/crepe/issues
[org]: https://github.com/crepe

## Installation

Crepe is made available as a Ruby gem. If you're using Bundler, include it in your `Gemfile`:

```ruby
gem 'crepe'
```

Or, you can install it manually:

```sh
$ gem install crepe
```

## Usage

Crepe applications are created by subclassing `Crepe::API`. The following is a simple example to showcase some of Crepe's more common features, an API to perform CRUD operations on a User class:

```ruby
# config.ru
require 'crepe'

class UserAPI < Crepe::API
  let(:user_params) { params.require(:user).permit :email, :password }

  get  { User.all }
  post { User.create!(user_params) }

  param id: /\d+/ do
    let(:user) { User.find(params[:id]) }

    get    { user }
    put    { user.update_attributes!(params[:user]) }
    patch  { user.update_attributes!(params[:user]) }
    delete { user.destroy! }
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    error! :not_found, e.message
  end

  rescue_from ActiveRecord::InvalidRecord do |e|
    error! :unprocessable_entity, e.message, errors: e.record.errors
  end
end

```


``` ruby
# config.ru
require 'crepe'

class TwitterAPI < Crepe::API
  let(:user) { User.find_by(username: params[:username]) }

  before { user.authorize!(params[:password]) }

  namespace :statuses do
    helper do
      let(:tweet_params)    {
        params.require(:status).permit :message, :in_reply_to_status_id
      }
      let(:current_tweet)   { current_user.tweets.find params[:id] }
    end

    # endpoints
    get(:home_timeline)     { current_user.timeline }
    get(:mentions_timeline) { current_user.mentions }
    get(:user_timeline)     { current_user.tweets }
    get(:retweets_of_me)    { current_user.tweets.retweeted }

    post(:update)           { current_user.tweets.create! tweet_params }
    get('show/:id')         { current_tweet }
    get('retweets/:id')     { current_tweet.retweets }
    post('destroy/:id')     { current_tweet.destroy }
    post('retweet/:id')     { current_user.retweet! Tweet.find params[:id] }

    stream(:firehose)       { Tweet.stream { |t| render t } }
    stream(:sample)         { Tweet.sample.stream { |t| render t } }
  end

  get('search/tweets')      { Tweet.search params.slice Tweet::SEARCH_KEYS }
  stream(:user)             { current_user.timeline.stream { |t| render t } }

  rescue_from ActiveRecord::RecordNotFound do |e|
    error! :not_found, e.message
  end
  rescue_from ActiveRecord::InvalidRecord do |e|
    error! :unprocessable_entity, e.message, errors: e.record.errors
  end
  rescue_from User::Unauthorized do |e|
    unauthorized! realm: 'Twitter API'
  end
end

run TwitterAPI
```

## License

(The MIT License.)

© 2013–2014 Stephen Celis <stephen@stephencelis.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
