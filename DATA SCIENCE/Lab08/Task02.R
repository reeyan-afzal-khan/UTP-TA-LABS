cat("\n=== Activity 2: AirPassengers Dataset ===\n")

data("AirPassengers")
print(AirPassengers)

ap_df <- data.frame(
  Year       = floor(time(AirPassengers)),
  Month      = cycle(AirPassengers),
  Passengers = as.numeric(AirPassengers)
)

cat("\nSummary Statistics:\n")
print(summary(ap_df$Passengers))


# --- Plot 1: Line Graph - Overall Passenger Trend ---
plot(AirPassengers,
     main = "Monthly Airline Passengers (1949-1960)",
     xlab = "Year",
     ylab = "Number of Passengers (Thousands)",
     col  = "royalblue",
     lwd  = 2,
     type = "l")
grid(col = "lightgray", lty = "dotted")


# --- Plot 2: Bar Chart - Average Passengers per Year ---
yearly_avg <- tapply(ap_df$Passengers, ap_df$Year, mean)

barplot(yearly_avg,
        main   = "Average Monthly Passengers per Year",
        xlab   = "Year",
        ylab   = "Avg Passengers (Thousands)",
        col    = "steelblue",
        border = "white",
        las    = 2)


# --- Plot 3: Boxplot - Passenger Distribution by Month ---
boxplot(Passengers ~ Month,
        data  = ap_df,
        main  = "Passenger Distribution by Month (1949-1960)",
        xlab  = "Month",
        ylab  = "Passengers (Thousands)",
        col   = "lightyellow",
        border= "gray30",
        names = month.abb)


# --- Plot 4: Line Graph - Seasonality Pattern by Year ---
colors_list <- rainbow(length(unique(ap_df$Year)))

plot(1:12, type = "n",
     xlim = c(1, 12),
     ylim = range(ap_df$Passengers),
     main = "Seasonal Pattern of Passengers by Year",
     xlab = "Month",
     ylab = "Passengers (Thousands)",
     xaxt = "n")

axis(1, at = 1:12, labels = month.abb)

years <- unique(ap_df$Year)
for (i in seq_along(years)) {
  yr_data <- ap_df[ap_df$Year == years[i], ]
  lines(yr_data$Month, yr_data$Passengers,
        col = colors_list[i], lwd = 1.5)
}

legend("topleft",
       legend = years,
       col    = colors_list,
       lwd    = 1.5,
       cex    = 0.7,
       ncol   = 3,
       title  = "Year")


# --- Plot 5: Histogram - Distribution of Passenger Counts ---
hist(ap_df$Passengers,
     main   = "Frequency Distribution of Monthly Passenger Counts",
     xlab   = "Passengers (Thousands)",
     ylab   = "Frequency",
     col    = "mediumseagreen",
     border = "white",
     breaks = 15)


cat("\nAll plots generated successfully!\n")
cat("\n--- Key Insights: Titanic (Activity 1) ---\n")
cat("  - More passengers did not survive than survived\n")
cat("  - 1st class passengers had the highest survival rate\n")
cat("  - Females survived at a much higher rate than males\n")
cat("  - Higher fares correlate with better survival odds\n")
cat("  - Most passengers were aged 20-40\n")
cat("\n--- Key Insights: AirPassengers (Activity 2) ---\n")
cat("  - Consistent growth from 1949 to 1960\n")
cat("  - Peak travel months: June, July, August\n")
cat("  - Lowest months: January, November\n")
cat("  - Growth rate accelerated in the late 1950s\n")
cat("  - Growth rate accelerated in the late 1950s\n")