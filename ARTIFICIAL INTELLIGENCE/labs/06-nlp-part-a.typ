#import "/.shared/typst/utp.typ": *
#unit("labs", "06-nlp-part-a")

#labsection(6, label: <sec:lab06-nlp-a>)[NLP Foundations: Handwriting OCR Evaluation]

#labproject[Evaluate OCR on real handwritten medicine names][
  #strong[Read first.] Chapter~#ref(<ch:nlp-foundations>). \

  #strong[Goal.] Benchmark OCR on 89 labelled images, test one controlled preprocessing pipeline, and classify the failures. \

  #strong[Scenario.] A clinic wants to digitise handwritten medicine names before storage or search. \

  #strong[Data.] `all_datasets/lab06-ocr-handwritten-prescription.zip`: one label CSV and 89 images. The notebook extracts it next to the archive. \

  #strong[Notebook.] `all_experiments/lab06_handwriting_ocr_worked.ipynb`. \

  #strong[Hand in.] The executed notebook, the `results/lab06/` folder and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labsetup[
  + Activate your course environment and confirm that the zip is in `all_datasets/`. Do not extract it yourself; the notebook does that.
  + #strong[Install the Tesseract OCR engine.] This is the one lab that needs software beyond Python. The `pytesseract` package in `requirements.txt` is only a wrapper around it. Use the line for your system, then reopen the terminal and check the version.
  + Start Jupyter from `all_experiments/`, open the notebook, and choose #strong[Restart Kernel and Run All Cells].

  ```terminal
  # Windows (PowerShell)
  winget install --id UB-Mannheim.TesseractOCR -e

  # macOS
  brew install tesseract

  # Debian or Ubuntu
  sudo apt install tesseract-ocr

  # Every system: check it, then start the lab
  tesseract --version
  cd all_experiments
  jupyter lab
  ```

  On Windows the notebook also looks in `C:\Program Files\Tesseract-OCR`, so it finds a default install even if the terminal does not.
]

#warning[
  #strong[Live or cached?] With Tesseract and its Python wrapper installed, this lab performs live recognition, and the first printed line says `OCR mode: live`. Otherwise it analyses the supplied predictions in `results/lab06/predictions.csv` and says `OCR mode: cached`. A cached run can reproduce the saved comparison and every metric, but it cannot test a new preprocessing choice. Never describe a cached run as new OCR inference. Keep `predictions.csv` in place, because cached mode reads it.
]

#include "visuals/06-flow.typ"

#labroutine

#exercises[
  #strong[Warm-up on paper.] The raw baseline reads `dicloran` as `diclerew`. Work out the Levenshtein distance by hand, using the table method of #figref(<fig:levenshtein>), and then the normalised distance.

  #emph[Answer.] Substitute `o`$arrow.r$`e`, `a`$arrow.r$`e` and `n`$arrow.r$`w`: distance 3. Both strings have 8 characters, so the normalised distance is $3\/8=0.375$.
]

#strong[Setup.] Run the imports and path setup first, and keep this kernel state for the later questions. In the script version the first seven lines also set the working directory.

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.py", first: 1, last: 7, lang: "python")

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.py", first: 8, last: 40, lang: "python")

#refoutput[
  ```terminal
  OCR mode: live | Tesseract 5.5.3.20260724 at C:\Program Files\Tesseract-OCR\tesseract.exe
  ```
]

#labquestion(1)[Validate the archive][
  Extract the archive next to itself, load the label file, check that all 89 labelled images exist exactly once, report the number of unique labels, and show a 3-by-3 sample grid.
]

#labanswer[
  #include "visuals/06-trace.typ"

  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.py", first: 42, last: 64, lang: "python")

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/ARTIFICIAL INTELLIGENCE/labs/visuals/06-notebook-reference.png", width: 88%, height: 5cm)
  ]

  #refoutput[
    ```terminal
    Labelled images: 89 | unique labels: 61
    ```
  ]

  #strong[What it means.] One label file and 89 photographs, each present exactly once. The 89 labels hold 61 distinct medicine names, so some names appear several times in different handwriting. The grid shows what the engine faces: cursive, varied stroke width, uneven lighting and lined paper.
]

