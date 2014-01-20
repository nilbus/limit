class RateLimit
  def self.debounce(*args)
    yield
  end
end
