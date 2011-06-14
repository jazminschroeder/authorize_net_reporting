module Common
  def underscore(str)
    str.gsub(/(.)([A-Z])/,'\1_\2').downcase
  end
  
end


