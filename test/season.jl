module TestSeason
  using DataFrames
  using Base.Test
  include("../src/season.jl")

  # Construction
  s10 = Season(2010)
  s10s = Season("2010")
  s10c = Season(s10.off, s10.def, s10.k)
  s11 = Season(2011)
  s12 = Season(2012)
  s13 = Season(2013)
  s14 = Season(2014)

  @test typeof(s10) == Season
  @test typeof(s10s) == Season
  @test typeof(s10.off.qb) == DataFrame
  @test typeof(s10s.off.qb) == DataFrame
  @test typeof(s10.off.rb) == DataFrame
  @test typeof(s10.off.te) == DataFrame
  @test typeof(s10.off.wr) == DataFrame
  @test typeof(s10.def.def) == DataFrame
  @test typeof(s10.def.wr) == DataFrame
  @test typeof(s10.k.k) == DataFrame
  @test s10c.off == s10.off
  @test s10c.def == s10.def
  @test s10c.k == s10.k


  # filter
  nwe14 = filter(s14, "NWE")
  @test nwe14.k.k[:Name] == ["Stephen Gostkowski"]
  @test nwe14.def.def[:team_abbr] == ["NWE"]
  @test nwe14.def.wr[:team_abbr] == ["NWE", "NWE", "NWE", "NWE", "NWE", "NWE"]
  @test nwe14.off.qb[:Name] == ["Jimmy Garoppolo", "Tom Brady"]
  @test nwe14.off.te[:team_abbr] == ["NWE", "NWE", "NWE", "NWE"]
  @test nwe14.off.wr[:team_abbr] == ["NWE", "NWE", "NWE", "NWE", "NWE", "NWE"]
  @test nwe14.off.rb[:team_abbr] == ["NWE", "NWE", "NWE", "NWE", "NWE", "NWE", "NWE"]

  # filter - specific dispatch
  nwe14k = filter(s14.k, "NWE")
  @test nwe14k.k[:Name] == ["Stephen Gostkowski"]
  nwe14d = filter(s14.def, "NWE")
  @test nwe14d.def[:team_abbr] == ["NWE"]
  @test nwe14d.wr[:Name] == [
    "Julian Edelman",
    "Brandon LaFell",
    "Danny Amendola",
    "Brian Tyms",
    "Aaron Dobson",
    "Matthew Slater"
  ]
  nwe14o = filter(s14.off, "NWE")
  @test nwe14o.qb[:Name] == [
    "Jimmy Garoppolo",
    "Tom Brady"
  ]
  @test nwe14o.wr[:Name] == [
    "Julian Edelman",
    "Brandon LaFell",
    "Danny Amendola",
    "Brian Tyms",
    "Aaron Dobson",
    "Matthew Slater"
  ]
  @test nwe14o.rb[:Name] == [
    "LeGarrette Blount",
    "Jonas Gray",
    "Shane Vereen",
    "Stevan Ridley",
    "Brandon Bolden",
    "James White",
    "James Develin"
  ]
  @test nwe14o.te[:Name] == [
    "Rob Gronkowski",
    "Tim Wright",
    "Michael Hoomanawanui",
    "Steve Maneri"
  ]


  # score
  nwe14s = score(nwe14)
  @test sort(nwe14s.off.qb[:score]) == [11, 277]
  @test sort(nwe14s.off.wr[:score]) == [0, 3, 14, 26, 121, 135]
  @test sort(nwe14s.off.te[:score]) == [0, 4, 49, 160]
  @test sort(nwe14s.off.rb[:score]) == [4, 5, 14, 48, 71, 87, 113]
  @test sort(nwe14s.k.k[:score]) == [49]
  @test sort(nwe14s.def.def[:score]) == [138]
  @test sort(nwe14s.def.def[:score_def]) == [132]
  @test sort(nwe14s.def.wr[:score]) == [0, 0, 0, 0, 0, 6]

  # Score - specific dispatch
  nwe14os = score(nwe14.off)
  @test sort(nwe14os.qb[:score]) == [11, 277]
  @test sort(nwe14os.wr[:score]) == [0, 3, 14, 26, 121, 135]
  @test sort(nwe14os.te[:score]) == [0, 4, 49, 160]
  @test sort(nwe14os.rb[:score]) == [4, 5, 14, 48, 71, 87, 113]
  nwe14ks = score(nwe14.k)
  @test sort(nwe14ks.k[:score]) == [49]
  nwe14ds = score(nwe14.def)
  @test sort(nwe14ds.def[:score]) == [138]
  @test sort(nwe14ds.def[:score_def]) == [132]
  @test sort(nwe14ds.wr[:score]) == [0, 0, 0, 0, 0, 6]


  # Source data resolver helpers
  # FIXME *nix specific paths
  @test rsearch(table_path("2014", "DEF"), "/src/../data/2014/DEF.csv").start > 0
  @test rsearch(table_logical_path("2014", "DEF"), "/src/../data/2014/DEF").start > 0
end
