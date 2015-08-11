module TestSeason
  using DataFrames
  using Base.Test
  include("../src/season.jl")

  # Construction
  s10 = Season(2010)
  s10s = Season("2010")
  s11 = Season(2011)
  s12 = Season(2012)
  s13 = Season(2013)
  s14 = Season(2014)

  @test typeof(s10) == Season
  @test typeof(s10s) == Season
  @test typeof(s10.qb) == DataFrame
  @test typeof(s10s.qb) == DataFrame
  @test typeof(s10.rb) == DataFrame
  @test typeof(s10.te) == DataFrame
  @test typeof(s10.wr) == DataFrame
  @test typeof(s10.st) == DataFrame
  @test typeof(s10.def) == DataFrame
  @test typeof(s10.k) == DataFrame


  # filter
  nwe14 = filter(s14, "NWE")
  @test nwe14.k[:Name] == ["Stephen Gostkowski"]
  @test nwe14.def[:team_abbr] == ["NWE"]
  @test nwe14.st[:team_abbr] == ["NWE"]
  @test nwe14.qb[:Name] == ["Jimmy Garoppolo", "Tom Brady"]
  @test length(nwe14.te[:Name]) == 4
  @test length(nwe14.wr[:Name]) == 6
  @test length(nwe14.rb[:Name]) == 7


  # Source data resolver helpers
  # XXX *nix specific paths
  @test rsearch(table_path("2014", "DEF"), "/src/../data/2014/DEF.csv").start > 0
  @test rsearch(table_logical_path("2014", "DEF"), "/src/../data/2014/DEF").start > 0
end
