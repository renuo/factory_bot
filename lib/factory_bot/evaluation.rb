module FactoryBot
  class Evaluation
    def initialize(evaluator, attribute_assigner, to_create, compiled)
      @evaluator = evaluator
      @attribute_assigner = attribute_assigner
      @to_create = to_create
      @compiled = compiled
    end

    delegate :object, :hash, to: :@attribute_assigner

    def create(result_instance)
      case @to_create.arity
      when 2 then @to_create[result_instance, @evaluator]
      else @to_create[result_instance]
      end
    end

    def notify(name, result_instance)
      @compiled.callbacks_for(name).each do |callback|
        callback.run(result_instance, @evaluator)
      end
    end
  end
end
