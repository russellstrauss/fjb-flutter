import express from 'express';
import Stripe from 'stripe';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Stripe
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// Create checkout session endpoint
app.post('/api/create-checkout', async (req, res) => {
  try {
    const {
      line_items,
      success_url,
      cancel_url,
      metadata,
      customer_email,
      customer_name,
      shipping_address,
      shipping_name,
    } = req.body;

    // Validate required fields
    if (!line_items || !Array.isArray(line_items) || line_items.length === 0) {
      return res.status(400).json({
        error: 'line_items is required and must be a non-empty array',
      });
    }

    // Get the origin from the request to construct proper success/cancel URLs
    const origin = req.get('origin') || req.get('referer') || 'http://localhost:8080';
    const baseUrl = origin.replace(/\/$/, ''); // Remove trailing slash

    // Build checkout session parameters
    const sessionParams = {
      payment_method_types: ['card'],
      line_items: line_items,
      mode: 'payment',
      success_url: success_url
        ? `${baseUrl}${success_url.startsWith('/') ? '' : '/'}${success_url}`
        : `${baseUrl}/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancel_url
        ? `${baseUrl}${cancel_url.startsWith('/') ? '' : '/'}${cancel_url}`
        : `${baseUrl}/checkout`,
      metadata: metadata || {},
    };

    // Add customer email if provided
    if (customer_email) {
      sessionParams.customer_email = customer_email;
    }

    // Add shipping address collection if shipping information is provided
    if (shipping_address) {
      sessionParams.shipping_address_collection = {
        allowed_countries: ['US', 'CA', 'GB'],
      };
    }

    // If we have shipping details, we can pre-fill some information
    // Note: Stripe Checkout doesn't support pre-filling shipping address,
    // but we can include it in metadata for order fulfillment
    if (shipping_address && metadata) {
      sessionParams.metadata = {
        ...metadata,
        shipping_address_line1: shipping_address.line1 || '',
        shipping_address_line2: shipping_address.line2 || '',
        shipping_city: shipping_address.city || '',
        shipping_state: shipping_address.state || '',
        shipping_postal_code: shipping_address.postal_code || '',
        shipping_country: shipping_address.country || '',
      };
      if (shipping_name) {
        sessionParams.metadata.shipping_name = shipping_name;
      }
    }

    // Create the Stripe Checkout Session
    const session = await stripe.checkout.sessions.create(sessionParams);

    // Return the checkout URL
    res.json({
      url: session.url,
      sessionId: session.id,
    });
  } catch (error) {
    console.error('Error creating checkout session:', error);
    
    // Return a user-friendly error message
    const errorMessage = error.type === 'StripeCardError'
      ? error.message
      : 'An error occurred while creating the checkout session. Please try again.';

    res.status(error.statusCode || 500).json({
      error: errorMessage,
      message: error.message,
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message,
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  if (!process.env.STRIPE_SECRET_KEY) {
    console.warn('WARNING: STRIPE_SECRET_KEY environment variable is not set!');
  }
});


