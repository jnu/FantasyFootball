using FantasyFootball
using Gadfly, Color
using DataFrames, DataFramesMeta
using StatsBase

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

fields = [:team_abbr, :score]
plucked = [
  [@transform(getfield(s14.off, f)[fields], pos = string(f)) for f in names(s14.off)],
  @transform(s14.def.def[fields], pos = "def/st"),
  @transform(s14.k.k[fields], pos = "k")
]

df = vcat(plucked...)


# Point density by position
pd_pos = plot(df, x = :score, color = :pos, Geom.density, Guide.title("Point production density by position, 2014"))
draw(SVG(joinpath(dir, "pos_point_density.svg"), 30cm, 12cm), pd_pos)
hist_pos = plot(df, x = :score, color = :pos, Geom.histogram, Guide.title("Point production by position"))
draw(SVG(joinpath(dir, "pos_point_hist.svg"), 30cm, 12cm), hist_pos)


# "Rounds" pos density
rounds = @transform(sort(df, cols = [:score], rev = true), round = [div(1, x) + 1 for x in 1:size(df)[1]])
pd_round = plot(@where(rounds, :round .< 10), x = :round, y = :pos, Geom.histogram2d, Scale.x_discrete, gradient, Guide.title("Position distribution of top hundred picks by draft round"))
#draw(SVG(joinpath(dir, "top_positions_by_rounds.svg"), 12cm, 6cm), pd_round)


# QB production over the years
qbs = [sort(s.off.qb, cols = [:score], rev = true)[[:Name, :score]] for s in seasons]
# Join all qb season years
all_qb = reduce((a, b) -> join(a, b, on = :Name, kind = :outer), qbs)
# rename score columns for better reading
pt_cols = [symbol("pts$(s)") for s in 2010:2014]
names!(all_qb, [:Name, pt_cols])
# standardize data for each season
all_qb_norm = @transform(all_qb, norm2010=zscore(:pts2010), norm2011=zscore(:pts2011), norm2012=zscore(:pts2012), norm2013=zscore(:pts2013), norm2014=zscore(:pts2014))
# Look at top N qbs in 2014 and see their previous seasons
top_qbs = sort(all_qb_norm, cols = [:norm2014], rev = true)[[:Name, :norm2010, :norm2011, :norm2012, :norm2013, :norm2014]]
top_qbs_lng = melt(top_qbs[1:20,:], :Name)
qbs_line = plot(top_qbs_lng, x = :variable, y = :value, color = :Name, Geom.line, Guide.title("Top 2014 QBs points over time"))
draw(SVG(joinpath(dir, "top_qb_over_time.svg"), 30cm, 12cm), qbs_line)


function mean_and_stddev_nona{T<:Real}(X::AbstractArray{T})
  sum = 0.
  n = 0
  for x in X
    if !isna(x)
      n += 1
      sum += x
    end
  end

  µ = sum / n

  sum = 0.
  for x in X
    if !isna(x)
      sum += (x - µ)^2
    end
  end

  σ = √(sum / n)

  (µ, σ)
end

function zscore_nona{T<:Real}(X::AbstractArray{T}, µ::Real, σ::Real)
  Z = Array(T, size(X))
  for i = 1:length(X)
    x = X[i]
    if !isna(x)
      @inbounds Z[i] = (x - µ) / σ
    else
      @inbounds Z[i] = x
    end
  end
  Z
end
zscore_nona{T<:Real}(X::AbstractArray{T}) = ((µ, σ) = mean_and_stddev_nona(X); zscore_nona(X, µ, σ))
