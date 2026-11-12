#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-nlp-foundations")

= NLP Foundations: Getting Text and Measuring It <ch:nlp-foundations>

#chapterguide[Manipulate Python strings, and know what a controlled experiment is.][describe an NLP pipeline from raw input to task output; explain why text normalisation comes before any comparison; compute Levenshtein distance by hand and turn it into character error rate; design a fair before/after comparison of a preprocessing step; and separate segmentation failures from recognition failures in an OCR error analysis.]

Natural language processing (NLP) starts before there is any language to process, because text has to come from somewhere: keystrokes, speech or images. Lab~6 applies optical character recognition to 89 photographs of handwritten medicine names and asks: #emph[how good is the resulting text, and how should we measure it?]

== Every NLP task is a pipeline

NLP systems acquire text, normalise it, build a representation, apply a task model and evaluate the output (#figref(<fig:nlp-pipeline>)).

#analogy[
  Think of an assembly line. A part that falls off at the first station is simply missing at every station after it, however good those later stations are. Early errors in NLP work the same way: no downstream model can use a word that OCR never saw.
]

#utpfig([Lab~6 covers acquisition, normalisation and OCR measurement. Lab~7 starts with clean text and builds a representation and classifier.], label: <fig:nlp-pipeline>)[
  #canvas(scale: 0.99, transform-shape: true, {
    let b = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.2, min-height: 1, align: center, font: font("small", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [Acquire \
  #fsize("script")[photo, audio, keyboard]], name: "acq", ..b)
    node(right-of("acq", 0.26), [Normalise \
  #fsize("script")[case, punctuation, tokens]], name: "norm", ..b)
    node(right-of("norm", 0.26), [Represent \
  #fsize("script")[counts, n-grams, vectors]], name: "rep", ..b)
    node(right-of("rep", 0.26), [Model \
  #fsize("script")[classify, translate, search]], name: "model", ..b)
    node(right-of("model", 0.26), [Evaluate \
  #fsize("script")[against references]], name: "eval", ..b)
    connect("acq", "norm", ..arr)
    connect("norm", "rep", ..arr)
    connect("rep", "model", ..arr)
    connect("model", "eval", ..arr)
    connect((-1.3, -0.75), (3.9, -0.75), ..utpbrace, draw: orange)
    node((1.3, -0.95), [Lab~6: OCR, normalisation, measurement], font: font("script", fill: orange), anchor: "north")
    connect((4.1, -0.75), (12, -0.75), ..utpbrace, draw: green)
    node((8.1, -0.95), [Lab~7: bag of words, Naive Bayes, evaluation], font: font("script", fill: green), anchor: "north")
  })
]

== Optical character recognition as text acquisition

#term[OCR] converts images to strings. Tesseract, the engine used in the lab, works in two stages. #term[Segmentation] locates the text on the page, and a neural #term[recognition] stage reads what it found. Keeping the stages apart in your head matters, because they fail differently: one misses text altogether, the other misreads it.

Lab~6 fixes `--oem 1` (neural recognition) and `--psm 7` (treat the image as a single line of text) for every cropped name. Holding these settings constant isolates the effect of preprocessing.

#intuition[
  Tesseract was built mainly for print, not for cursive on lined paper. Asking it to read a doctor’s handwriting is like asking someone who learned a language from textbooks to follow a fast regional accent. Downstream processing cannot reliably recover what the recogniser missed.
]

== Normalisation before comparison

“Tab Azimax” and “tab azimax”, or “40 mg” and “40mg”, differ as strings. If we compared raw strings, a capital letter would count as an error just like a wrong drug name. Lab~6 therefore reduces predictions and references to lowercase letters and digits before comparing them:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.py", first: 69, last: 70, lang: "python")

This rule excludes case, spacing and punctuation from the error count. A task that must distinguish “40 mg” from “4 0mg” needs a different rule, and its scores are not directly comparable with these. The choice is visible in the numbers: on the raw baseline the character error rate is 0.88 with this normaliser, 0.88 if spaces are kept, and 0.93 with no normalisation at all.

#keyidea[
  Normalise both sides identically, decide in advance which differences count as errors, and write the rule down. A metric is only meaningful relative to the normalisation it was computed under.
]

== Measuring text quality: edit distance

#term[Exact match] requires identical normalised strings, and none of the 89 baseline predictions qualifies. That single number hides a lot. Reading `dicloran` as `diclorew` is nearly right, while reading it as nothing at all is useless, yet exact match scores both as zero. We need a graded measure.

#term[Levenshtein distance] gives one: the minimum number of single-character insertions, deletions and substitutions needed to turn one string into the other. Imagine a proofreader correcting the OCR output with a red pen and charging one unit per mark. The distance is the smallest possible bill (#figref(<fig:levenshtein>)).

#utpfig([The table for turning the reference `nims` into the OCR output `nidu`, as Lab~6’s baseline actually read it. Cell $(i,j)$ holds the cost of matching the first $i$ characters of the reference with the first $j$ of the prediction: one more than the cell above (delete), one more than the cell to the left (insert), or the diagonal plus one if the characters differ (substitute). The answer, 2, is in the bottom-right corner: substitute `m`$arrow.r$`d` and `s`$arrow.r$`u`.], label: <fig:levenshtein>)[
  #canvas({
    let W = 0.78
    for (ci, c) in ("n", "i", "d", "u").enumerate(start: 1) {
      node((W * ci, W * 0.85), [#c], font: font("normal", weight: "bold", fill: orange))
    }
    for (ri, r) in ("n", "i", "m", "s").enumerate(start: 1) {
      node((-W * 0.85, -W * ri), [#r], font: font("normal", weight: "bold", fill: blue))
    }
    for (ri, row) in ((0, 1, 2, 3, 4), (1, 0, 1, 2, 3), (2, 1, 0, 1, 2), (3, 2, 1, 1, 2), (4, 3, 2, 2, 2)).enumerate() {
      for (ci, vv) in row.enumerate() {
        if ri == ci {
          node((W * ci, -W * ri), [#vv], ..utphot, min-width: W, min-height: W, font: font("script", weight: "bold"))
        } else {
          node((W * ci, -W * ri), [#vv], ..utpcell, min-width: W, min-height: W, font: font("script"))
        }
      }
    }
    node((-W * 0.85, -W * 4.6), [reference], font: font("small"), ..utplabel, anchor: "north", text: blue)
    node((W * 2.5, W * 1.3), [prediction], font: font("small"), ..utplabel, anchor: "south", text: orange)
    node((W * 5.4, -W * 1.2), [$D[i,j]=min(D[i-1,j]+1, space D[i,j-1]+1, space D[i-1,j-1]+[r_i != p_j])$ \ #v(3.9851pt)
   The highlighted diagonal is the cheapest path: match `n`, match `i`, substitute, substitute. \ #v(3.9851pt)
   Distance $=2$; normalised by the longer length, $2\/4=0.5$.], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 6.2)
  })
]

The lab’s implementation computes that table one row at a time, keeping only the previous row:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.py", first: 104, last: 112, lang: "python")

The lab reports three distance-based metrics and a separate blank count:

#utptable[
  #tabularx(
    columns: (30%, 30%, 1fr),
    styles: (navy-bold,),
    header: ([Metric], [Definition], [Answers]),
    [Exact-match accuracy], [Fraction of images with distance $0$], [How often is the name usable as-is?],
    [Mean normalised edit distance], [Mean over images of distance $\/$ longer length; in $[0,1]$], [How wrong is a typical image?],
    [Character error rate (CER)], [Total edits $\/$ total reference characters; can exceed $1$], [How many corrections per 100 reference characters?],
    [Blank predictions], [Images whose normalised prediction is empty], [How often did segmentation find nothing?],
  )
]

#workedexample[
  Take two images. Reference `nims` is read as `nidu`: 2 edits on 4 characters. Reference `tabnims100mg` is read as nothing: 12 edits on 12 characters.

  $ "mean normalised distance"=frac(2\/4+12\/12, 2)=0.75, wide "CER"=frac(2+12, 4+12)=0.875. $

  The mean treats both images equally. CER pools the characters, so the long name counts for more.
]

#pitfall[
  CER is a ratio of totals, so long references dominate it. The normalised distance is a mean of per-image ratios, so every image counts equally. The two can move in opposite directions on the same data. Report both, and say which one a decision rests on.
]

== A controlled preprocessing experiment

The baseline has CER near $0.9$ and 44 blank predictions. Lab~6 tests one fixed preprocessing pipeline: grayscale, a 20-pixel white border, a width cap and $1.5 times$ enlargement. These steps target colour noise, text touching the image edge and character size, and they leave the OCR settings alone.

Use the same 89 images, the same normalisation and the same OCR configuration, so that only the image preprocessing changes. A fair experiment changes one thing.

#utptable[
  #tabularx(
    columns: (30%, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Pipeline], [Exact match], [Norm. edit distance], [CER], [Blank]),
    [Raw images], [0.000], [0.860], [0.881], [44],
    [Grayscale, border, resize], [0.011], [0.767], [0.788], [15],
  )
]

Blanks fall from 44 to 15 and CER falls by about $0.09$, but only one image, `ostium`, becomes an exact match. Look past the totals and the picture is more mixed. Measured by edits, 43 images improved, 18 got worse and 28 did not change. Thirty-four images that were blank now yield text, while 5 that yielded text are now blank: `tab mesulid`, for instance, was read as `wos Mesulia` on the raw image and not at all after preprocessing. On balance preprocessing helps segmentation find text, and it leaves substantial recognition errors behind.

== Error analysis: which stage failed?

Lab~6 sorts predictions by normalised edit distance and tags the worst cases. It keeps all 89 samples, records any OCR-engine exception instead of dropping the image, and assigns each difficult case one of three reproducible labels. If Tesseract is not installed, the notebook identifies the run as #emph[cached] and loads the validated predictions supplied with the course package; it never presents cached text as a live run.

/ Engine error.: Tesseract rejects an individual image. The sample stays in the benchmark as a failed recognition, with the error recorded in `predictions.csv`.
/ No text detected.: An empty normalised prediction suggests missed text, for example from faint strokes, low contrast or slanted writing. Preprocessing may help. Seven of the eight worst preprocessed cases are of this kind.
/ Character confusion.: Text is returned but misread: `provas` as `Pras`, or `starcox 90` as `Stak Oe 90`. Persistent handwriting errors point to the need for a recogniser trained on handwriting.

Save the six hardest images with their references and predictions, so readers can check the tags for themselves.

#keyidea[
  Attribute each failure to the stage that produced it. The fix for “no text found” is different from the fix for “wrong text found”, and an aggregate score cannot tell them apart.
]

== Fitness for purpose

The benchmark shows a poor fit between printed-text OCR and cursive handwriting, not evidence for clinical use. Misread medicine names or doses can cause real harm. Clinical transcription would require a handwriting-specific recogniser, representative data, held-out validation, privacy controls and human review of uncertain readings.

#chapterrecap[
  - NLP is a pipeline, and errors made early cannot be repaired later.
  - Normalise references and predictions by one written rule before comparing them. A metric means nothing without it.
  - Levenshtein distance counts the fewest single-character edits, and normalised distance and CER aggregate it in two different ways.
  - Change one thing at a time. Preprocessing cut blanks from 44 to 15 but barely moved exact matches.
  - Attribute each failure to segmentation or recognition, because they need different fixes.
]

#quickcheck[
  + How do an engine error, a blank prediction, and `nims` being read as `nidu` differ?
  + Compute the Levenshtein distance between `breeky` and `beeky`, and the normalised distance.
  + Why must the OCR configuration stay fixed when the preprocessing pipeline is tested?
  + After preprocessing, CER fell by $0.09$ but exact-match accuracy rose by only one image. What does that pattern say about which stage improved?
  + The lab’s normaliser deletes spaces. Name a task for which that would be the wrong choice.
]
