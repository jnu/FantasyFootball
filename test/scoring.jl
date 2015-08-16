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


  # Kicker scoring
  @test score_k() == 0
  @test score_k(xp_made=1) == 1
  @test score_k(xp_att=1) == -1
  @test score_k(fg_made=1) == 0
  @test score_k(fg_att=1) == -1
  @test score_k(f0019=1) == 3
  @test score_k(f2029=1) == 3
  @test score_k(f3039=1) == 3
  @test score_k(f4049=1) == 4
  @test score_k(f50=1) == 5

  @test score_k(xp_made=1, xp_att=2, fg_made=1, fg_att=2, f0019=1, f2029=1, f3039=1, f4049=1, f50=1) == (1 + -1 + -1 + 3 + 3 + 3 + 4 + 5)


  # Defense / Special Teams scoring
  @test score_def_st() == 0
  @test score_def_st(games=1) == 5
  @test score_def_st(games=2) == 10
  @test score_def_st(papg=1) == 0
  @test score_def_st(games=1, papg=0) == 5
  @test score_def_st(games=1, papg=6) == 4
  @test score_def_st(games=1, papg=13) == 3
  @test score_def_st(games=1, papg=17) == 1
  @test score_def_st(games=1, papg=27) == 0
  @test score_def_st(games=1, papg=34) == -1
  @test score_def_st(games=1, papg=45) == -3
  @test score_def_st(games=1, papg=46) == -5
  @test score_def_st(kr_td=1) == 6
  @test score_def_st(pr_td=1) == 6
  @test score_def_st(int_td=1) == 6
  @test score_def_st(fum_td=1) == 6
  @test score_def_st(sack=1) == 1
  @test score_def_st(sfty=1) == 2

  @test score_def_st(games=1, papg=1, kr_td=1, pr_td=1, int_td=1, fum_td=1, sack=1, sfty=1) == (4 + 6 + 6 + 6 + 6 + 1 + 2)

end