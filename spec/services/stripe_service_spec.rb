require 'rails_helper'

RSpec.describe StripeService do
  let(:amount) { 1000 } # RM 10.00
  let(:currency) { 'myr' }
  let(:metadata) { { user_id: 1, payment_type: 'bidding_fee' } }
  
  describe '.create_payment_intent' do
    context 'when successful' do
      let(:payment_intent) { double('PaymentIntent', id: 'pi_123', client_secret: 'secret_123') }
      
      before do
        allow(Stripe::PaymentIntent).to receive(:create).and_return(payment_intent)
      end
      
      it 'creates a payment intent with correct parameters' do
        expect(Stripe::PaymentIntent).to receive(:create).with(
          amount: amount,
          currency: currency,
          metadata: metadata,
          automatic_payment_methods: { enabled: true }
        )
        
        result = described_class.create_payment_intent(amount, currency, metadata)
        
        expect(result[:success]).to be true
        expect(result[:payment_intent]).to eq(payment_intent)
      end
    end
    
    context 'when card error occurs' do
      before do
        error = Stripe::CardError.new(
          'Your card was declined',
          { message: 'Your card was declined' }
        )
        allow(Stripe::PaymentIntent).to receive(:create).and_raise(error)
      end
      
      it 'returns error message' do
        result = described_class.create_payment_intent(amount, currency, metadata)
        
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Your card was declined')
      end
    end
    
    context 'when invalid request error occurs' do
      before do
        allow(Stripe::PaymentIntent).to receive(:create)
          .and_raise(Stripe::InvalidRequestError.new('Invalid amount', 'amount'))
      end
      
      it 'returns error message' do
        result = described_class.create_payment_intent(amount, currency, metadata)
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('Invalid payment information')
      end
    end
  end
  
  describe '.retrieve_payment_intent' do
    let(:payment_intent_id) { 'pi_123' }
    
    context 'when successful' do
      let(:payment_intent) { double('PaymentIntent', id: payment_intent_id) }
      
      before do
        allow(Stripe::PaymentIntent).to receive(:retrieve).and_return(payment_intent)
      end
      
      it 'retrieves the payment intent' do
        expect(Stripe::PaymentIntent).to receive(:retrieve).with(payment_intent_id)
        
        result = described_class.retrieve_payment_intent(payment_intent_id)
        
        expect(result[:success]).to be true
        expect(result[:payment_intent]).to eq(payment_intent)
      end
    end
    
    context 'when payment intent not found' do
      before do
        allow(Stripe::PaymentIntent).to receive(:retrieve)
          .and_raise(Stripe::InvalidRequestError.new('No such payment_intent', 'id'))
      end
      
      it 'returns error message' do
        result = described_class.retrieve_payment_intent(payment_intent_id)
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('Payment intent not found')
      end
    end
  end
end 