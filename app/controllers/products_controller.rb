class ProductsController < ApplicationController
  before_action :set_product, only: %i[show update destroy]

  def index
    render json: Product.all.map { |product| ProductSerializer.new(product) }
  end

  def show
    render json: ProductSerializer.new(@product)
  end

  def create
    product = Product.new(product_params)
    product.save!
    render json: ProductSerializer.new(product), status: :created, location: product
  end

  def update
    @product.update!(product_params)
    render json: ProductSerializer.new(@product)
  end

  def destroy
    @product.destroy!
    head :no_content
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price)
  end
end
