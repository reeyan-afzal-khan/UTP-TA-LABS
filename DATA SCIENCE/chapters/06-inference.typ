#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-inference")


#heading(level: 1)[Sampling, Uncertainty, and Statistical Inference]
 <ch:inference> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should be comfortable with descriptive statistics, distributions, and group comparisons.

*By the end, you can:* distinguish population from sample, explain sampling variability, construct bootstrap confidence intervals, and interpret hypothesis tests alongside effect size.]


#heading(level: 2)[A sample is one possible view of a population]
 A #strong[population] is the set of cases the question concerns. A #strong[sample] is the observed subset. Statistics computed from a sample vary from sample to sample, even when the underlying population is unchanged.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/40fec61e58b6753b.svg")], caption: [Different random samples produce different estimates. Statistical inference quantifies that uncertainty rather than pretending the observed sample is exact.]) <fig:sampling-variability>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/inference_sampling_distribution.svg", width: 90%)], caption: [Each simulated point in the histogram is a mean from a sample of 30 wine observations. The means vary from sample to sample but are more concentrated than individual measurements.]) <fig:inference-sampling-dist>


#heading(level: 2)[Standard error describes estimate-to-estimate variability]
 The #strong[standard error] is the standard deviation of a statistic's sampling distribution. For a sample mean under familiar assumptions, $ S E \( macron(x) \) approx s / sqrt(n) . $ The square-root relationship is important: quadrupling sample size roughly halves the standard error, all else equal. This gain in precision does not remove bias from poor sampling or measurement.


#heading(level: 2)[Bias and variability are different problems]
 A large convenience sample can estimate the wrong population very precisely. More observations reduce random variability, but they do not automatically repair selection bias, measurement bias, or confounding.


#heading(level: 2)[Bootstrap confidence intervals]
 The bootstrap approximates sampling variability by repeatedly resampling the observed data with replacement.

+ Compute the statistic of interest on the observed sample.

+ Resample the rows with replacement to create a bootstrap sample of the same size.

+ Recompute the statistic and store it.

+ Repeat many times; use the bootstrap distribution to form an interval.

#code-block("set.seed(42)\nboot_means <- replicate(\n  2000,\n  mean(sample(wine$alcohol, replace = TRUE))\n)\nquantile(boot_means, c(0.025, 0.975))", lang: "r")

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/inference_bootstrap.svg", width: 90%)], caption: [Bootstrap resamples mimic repeated sampling from an empirical approximation to the population. The central 95% of the resampled means gives a simple percentile interval.]) <fig:inference-bootstrap>


#heading(level: 2)[Confidence intervals quantify a range of compatible values]
 A 95% confidence interval is produced by a procedure designed to cover the target parameter about 95% of the time under repeated sampling and the method's assumptions. Once a particular interval has been calculated, the parameter is fixed; the frequentist interpretation concerns the long-run procedure rather than a 95% probability assigned to that fixed parameter.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/inference_ci_repeated.svg", width: 90%)], caption: [Most intervals in this simulation cross the dashed population mean; occasional intervals miss it. This long-run behaviour is what confidence level describes.]) <fig:inference-ci-coverage>


#heading(level: 2)[Hypothesis tests compare data with a null model]
 A p-value is the probability, under a specified null hypothesis and test assumptions, of obtaining a result at least as incompatible with the null as the observed result. It is not the probability that the null hypothesis is true.

#callout("pitfall", title: [Analytical pitfall])["Statistically significant" does not mean "important", "large", or "causal". With enough data, a tiny difference can have a small p-value. Always report the magnitude and practical meaning of the effect.]


#heading(level: 2)[A hypothesis test has several moving parts]
 A disciplined test states the null and alternative hypotheses, chooses a statistic, checks assumptions, computes the statistic's null reference distribution or approximation, and then interprets the p-value in context. The p-value is sensitive to both effect size and sample size, which is why it should not be used as a stand-alone measure of scientific importance.

For a two-group comparison, also inspect group distributions and report an effect such as a difference in means or medians in original units. If a standardised effect size is useful for comparison across scales, explain what its units mean.


#heading(level: 2)[Effect size and uncertainty belong together]
 For a difference in means, report the observed difference in original units and an interval or test that describes uncertainty. Readers can then judge both size and precision.

#callout("workedexample", title: [Worked example])[Suppose two wine cultivars differ in mean alcohol measurement. The t-test addresses compatibility with a zero-difference model; the actual difference in alcohol units tells the reader whether the magnitude is meaningful in context.]


#heading(level: 2)[Multiple testing increases false discoveries]
 If an analyst tests many unrelated hypotheses and reports only those with small p-values, some apparently "significant" results can arise by chance. Pre-specifying primary questions, correcting for multiplicity when appropriate, and validating exploratory findings on new data reduce this risk.

#callout("pitfall", title: [Analytical pitfall])[A confidence interval or p-value quantifies uncertainty conditional on assumptions. It does not automatically account for selection bias, measurement error, poor operational definitions, unrecorded exclusions, or the fact that the hypothesis was chosen after inspecting the same data.]


#heading(level: 2)[Study design limits causal claims]
 Randomised experiments can isolate treatment effects when implemented well. Observational data can describe associations and support prediction, but causal interpretation requires stronger assumptions and methods than correlation or regression alone.

#callout("keyidea", title: [Key idea])[Inference is not a machine for turning samples into certainty. It is a framework for expressing what the data say while keeping sampling and design uncertainty visible.]

#callout("quickcheck", title: [Check your understanding])[+ What is the difference between sampling variability and selection bias?

+ What does resampling with replacement accomplish in the bootstrap?

+ What does a p-value #emph[not] tell you?

+ Why should effect size accompany statistical significance?]


#heading(level: 2)[Worked inference: student performance and observational uncertainty]


In the Student Performance dataset, mean final grade `G3` is about 12.28 among students who report an intention to pursue higher education and about 8.80 among those who do not---an observed difference of roughly 3.48 grade points.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/inference_student_bootstrap.svg", width: 90%)], caption: [Resampling students within the observed groups approximates the sampling variability of the group mean difference under the empirical distribution. The interval describes uncertainty in the estimate, not uncertainty about unmeasured confounding.]) <fig:inference-student-bootstrap>

This example separates three questions that students often merge. #strong[Estimation] asks how large the observed difference is. #strong[Sampling uncertainty] asks how much that estimate might vary under repeated sampling. #strong[Causal interpretation] asks whether changing higher-education intention would change grades. Bootstrap intervals help with the second question; they do not solve the third.

Potential confounders include prior grades, study time, parental education, school support, failures, and socioeconomic context. Formal uncertainty can be numerically precise while the causal claim remains weak.


#heading(level: 2)[Bootstrap and permutation answer different questions]


The Student Performance example is useful because two resampling procedures can be placed side by side. The bootstrap resamples within the observed groups and asks how much the estimated mean difference would vary if similar samples were collected again. A permutation procedure instead breaks the link between group label and outcome and asks how unusual the observed contrast is under an exchangeability-based no-association reference model.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/inference_student_permutation.svg", width: 90%)], caption: [The shuffled-label distribution is centred near zero because the group labels have been deliberately detached from final grades. The observed difference is then compared with this reference distribution.]) <fig:inference-student-permutation>

The procedures are related but not interchangeable. The bootstrap is primarily an estimation tool here; the permutation distribution is a testing tool. Both inherit assumptions from the sampling process, and neither makes the observational comparison causal. This is why a complete inference statement should report the #strong[effect size], the #strong[uncertainty or reference distribution], and the #strong[design limitation] in separate sentences.
