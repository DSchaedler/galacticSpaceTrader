def materialTest(args)

  # Run Setup
  args.state.materialSetup ||= false
  if args.state.materialSetup == false
    args.state.materialRates ||= {} # Hash of generation rates for materials
    args.state.materialStore ||= {} # Hash of stored materials
    
    # Populate the hashes above
    for i in RESOURCES
      args.state.materialRates[i] = randr(0.01, 1)
      args.state.materialStore[i] = 0
    end

    args.state.materialSetup = true
  end

  # Calculate and print all info

  #Calculate volume stored
  totalVolume = 0
  args.state.materialStore.each do | key, value |
    totalVolume += args.state.materialStore[key]
  end

  printIndex = 0
  for i in RESOURCES

    # Update quantites each second
    if args.state.tick_count % 60 == 0 && totalVolume < 1000
      args.state.materialStore[i] += args.state.materialRates[i]
      args.state.materialStore[i] = args.state.materialStore[i].round(2)
    end

    # Print labels
    textSize = args.gtk.calcstringbox(i) # Get size of text, useful to have pre-calculated
    top = args.grid.top
    right = args.grid.right
    center = args.grid.right / 2 #Reference for simplicity

    args.outputs.primitives << {x: center - textSize[0], y: top - ( textSize[1] * printIndex ), text: "#{i}", primitive_marker: :label} #RESOURCE NAME
    args.outputs.primitives << {x: center + 10, y: top - (textSize[1] * printIndex), text: args.state.materialStore[i], primitive_marker: :label} #RESOURCE STORED

    labelWidth = args.gtk.calcstringbox("999.99")[0] # Width of quantity label
    
    # Print percent bar
    barwidth = right - (center + labelWidth)
    materialPercent = args.state.materialStore[i] / totalVolume
    color = hexToRGB(XKCD_COLORS.values[printIndex * 10])
    args.outputs.primitives << {
      x: center + labelWidth, 
      y: args.grid.top - ( textSize[1] * printIndex) - textSize[1], 
      w: materialPercent * barwidth,
      h: textSize[1],
      r: color[0],
      g: color[1],
      b: color[2],
      primitive_marker: :solid} #Black Bar
    
    # Iterate Index
    printIndex += 1

  end

  #Print total volume
  args.outputs.primitives << [args.grid.right / 2 + 10, args.grid.top - (textSize[1]*printIndex+1), "#{totalVolume.round(2)}"].label

end