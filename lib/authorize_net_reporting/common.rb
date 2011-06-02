module Common
  def underscore(str)
    str.gsub(/(.)([A-Z])/,'\1_\2').downcase
  end
  
  def requires!(hash, *params)
    params.each do |param|
      raise ArgumentError, "Missing Required Parameter #{param}" unless hash.has_key?(param) 
    end
  end
  
end

class Hash
  def to_single_hash(hash = self)
    hash.each do |key, value|
      case value
        when Hash then to_single_hash(value)
        when String, Integer then   (@temp_hash||={})[key] = value
        else raise ArgumentError, "Error"  
      end  
    end
    @temp_hash
  end
end  

