require 'time'
require 'date'

class String # :nodoc:
  def to_liquid
    self
  end
end

class Array  # :nodoc:
  def to_liquid
    self
  end
end

class Hash  # :nodoc:
  def to_liquid
    self
  end
end

class Numeric  # :nodoc:
  def to_liquid
    self
  end
end

class Time  # :nodoc:
  def to_liquid
    self
  end
end

class DateTime < Date  # :nodoc:
  def to_liquid
    self
  end
end

class Date  # :nodoc:
  def to_liquid
    self
  end
end

def true.to_liquid  # :nodoc:
  self
end

def false.to_liquid # :nodoc:
  self
end

def nil.to_liquid # :nodoc:
  self
end