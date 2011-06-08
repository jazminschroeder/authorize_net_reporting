class AuthorizeNetTransaction < Gateway
  def initialize(params)
    params.each do |key, value|
      self.class.__send__(:attr_accessor, underscore(key))
      instance_variable_set("@#{underscore(key)}", value)
    end  
  end
end


class Batch < Gateway
  def initialize(params)
    params.each do |key, value|
      self.class.__send__(:attr_accessor, underscore(key))
      instance_variable_set("@#{underscore(key)}", value)
    end  
  end
end
