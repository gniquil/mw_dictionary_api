# MWDictionaryAPI

## Information

MWDictionaryAPI provides some simple wrapper for one to start using Merriam Webster Developer API.
At this point, only the "sd4" product (a designation for 9-11th grade students) has been tested 
(see the spec files). Nevertheless it's probably safe to use this with the "collegiate", "sd2", "sd3", and "learners" products as well, as the definition for the XML nodes are very similar.

The nice thing about this gem is it normalizes a few idiosyncracies of the MW API, namely:

1. entries vs definitions.

   When one searches the API, often MW returns a list of entries, each containing a list of definitions. Once translated into Ruby, it much easier to list or group them

2. sense number

   For each entry of the returned result, if there are multiple definitions, it is indexed by "sense_number". However MW's sense number is formatted for human reading, not for machines.
   For example, sense numbers can be "1", "2 a", "b (1)", "(2)", which should be translated to
   "1", "2a", "2b(1)", "2b(2)", and so on.

3. general formatting

   MW API's returned xml is formatted mostly according to how it is displayed on their webpage.
   Many markers for cross reference links, examples, and etc. are littered all over the text.
   This gem tries to normalize this by moving these extra meta info into separate fields

## How to use

### Step 1. Register and get your API_KEY

Go to their website and obtain the API_KEY for the correct product. For now only `sd4` is tested.
`collegiate` should work as well.

### Step 2. Install the gem

First clone into a local repository then do gem install

### Step 2. Create a new new client and query away

```ruby
require 'mw_dictionary_api'
client = MWDictionaryAPI::Client.new(ENV['MW_SD4_API_KEY'])
```

Here we assume you have exported the API_KEY into `MW_SD4_API_KEY` environment variable

### Step 3. Create a cache so prevent hitting your API limit

```ruby
result = client.search('one')
puts result.entries.map { |e| e.to_hash }
```

## If you see problems

Please get in touch with me via github and let me know if you find any problems. I will be happy
to fix it.



