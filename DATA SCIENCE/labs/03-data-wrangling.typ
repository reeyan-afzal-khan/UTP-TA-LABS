#import "/.shared/typst/utp.typ": *
#unit("labs", "03-data-wrangling")

#lab("3")[Reshape time-aware data and engineer defensible features] <sec:lab03>

#callout("labproject", title: [Wrangling and feature engineering: build an analysis-ready table])[#strong[Coverage.] Chapter~#ref(label("ch:wrangling"), supplement: none). \
#strong[Goal.] You should be able to preserve observational grain, construct derived variables, aggregate intentionally, validate engineered features, and explain what information is lost when data are summarised. \
#strong[Dataset.] `bike_sharing_dataset_hour.csv`. \
#strong[Scenario.] Hourly bike records are too granular for a manager who wants to understand commuting demand. Your task is to transform the source table into a compact, traceable analytical dataset without losing the meaning of the original measurements.


#include "/DATA SCIENCE/labs/visuals/03-flow.typ"


#strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block. #code-block("Rscript all_experiments/lab03_wrangling.R", lang: "text")

#strong[Step 1.] Load, validate and prepare the data #source-code("/DATA SCIENCE/all_experiments/lab03_wrangling.R", first: 1, last: 10, lang: "r")

#strong[Step 2.] Preserve source columns; all transformations create new fields. 
#include "/DATA SCIENCE/labs/visuals/03-trace.typ"
 #source-code("/DATA SCIENCE/all_experiments/lab03_wrangling.R", first: 11, last: 19, lang: "r")

#strong[Step 3.] Cyclical encodings keep hour 23 close to hour 0 in feature space.

#strong[Use the chapter while coding.] Revisit #link(label("ch:wrangling"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] These two coordinates keep midnight next to the previous hour in feature space. Preserve hr for labels. Tiny floating-point differences from 1 are expected; a large error suggests a wrong angle or mismatched columns. 
#include "/DATA SCIENCE/labs/visuals/03-worked-case.typ"


#source-code("/DATA SCIENCE/all_experiments/lab03_wrangling.R", first: 20, last: 23, lang: "r")

#strong[Step 4.] Validation checks before analysis. #source-code("/DATA SCIENCE/all_experiments/lab03_wrangling.R", first: 24, last: 30, lang: "r")

#strong[Step 5.] Aggregate 17k+ observations into an interpretable demand profile. #source-code("/DATA SCIENCE/all_experiments/lab03_wrangling.R", first: 31, last: 50, lang: "r")

#strong[Step 6.] Visualise the grouped result, not all raw points. #source-code("/DATA SCIENCE/all_experiments/lab03_wrangling.R", first: 51, last: 61, lang: "r")

#strong[Step 7.] Sensitivity check: move the morning-peak end from 09:00 to 08:00. #source-code("/DATA SCIENCE/all_experiments/lab03_wrangling.R", first: 62, last: 71, lang: "r") #strong[Chapter connection.] Revisit #link(label("ch:wrangling"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA SCIENCE/labs/visuals/03-data-wrangling-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Reproduce one group summary directly from its raw rows. Shift a peak-hour boundary by one hour and identify the exact records whose category changes.

#strong[Required evidence.] Submit the final analysis-ready column definitions, one grouped demand profile, and three validation checks. For every engineered variable, include a one-sentence definition precise enough for another analyst to reproduce it independently.

#strong[Decision checkpoint.] Recommend one feature that should enter a future demand model and one feature that should #emph[not] be used without additional care. Justify both choices from the variable meaning and the risk of leakage or redundancy.]]
