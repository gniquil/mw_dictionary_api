module MWDictionaryAPI
  module Parsable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def rules
        @rules ||= {}
      end

      def inherited_rules
        if superclass.respond_to? :inherited_rules
          superclass.inherited_rules.merge(rules)
        else
          rules
        end
      end

      def rule(attr_name, **options, &block)
        rules[attr_name] = { attr_name: attr_name, options: options, block: block }
      end

      def apply_rule(attr_name, data, options)
        inherited_rules[attr_name][:block].call(data, options)
      end

      def rule_helpers(&block)
        instance_eval(&block)
      end
    end

    def initialize(**options)
      @options = options
    end

    def parse(data)
      attributes = {}

      self.class.inherited_rules.each do |attr_name, rule|
        unless rule[:options][:hidden]
          options = @options.merge(rule[:options])
          attributes[attr_name] = rule[:block].call(data, options)
        end
      end
      attributes
    end

  end
end