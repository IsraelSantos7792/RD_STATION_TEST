class ProductSerializer
  def initialize(product)
    @product = product
  end

  def as_json(*)
    {
      id: product.id,
      name: product.name,
      price: product.price
    }
  end

  private

  attr_reader :product
end
