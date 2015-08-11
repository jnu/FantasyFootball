module ScoringTests
  using Base.Test
  include("../src/scoring.jl")

  # Offensive scoring
  @test score_off() == 0
  @test score_off(rush_yds=1) == 0
  @test score_off(rush_yds=10) == 1
  @test score_off(rush_td=1) == 6
  @test score_off(rec_yds=1) == 0
  @test score_off(rec_yds=10) == 1
  @test score_off(rec_td=1) == 6
  @test score_off(pass_yds=10) == 0
  @test score_off(pass_yds=25) == 1
  @test score_off(pass_td=1) == 4
  @test score_off(pass_int=1) == -2
  @test score_off(sack=1) == 0
  @test score_off(fum_l=1) == -2
  @test score_off(pr_td=1) == 6
  @test score_off(kr_td=1) == 6

  @test score_off(rush_yds=10, rush_td=1, rec_yds=10, rec_td=1, pass_yds=25, pass_td=1, pass_int=1, sack=1, fum_l=1, pr_td=1, kr_td=1) == (1 + 6 + 1 + 6 + 1 + 4 + -2 + 0 + -2 + 6 + 6)

end