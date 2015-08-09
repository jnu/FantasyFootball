# Score an offensive player
# Missing (not in stats, so can't be considered):
#  - 2pt Conversions
function score_off(; rush_yds = 0, rush_td = 0, rec_yds = 0, rec_td = 0, pass_yds = 0, pass_td = 0, pass_int = 0, sack = 0, fum_l = 0, pr_td = 0, kr_td = 0
)
  (
    div(rush_yds, RUSH_YDS_BATCH) * RUSH_YDS_PTS +
    rush_td * RUSH_TD_PTS +
    div(rec_yds, REC_YDS_BATCH) * REC_YDS_PTS +
    rec_td * REC_TD_PTS +
    div(pass_yds, PASS_YDS_BATCH) * PASS_YDS_PTS +
    pass_td * PASS_TD_PTS +
    pass_int * PASS_INT_PTS +
    sack * SACK_PTS +
    fum_l * FUM_L_PTS +
    pr_td * PR_TD_PTS +
    kr_td * KR_TD_PTS
  )
end
