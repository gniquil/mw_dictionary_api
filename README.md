# MWDictionaryAPI

## Information

MWDictionaryAPI provides some simple wrapper for one to start using Merriam Webster Developer API.
The difficult thing about the API is its response, which is in XML formatted for presentation rather than programatic access.

The bulk of this gem consists of a parser to help parse the results and reconcile some inconsistencies. I am not aiming to be complete in terms of translating response to ruby objects, but rather pulling in most of the useful and relevant data associated with normal usage of 
dictionary. 

If there are things that you need that are not covered, hopefully you will find the parser class to be easy to extend as that's how this gem was written (see the "Extending the parser" section below).
Then let me know and I will be happy to put them in.

Finally, at this point, only the "sd4" product (a designation for 9-11th grade students) has been tested. Nevertheless it's probably safe to use this with the "collegiate", "sd2", "sd3", and "learners" products as well, as the definition for the XML nodes are very similar.

## How to use

### Install the gem

I will submit the gem soon. TBD...

### Register and get your API_KEY and jot down the product type

Go to their website and obtain the API_KEY and product type. For now only `sd4` is tested.
`collegiate` should work as well. To determine the type of product, notice the API Request URL
on their developer site. The product type is the lower case value of the segment in the URL as
follows:

> http://www.dictionaryapi.com/api/v1/references/{sd4}/xml/hypocrite?key=...

### Create a new new client and query away

```ruby
require 'mw_dictionary_api'

client = MWDictionaryAPI::Client.new(ENV['MW_SD4_API_KEY'])
result = client.search("one")
p result.to_hash
```

To use other types of dictionaries

```ruby
client = MWDictionaryAPI::Client.new(ENV['MW_COLLEGIATE_API_KEY'], api_type: "collegiate")

# or change it after client has been created
client.api_type = "sd4"
client.api_key = ENV['MW_SD4_API_KEY']
```

### Customization

#### Caching

To avoid going over your request limit and provide faster response, responses are cached in 
memory

```ruby
client.search('one') # first time hits the api
client.search('one') # fetched directly from memory

# to force the update of the cache
client.search('one', update_cache: true)

# you can also skip the cache for all requests
MWDictionaryAPI::Client.cache = nil
client.search('one') # fetches from web again
```

Implementing your own cache is easy as well. All you need to do is provide a class that implements
`#find(term)`, `#add(term, response)`, `#remove(term)`, and optionally `#clear` methods. You can
easily adapt `activerecord` to semi-persist somewhere.

The following is actually the memory implementation used by default:

```ruby
class SimpleCache

  def self.find(term)
    cache[term]
  end

  def self.add(term, result)
    cache[term] = result
  end

  def self.remove(term)
    cache.delete(term)
  end

  # following methods are optional
  def self.clear
    cache.clear
  end

  def self.cache
    @cache ||= {}
  end
end

MWDictionaryAPI::Client.cache = SimpleCache
```

#### Extending the parser

At its core this gem uses a few different parser objects to parse the result. The response from
Merriam Webster is a list of `<entry>` elements. Therefore the default top level parser is
implemented as follows

```ruby
module MWDictionaryAPI
  module Parsers
    class ResultParser
      include MWDictionaryAPI::Parsable

      rule :entries do |data, opts| # entries is the key
        data.css("entry").inject([]) do |entries, xml_entry|
          parser = Parsers::EntryParser.new(api_type: opts[:api_type], response_format: opts[:response_format])
          entries << parser.parse(xml_entry)
          entries
        end
      end

      ...
    end
  end
end
```

The `Parsable` module allows you to use the `rule` macro. For now, please refer to the source code on how to use (or actually the spec/features/general_spec.rb is probably the best place
to start).

You can extend the parser functionalities by

1. reopening the `MWDictionaryAPI::Parsers::ResultParser`

2. or create your own by extending or create from scratch

```ruby
class MyParser < MWDictionaryAPI::Parsers::ResultParser
  ...
end

# or 

class MyParser
  include MWDictionaryAPI::Parsable
  ...
end
```

If you create your own, you can use them in 2 ways:

```ruby
MWDictionaryAPI::Client.parser_class = MyParser # configure before hand

# or

client.search("one", parser_class: MyParser)
```

Note that any `rule`s defined by the parent class are inherited. Nevertheless any `rule`s either
defined by the parent or the same class is overwritten if you use the same key.

## If you see problems

That's it. Please get in touch with me via github and let me know if you find any problems. I will be happy to fix it. 



