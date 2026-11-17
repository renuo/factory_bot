module FactoryBot
  # Everything a run needs from a factory and a list of traits, resolved once
  # and cached by the configuration.
  # @api private
  class CompiledFactory
    attr_reader :build_class, :attributes, :callbacks, :constructor, :to_create

    def initialize(build_class:, attributes:, callbacks:, constructor:, to_create:)
      @build_class = build_class
      @attributes = attributes
      @callbacks = callbacks
      @constructor = constructor
      @to_create = to_create
    end

    def run(build_strategy, overrides, &block)
      block ||= ->(result) { result }

      strategy = Strategy.lookup_strategy(build_strategy).new

      evaluator = Evaluator.new(self, strategy, overrides.symbolize_keys)
      attribute_assigner = AttributeAssigner.new(evaluator, self, &constructor)
      evaluation = Evaluation.new(evaluator, attribute_assigner, to_create, self)

      evaluation.notify(:before_all, nil)
      instance = strategy.result(evaluation).tap(&block)
      evaluation.notify(:after_all, instance)

      instance
    end

    def associations
      @associations ||= attributes.values.select(&:association?)
    end

    def attribute_names
      @attribute_names ||= attributes.keys
    end

    def non_transient_attributes
      @non_transient_attributes ||= attributes.values.reject(&:transient)
    end

    def non_transient_attribute_names
      @non_transient_attribute_names ||= non_transient_attributes.map(&:name)
    end

    def transient_attribute_names
      @transient_attribute_names ||= attributes.values.select(&:transient).map(&:name)
    end

    def association_names
      @association_names ||= associations.map(&:name)
    end

    def callbacks_for(name)
      @callbacks_by_name ||= callbacks.group_by(&:name)
      @callbacks_by_name.fetch(name, [])
    end
  end
end
