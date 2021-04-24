def materialTest(args)

  # Run Setup
  args.state.materialSetup ||= false
  if args.state.materialSetup == false
    args.state.materialRates ||= {}
    args.state.materialStore ||= {}
    
    for i in RESOURCES
      args.state.materialRates[i] = 0.01
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
      args.state.materialStore[i] += randr(1, 3)
      args.state.materialStore[i] = args.state.materialStore[i].round(2)
    end

    # Print labels
    textSize = args.gtk.calcstringbox(i)
    args.outputs.labels << [args.grid.right / 2 - textSize[0], args.grid.top - ( textSize[1] * printIndex ), "#{i}"] #RESOURCE NAME
    args.outputs.labels << [args.grid.right / 2 + 10, args.grid.top - (textSize[1]*printIndex), args.state.materialStore[i]] #RESOURCE STORED
    
    labelWidth = args.gtk.calcstringbox(args.state.materialStore[i].to_s)[0] #Width of quantity label
    center = args.grid.right / 2 #Reference for simplicity
    
    # Print percent bar
    barwidth = args.grid.right - (center / 2 + labelWidth)
    materialPercent = args.state.materialStore[i] / totalVolume
    args.outputs.solids << [
      center + 300, 
      args.grid.top - ( textSize[1] * printIndex) - textSize[1], 
      materialPercent * barwidth,
      textSize[1]] #Black Bar
    
    # Iterate Index
    printIndex += 1

  end

  #Print total volume
  args.outputs.labels << [args.grid.right / 2 + 10, args.grid.top - (textSize[1]*printIndex+1), "#{totalVolume.round(2)}"]

end