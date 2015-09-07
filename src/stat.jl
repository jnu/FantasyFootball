# Standardization for data arrays containing NAs. The NAs are simply ignored
# when analyzing the population.

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
  Z = DataArray(Real, size(X))
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