#labquestion(2)[Run the baseline OCR][
  Use one fixed Tesseract configuration for every raw image (LSTM engine, page-segmentation mode 7 = one text line) and normalise both prediction and label to lowercase letters and digits. Record a per-image engine failure instead of dropping the sample or stopping the benchmark.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.py", first: 66, last: 102, lang: "python")

  #refoutput[
    ```terminal
              truth      prediction prediction_norm
    0  cefiget 40mg
    1    tab azimax              Ao              ao
    2  tab toniflex  p53 Towid host    p53towidhost
    3          nims            Nidu            nidu
    4      dicloran        diclerew        diclerew
    OCR engine errors: 0
    ```
  ]

  #strong[What it means.] The first rows distinguish a blank recognition from a misread name while retaining every labelled image. The configuration is fixed, so any later improvement must come from the image rather than from engine tuning.
]

#strong[Connect it to the chapter.] The next questions measure the second and third boxes of this pipeline, and an error made in the first cannot be repaired by them.

#include "visuals/06-nlp-part-a-chapter.typ"

#labquestion(3)[Measure recognition quality][
  Implement Levenshtein edit distance and report, for the baseline: exact-match accuracy, mean normalised edit distance (distance divided by the longer string, so it lies in 0--1), character error rate (total edits divided by total reference characters; it can exceed 1), and the number of blank predictions.
]

#labanswer[
  Inspect the normalisation and distance functions before interpreting the metrics:

  #include "visuals/06-worked-case.typ"

  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.py", first: 104, last: 133, lang: "python")

  #refoutput[
    ```terminal
       pipeline  exact_match  mean_norm_edit_distance  character_error_rate  blank_predictions
    0  baseline        0.000                   0.8598                0.8805                 44
    ```
  ]

  #strong[What it means.] Generic OCR on raw handwriting is poor: none of the 89 names is read exactly, the character error rate is close to 0.9, and 44 images yield no text. Any engine error is counted as a failed recognition, not silently removed.
]

#labquestion(4)[Build one preprocessing pipeline][
  Convert each image to grayscale, add a 20-pixel white border, cap the width at 1,200 pixels, and enlarge by $1.5 times$ with bicubic resampling. Save the results under `results/lab06/preprocessed/`. The OCR configuration does not change.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.py", first: 135, last: 148, lang: "python")

  #refoutput[
    ```terminal
    Prepared images: 89 | example size: (1800, 638) mode: L
    ```
  ]

  #strong[What it means.] Each step targets a known weakness of Tesseract on photographs: grayscale removes colour noise, the border stops text touching the edge (which breaks line segmentation), the width cap bounds runtime, and the enlargement brings stroke height into the range the engine was trained on. Only the image changes.
]

#labquestion(5)[Compare the two pipelines fairly][
  Run OCR on the preprocessed images with the identical configuration, keep exactly the same 89 samples, save one row per image and pipeline to `predictions.csv`, and save both sets of metrics to `metrics.csv`.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.py", first: 150, last: 156, lang: "python")

  #refoutput[
    ```terminal
                             exact_match  mean_norm_edit_distance    CER  blank
    baseline                      0.0000                   0.8598  0.8805     44
    grayscale_border_resize       0.0112                   0.7673  0.7883     15
    ```
  ]

  #strong[What it means.] Preprocessing cuts the blank predictions from 44 to 15 and lowers the character error rate by about 0.09, but exact-match accuracy barely moves (one correct name out of 89): the engine now #emph[sees] text on most images yet still cannot read cursive. Because both pipelines were scored on the same 89 images with the same configuration, the difference is attributable to the preprocessing alone. Exact numbers depend on the Tesseract version; the direction of the changes should not.
]

