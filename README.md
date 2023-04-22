# AskChatGPT

[![RailsJazz](https://github.com/igorkasyanchuk/rails_time_travel/blob/main/docs/my_other.svg?raw=true)](https://www.railsjazz.com)
[![Listed on OpenSource-Heroes.com](https://opensource-heroes.com/badge-v1.svg)](https://opensource-heroes.com/o/railsjazz)

AI-Powered Assistant Gem right in your Rails console.

![AskChatGPT](docs/gpt.gif)

A Gem that leverages the power of AI to make your development experience more efficient and enjoyable. With this gem, you can streamline your coding process, effortlessly refactor and improve your code, and even generate tests on the fly.

We are welcoming you to propose new prompts or adjust existing ones!

## Usage

Go to Rails console and run:

```ruby
  gpt.ask("how to get max age of user with projects from Ukraine").with_model(User, Project, Country)
  gpt.ask("convert json to xml")
  gpt.refactor("User.get_report")
  gpt.improve("User.get_report")
  gpt.rspec_test(User)
  gpt.unit_test(User)
  gpt.code_review(User.method(:get_report))
  gpt.find_bug('User.full_name')
```

## Examples

Ask for code ideas:
![AskChatGPT](docs/gpt1.png)

Do you need help to write rspec test?
![AskChatGPT](docs/gpt2.png)

What about unit tests?
![AskChatGPT](docs/gpt3.png)

Ask ChatGPT to improve your code:
![AskChatGPT](docs/gpt4.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "ask_chatgpt"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install ask_chatgpt
```

## Options & Configurations

Run `rails g ask_chatgpt initializer`.

And you can edit:

```ruby
  AskChatGPT.setup do |config|
    # config.access_token = ENV["OPENAI_API_KEY"]
    # config.debug = false
    # config.model = "gpt-3.5-turbo"
    # config.temperature = 0.1
  end
```

Note: that you need to setup your API Key https://platform.openai.com/account/api-keys. You can store it in the .env or .bash_profile. BUT make sure it won't be committed to the Github. Is must be private.

## TODO

- cli app?
- more prompts (cover controllers, sql, etc?)
- tests
- can it be used with pry/byebug/etc?
- print tokens usage?
- support org_id?

## Contributing

You are welcome to contribute.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
