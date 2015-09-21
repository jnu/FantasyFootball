using FantasyFootball
using Gadfly, Color
using DataFrames, DataFramesMeta
using StatsBase

# include stat functions that can work around NAs
include("stat.jl")

gradient = Scale.ContinuousColorScale(Scale.lab_gradient(color("white"), RGB(0.5, 0, 0), color("red")))

# target dir should be checked into git, but empty.
dir = joinpath(dirname(@__FILE__), "..", "graphs")
# TODO - clean target directory here?

# General experiments

# General setup
s10 = score(Season(2010))
s11 = score(Season(2011))
s12 = score(Season(2012))
s13 = score(Season(2013))
s14 = score(Season(2014))

seasons = [s10, s11, s12, s13, s14]

off = [[@transform(getfield(seasons[i].off, f), pos=string(f), season=string(2009 + i)) for f in names(seasons[i].off)] for i in 1:length(seasons)]

fields = [:team_abbr, :score]
plucked = [
  [@transform(getfield(s14.off, f)[fields], pos = string(f)) for f in names(s14.off)],
  @transform(s14.def.def[fields], pos = "def/st"),
  @transform(s14.k.k[fields], pos = "k")
]

df = vcat(plucked...)
#
# pos_tables = [nu
# for season in seasons:
#   off = @


# Point density by position
# pd_pos = plot(df, x = :score, color = :pos, Geom.density, Guide.title("Point production density by position, 2014"))
# draw(SVG(joinpath(dir, "pos_point_density.svg"), 30cm, 12cm), pd_pos)
# hist_pos = plot(df, x = :score, color = :pos, Geom.histogram, Guide.title("Point production by position"))
# draw(SVG(joinpath(dir, "pos_point_hist.svg"), 30cm, 12cm), hist_pos)


# # "Rounds" pos density
# rounds = @transform(sort(df, cols = [:score], rev = true), round = [div(1, x) + 1 for x in 1:size(df)[1]])
# pd_round = plot(@where(rounds, :round .< 10), x = :round, y = :pos, Geom.histogram2d, Scale.x_discrete, gradient, Guide.title("Position distribution of top hundred picks by draft round"))
# #draw(SVG(joinpath(dir, "top_positions_by_rounds.svg"), 12cm, 6cm), pd_round)

# Names for the point columns
pt_cols = [symbol("pts$(s)") for s in 2010:2014]

# Helpers to extract score info by position and join the year tables
# e.g.
# qbs = [sort(s.off.qb), cols = [:score], rev = true)[[:Name, :score]] for s in seasons]
# all_qb = reduce((a, b) -> join(a, b, on = :Name, kind = :outer), qbs)
join_pos(pos, j) = reduce((a, b) -> join(a, b, on = j, kind = :outer), pos)
get_tables(pos, j) = [sort(getfield(s.off, pos), cols = [:score], rev = true)[[j, :score]] for s in seasons]
get_tables(p1, p2, j) = [sort(getfield(getfield(s, p1), p2), cols = [:score], rev = true)[[j, :score]] for s in seasons]
function get_all_years(p1, p2, j=:Name)
    table = join_pos(get_tables(p1, p2), j)
    names!(table, [j, pt_cols])
    @transform(table, std2010=nazscore(:pts2010), std2011=nazscore(:pts2011), std2012=nazscore(:pts2012), std2013=nazscore(:pts2013), std2014=nazscore(:pts2014))
end

wrs = get_all_years(:off, :wr)
rbs = get_all_years(:off, :rb)
tes = get_all_years(:off, :te)
qbs = get_all_years(:off, :qb)
def = get_all_years(:def, :def, :team_abbr)


std_cols = [:std2010, :std2011, :std2012, :std2013, :std2014]
function best_of_2014(table, n=100)
    top = sort(@where(table, !isna(:std2014)), cols=[sym], rev=true)[[:Name, std_cols]]
    top_lng = @where(melt(top[1:n,:], :Name), !isna(:value))
end


import Base.max
function max{T<:Real}(cols::DataArray{T}...)
    Z = DataArray(T, size(cols[1]))
    for i in 1:length(cols[1])
        @inbounds Z[i] = max([isna(col[i]) ? -Inf : col[i] for col in cols]...)
    end
    Z
end

function best_ever(table, n)
    tbl = @transform(table[[:Name, std_cols]], max = max(:std2010, :std2011, :std2012, :std2013, :std2014))
    best = sort(tbl, cols=[:max], rev=true)[1:n,:]
    top_melt = melt(best[[:Name, std_cols]], :Name)
    sort(@where(top_melt, !isna(:value)), cols=[:variable, :value])
end

_top_line(df) = plot(df, x=:variable, y=:value, color=:Name, Geom.line)
_top_rect(df) = plot(df, x=:variable, y=:Name, color=:value, Geom.rectbin)

top2014_line(table, n=10) = _top_line(best_of_2014(table, n))
top2014_rect(table, n=20) = _top_rect(best_of_2014(table, n))
best_line(table, n=20) = _top_line(best_ever(table, n))
best_rect(table, n=20) = _top_rect(best_ever(table, n))


