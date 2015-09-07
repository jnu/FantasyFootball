# Standardization for data arrays containing NAs. The NAs are simply ignored
# when analyzing the population.

function na_mean_and_stddev{T<:Real}(X::AbstractArray{T}, sample::Bool)
  sum = 0.
  n = 0
  for x in X
    if !isna(x)
      n += 1
      sum += x
    end
  end

  # TODO handle n=0
  µ = sum / n

  sum = 0.
  for x in X
    if !isna(x)
      sum += (x - µ)^2
    end
  end

  # Use n - 1 to calculate sample stddev
  if sample
    n -= 1
  end

  # TODO handle n=0
  # TODO could multiply by cached 1/n if available
  σ = √(sum / n)

  (µ, σ)
end

function nazscore{T<:Real}(X::AbstractArray{T}, µ::Real, σ::Real)
  Z = DataArray(Float64, size(X))
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
nazscore{T<:Real}(X::AbstractArray{T}) = ((µ, σ) = na_mean_and_stddev(X, true); nazscore(X, µ, σ))
nazscore_pop{T<:Real}(X::AbstractArray{T}) = ((µ, σ) = na_mean_and_stddev(X, false); nazscore(X, µ, σ))
