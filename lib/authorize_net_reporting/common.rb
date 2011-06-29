# Helper ruby methods 
module AuthorizeNetReporting
  module Common
    def underscore(str)#:nodoc:
      str.gsub(/(.)([A-Z])/,'\1_\2').downcase
    end
  
    def camelize(str)#:nodoc:
      str.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end

