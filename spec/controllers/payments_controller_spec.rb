require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:user) { create(:user, :seafarer) }
  let(:plate_number) { create(:plate_number) }
  let(:amount) { 1000 } # RM 10.00
  
  describe 'GET #new' do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end
    
    context 'when creating a payment intent succeeds' do
      let(:payment_intent) { double('PaymentIntent', client_secret: 'secret_123') }
      
      before do
        allow(StripeService).to receive(:create_payment_intent)
          .and_return({ success: true, payment_intent: payment_intent })
      end
      
      it 'assigns @client_secret and renders new template' do
        get :new, params: { plate_number_id: plate_number.id, amount: amount, payment_type: 'bidding_fee' }
        
        expect(assigns(:client_secret)).to eq('secret_123')
        expect(response).to render_template(:new)
      end
    end
    
    context 'when creating a payment intent fails' do
      before do
        allow(StripeService).to receive(:create_payment_intent)
          .and_return({ success: false, error: 'Payment failed' })
      end
      
      it 'sets flash error and redirects back' do
        get :new, params: { plate_number_id: plate_number.id, amount: amount, payment_type: 'bidding_fee' }
        
        expect(flash[:error]).to eq('Payment failed')
        expect(response).to redirect_to(root_path)
      end
    end
  end
  
  describe 'POST #create' do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end
    
    let(:payment_intent_id) { 'pi_123' }
    let(:payment_method_id) { 'pm_123' }
    
    context 'when payment is successful' do
      let(:payment_intent) do
        double('PaymentIntent',
          status: 'succeeded',
          amount: amount,
          metadata: { 'payment_type' => 'bidding_fee', 'reference_id' => plate_number.id }
        )
      end
      
      before do
        allow(StripeService).to receive(:retrieve_payment_intent)
          .and_return({ success: true, payment_intent: payment_intent })
      end
      
      it 'creates a payment record and redirects' do
        expect {
          post :create, params: {
            plate_number_id: plate_number.id,
            payment_intent_id: payment_intent_id,
            payment_method_id: payment_method_id
          }
        }.to change(Payment, :count).by(1)
        
        expect(response).to redirect_to(plate_numbers_path)
        expect(flash[:success]).to eq('Bidding fee paid successfully. You can now participate in auctions.')
      end
    end
    
    context 'when payment fails' do
      before do
        allow(StripeService).to receive(:retrieve_payment_intent)
          .and_return({ success: false, error: 'Payment failed' })
      end
      
      it 'sets flash error and redirects back' do
        post :create, params: {
          plate_number_id: plate_number.id,
          payment_intent_id: payment_intent_id,
          payment_method_id: payment_method_id
        }
        
        expect(flash[:error]).to eq('Payment failed')
        expect(response).to redirect_to(root_path)
      end
    end
  end
  
  describe 'POST #webhook' do
    let(:event_data) do
      {
        'id' => 'pi_123',
        'object' => 'payment_intent',
        'status' => 'succeeded',
        'amount' => 1000,
        'metadata' => {
          'payment_type' => 'bidding_fee',
          'reference_id' => '1'
        }
      }
    end
    
    let(:event) do
      double('Event',
        type: 'payment_intent.succeeded',
        data: double('EventData', object: event_data)
      )
    end
    
    let(:payload) { '{"type":"payment_intent.succeeded","data":{"object":{"id":"pi_123"}}}' }
    let(:signature) { 't=1234567890,v1=dummy_signature' }
    
    before do
      request.headers['HTTP_STRIPE_SIGNATURE'] = signature
      allow(Stripe::Webhook).to receive(:construct_event)
        .with(payload, signature, Rails.configuration.stripe[:signing_secret])
        .and_return(event)
    end
    
    it 'processes the webhook event' do
      post :webhook, body: payload
      
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq({ 'status' => 'success' })
    end
  end
end 