#labquestion(6)[Analyse the failures][
  Take the worst preprocessed predictions by normalised edit distance and tag each as an #emph[engine error], #emph[no text detected], or #emph[character confusion]. Save `error_analysis.csv` and a figure of the six hardest images.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.py", first: 158, last: 174, lang: "python")

  #refoutput[
    ```terminal
    Saved: ['error_analysis.csv', 'metrics.csv', 'ocr_failures.png', 'predictions.csv', 'sample_grid.png']
    ```
  ]

  #strong[What it means.] Of the eight worst cases, seven are #emph[no text detected] and one is #emph[character confusion]. An engine error is a recorded runtime failure, no text detected is a segmentation failure, and character confusion is a recognition failure, and each needs a different fix. This is a benchmark of how well a model fits a domain, not evidence that generic OCR suits clinical transcription.
]

#exercises[
  Add new cells at the end of the notebook. Tasks 1 and 2 work in live and cached mode, because they recompute from the saved predictions. Task 3 needs live OCR.

  + #strong[Look past the totals.] Using `baseline` and `preprocessed`, count the images whose edits improved, worsened or stayed the same, and how many went from blank to text and from text to blank.
  + #strong[Change the normaliser.] Recompute CER for both pipelines with a normaliser that keeps single spaces, and again with no normalisation at all. How much of the “error” depends on this rule?
  + #strong[Test one more step (live mode only).] Add one preprocessing step of your own, for example `ImageOps.autocontrast`. Keep the images, labels, normaliser and OCR configuration fixed, and report whether blanks and CER move. Keep your result whichever way it goes: a step that does not help is still a finding.

  ```python
  b, p = baseline.set_index("filename"), preprocessed.set_index("filename")
  print("improved", (p.edits < b.edits).sum(), "worse", (p.edits > b.edits).sum(), "same", (p.edits == b.edits).sum())
  print("blank to text", ((b.prediction_norm == "") & (p.prediction_norm != "")).sum(),
        "text to blank", ((b.prediction_norm != "") & (p.prediction_norm == "")).sum())
  ```
]

#answers[
  + On the saved predictions: 43 improved, 18 worse and 28 the same; 34 went from blank to text and 5 from text to blank. `tab mesulid`, for example, was read as `wos Mesulia` on the raw image and not at all after preprocessing. The aggregate improvement hides real losses.
  + Keeping spaces gives CER 0.884 (baseline) and 0.783 (preprocessed). No normalisation gives 0.928 and 0.858. The ordering of the pipelines survives, and the gap between them does not stay the same, so always state the rule.
  + This depends on your Tesseract version and your choice of step, so there is no fixed answer. Your report should give the numbers for all three pipelines on the same 89 images.
]

#tip[
  / `tesseract is not recognized`: Close and reopen the terminal after installing, or add the install folder to `PATH`. The notebook will still find the default Windows location.
  / The first line says `cached` after installing: Restart the Jupyter kernel so it sees the new program, and check that `pytesseract` is installed in the active environment.
  / `predictions.csv is missing` in cached mode: Restore `results/lab06/predictions.csv` from the course package, or install Tesseract.
  / Slightly different numbers in live mode: Expected: Tesseract versions differ. Report your version with your numbers.
]

#checklist[
  - All 89 labelled images are present exactly once.
  - Both pipelines are scored on the same 89 images with the identical OCR configuration, and engine failures are counted, not dropped.
  - Exact match, normalised edit distance, character error rate and blank predictions are reported for both pipelines.
  - Preprocessing reduces the blank predictions (from 44 to 15 on the saved run), and you can explain why exact match barely moves.
  - `results/lab06/` holds `predictions.csv`, `metrics.csv`, `error_analysis.csv`, `sample_grid.png` and `ocr_failures.png`.
]

#submission[
  - Restart the kernel and run all cells without errors.
  - Submit the executed notebook, including the cells you added for the exercises, and the generated `results/lab06/` folder.
  - Report the OCR mode and, for a live run, the Tesseract version.
  - State which OCR stage improved, which failure remained, and why this pipeline is not suitable for autonomous clinical transcription.
]
