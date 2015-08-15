include("scoring.jl")
using DataFrames
using DataFramesMeta

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Constant table data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Private helpers
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Get the table logical path relative to current script by year and position
table_logical_path(year::String, position::String) = joinpath(dirname(@__FILE__), "..", "data", year, position)

# Get the FS path relative to the current location for the year and position
table_path(year::String, position::String) = string(table_logical_path(year, position), ".csv")

# Ensure that tables have a normalized key for access by team
function with_team_abbr!(df::DataFrame)
  # XXX Can't use @transform for this?
  df[:team_abbr] = map(team -> length(team) == 3 ? team : ABBR_LOOKUP[team], df[:Team])
  df
end

# Add a fantasy score column to the data frame
function score_table(df::DataFrame, f::Function)
  # Julia doesn't support conditional list comprehensions or tuple destructuring,
  # so this is a bit of a mess. TODO - implement in julia?
  columns = [(pair[1], haskey(df, pair[2]) ? df[pair[2]] : 0) for pair in COLUMN_MAP]
  @transform(df, score = f(; columns...))
end


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Type def
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

abstract Squad

immutable Offense <: Squad
  qb::DataFrame
  rb::DataFrame
  wr::DataFrame
  te::DataFrame
end

immutable Defense <: Squad
  def::DataFrame
end

immutable SpecialTeams <: Squad
  st::DataFrame
  off::DataFrame
end

immutable Kicker <: Squad
  k::DataFrame
end

# Season type - holds tables for positions in a given year
immutable Season
  off::Offense
  def::Defense
  st::SpecialTeams
  k::Kicker

  function Season(year::String)
    tables = map(p -> with_team_abbr!(readtable(table_path(year, p))), ["QB", "RB", "WR", "TE", "ST", "DEF", "K"])
    new(tables[1], tables[2], tables[3], tables[4], tables[5], tables[6], tables[7])
  end

  function Season(year::Int64)
    Season(string(year))
  end

  function Season(qb::DataFrame, rb::DataFrame, wr::DataFrame, te::DataFrame, st::DataFrame, def::DataFrame, k::DataFrame)
    new(Offense(qb, rb, wr, te), Defense(def), SpecialTeams(st, off), Kicker(k))
  end
end


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Public functions on Seasons
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Filter a season by team
function filter(season::Season, team::String)
  filtered = [@where(getfield(season, f), :team_abbr .== team) for f in names(season)]
  Season(filtered...)
end

# Add fantasy score column to all frames in a season
function score(season::Season)
  scored = [score(season.off), score(season.def), score(season.st), score(season.k)]
  Season(scored...)
end

score(squad::Offense) = [scored_table(getfield(squad, f), score_off) for f in names(squad)]
score(squad::Defense) = scored_table(squad, score_def)
score(squad::SpecialTeams) = score_table(squad.off, score_st_off) + score_table(squad.st, score_st)
score(squad::Kicker) = scored_table(squad, score_k)
