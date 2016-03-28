class Thermos::BeverageStorage
  include Singleton

  def add_beverage(beverage)
    @beverages ||= {}
    @beverages[beverage.key] = beverage
  end

  def get_beverage(key)
    @beverages[key]
  end

  def empty!
    @beverages = {}
  end

  def beverages
    @beverages.values
  end
end
