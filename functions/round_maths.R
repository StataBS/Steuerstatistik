# Custom rounding function to simulate "mathematical rounding"
# (always round .5 up) because R's built-in round() uses "round to even" (Banker's rounding).
# This function ensures that values like 2.5 become 3 and not 2.

round_maths <- function(x, digits = 0) {
  multiplier <- 10^digits
  floor(x * multiplier + 0.5) / multiplier
}