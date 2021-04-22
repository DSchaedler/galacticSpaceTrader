# Returns a random number in a range of min, max. Not included in engine for some reason
def randr (min, max) 
  rand(max - min) + min
end