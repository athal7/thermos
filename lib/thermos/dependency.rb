class Thermos::Dependency
  attr_reader :primary_model, :association_name, :klass_name, :table_name

  def initialize(primary_model:, association_name:)
    @primary_model = primary_model
    @association_name = association_name
    reflection = @primary_model.reflections[@association_name.to_s]
    @table_name = reflection.table_name
    @klass_name = reflection.class_name.constantize
  end
end
