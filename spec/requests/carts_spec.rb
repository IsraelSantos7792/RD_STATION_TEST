require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let!(:product) { Product.create!(name: "Test Product", price: 10.0) }

  describe "GET /cart" do
    it "creates an empty cart on first access" do
      get "/cart", as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["products"]).to eq([])
      expect(body["total_price"]).to eq(0)
    end
  end

  describe "POST /cart" do
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

    it "defaults quantity to 1 when not provided" do
      post "/cart", params: { product_id: product.id }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["products"][0]["quantity"]).to eq(1)
    end

    it "returns 422 when product_id is missing" do
      post "/cart", params: {}, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["error"]).to be_present
    end

    it "returns 404 when the product does not exist" do
      post "/cart", params: { product_id: -1, quantity: 1 }, as: :json

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Resource not found")
    end

    it "returns 422 when quantity is zero or negative" do
      post "/cart", params: { product_id: product.id, quantity: 0 }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /cart/add_item" do
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
    it "removes item if exists" do
      post "/cart", params: { product_id: product.id, quantity: 2 }, as: :json
      delete "/cart/#{product.id}", as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["products"]).to eq([])
      expect(body["total_price"]).to eq(0)
    end

    it "returns 404 when product not in cart" do
      get "/cart", as: :json
      delete "/cart/#{product.id}", as: :json

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to be_present
    end
  end

  describe "unexpected errors" do
    it "returns a generic 500 JSON envelope instead of leaking internals outside local environments" do
      allow(Rails.env).to receive(:local?).and_return(false)
      allow(Carts::FindOrCreateForSession).to receive(:call).and_raise(RuntimeError, "boom")

      get "/cart", as: :json

      expect(response).to have_http_status(:internal_server_error)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Internal server error")
      expect(body["error"]).not_to include("boom")
    end
  end

  describe "DELETE /cart" do
    it "destroys the cart and clears the session" do
      post "/cart", params: { product_id: product.id, quantity: 1 }, as: :json

      delete "/cart", as: :json
      expect(response).to have_http_status(:ok)

      get "/cart", as: :json
      new_cart_id = JSON.parse(response.body)["id"]
      expect(new_cart_id).to be_present
    end
  end
end
