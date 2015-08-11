using FantasyFootball

tests = [
  "scoring",
  "Season"
]

for t in tests
  tfile = string(t, ".jl")
  print(" * $(tfile) ... ")
  include(tfile)
  println("ok")
end
