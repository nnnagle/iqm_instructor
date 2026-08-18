<!-- Converted from the original .docx (the write path to GitHub is
     text-only). Structure is light; tables are flattened. The
     authored source of record is the Word document. -->

GEOG 415 Semester-Long Place Rating Project
A cumulative lab sequence for building, auditing, and reporting a public-data rating system
Working design document • 12 labs • 6 modules • every lab produces material used in the final project
1. Purpose and basic idea
The semester-long project is a way to make the methods course cumulative rather than episodic. Students begin with a substantive place-based question, acquire and document public data, explore the data, construct a transparent rating, evaluate uncertainty, fit simple statistical models, compare explanatory and predictive approaches, and finally ask how spatial scale and dependence change the answer.
The project should remain methodologically modest. The objective is not to build the best possible operational index. The objective is to make students confront the chain of quantitative decisions that turns public data into a number, a map, and potentially a policy-relevant claim.
A strong default project is a Community Health Access Priority Rating at the census-tract level. The question is simple enough to explain—Which communities should receive priority for additional primary-care access?—but the answer requires measurement, comparison, uncertainty, modeling, prediction, and geographic reasoning.
Design principles
No throwaway labs. Each lab creates a file, figure, decision, paragraph, or analytic result that appears later in the final project.
Students should understand every score they calculate. Keep weighting, scaling, and modeling transparent.
Use authentic public data, but constrain the geography and number of indicators enough that data engineering does not consume the course.
Separate need, service access, health outcome, and validation variables so students do not accidentally define success by the same variables used to build the rating.
Use sophisticated methods only when they answer a question students already understand. Linear regression, logistic regression, and one optional random forest are enough.
Treat metadata, provenance, uncertainty, and ethical interpretation as part of the analysis rather than appendices added at the end.
2. A concrete implementation
The following design is intentionally specific enough that it could actually be run in a semester. The exact datasets and vintages should be verified immediately before the course begins.
Component
Example public source
Role in project
Keep it simple
Geography
Census tract boundaries
Unit of analysis and mapping
One state, not the whole U.S.
Community need
ACS 5-year estimates
Poverty, uninsured, vehicle access, age/disability, etc.
Use 3–5 indicators, not 15.
Service access
Public health-facility point locations (e.g., HRSA health centers)
Distance/proximity to service
Euclidean distance is acceptable if limitations are documented.
External outcome
A tract-level public health outcome source (e.g., CDC PLACES)
Used to test whether the rating is associated with something substantively relevant
Choose one primary outcome.
External comparator
An established place-based index (e.g., CDC/ATSDR SVI)
Late-semester comparison with an official rating system
Do not show this too early; students should first struggle with their own design choices.
A physical-hazard variant is possible, but social-service access is probably cleaner for this course because the data remain mostly tabular/vector and the project does not turn into a raster/GIS-processing exercise.
The rating students are trying to build
Students should begin with a conceptual distinction between community need and service access. A tract can have high social need and relatively good service proximity, or modest social need and very poor service access. The first rating can therefore be deliberately simple:
Priority Rating = transparent combination of NEED + POOR ACCESS
At first, students might percentile-rank each input, reverse the direction where necessary, and average the components. Equal weighting is not presented as objectively correct. It is presented as a choice that is easy to understand and therefore easy to criticize.
3. The six-module intellectual architecture
Module
Technical takehome
Socio-technical takehome
Ethical takehome
1. Data & Measurement
A variable is a measurement of something, not the thing itself.
Data are produced through measurement systems and institutional categories.
Ask who or what is mismeasured, misclassified, missing, or made invisible.
2. Association & Comparison
A relationship can be real without having the explanation you think it has.
Institutions understand populations through comparison and association.
Ask whether the comparison is fair and whether another grouping or omitted factor changes it.
3. Uncertainty & Evidence
An estimate is incomplete without some account of uncertainty.
Probability became a technology for making decisions under uncertainty.
Ask how certain we are entitled to sound and who bears the cost of error.
4. Statistical Models
Every model leaves things out; the question is whether it leaves out something that matters.
Models make complex worlds tractable and can acquire authority once embedded in software and institutions.
Ask what assumptions and modeling choices are hidden in the result.
5. Explanation & Prediction
Predicting what happens is not the same as knowing why it happens.
Institutions increasingly act on predictions, even without causal understanding.
Ask whether prediction is an appropriate basis for action and who bears prediction errors.
6. Geography Breaks the Rules
Where and at what scale you measure something can change the answer.
Spatial units are institutional and political constructions, not merely neutral containers.
Ask how boundaries, aggregation, location, and spatial targeting distribute consequences.
4. Twelve-lab cumulative sequence
Each module has two lab sessions. The first lab usually introduces a new analytic problem; the second consolidates it into a reusable project product. The sequence below assumes students start with no project data and finish with a documented, reproducible rating system and technical report.
Module 1 — Data and Measurement
Core question: Where did these numbers come from?
Technical takehome: A variable is a measurement of something, not the thing itself.
Lab 1. Define the problem and build the source inventory
Introduce the planning question and define the target geography and unit of analysis.
Students write a one-paragraph operational definition of “priority for additional primary-care access.”
Identify candidate need variables, service-location data, an external outcome, and tract boundaries.
Download or access the raw public data. Keep raw files unchanged.
Begin a provenance log: source agency, dataset name, vintage, access date, URL/API endpoint, geographic coverage, and intended role.
Deliverable: Project Charter + Data Source Inventory. This becomes the opening problem statement and data/provenance section of the final report.
Lab 2. Build the first analytic dataset and metadata
Import data into R and standardize tract identifiers.
Inspect variable definitions, units, missing-value codes, denominators, and margins of error where available.
Join the candidate indicators to tract geography and check failed joins.
Create a concise data dictionary with plain-language definitions.
Produce 2–3 raw-variable maps and one table documenting missingness.
Deliverable: Analytic Dataset v1 + Data Dictionary + Provenance Log v1 + Raw-Variable Figure Set. These files are reused in every later lab.
Module 2 — Association and Comparison
Core question: What varies with what?
Technical takehome: A relationship can be real without having the explanation you think it has.
Lab 3. Explore distributions, relationships, and candidate indicators
Describe each candidate variable using plots and simple summaries.
Examine bivariate relationships with scatterplots/correlations and relevant group comparisons.
Identify skew, outliers, redundant indicators, and surprising geographic patterns.
Ask whether apparent relationships reflect measurement, confounding, or aggregation.
Narrow the indicator list to a defensible small set.
Deliverable: Exploratory Analysis Brief with 4–6 figures and a short Indicator Selection Memo. Most figures can later enter the final report or appendix.
Lab 4. Construct Rating v0.1
Choose a transparent direction for each variable: what makes priority go up or down?
Convert indicators to a common scale, preferably percentiles or simple z-scores.
Construct an equal-weight baseline rating.
Map the rating and identify the ten highest- and lowest-rated tracts.
Create one plausible alternative weighting and compare rank changes.
Document every scoring rule in a scoring specification.
Deliverable: Rating v0.1 + Scoring Specification + Priority Map v0.1 + Weight-Sensitivity Table. This becomes the methods core of the final project.
Module 3 — Uncertainty and Evidence
Core question: How sure are we?
Technical takehome: An estimate is incomplete without some account of uncertainty.
Lab 5. Audit uncertainty in the inputs and rating
Examine uncertainty in ACS inputs using reported margins of error or confidence bounds.
Identify indicators and tracts with especially unstable estimates.
Recalculate the rating under simple plausible low/high scenarios or a light simulation.
Measure how many tracts move meaningfully in rank or category.
Discuss what a threshold such as “top 20% priority” hides about uncertainty.
Deliverable: Rating Stability Audit + Uncertainty Figure + List of Unstable Cases. These become an uncertainty subsection and limitations table.
Lab 6. Test an external comparison
Introduce one external outcome not used to build the rating.
Compare the outcome across high- and low-priority groups or across rating quantiles.
Estimate a difference, standard error, confidence interval, and p-value where appropriate.
Report the magnitude first and the significance second.
Ask whether the observed association validates the rating, and what it cannot establish.
Deliverable: Evidence Memo with effect size, interval, significance test, and interpretation. This becomes the first validation result in the final report.
Module 4 — Statistical Models
Core question: How do we describe relationships?
Technical takehome: Every model leaves things out; the question is whether it leaves out something that matters.
Lab 7. Fit and diagnose a simple linear model
Use the external outcome as the response and one key rating component or the rating itself as the explanatory variable.
Interpret intercept, slope, fitted values, and residuals in substantive language.
Inspect residual and fitted-value diagnostics.
Identify influential or poorly fit tracts and locate them on the map.
Ask what a large positive or negative residual means geographically.
Deliverable: Model 1 Results + Diagnostic Figure Set + Residual Map. The residual map is deliberately saved for Module 6.
Lab 8. Build a modest multiple regression
Add only a few substantively justified predictors.
Interpret coefficients conditionally rather than as isolated bivariate relationships.
Introduce one transformation or interaction only if the data make the need obvious.
Compare model fit and residual behavior with the simpler model.
Write a short model card: purpose, inputs, output, assumptions, appropriate use, inappropriate use.
Deliverable: Model 2 + Model Card + Comparison Table. This becomes the statistical-modeling section of the final report.
Module 5 — Explanation and Prediction
Core question: What question is this model answering?
Technical takehome: Predicting what happens is not the same as knowing why it happens.
Lab 9. Turn the problem into prediction
Define a simple binary outcome, such as whether a tract falls in the highest quartile of the external health burden measure.
Split the data into training and test sets.
Fit a logistic regression using the same small set of predictors.
Generate predicted probabilities for the test data.
Evaluate predictions with a small number of understandable metrics and map predicted risk.
Deliverable: Predictive Model v1 + Test-Set Performance Table + Predicted-Probability Map.
Lab 10. Compare transparent prediction with one blacker box
Fit one random forest, preferably from a provided template rather than an algorithm-coding exercise.
Compare test-set performance with logistic regression.
Compare which places each model labels as high priority/high risk.
Inspect variable importance cautiously.
Ask whether modest gains in prediction justify a less interpretable model for a public allocation decision.
Deliverable: Model Comparison Memo + Recommendation: logistic regression, random forest, neither, or use only as a diagnostic. This becomes the explanation-vs-prediction discussion.
Module 6 — Geography Breaks the Rules
Core question: What changes when observations exist in space and time?
Technical takehome: Where and at what scale you measure something can change the answer.
Lab 11. Audit spatial dependence and scale
Return to the residual map from Lab 7/8 and ask whether errors cluster geographically.
Use a simple spatial-dependence diagnostic if taught, or a structured map-based analysis if not.
Aggregate or rebuild a small part of the analysis at a second scale, such as county level.
Compare correlations, coefficients, and priority rankings across scales.
Identify examples where an individual tract story disappears or reverses after aggregation.
Deliverable: Spatial and Scale Audit + Two-Scale Comparison Figure. This becomes the geographic limitations section.
Lab 12. External benchmark, final rating, and reproducibility handoff
Reveal an established public place-based index and compare it with the students’ rating.
Identify places of strong agreement and disagreement, then explain why disagreement occurs.
Finalize the rating specification only after reviewing uncertainty, modeling, prediction, and scale results.
Clean scripts so the project can be rerun from raw data to final outputs.
Update metadata and provenance to final form.
Peer-review another project using a short rubric focused on transparency, reproducibility, interpretation, and ethical use.
Deliverable: Final Rating v1.0 + Benchmark Comparison + Reproducibility Package + Final Metadata + Peer-Review Memo. These are the final-project components, not new work after the lab sequence.

