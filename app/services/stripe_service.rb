class StripeService
  def self.create_payment_intent(amount, currency = 'myr', metadata = {})
    begin
      payment_intent = Stripe::PaymentIntent.create(
        amount: amount,
        currency: currency,
        metadata: metadata,
        automatic_payment_methods: {
          enabled: true,
        }
      )
      
      return { success: true, payment_intent: payment_intent }
    rescue Stripe::CardError => e
      return { success: false, error: e.message }
    rescue Stripe::InvalidRequestError => e
      return { success: false, error: "Invalid payment information: #{e.message}" }
    rescue => e
      return { success: false, error: "Payment processing failed: #{e.message}" }
    end
  end
  
  def self.retrieve_payment_intent(payment_intent_id)
    begin
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
      return { success: true, payment_intent: payment_intent }
    rescue Stripe::InvalidRequestError => e
      return { success: false, error: "Payment intent not found: #{e.message}" }
    rescue => e
      return { success: false, error: "Error retrieving payment intent: #{e.message}" }
    end
  end
  
  def self.create_checkout_session(amount, currency = 'myr', metadata = {}, success_url = nil, cancel_url = nil)
    begin
      session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: currency,
            product_data: {
              name: 'SeaBid Payment',
              description: 'Payment for SeaBid service',
            },
            unit_amount: amount,
          },
          quantity: 1,
        }],
        mode: 'payment',
        success_url: success_url,
        cancel_url: cancel_url,
        metadata: metadata,
      })
      
      return { success: true, session: session }
    rescue Stripe::CardError => e
      return { success: false, error: e.message }
    rescue Stripe::InvalidRequestError => e
      return { success: false, error: "Invalid payment information: #{e.message}" }
    rescue => e
      return { success: false, error: "Payment processing failed: #{e.message}" }
    end
  end
  
  def self.retrieve_checkout_session(session_id)
    begin
      session = Stripe::Checkout::Session.retrieve(session_id)
      return { success: true, session: session }
    rescue Stripe::InvalidRequestError => e
      return { success: false, error: "Checkout session not found: #{e.message}" }
    rescue => e
      return { success: false, error: "Error retrieving checkout session: #{e.message}" }
    end
  end
end 