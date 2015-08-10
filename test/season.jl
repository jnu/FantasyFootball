using FantasyFootball
using DataFrames
using Base.Test

s10 = Season(2010)
s11 = Season(2011)
s12 = Season(2012)
s13 = Season(2013)
s14 = Season(2014)

@test typeof(s10) == Season
@test typeof(s10.qb) == DataFrame
@test typeof(s10.rb) == DataFrame
@test typeof(s10.te) == DataFrame
@test typeof(s10.wr) == DataFrame
@test typeof(s10.st) == DataFrame
@test typeof(s10.def) == DataFrame
@test typeof(s10.k) == DataFrame
