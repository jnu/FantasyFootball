include("../src/point_system.jl")

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

function get_points_allowed_pts(papg::Real)
  cur = PTS_ALLOWED_PTS[1]
  for bin in PTS_ALLOWED_PTS
    if papg < bin[1]
      return cur[2]
    else
      cur = bin
    end
  end
  return cur[2]
end

# Score a team's defense
#  - No blocks
#  - Points allowed is just an average
function score_def_st(; games = 0, papg = 0, kr_td = 0, pr_td = 0, int_td = 0, fum_td = 0, sack = 0, sfty = 0)
  (
    games * get_points_allowed_pts(papg) +
    kr_td * DEF_KR_TD_PTS +
    pr_td * DEF_PR_TD_PTS +
    int_td * INT_TD_PTS +
    fum_td * FUM_TD_PTS +
    sack * DEF_SACK_PTS +
    sfty * DEF_SFTY_PTS
  )
end

function score_k(; xp_made = 0, xp_att = 0, fg_made = 0, fg_att = 0, f0019 = 0, f2029 = 0, f3039 = 0, f4049 = 0, f50 = 0)
  (
    xp_made * XP_MADE_PTS +
    (max(xp_att - xp_made, 0) + max(fg_att - fg_made, 0)) * FG_MISS_PTS +
    (f0019 + f2029 + f3039) * FG_0039_PTS +
    f4049 * FG_4049_PTS +
    f50 * FG_50_PTS
  )
end
