using Clustering
using DataFrames
using DataFramesMeta

const BASE_DIR = dirname(@__FILE__)


# Get a DataFrame describing the aggregate of year, week, and kind.
function gettable(year::Int, week = 0, kind = "REG")
    dir = joinpath(BASE_DIR, "..", "data", "nflgame")
    # Construct the path for the table
    filename = "$(year)-season"
    if week > 0
        wk = ""
        if week < 10
            wk = "0"
        end
        wk *= string(week)
        filename *= "-week" * wk
    end
    filename *= "-" * lowercase(kind)
    filename *= ".csv"
    readtable(joinpath(dir, filename))
end 

# Extract players matching the given position from a DataFrame
function getpos(table::AbstractDataFrame, pos::String)
    @where(@where(table, !isna(:pos)), :pos .== pos)
end


qb_stats = [
    :name,
    :passing_att,
    :passing_cmp,
    # :passing_cmp_air_yds,
    # :passing_incmp,
    # :passing_incmp_air_yds,
    :passing_int,
    # :passing_sk,
    # :passing_sk_yds,
    :passing_tds,
    # :passing_twopta,
    # :passing_twoptm,
    # :passing_twoptmissed,
    :passing_yds,
    # :penalty,
    # :penalty_yds,
    :rushing_att,
    # :rushing_lng,
    :rushing_tds,
    # :rushing_twopta,
    # :rushing_twoptm,
    # :rushing_twoptmissed,
    :rushing_yds
]


function getqbs(year, attempts = None)
    qbs = getpos(gettable(year), "QB")

    if attempts != None
        qbs = @where(@where(qbs, !isna(:passing_att)), :passing_att .>= attempts)
    end

    qbs[1:end, qb_stats]
end



function qbstats(year, k = 2)
    qbs = getqbs(year)[:, qb_stats]
    # TODO replace NA with 0?
    cqbs = qbs[complete_cases(qbs), :]
    dqbs = @transform(cqbs,
            rush_rat = :passing_att ./ :rushing_att,
            pass_ypa = :passing_yds ./ :passing_att,
            rush_ypa = :rushing_yds ./ :rushing_att,
            pass_acc = :passing_cmp ./ :passing_att,
            pass_int_acc = :passing_int ./ :passing_att,
            td_prod = (:passing_tds + :rushing_tds) ./ (:passing_att + :rushing_att)
        )
    mtx = transpose(convert(Matrix{Float64}, dqbs[:, 2:end]))
    cluster = kmeans(mtx, 2)
    # NB use string for cluster ID to get ordinal cluster scale from Gadfly
    @transform(dqbs, kcluster = ["k$(c)" for c in cluster.assignments])
end


