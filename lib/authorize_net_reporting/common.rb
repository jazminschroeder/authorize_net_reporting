# Helper methods   
module Common
  # Converts string to underscore
  def underscore(str)
    str.gsub(/(.)([A-Z])/,'\1_\2').downcase
  end
  # Converts string to camelCase format
  def camelize(str)
    str.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
end

