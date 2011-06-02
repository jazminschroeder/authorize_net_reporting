class AuthorizeNetTransaction < Gateway
  def initialize(params)
    params.each do |key, value|
      self.class.__send__(:attr_accessor, key)
      instance_variable_set("@#{key}", value)
    end  
  end
end