5. The final project is an assembly, not a new assignment
If the cumulative structure works, students should reach the final two weeks with nearly all substantive analysis already completed. The final project is primarily synthesis, revision, and judgment.
Final component
Built mainly in
What students submit
Problem statement and intended use
Lab 1
What the rating is for, what decision it might inform, and what it is not for.
Data and metadata
Labs 1–2, updated throughout
Source inventory, data dictionary, provenance, missingness, processing notes.
Exploratory analysis
Lab 3
Distributions, relationships, maps, and indicator rationale.
Rating construction
Lab 4
Exact scoring specification, weighting rationale, final map and ranking.
Uncertainty and evidence
Labs 5–6
Stability analysis, effect sizes, intervals, and cautious interpretation.
Statistical modeling
Labs 7–8
Linear/multiple regression, diagnostics, residual geography, model card.
Prediction comparison
Labs 9–10
Logistic regression and optional random forest, held-out evaluation, interpretation tradeoffs.
Geographic audit
Lab 11
Spatial dependence/scale analysis and MAUP/ecological limitations.
Benchmark and recommendation
Lab 12
Comparison with an established index and final recommendation about whether/how the rating should be used.
Reproducibility package
All labs
Clean scripts, raw-data instructions, processed data as permitted, figures, and README.
Suggested final report structure
Executive summary: What did you build, what does it say, and should anyone use it?
1. Problem and intended use
2. Data, measurement, and provenance
3. Exploratory analysis and rating design
4. Uncertainty and external evidence
5. Statistical models and diagnostics
6. Explanation versus prediction
7. Geography, scale, and spatial limitations
8. Ethical assessment and appropriate/inappropriate uses
9. Final recommendation
Appendix: metadata, model card, sensitivity results, reproducibility notes
6. Workflow rules that make the cumulative design work
Use a fixed project folder from Lab 1 onward: /raw, /processed, /scripts, /figures, /tables, /metadata, /report.
Raw data are never edited manually. All transformations occur in scripts and write new processed files.
Each lab begins by opening the previous lab’s project and ends by updating the same project.
Every figure and table used in a lab should be generated by code and saved with stable filenames.
Require a short CHANGELOG entry after every lab: what changed in the data, rating, assumptions, or interpretation?
Use a small number of common instructor-supplied helper functions/templates so syntax does not become the main learning objective.
Grade documentation and interpretation explicitly. Otherwise students will infer that only the numerical result matters.
Permit teams for data management and analysis, but require individual short reflections or interpretations if individual accountability matters.
A simple deliverable naming scheme
Lab
Reusable project files
Lab 01
project_charter.pdf / source_inventory.csv
Lab 02
analytic_v1.csv / data_dictionary.csv / provenance.md
Lab 03
eda_brief.pdf / indicator_decisions.md
Lab 04
rating_v01.csv / scoring_spec.md / rating_map_v01.png
Lab 05
uncertainty_audit.pdf
Lab 06
evidence_memo.pdf
Lab 07
model1.rds / diagnostics.pdf / residual_map.png
Lab 08
model2.rds / model_card.md / model_comparison.csv
Lab 09
prediction_v1.csv / performance_logit.csv
Lab 10
model_comparison_memo.pdf
Lab 11
spatial_scale_audit.pdf
Lab 12
final_rating.csv / benchmark_comparison.pdf / README.md
7. Deliberate constraints: what not to let this become
Do not let students choose twenty indicators. A small rating is easier to understand, defend, and audit.
Do not require network accessibility, location-allocation, PCA, factor analysis, spatial regression, or causal-inference machinery.
Do not let the random forest become a machine-learning unit. It is a comparison device for asking what interpretability is worth.
Do not use a national dataset if one-state data are enough to teach the idea.
Do not grade a high predictive score as evidence that a student built a good public rating. Technical performance, transparency, intended use, uncertainty, and ethical consequences are separate criteria.
Do not hide instructor choices. If the course supplies a boundary file, a facility file, or a cleaned starter dataset, say what work has been done for students and why.
8. Assessment logic
A useful grading scheme would reward cumulative quality rather than treating the final report as a separate high-stakes event. Each lab can be graded lightly for completion and correctness, with the final project graded mainly on revision, integration, and judgment.
Criterion
What strong work looks like
Technical correctness
Data, calculations, statistical interpretations, and maps are correct enough for the course level.
Transparency
A reader can reconstruct exactly how the rating was made.
Metadata/provenance
Sources, definitions, transformations, missingness, and limitations are documented.
Evidence and uncertainty
Claims distinguish magnitude, uncertainty, statistical significance, and substantive importance.
Model judgment
Student understands what linear/logistic regression and the optional random forest do and do not establish.
Geographic reasoning
Scale, aggregation, ecological inference, and spatial dependence are treated as substantive concerns.
Socio-technical reasoning
Student recognizes that variables, categories, ratings, and models are institutional artifacts as well as technical objects.
Ethical reasoning
Student identifies who could be helped or harmed by plausible uses and misuses of the rating.
Communication
Maps, tables, metadata, and prose are clear enough for a non-specialist decision maker.
9. Why this structure is promising
The project gives nearly every major method in GEOG 415 a reason to exist. Students need exploratory graphics because they must decide what belongs in the rating. They need metadata because public variables are constructed measurements. They need sampling uncertainty because the rating inherits uncertainty from its inputs. They need regression because they want to know whether the rating is associated with an external outcome. They need prediction because a rating may be used prospectively. They need spatial reasoning because ratings of places depend on boundaries, scale, and neighboring places.
Most importantly, students finish not merely knowing how to calculate a score. They have watched a quantitative object acquire authority over the course of a semester, and they are in a position to ask whether that authority is deserved.
