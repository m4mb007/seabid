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
        "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium transition-colors duration-200 " +
        (current_page?(path) ? "border-blue-500 text-blue-600" : "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
      end
end
