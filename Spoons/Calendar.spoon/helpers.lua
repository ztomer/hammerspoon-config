return function(canvas)
  Helpers = {}

  function Helpers.daysInMonth(year, month)
    -- Adjust to the first day of the given month
    local givenMonthDate = {
      year = year,
      month = month,
      day = 1
    }

    -- Calculate the first day of the next month
    local nextMonthDate = {
      year = givenMonthDate.year,
      month = givenMonthDate.month + 1,
      day = 1
    }

    -- Handle year change
    if nextMonthDate.month > 12 then
      nextMonthDate.month = 1
      nextMonthDate.year = nextMonthDate.year + 1
    end

    -- Convert dates to timestamps
    local givenMonthTimestamp = os.time(givenMonthDate)
    local nextMonthTimestamp = os.time(nextMonthDate)

    -- Calculate the number of days in the given month
    local daysInGivenMonth = (os.difftime(nextMonthTimestamp, givenMonthTimestamp) / (24 * 3600))

    return math.floor(daysInGivenMonth + 0.5) -- closest integer
  end

  function Helpers.canvasEl(id)
    for index, element in pairs(canvas) do
      if element.id == id then
        return element
      end
    end
    return {}
  end

  function Helpers.canvasIndex(id)
    for index, element in pairs(canvas) do
      if element.id == id then
        return index
      end
    end
    return 0
  end

  function Helpers.calculateDateToday()
    return os.date("*t")
  end

  Helpers.monthAbbr = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec" }

  function Helpers.calculateMonthYear(displayDate)
    return Helpers.monthAbbr[displayDate.month] .. ' ' .. displayDate.year
  end

  function Helpers.calculateDowForFirstDom(displayDate)
    return os.date("*t", os.time({ year = displayDate.year, month = displayDate.month, day = 1 })).wday
  end

  Helpers.weeknames = { "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" }

  function Helpers.place(x, y, relativeCoordinates)
    local absoluteCoordinates = {}
    for _, point in ipairs(relativeCoordinates) do
      table.insert(absoluteCoordinates, { x = x + point.x, y = y + point.y })
    end
    return absoluteCoordinates
  end

  function Helpers.scale(w, h, relativeCoordinates)
    local scaledCoordinates = {}
    for _, point in ipairs(relativeCoordinates) do
      table.insert(scaledCoordinates, { x = point.x * w, y = point.y * h })
    end
    return scaledCoordinates
  end

  return Helpers
end
