module ApplicationHelper
    # app/helpers/application_helper.rb
    def bid_status_text(plate, bid)
        if plate.status == 'sold'
          bid.amount == plate.current_price ? 'Won' : 'Outbid'
        elsif plate.end_time < Time.current
          'Closed'
        else
          bid.amount == plate.current_price ? 'Winning' : 'Outbid'
        end
      end
      
      def bid_status_color(plate, bid)
        if plate.status == 'sold' && bid.amount == plate.current_price
          'bg-green-100 text-green-800'
        elsif plate.status == 'sold' || plate.end_time < Time.current
          'bg-red-100 text-red-800'
        elsif bid.amount == plate.current_price
          'bg-blue-100 text-blue-800'
        else
          'bg-yellow-100 text-yellow-800'
        end
      end


      def nav_class(path)
        "rounded-md px-3 py-2 text-sm font-medium #{current_page?(path) ? 'bg-blue-100 text-blue-700' : 'text-gray-500 hover:bg-gray-50'}"
      end

      # Masks an email address for privacy
      # Example: "john.doe@example.com" -> "j******e@example.com"
      # For very short local parts (like "a@b.com"), shows as is
      def mask_email(email)
        return "" if email.blank?
        parts = email.split("@")
        return email if parts.length != 2
        
        username = parts[0]
        domain = parts[1]
        
        masked_username = if username.length <= 2
          username[0] + "*" * (username.length - 1)
        else
          username[0] + "*" * (username.length - 2) + username[-1]
        end
        
        masked_username + "@" + domain
      end
      
      # Alternative simpler version that just shows ***@domain.com
      def simple_mask_email(email)
        return email if email.blank?
        
        _, domain = email.split('@')
        "***@#{domain}"
      end

      def verification_status_badge(user)
        status = user.verification_status
        content_tag(:span, status[:text], class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{status[:class]}")
      end
end
