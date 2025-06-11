class NewslettersController < ApplicationController
  def subscribe
    @newsletter = Newsletter.new(email: params[:email])
    
    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to root_path, notice: 'Thank you for subscribing to our newsletter!' }
        format.json { render json: { message: 'Subscription successful' }, status: :created }
      else
        format.html { redirect_to root_path, alert: 'Failed to subscribe: ' + @newsletter.errors.full_messages.join(', ') }
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end
end 