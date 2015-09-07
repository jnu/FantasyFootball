module TestStat
  include("../src/stat.jl")
  using DataFrames
  using StatsBase
  using Base.Test

  nona = @data [1, 2, 3, 4, 5]
  onena = @data [1, NA, 3, 4, 5]
  twona = @data [1, NA, 3, NA, 5]

  # Using 0 NA
  # Track StatsBase zscore results. They use sample stddev as default, so we
  # should too for consistency. Throw an error if this changes.
  statsbase_zscore = @data zscore(nona)
  statsbase_zscore_pop = @data zscore(nona, 3., √2)
  @test isequal(nazscore(nona), statsbase_zscore)
  @test isequal(nazscore_pop(nona), statsbase_zscore_pop)
  # Give the objectively correct results as a sanity check in case StatsBase
  # gets whacky.
  expected_nona = @data [
    -1.2649110640673518,
    -0.6324555320336759,
    0.0,
    0.6324555320336759,
    1.2649110640673518
  ]
  expected_nona_pop = @data [
    -1.414213562373095,
    -0.7071067811865475,
    0.0,
    0.7071067811865475,
    1.414213562373095
  ]
  @test isequal(nazscore(nona), expected_nona)
  @test isequal(nazscore_pop(nona), expected_nona_pop)

  # Using 1 NA
  expected_onena = @data [
    -1.3174650984805198,
    NA,
    -0.14638501094227999,
    0.43915503282683993,
    1.02469507659596
  ]
  expected_onena_pop = @data [
    -1.52127765851133,
    NA,
    -0.1690308509457033,
    0.50709255283711,
    1.1832159566199232
  ]

  @test isequal(nazscore(onena), expected_onena)
  @test isequal(nazscore_pop(onena), expected_onena_pop)

  # Using 2 NA
  expected_twona = @data [-1., NA, 0., NA, 1.]
  expected_twona_pop = @data [
    -1.224744871391589,
    NA,
    0.0,
    NA,
    1.224744871391589
  ]

  @test isequal(nazscore(twona), expected_twona)
  @test isequal(nazscore_pop(twona), expected_twona_pop)
end