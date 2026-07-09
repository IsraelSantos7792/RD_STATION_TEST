require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST /cart" do
    let!(:product) { Product.create!(name: "Test Product", price: 10.0) }

    it "creates (or reuses) a session cart and adds product" do
      post "/cart", params: { product_id: product.id, quantity: 2 }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["id"]).to be_present
      expect(body["products"].size).to eq(1)
      expect(body["products"][0]["id"]).to eq(product.id)
      expect(body["products"][0]["quantity"]).to eq(2)
      expect(body["total_price"]).to eq("20.0").or eq(20.0)
    end
  end

  describe "POST /cart/add_item" do
    let!(:product) { Product.create!(name: "Test Product", price: 10.0) }

    it "increments quantity when product already exists" do
      post "/cart", params: { product_id: product.id, quantity: 1 }, as: :json
      post "/cart/add_item", params: { product_id: product.id, quantity: 1 }, as: :json
      post "/cart/add_item", params: { product_id: product.id, quantity: 1 }, as: :json

      expect(response).to have_http_status(:ok)
      cart_id = JSON.parse(response.body)["id"]
      cart = Cart.find(cart_id)
      expect(cart.cart_items.find_by(product_id: product.id).quantity).to eq(3)
    end
  end

  describe "DELETE /cart/:product_id" do
    let!(:product) { Product.create!(name: "Test Product", price: 10.0) }

    it "removes item if exists" do
      post "/cart", params: { product_id: product.id, quantity: 2 }, as: :json
      delete "/cart/#{product.id}", as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["products"]).to eq([])
    end

    it "returns 404 when product not in cart" do
      get "/cart", as: :json
      delete "/cart/#{product.id}", as: :json

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to be_present
    end
  end
end
