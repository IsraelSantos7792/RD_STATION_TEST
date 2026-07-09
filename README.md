# Desafio técnico — API de carrinho (e-commerce)

API REST em Ruby on Rails para gerenciar um carrinho de compras por **sessão**.

## Requisitos

- Ruby **3.3.1**
- Rails **7.1.3.2**
- Postgres **16**
- Redis **7.0.15**

## Como rodar (sem Docker)

```bash
bundle install
bin/rails db:create db:migrate
bundle exec rails server
```

### Com frontend (Next.js)

Se for usar o frontend em Next.js na porta `3000`, suba o Rails na porta `5050`:

```bash
bundle exec rails server -p 5050
```

No frontend, configure:

```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:5050
```

Sidekiq (em outro terminal):

```bash
bundle exec sidekiq
```

Testes:

```bash
bundle exec rspec
```

## Sessão (como funciona)

O carrinho atual é identificado por `session[:cart_id]` (cookie). Mantendo os cookies nas requisições, você continua no mesmo carrinho. Para simular uma sessão nova no Postman, apague os cookies do host.

## Endpoints

### 1) Registrar produto no carrinho (cria carrinho na sessão se precisar)

- **POST** `/cart`

Request:

```json
{ "product_id": 345, "quantity": 2 }
```

Response (exemplo):

```json
{
  "id": 789,
  "products": [
    { "id": 345, "name": "Nome do produto", "quantity": 2, "unit_price": 1.99, "total_price": 3.98 }
  ],
  "total_price": 3.98
}
```

### 2) Listar itens do carrinho atual

- **GET** `/cart`

Response segue o mesmo formato do endpoint acima.

### 3) Alterar/incrementar quantidade de produto no carrinho

- **POST** `/cart/add_item`

Request:

```json
{ "product_id": 1230, "quantity": 1 }
```

Response segue o mesmo formato do carrinho (quantidade do item é incrementada se já existir).

### 4) Remover produto do carrinho

- **DELETE** `/cart/:product_id`

Regras:
- Se o produto não estiver no carrinho, retorna **404** com `{"error":"Product not in cart"}`.
- Se remover e o carrinho ficar vazio, retorna `products: []` e `total_price: 0`.

## Carrinhos abandonados

- Um carrinho é marcado como abandonado se ficar **sem interação por 3 horas**.
- Um carrinho abandonado por **mais de 7 dias** é removido.
- O job é executado periodicamente via Sidekiq Scheduler.

## Postman

O arquivo `Rd Station test.postman_collection.json` contém uma collection com:
- `GET /cart`
- `POST /cart`
- `POST /cart/add_item`
- `DELETE /cart/:product_id`
- `GET /products`

Configure a variável `BASE` como, por exemplo, `http://localhost:5050/` (com a barra no final) se estiver usando o frontend, ou `http://localhost:3000/` se subir o Rails na porta padrão.

RD_STATION_TEST

