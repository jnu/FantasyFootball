using FantasyFootball

tests = [
  "scoring",
  "season",
  "stat"
]

for t in tests
  tfile = string(t, ".jl")
  print(" * $(tfile) ... ")
  include(tfile)
  println("ok")
end
