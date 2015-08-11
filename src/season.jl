using DataFrames
using DataFramesMeta


const ABBR_LOOKUP = [
  "Arizona Cardinals" => "ARI",
  "Atlanta Falcons" => "ATL",
  "Baltimore Ravens" => "BAL",
  "Buffalo Bills" => "BUF",
  "Carolina Panthers" => "CAR",
  "Chicago Bears" => "CHI",
  "Cincinnati Bengals" => "CIN",
  "Cleveland Browns" => "CLE",
  "Dallas Cowboys" => "DAL",
  "Denver Broncos" => "DEN",
  "Detroit Lions" => "DET",
  "Green Bay Packers" => "GNB",
  "Houston Texans" => "HOU",
  "Indianapolis Colts" => "IND",
  "Jacksonville Jaguars" => "JAC",
  "Kansas City Chiefs" => "KAN",
  "Miami Dolphins" => "MIA",
  "Minnesota Vikings" => "MIN",
  "New England Patriots" => "NWE",
  "New Orleans Saints" => "NOR",
  "New York Giants" => "NYG",
  "New York Jets" => "NYJ",
  "Oakland Raiders" => "OAK",
  "Philadelphia Eagles" => "PHI",
  "Pittsburgh Steelers" => "PIT",
  "San Diego Chargers" => "SDG",
  "San Francisco 49ers" => "SFO",
  "Seattle Seahawks" => "SEA",
  "St. Louis Rams" => "STL",
  "Tampa Bay Buccaneers" => "TAM",
  "Tennessee Titans" => "TEN",
  "Washington Redskins" => "WAS"
]

const COLUMN_MAP = {
  (:rush_yds, :RushYds),
  (:rush_td, :RushTD),
  (:rec_yds, :RecYds),
  (:rec_td, :RecTD),
  (:pass_yds, :Yds),
  (:pass_td, :TD),
  (:pass_int, :Int),
  (:sack, :Sack),
  (:fum_l, :FumL),
  (:pr_td, :PRTD),
  (:kr_td, :KRTD)
}

# Get the table logical path relative to current script by year and position
table_logical_path(year::String, position::String) = joinpath(dirname(@__FILE__), "..", "data", year, position)
# Get the FS path relative to the current location for the year and position
table_path(year::String, position::String) = string(table_logical_path(year, position), ".csv")

# Ensure that tables have a normalized key for access by team
function with_team_abbr!(table)
  table[:team_abbr] = map(team -> length(team) == 3 ? team : ABBR_LOOKUP[team], table[:Team])
  table
end


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
    tables = map(p -> with_team_abbr!(readtable(table_path(year, p))), ["QB", "RB", "WR", "TE", "ST", "DEF", "K"])
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
  filtered = [@where(getfield(season, f), :team_abbr .== team) for f in names(season)]
  Season(filtered...)
end

function score_off_table(df)
  # Julia doesn't support conditional list comprehensions or tuple destructuring,
  # so this is a bit of a mess. TODO - implement in julia?
  columns = [(pair[1], haskey(df, pair[2]) ? df[pair[2]] : 0) for pair in COLUMN_MAP]
  @transform(df, score = score_off(; columns...))
end

function score(season::Season)
  # XXX macro to clean this up
  scored = [score_off_table(getfield(season, f)) for f in names(season)]
  Season(scored...)
end

