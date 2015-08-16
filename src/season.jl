include("scoring.jl")
using DataFrames
using DataFramesMeta

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

immutable DefenseST <: Squad
  def::DataFrame
  wr::DataFrame
end

immutable Kicker <: Squad
  k::DataFrame
end

# Season type - holds tables for positions in a given year
immutable Season
  off::Offense
  def::DefenseST
  k::Kicker

  function Season(year::String)
    tables = map(p -> with_team_abbr!(readtable(table_path(year, p))), ["QB", "RB", "WR", "TE", "DEF", "K"])
    Season(tables[1], tables[2], tables[3], tables[4], tables[5], tables[6])
  end

  function Season(year::Int64)
    Season(string(year))
  end

  function Season(qb::DataFrame, rb::DataFrame, wr::DataFrame, te::DataFrame, def::DataFrame, k::DataFrame)
    new(Offense(qb, rb, wr, te), DefenseST(def, wr), Kicker(k))
  end

  function Season(off::Offense, def::DefenseST, k::Kicker)
    new(off, def, k)
  end
end

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

const OFF_COL_MAP = {
  # Offensive
  (:rush_yds, :RushYds),
  (:rush_td, :RushTD),
  (:rec_yds, :RecYds),
  (:rec_td, :RecTD),
  (:pass_yds, :Yds),
  (:pass_td, :TD),
  (:pass_int, :Int),
  (:sack, :Sack),
  (:fum_l, :FumL),
  # Def / ST
  # (:pr_td, :PRTD),
  # (:kr_td, :KRTD)
}

const DEF_COL_MAP = {
  # (:pr_td, :PRTD),
  # (:kr_td, :KRTD),
  (:games, :G),
  (:papg, symbol("Pts/G")),
  (:int_td, :IntTD),
  (:fum_td, :DefTD), # not quite right
  (:sack, :Sack)
  # (:sfty, :Safety) # Not available?
}

const WR_ST_COL_MAP = {
  (:pr_td, :PRTD),
  (:kr_td, :KRTD)
}

const K_COL_MAP = {
  (:xp_made, :XPM),
  (:xp_att, :XPA),
  (:fg_made, :FGM),
  (:fg_att, :FGA),
  (:f0019, symbol("M0-19")),
  (:f2029, symbol("M20-29")),
  (:f3039, symbol("M30-39")),
  (:f4049, symbol("M40-49")),
  (:f50, symbol("M50+"))
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
function score_table(df::DataFrame, col_map::Array, f::Function)
  # Julia doesn't support conditional list comprehensions or tuple destructuring,
  # so this is a bit of a mess. TODO - implement in julia?
  columns = [(pair[1], haskey(df, pair[2]) ? df[pair[2]] : 0) for pair in col_map]
  @transform(df, score = f(; columns...))
end


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Public functions on Seasons and Squads
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Filter a season by team
function filter(season::Season, team::String)
  Season(filter(season.off, team), filter(season.def, team), filter(season.k, team))
end

function filter(squad::Offense, team::String)
  filtered = [@where(getfield(squad, f), :team_abbr .== team) for f in [:qb, :rb, :wr, :te]]
  Offense(filtered...)
end

function filter(squad::Kicker, team::String)
  Kicker(@where(squad.k, :team_abbr .== team))
end

function filter(squad::DefenseST, team::String)
  filtered = [@where(getfield(squad, f), :team_abbr .== team) for f in [:def, :wr]]
  DefenseST(filtered...)
end


# Add fantasy score column to all frames in a season
function score(season::Season)
  Season(score(season.off), score(season.def), score(season.k))
end

function score(squad::Offense)
  scored = [score_table(getfield(squad, f), OFF_COL_MAP, score_off) for f in [:qb, :rb, :wr, :te]]
  Offense(scored...)
end

function score(squad::Kicker)
  Kicker(score_table(squad.k, K_COL_MAP, score_k))
end

function score(squad::DefenseST)
  def = score_table(squad.def, DEF_COL_MAP, score_def_st)
  wr = score_table(squad.wr, WR_ST_COL_MAP, score_def_st)
  # FIXME: transfer wr scores to def table
  DefenseST(def, wr)
end
