using FantasyFootball

@test score_off() == 0
@test score_off(rush_yds=1) == 0
@test score_off(rush_yds=10) == 1
@test score_off(rush_td=1) == 6
@test score_off(rec_yds=1) == 0
@test score_off(rec_yds=10) == 1
@test score_off(rec_td=1) == 6
@test score_off(pass_yds=10) == 0
@test score_off(pass_yds=100) == 4
@test score_off(pass_td=1) == 4
