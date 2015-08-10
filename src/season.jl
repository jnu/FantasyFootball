using DataFrames

immutable Season
  qb::DataFrame
  rb::DataFrame
  wr::DataFrame
  te::DataFrame
  st::DataFrame
  def::DataFrame
  k::DataFrame

  function Season(year::Int64)
    tables = map(p -> readtable("data/$(year)/$(p).csv"), ["QB", "RB", "WR", "TE", "ST", "DEF", "K"])
    new(tables[1], tables[2], tables[3], tables[4], tables[5], tables[6], tables[7])
  end
end
