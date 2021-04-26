# Returns a random number in a range of min, max. Not included in engine for some reason
def randr (min, max) 
  rand(max - min) + min
end

def hexToRGB (hexstring)
  rgbArray = hexstring.gsub("#", "").split('').each_slice(2).map {|e| e.join.to_i(16)}
  return rgbArray
end