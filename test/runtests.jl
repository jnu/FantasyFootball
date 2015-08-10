using FantasyFootball

tests = [
  "scoring",
  "season"
]

for t in tests
  tfile = string(t, ".jl")
  print(" * $(tfile) ... ")
  include(tfile)
  println("ok")
end
