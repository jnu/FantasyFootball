using FantasyFootball
using Clustering
using DataFrames, DataFramesMeta
using Gadfly, Immerse

const BASE_DIR = dirname(@__FILE__)


function replacena!(df::AbstractDataFrame, replacement::Any)
    nrows, ncols = size(df)
    for j = 1:ncols
        for i = 1:nrows
            if isna(df[i, j])
                df[i, j] = replacement
            end
        end
    end
    df
end 


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
    :team,
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


function getqbs(year, week = 0; nona = false, attempts = 0)
    qbs = getpos(gettable(year, week), "QB")[:, qb_stats]

    if attempts > 0
        qbs = @where(
            @where(qbs, !isna(:passing_att)),
            :passing_att .>= attempts
        )
    end

    if nona
        replacena!(qbs, 0)
    end

    qbs
end



function qbstats(year, week = 0; k = 2, attempts = 0, nona = false)
    qbs = getqbs(year, week; attempts = attempts, nona = nona)
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
    mtx = transpose(convert(Matrix{Float64}, dqbs[:, 3:end]))
    cluster = kmeans(mtx, k)
    # NB use string for cluster ID to get ordinal cluster scale from Gadfly
    @transform(dqbs, kcluster = ["k$(c)" for c in cluster.assignments])
end

function _join_weeks(year::Int, pull_week::Function)
    vcat([
        @transform(
            pull_week(year, wk),
            week="week$(wk)"
        ) for wk in 1:17
    ]...)
end

function _pull_qb_week(year::Int, week::Int)
    qbstats(year, week; nona=true, attempts=0)
end

function allqbwks(year::Int)
    _join_weeks(year, _pull_qb_week)
end



wr_stats = [
    :name,
    :team,
    # :receiving_lng,
    # :receiving_lngtd,
    :receiving_rec,
    :receiving_tar,
    :receiving_tds,
    # :receiving_twopta,
    # :receiving_twoptm,
    # :receiving_twoptmissed,
    :receiving_yac_yds,
    :receiving_yds
]


function getwrs(year, week = 0; targets = 0, nona = false) 
    wrs = getpos(gettable(year, week), "WR")[:, wr_stats]

    if targets > 0
        wrs = @where(
            @where(wrs, !isna(:receiving_tar)),
            :receiving_tar .>= targets
        )
    end

    if nona
        replacena!(wrs, 0)
    end

    wrs
end


function _pull_wr_week(year::Int, week::Int)
    wrstats(year, week; nona=true, targets=0)
end

function allwrwks(year::Int)
    _join_weeks(year, _pull_wr_week)
end


function wrstats(year, week = 0; k = 2, targets = 0, nona = false)
    wrs = getwrs(year, week; targets = targets, nona = nona)
    cwrs = wrs[complete_cases(wrs), :]
    dwrs = @transform(cwrs,
        td_p_tar = :receiving_tds ./ :receiving_tar,
        yd_p_tar = :receiving_yds ./ :receiving_tar
    )
    mtx = transpose(convert(Matrix{Float64}, dwrs[:, 3:end]))
    cluster = kmeans(mtx, k)
    @transform(dwrs, kcluster = ["k$(c)" for c in cluster.assignments])
end


