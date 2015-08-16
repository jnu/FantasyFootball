using FantasyFootball
using Gadfly, Color
using DataFrames, DataFramesMeta

gradient = Scale.ContinuousColorScale(Scale.lab_gradient(color("white"), RGB(0.5, 0, 0), color("red")))

# target dir should be checked into git, but empty.
dir = joinpath(dirname(@__FILE__), "..", "graphs")
# TODO - clean target directory here?

# General experiments

# General setup
s14 = score(Season(2014))

fields = [:team_abbr, :score]
plucked = [
  [@transform(getfield(s14.off, f)[fields], pos = string(f)) for f in names(s14.off)],
  @transform(s14.def.def[fields], pos = "def/st"),
  @transform(s14.k.k[fields], pos = "k")
]

df = vcat(plucked...)


# Point density by position
pd_pos = plot(df, x = :score, color = :pos, Geom.density, Guide.title("Point production density by position, 2014"))
draw(SVG(joinpath(dir, "point_density.svg"), 35cm, 15cm), pd_pos)


# "Rounds" pos density
rounds = @transform(sort(df, cols = [:score], rev = true), round = [div(1, x) + 1 for x in 1:size(df)[1]])
pd_round = plot(@where(rounds, :round .< 10), x = :round, y = :pos, Geom.histogram2d, Scale.x_discrete, gradient, Guide.title("Position distribution of top hundred picks by draft round"))
#draw(SVG(joinpath(dir, "top_positions_by_rounds.svg"), 12cm, 6cm), pd_round)
