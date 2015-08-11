using DataFrames
using DataFramesMeta

# Get the table logical path relative to current script by year and position
table_logical_path(year::String, position::String) = joinpath(dirname(@__FILE__), "..", "data", year, position)
# Get the FS path relative to the current location for the year and position
table_path(year::String, position::String) = string(table_logical_path(year, position), ".csv")

# Season type - holds tables for positions in a given year
immutable Season
  qb::DataFrame
  rb::DataFrame
  wr::DataFrame
  te::DataFrame
  st::DataFrame
  def::DataFrame
  k::DataFrame

  function Season(year::String)
    tables = map(p -> readtable(table_path(year, p)), ["QB", "RB", "WR", "TE", "ST", "DEF", "K"])
    new(tables[1], tables[2], tables[3], tables[4], tables[5], tables[6], tables[7])
  end

  function Season(year::Int64)
    Season(string(year))
  end

  function Season(qb::DataFrame, rb::DataFrame, wr::DataFrame, te::DataFrame, st::DataFrame, def::DataFrame, k::DataFrame)
    new(qb, rb, wr, te, st, def, k)
  end
end

# Filter a season by team.
function filter(season::Season, team::String)
  qb = @where(season.qb, :Team .== team)
  rb = @where(season.rb, :Team .== team)
  wr = @where(season.wr, :Team .== team)
  te = @where(season.te, :Team .== team)
  st = @where(season.st, :Team .== team)
  def = @where(season.def, :Team .== team)
  k = @where(season.k, :Team .== team)

  Season(qb, rb, wr, te, st, def, k)
end

