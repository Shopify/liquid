require 'cgi'

module Liquid
  
  module StandardFilters
    
    # Return the size of an array or of an string
    def size(input)
      
      input.respond_to?(:size) ? input.size : 0
    end         
    
    # convert a input string to DOWNCASE
    def downcase(input)
      input.to_s.downcase
    end         

    # convert a input string to UPCASE
    def upcase(input)
      input.to_s.upcase
    end
    
    # capitalize words in the input centence
    def capitalize(input)
      input.to_s.capitalize
    end
        
    def escape(input)
      CGI.escapeHTML(input) rescue input
    end
    
    alias_method :h, :escape
    
    # Truncate a string down to x characters
    def truncate(input, length = 50, truncate_string = "...")
      if input.nil? then return end
      l = length.to_i - truncate_string.length
      l = 0 if l < 0
      input.length > length.to_i ? input[0...l] + truncate_string : input
    end

    def truncatewords(input, words = 15, truncate_string = "...")
      if input.nil? then return end
      wordlist = input.to_s.split
      l = words.to_i - 1
      l = 0 if l < 0
      wordlist.length > l ? wordlist[0..l].join(" ") + truncate_string : input 
    end
    
    def strip_html(input)
      input.to_s.gsub(/<.*?>/, '')
    end       
    
    # Remove all newlines from the string
    def strip_newlines(input)        
      input.to_s.gsub(/\n/, '')      
    end
    
    
    # Join elements of the array with certain character between them
    def join(input, glue = ' ')
      [input].flatten.join(glue)
    end

    # Sort elements of the array
    def sort(input)
      [input].flatten.sort
    end               
            
    # Replace occurrences of a string with another
    def replace(input, string, replacement = '')
      input.to_s.gsub(string, replacement)
    end
                                                 
    # Replace the first occurrences of a string with another
    def replace_first(input, string, replacement = '')
      input.to_s.sub(string, replacement)
    end              
                                                           
    # remove a substring
    def remove(input, string)
      input.to_s.gsub(string, '')      
    end
                        
    # remove the first occurrences of a substring
    def remove_first(input, string)
      input.to_s.sub(string, '')      
    end            
                                             
    # Add <br /> tags in front of all newlines in input string
    def newline_to_br(input)        
      input.to_s.gsub(/\n/, "<br />\n")      
    end
    
    # Reformat a date
    #
    #   %a - The abbreviated weekday name (``Sun'')
    #   %A - The  full  weekday  name (``Sunday'')
    #   %b - The abbreviated month name (``Jan'')
    #   %B - The  full  month  name (``January'')
    #   %c - The preferred local date and time representation
    #   %d - Day of the month (01..31)
    #   %H - Hour of the day, 24-hour clock (00..23)
    #   %I - Hour of the day, 12-hour clock (01..12)
    #   %j - Day of the year (001..366)
    #   %m - Month of the year (01..12)
    #   %M - Minute of the hour (00..59)
    #   %p - Meridian indicator (``AM''  or  ``PM'')
    #   %S - Second of the minute (00..60)
    #   %U - Week  number  of the current year,
    #           starting with the first Sunday as the first
    #           day of the first week (00..53)
    #   %W - Week  number  of the current year,
    #           starting with the first Monday as the first
    #           day of the first week (00..53)
    #   %w - Day of the week (Sunday is 0, 0..6)
    #   %x - Preferred representation for the date alone, no time
    #   %X - Preferred representation for the time alone, no date
    #   %y - Year without a century (00..99)
    #   %Y - Year with century
    #   %Z - Time zone name
    #   %% - Literal ``%'' character
    def date(input, format)
      
      if format.to_s.empty?
        return input.to_s
      end
      
      date = case input
      when String
        Time.parse(input)
      when Date, Time, DateTime
        input
      else
        return input
      end
              
      date.strftime(format.to_s)
    rescue => e 
      input
    end
    
    # Get the first element of the passed in array 
    # 
    # Example:
    #    {{ product.images | first | to_img }}
    #  
    def first(array)
      array.first if array.respond_to?(:first)
    end

    # Get the last element of the passed in array 
    # 
    # Example:
    #    {{ product.images | last | to_img }}
    #  
    def last(array)
      array.last if array.respond_to?(:last)
    end
    
  end
   
  Template.register_filter(StandardFilters)
end
