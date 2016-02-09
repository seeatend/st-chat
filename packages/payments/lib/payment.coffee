# Some simple currency helpers, currently intended for exact 2 decmial place use

Currency = (dollars, cents) ->
  dollars = if dollars then dollars else 0
  cents = if cents then cents else 0
  @totalCents = dollars * 100 + cents
  return

Currency::toCents = ->
  @totalCents

Currency::format = ->
  '$' + Math.floor(@totalCents / 100) + '.' + @totalCents % 100
