df <- read.csv("titanic_sortbyfare.csv")

# Preview the data
cat("=== Activity 1: Titanic Dataset ===\n")
head(df)
str(df)
summary(df)

# Clean up: Convert Survived and Pclass to factors for plotting
df$Survived <- factor(df$Survived, levels = c(0, 1),
                      labels = c("Did Not Survive", "Survived"))
df$Pclass   <- factor(df$Pclass, levels = c(1, 2, 3),
                      labels = c("1st Class", "2nd Class", "3rd Class"))
df$Sex      <- factor(df$Sex)


# --- Plot 1: Bar Chart - Survival Count ---
survival_counts <- table(df$Survived)

barplot(survival_counts,
        main   = "Titanic: Passenger Survival Count",
        xlab   = "Survival Status",
        ylab   = "Number of Passengers",
        col    = c("salmon", "steelblue"),
        border = "white",
        ylim   = c(0, max(survival_counts) + 20))

# Observation: More passengers did not survive than survived,
# highlighting the severity of the Titanic disaster.


# --- Plot 2: Bar Chart - Survival by Passenger Class ---
class_survival <- table(df$Pclass, df$Survived)

barplot(class_survival,
        beside  = TRUE,
        main    = "Survival Count by Passenger Class",
        xlab    = "Survival Status",
        ylab    = "Number of Passengers",
        col     = c("gold", "lightgreen", "tomato"),
        legend  = rownames(class_survival),
        args.legend = list(title = "Class", x = "topright"),
        border  = "white")

# Observation: 1st class passengers had a significantly higher
# survival rate compared to 2nd and 3rd class passengers,
# suggesting that wealth/class played a role in survival chances.


# --- Plot 3: Bar Chart - Survival by Sex ---
sex_survival <- table(df$Sex, df$Survived)

barplot(sex_survival,
        beside  = TRUE,
        main    = "Survival Count by Sex",
        xlab    = "Survival Status",
        ylab    = "Number of Passengers",
        col     = c("plum", "skyblue"),
        legend  = rownames(sex_survival),
        args.legend = list(title = "Sex", x = "topright"),
        border  = "white")

# Observation: Females had a much higher survival rate than males,
# consistent with the "women and children first" evacuation policy.


# --- Plot 4: Histogram - Age Distribution ---
age_clean <- df$Age[!is.na(df$Age)]

hist(age_clean,
     main   = "Age Distribution of Titanic Passengers",
     xlab   = "Age (Years)",
     ylab   = "Frequency",
     col    = "lightblue",
     border = "white",
     breaks = 15)

# Observation: Most passengers were young adults aged 20-40.
# There is also a small group of children under 10.


# --- Plot 5: Boxplot - Fare by Passenger Class ---
boxplot(Fare ~ Pclass,
        data   = df,
        main   = "Ticket Fare Distribution by Passenger Class",
        xlab   = "Passenger Class",
        ylab   = "Fare (GBP)",
        col    = c("gold", "lightgreen", "tomato"),
        border = "gray30")

# Observation: 1st class fares vary enormously (up to £512),
# while 3rd class fares cluster near the bottom — reflecting
# the stark economic divide between passenger groups.


# --- Plot 6: Scatterplot - Age vs Fare ---
colors_survival <- ifelse(df$Survived == "Survived", "steelblue", "salmon")

plot(df$Age, df$Fare,
     main = "Age vs Fare Paid (Colored by Survival)",
     xlab = "Age (Years)",
     ylab = "Fare (GBP)",
     col  = colors_survival,
     pch  = 19,
     cex  = 0.8)

legend("topright",
       legend = c("Survived", "Did Not Survive"),
       col    = c("steelblue", "salmon"),
       pch    = 19,
       title  = "Survival Status")

# Observation: Passengers who paid higher fares (1st class) tended
# to survive more often. Most non-survivors paid lower fares.ge