# Scoring constants

# Offense
const RUSH_YDS_BATCH = 10
const RUSH_YDS_PTS = 1
const RUSH_TD_PTS = 6
const REC_YDS_BATCH = 10
const REC_YDS_PTS = 1
const REC_TD_PTS = 6
const PASS_YDS_BATCH = 25
const PASS_YDS_PTS = 1
const PASS_TD_PTS = 4
const PASS_INT_PTS = -2
const SACK_PTS = 0
const KR_TD_PTS = 6
const PR_TD_PTS = 6
const FUM_L_PTS = -2

# Defense
const DEF_KR_TD_PTS = 6
const DEF_PR_TD_PTS = 6
const INT_TD_PTS = 6
const FUM_TD_PTS = 6
const PUNT_TD_PTS = 6
const DEF_INT_PTS = 2
const DEF_FUM_R_PTS = 2
const DEF_SFTY_PTS = 2
const DEF_SACK_PTS = 1
const PTS_ALLOWED_PTS = {
  (0, 5),
  (1, 4),
  (7, 3),
  (14, 1),
  (18, 0),
  (28, -1),
  (35, -3),
  (46, -5)
}

# Kicker
const FG_MISS_PTS = -1
const XP_MADE_PTS = 1
const FG_0039_PTS = 3
const FG_4049_PTS = 4
const FG_50_PTS = 5
