# Farmer John's Botanicals - Stripe Backend API

This backend API server handles Stripe Checkout session creation for the Flutter e-commerce app.

## Prerequisites

- Node.js 18+ installed
- A Stripe account (sign up at https://stripe.com)
- Stripe API keys (get them from https://dashboard.stripe.com/apikeys)

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment Variables

Copy the example environment file and add your Stripe secret key:

```bash
cp .env.example .env
```

Edit `.env` and add your Stripe secret key:

```
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
```

**Important Notes:**
- For development, use a **test key** (starts with `sk_test_`)
- For production, use a **live key** (starts with `sk_live_`)
- Never commit your `.env` file to version control
- Keep your secret keys secure - they have full access to your Stripe account

### 3. Start the Server

For development (with auto-reload):
```bash
npm run dev
```

For production:
```bash
npm start
```

The server will start on `http://localhost:3000` by default (or the port specified in the `PORT` environment variable).

### 4. Verify the Server is Running

Visit `http://localhost:3000/health` in your browser or use curl:

```bash
curl http://localhost:3000/health
```

You should see:
```json
{
  "status": "ok",
  "message": "Server is running"
}
```

## API Endpoints

### POST /api/create-checkout

Creates a Stripe Checkout session and returns the checkout URL.

**Request Body:**
```json
{
  "line_items": [
    {
      "price_data": {
        "currency": "usd",
        "product_data": {
          "name": "Product Name",
          "images": ["https://example.com/image.jpg"]
        },
        "unit_amount": 2000
      },
      "quantity": 1
    }
  ],
  "success_url": "/success?session_id={CHECKOUT_SESSION_ID}",
  "cancel_url": "/checkout",
  "metadata": {
    "cart_items": "[{\"sku\":\"SKU123\",\"name\":\"Product\",\"quantity\":1}]",
    "customer_email": "customer@example.com"
  },
  "customer_email": "customer@example.com",
  "customer_name": "John Doe",
  "shipping_address": {
    "line1": "123 Main St",
    "line2": "Apt 4",
    "city": "New York",
    "state": "NY",
    "postal_code": "10001",
    "country": "US"
  }
}
```

**Response:**
```json
{
  "url": "https://checkout.stripe.com/c/pay/cs_test_...",
  "sessionId": "cs_test_..."
}
```

**Error Response:**
```json
{
  "error": "Error message here",
  "message": "Detailed error message"
}
```

## Flutter App Configuration

To connect your Flutter app to this backend:

1. **Development (localhost):**
   ```bash
   flutter run -d chrome --dart-define=STRIPE_API_URL=http://localhost:3000
   ```

2. **Production:**
   ```bash
   flutter build web --dart-define=STRIPE_API_URL=https://your-api-domain.com
   ```

The Flutter app is configured to use `http://localhost:3000` by default if no `STRIPE_API_URL` is provided.

## Security Notes

- **Never** expose your Stripe secret key in client-side code
- Always use HTTPS in production
- Consider implementing rate limiting for production use
- Validate and sanitize all input data
- Set up webhooks to handle payment completion securely

## Testing

To test the API endpoint, you can use curl:

```bash
curl -X POST http://localhost:3000/api/create-checkout \
  -H "Content-Type: application/json" \
  -d '{
    "line_items": [{
      "price_data": {
        "currency": "usd",
        "product_data": {"name": "Test Product"},
        "unit_amount": 2000
      },
      "quantity": 1
    }],
    "success_url": "/success?session_id={CHECKOUT_SESSION_ID}",
    "cancel_url": "/checkout"
  }'
```

## Troubleshooting

### "STRIPE_SECRET_KEY environment variable is not set"
- Make sure you've created a `.env` file in the `backend/` directory
- Verify the `.env` file contains `STRIPE_SECRET_KEY=sk_test_...`

### CORS Errors
- The server is configured to accept requests from any origin
- If you need to restrict CORS, modify the `cors()` configuration in `server.js`

### Port Already in Use
- Change the `PORT` environment variable in `.env`
- Or kill the process using port 3000

## Production Deployment

For production deployment:

1. Use environment variables provided by your hosting platform (Heroku, Railway, Vercel, etc.)
2. Set `STRIPE_SECRET_KEY` to your live Stripe secret key
3. Configure CORS to only allow requests from your Flutter app domain
4. Enable HTTPS
5. Set up Stripe webhooks to handle payment confirmations
6. Monitor logs for errors

## Support

For Stripe-specific issues, refer to:
- [Stripe Documentation](https://stripe.com/docs)
- [Stripe API Reference](https://stripe.com/docs/api)
- [Stripe Checkout Documentation](https://stripe.com/docs/payments/checkout)


