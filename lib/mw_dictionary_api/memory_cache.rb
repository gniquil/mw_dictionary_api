# encoding: UTF-8

module MWDictionaryAPI

  class MemoryCache

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
end