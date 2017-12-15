# Multiply a 5000 by 5000 matrix of random numbers by its transpose
system.time({ x <- replicate(5e3, rnorm(5e3)); tcrossprod(x) })
