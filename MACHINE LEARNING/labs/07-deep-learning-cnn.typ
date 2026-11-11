#import "/.shared/typst/utp.typ": *
#unit("labs", "07-deep-learning-cnn")

#lab("7")[Deep learning I: a first neural network and a CNN for images] <sec:lab07-cnn>

#callout("labproject", title: [Train a dense network and a convolutional network on photos of wood defects])[#strong[Read first.] Chapter~#ref(label("ch:deep"), supplement: none). \
#strong[Goal.] Turn images into tensors, write one training loop and read its curves, compare a dense network and a CNN with Lab~4's classical baseline, look at what the CNN learned and where it fails, and save the weights with a model card. \
#strong[Scenario.] The sawmill from Lab~4 wants every defect its camera finds sorted into one of seven types, so that boards can be graded automatically. Lab~4's PCA and logistic regression got 63.3% of the test images right. Is a neural network worth the extra machinery? Each step up the ladder has to earn its place on the same 3,134 test images, from boards no model has seen. \
#strong[Data.] `all_datasets/ unsupervised/ wood_surface_defects/ wood_defects.npz`, the wood-defect images from Lab~4: 15,701 colour photos, $32 times 32$ pixels, of seven defect types on sawn boards (Kodytek, Bodzas and Bilik, 2022). \
#strong[Notebook.] `all_experiments/ lab07_deep_learning_cnn/ lab07_deep_learning_cnn_worked.ipynb`, with a README beside it. \
#strong[Hand in.] The executed notebook, `results/lab07/`, the weights with their card and a short conclusion, as listed in the checklist at the end of this sheet.]

#heading(level: 2, numbering: none)[Your map of this lab]
#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    [Part], [What you do], [Questions],
    [A], [Turn the images into tensors, with Lab~4's board-wise splits], [2],
    [B], [Build a dense network, write the training loop, read the curves], [3--5],
    [C], [Build and train a CNN; test it once; inspect its mistakes and filters], [6--10],
    [D], [Save the weights with a card and reload them], [11],
    [Finish], [Save the evidence; then train longer and try a one-block CNN], [12--14],
    [After], [Your-turn tasks, expected findings, troubleshooting and the two checklists], [---],
  )]
  , kind: table
  )

#callout("labmode", title: [Lab setup])[+ Activate your course environment. PyTorch comes with `requirements.txt`; if it is missing, the Setup cell installs the CPU build once.

+ Check the small worked numbers of Chapter~#ref(label("ch:deep"), supplement: none), which run on NumPy alone. The last line must read `Every number above matches the book.`

+ From the course folder, start Jupyter, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. It took under two minutes on the laptop CPU behind this sheet, most of it the 25-epoch run in the solution. No GPU is needed.

+ To reproduce the sheet's numbers on a machine with a GPU, hide the GPU first, as Chapter~#ref(label("ch:toolkit"), supplement: none) shows. A GPU run is just as valid, and its numbers differ a little.

#code-block("python all_experiments/book_checks/demo_advanced.py\njupyter lab", lang: "text") Prefer a plain script? From the course folder, `python all_experiments/ lab07_deep_learning_cnn/ lab07_deep_learning_cnn_worked.py` runs the same code and writes the same evidence.]

#strong[How to work through this sheet.] Predict the result, run the matching notebook cell, compare with the reference output, and explain the result in your own words.

#callout("yourturn", title: [Your turn])[#strong[Warm-up on paper.] Do these before opening the notebook; Questions~3 and~6 will check you.

+ A colour image of $32 times 32$ pixels holds how many numbers? How many weights has a dense network from those inputs through 128 hidden units to 7 outputs, counting one bias per unit? ($3 \, 072$; $393 \, 344 + 903 = 394 \, 247$.)

+ That image passes through a padded $3 times 3$ convolution with 16 filters and a $2 times 2$ max pool. Give the output shape, and the number of weights in the convolution; each filter reads all three colours. ($16 times 16 times 16$; $3 times 16 times 9 + 16 = 448$.)

+ After a second such block with 32 filters, how many numbers go into the first dense layer, and how many weights does that layer need for 64 units? ($32 times 8 times 8 = 2 \, 048$; $2 \, 048 times 64 + 64 = 131 \, 136$.)]

#callout("labquestion", title: [Question 1 --- Setup])[Run this first, and keep this kernel for the later questions. `start_pytorch()` installs PyTorch once if it is missing, picks the device to train on, and fixes the random seed; `start_lab()` returns the three folders the lab uses, as in every lab.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 11, last: 31, lang: "python") *Reference output.*

#code-block("Python 3.13.9 at C:\\ProgramData\\anaconda3\\python.exe\nPyTorch 2.11.0+cu128 | device: cpu\ncourse folder: MACHINE LEARNING\nreads all_datasets/, writes results/lab07/ and models/", lang: "text")

#strong[What it means.] The first line names the Python that runs the kernel, which is the environment PyTorch must be installed in. This sheet's numbers come from a CPU run.]

#callout("labpart", title: [Part A --- Images as tensors])[*Goal.* Turn the defect images into tensors, with the same board-wise splits as Lab~4.

Question 2 •~Data: wood surface defects]

#callout("labquestion", title: [Question 2 --- Turn images into tensors])[The same defect photos as Lab~4: each is a $32 times 32$ grid of pixels with three colour values from 0 to 255. PyTorch works on #emph[tensors], which are arrays that remember how to compute gradients. A convolutional layer expects images as (batch, channels, height, width), so each image becomes $3 times 32 times 32$, scaled to $\[ 0 \, 1 \]$. The splits repeat Lab~4's, with the same seeds: whole boards go to fitting, validation or test, and the test images stay closed until Question~8.] #callout("labanswer", title: [Worked answer])[
#include "/MACHINE LEARNING/labs/visuals/07-trace.typ"
 #source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 33, last: 60, lang: "python") #callout("labvisual", title: [Reference plot from the supplied notebook])[#image("/MACHINE LEARNING/labs/visuals/07-notebook-reference.png", width: 90%)] *Reference output.*

#code-block("fit: (9357, 3, 32, 32)  validation: (3210, 3, 32, 32)  test: (3134, 3, 32, 32)", lang: "text")

#strong[What it means.] 9,357 images to fit, 3,210 to validate and 3,134 sealed for the test, exactly Lab~4's three groups of boards. Each image is three channels of $32 times 32$ values, so a network can compare its results with Lab~4's on the very same test images.]

#callout("labcheckpoint", title: [Checkpoint: before you move on])[- 9,357 images to fit, 3,210 to validate, and 3,134 sealed for the test, each $3 times 32 times 32$.]

#callout("labpart", title: [Part B --- A first neural network and the training loop])[*Goal.* Build a dense network, write the training loop, and read its accuracy curves.

Questions 3--5 •~Data: wood surface defects]

#callout("labquestion", title: [Question 3 --- Build a dense network])[A dense network flattens the 3,072 numbers of an image into a vector, computes 128 weighted sums, passes each through ReLU, and computes 7 class scores from those. Written in `nn.Sequential`, it is four lines.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 62, last: 72, lang: "python") *Reference output.*

#code-block("Sequential(\n  (0): Flatten(start_dim=1, end_dim=-1)\n  (1): Linear(in_features=3072, out_features=128, bias=True)\n  (2): ReLU()\n  (3): Linear(in_features=128, out_features=7, bias=True)\n)\ntrainable weights: 394247", lang: "text")

#strong[What it means.] The count matches your warm-up, and almost all of it sits in the first layer, one weight for every pixel value and hidden unit. The classical baseline from Lab~4 has no hidden layer at all.]

#callout("labquestion", title: [Question 4 --- Write the training loop and train])[The training loop is the whole method. Each epoch shuffles the training images and walks through them in batches of 128. For each batch: compute the class scores (forward pass), compute the cross-entropy loss, compute every gradient with `backward()`, and let the optimizer move every weight a small step. After each epoch, accuracy is recorded on the training and validation images. `predict` works in chunks of 2,000, so scoring many images never needs them all in memory at once.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 74, last: 105, lang: "python") *Reference output.*

#code-block("dense network: validation accuracy by epoch = [0.408, 0.48, 0.552, 0.554, 0.536, 0.485,\n 0.561, 0.539, 0.596, 0.556]", lang: "text")

#strong[What it means.] This is the recipe from Chapter~#ref(label("ch:orientation"), supplement: none), in eight lines: model, loss, optimizer.]

#callout("labquestion", title: [Question 5 --- Read the accuracy curves])[Plot the two accuracy lists against the epoch, and read them as you read the tree-depth curve in Lab~3.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 107, last: 122, lang: "python")

#strong[What it means.] The two curves move together and zigzag: up to 0.596, down to 0.485, never apart. This is not overfitting, which would open a gap between them; it looks like an optimizer whose steps are too large for nearly 400,000 weights fed with raw pixels, so each epoch lands somewhere new. A dense network must learn every pattern separately at every position, and 9,357 images are few for that.]

#callout("labcheckpoint", title: [Checkpoint: before you move on])[- The dense network has 394,247 weights.

- Its training and validation curves zigzag together between 0.49 and 0.60, ending at 0.556 on validation.]

#callout("labpart", title: [Part C --- A convolutional network])[*Goal.* Build a CNN, compare it with the dense network on the test images, and look at its mistakes and filters.

Questions 6--10 •~Data: wood surface defects]

#callout("labquestion", title: [Question 6 --- Build a CNN and trace its shapes])[A CNN keeps the image as a grid. The first layer slides sixteen $3 times 3$ filters, each reading all three colours, across it and produces sixteen feature maps; max pooling halves each map; a second layer does the same with thirty-two filters; the result is flattened and classified by a small dense layer. Printing the shape after each stage shows where the numbers go.] #callout("labanswer", title: [Worked answer])[
#include "/MACHINE LEARNING/labs/visuals/07-worked-case.typ"
 #source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 124, last: 143, lang: "python") *Reference output.*

#code-block("trainable weights: 136679\nConv2d     -> (16, 32, 32)\nMaxPool2d  -> (16, 16, 16)\nConv2d     -> (32, 16, 16)\nMaxPool2d  -> (32, 8, 8)\nFlatten    -> (2048,)\nLinear     -> (64,)\nLinear     -> (7,)", lang: "text")

#strong[What it means.] Padding keeps each convolution at the same spatial size, and each pool halves it: 32, 16, 8. The two convolutions hold only 5,088 weights (448 and 4,640); the first `Linear` layer holds 131,136 of the 136,679. Its 2,048 inputs must match the flattened tensor, and that mismatch is the commonest bug when changing an architecture. The CNN has a third of the dense network's weights.]

#callout("labquestion", title: [Question 7 --- Train the CNN])[The same loop trains it; nothing else changes.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 145, last: 148, lang: "python") *Reference output.*

#code-block("CNN: validation accuracy by epoch = [0.503, 0.593, 0.62, 0.657, 0.656, 0.676, 0.683,\n 0.697, 0.666, 0.704]", lang: "text")

#strong[What it means.] Convolution needs a different architecture and no different training code. The CNN starts ahead of the dense network (0.503 against 0.408 after one epoch), climbs almost steadily, and ends ten epochs at 0.704, still rising, with training at 0.718: little overfitting yet.]

#strong[Connect it to the chapter.] Every network in this lab is this picture with different layers. 
#include "/MACHINE LEARNING/labs/visuals/07-deep-learning-cnn-chapter.typ"


#callout("labquestion", title: [Question 8 --- Open the test images once])[Now the test boards, opened once for each model. The first number is Lab~4's result for PCA and logistic regression on the same 3,134 images.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 150, last: 166, lang: "python") *Reference output.*

#code-block("PCA + logistic (Lab 4)   test accuracy = 0.6331\ndense network            test accuracy = 0.5491\nCNN                      test accuracy = 0.7001", lang: "text")

#strong[What it means.] The ladder is not a ladder. The dense network scores #emph[below] Lab~4's linear model: more weights, and a hidden layer, do not help when every pattern must be learned again at every position. The CNN beats both, by seven points over PCA and fifteen over the dense network, with a third of the dense network's weights: a filter that finds the dark ring of a knot in one place finds it everywhere. Differences between runs are smaller but real here: the book's check script trains the same CNN with a different shuffle order and gets 0.686. The ranking holds.]

#callout("labquestion", title: [Question 9 --- Inspect the CNN's mistakes])[Which types does the CNN still confuse? Recall per type, a confusion matrix on the test boards, and the misclassified images themselves answer that.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 168, last: 192, lang: "python") *Reference output.*

#code-block("test recall by type:\nlive knot          0.448\nquartzity          0.679\nresin              0.721\nknot with crack    0.737\ncrack              0.745\nmarrow             0.794\ndead knot          0.858", lang: "text")

#strong[What it means.] This run makes 940 errors out of 3,134, and they are not spread evenly. Dead knots, dark and sharply ringed, are found 86% of the time; live knots only 45%. The largest cell in the matrix by far is a live knot read as a knot with a crack (246 times), followed by live knot as dead knot (87) and knot with crack as live knot (63). The three knot types blur into one another, the same confusion Lab~4's PCA model showed. Then look at the images: a live knot with a dark streak read as cracked, a crack in curving grain read as quartzity. At $32 times 32$ pixels a fine crack is a line one or two pixels wide, and some of these would be hard for a grader too. A count cannot show you that.]

#callout("labquestion", title: [Question 10 --- Look at the learned filters])[What did the first layer learn? Its sixteen filters are $3 times 3$ grids of weights for each colour; added over the three colours, they can be drawn directly, along with the sixteen maps they make of one test image.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 194, last: 214, lang: "python")

#strong[What it means.] Several filters have a warm side and a cool side: they respond to a change of brightness in one direction, an edge, like the filter you worked by hand in Chapter~#ref(label("ch:deep"), supplement: none). The maps of a test knot with a crack show the division of labour: some light up the dark knot, some the bright wood around it, some only the outline of the knot or the edges of the photo, and one stays almost blank for this image. Nobody told the network to look for edges or knots; they are what reduces the loss.]

#callout("labcheckpoint", title: [Checkpoint: before you move on])[- The CNN has 136,679 weights and reaches 0.704 validation accuracy after 10 epochs.

- Test accuracy: 0.633 for Lab~4's PCA model, 0.549 for the dense network, 0.700 for the CNN.

- Live knots are found only 45% of the time, most often read as knots with cracks.]

#callout("labpart", title: [Part D --- Save the weights with a card])[*Goal.* Save the weights with a model card, and check that they reload.

Question 11 •~Data: the trained CNN]

#callout("labquestion", title: [Question 11 --- Save the weights with a card])[`torch.save` writes the learned weights (the #emph[state dict]) to a file. Loading them requires building the same architecture first, which is why `make_cnn` and the model card belong beside the file. The reloaded model is checked against the in-memory one before the file is trusted.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 216, last: 238, lang: "python") *Reference output.*

#code-block("saved wood_cnn.pt (537 KB); reload reproduces predictions: True", lang: "text")

#strong[What it means.] 537~KB is the 136,679 weights at four bytes each, plus a little bookkeeping. The card records the seven types, the input format, the architecture, the training settings and the test score. Without it, the weights are just numbers.]

#callout("labcheckpoint", title: [Checkpoint: before you move on])[- `wood_cnn.pt` is 537~KB, and the reloaded network reproduces every test prediction.]

#callout("labpart", title: [Finish --- Save the evidence, then try it yourself])[*Goal.* Write the results folder, then extend the lab yourself before reading one worked solution.

Questions 12--14]

#callout("labquestion", title: [Question 12 --- Save the evidence])[Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 240, last: 247, lang: "python") *Reference output.*

#code-block("Saved: ['cnn_accuracy_per_epoch.png', 'cnn_confusion_matrix_on_the_test_boards.png',\n 'dense_network_accuracy_per_epoch.png', 'metrics.csv', 'one_training_image_of_each_type.png',\n 'ten_of_the_cnn_s_mistakes.png', 'the_first_layer_s_sixteen_views.png',\n 'the_sixteen_3x3_filters_of_the_first_convolutional_layer.png',\n 'three_models_one_set_of_test_boards.png', 'training_curves.csv']", lang: "text")]

#heading(level: 2, numbering: none)[Try it yourself]
#callout("labquestion", title: [Question 13 --- Try it yourself])[Train the CNN for 25 epochs and read the accuracy curves: does the validation curve stop improving, and what is the training curve doing by then? Then build a CNN with only the first convolutional block (delete the second `Conv2d`, `ReLU` and `MaxPool2d`; the flattened size becomes $16 times 16 times 16$), and see whether the second block earns its keep. Attempt it in this empty cell before reading the solution.]

#callout("labquestion", title: [Question 14 --- One solution])[The CNN trained for 25 epochs, then a one-block CNN.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py", first: 251, last: 275, lang: "python") *Reference output.*

#code-block("25 epochs: best validation 0.7408 at epoch 24; last epoch: training 0.7490, validation 0.7361\none-block CNN: weights = 263111  test accuracy = 0.6812\ntwo-block CNN: weights = 136679  test accuracy = 0.7001", lang: "text")

#strong[What it means.] Validation keeps climbing to 0.741 at epoch 24, and training, at 0.749, is barely ahead of it: after 25 epochs this small CNN is still learning and has hardly begun to overfit, so more epochs would pay. Early stopping would keep the best epoch, which here is almost the last. The one-block CNN has almost twice the weights, 263,111, because its flattened vector is $16 times 16 times 16 = 4 \, 096$ long, and it scores lower, 0.681 against 0.700. The second block earns its keep twice: its pooling shrinks the map before the expensive dense layer, and its filters can combine the first layer's edges into larger shapes, such as the ring of a knot.]

#callout("labpart", title: [After the lab --- Your turn, troubleshooting and hand-in])[*Goal.* Extend the lab with the Your-turn tasks, compare with the expected findings, and check your work against the two checklists before you hand it in.

Your-turn tasks •~Expected findings •~Troubleshooting •~Checklists]

#callout("yourturn", title: [Your turn])[Add new cells at the end of the notebook for these tasks, and record your numbers before reading the expected findings. Each run trains for 10 epochs, a few seconds to a minute on a laptop CPU. Compare the size of each effect with the differences between runs you have already seen.

+ #strong[Take the ReLU away.] Rebuild the dense network without `nn.ReLU()`, keeping both linear layers. Predict the test accuracy, given what Chapter~#ref(label("ch:deep"), supplement: none) says about stacked linear layers.

+ #strong[Move the learning rate.] Train the CNN with learning rates 0.0001, 0.001, 0.01 and 0.1. Which fails, and how?

+ #strong[Drop the dropout.] Rebuild the CNN with `nn.Dropout(0.0)`. Does dropout earn its place after 10 epochs?]

#callout("expectedfindings", title: [Expected findings])[#strong[Warm-up.] $32 times 32 times 3 = 3 \, 072$ numbers; $3 \, 072 times 128 + 128 = 393 \, 344$ and $128 times 7 + 7 = 903$, so 394,247 weights. The first block gives $16 times 16 times 16$, with $3 times 16 times 9 + 16 = 448$ weights; after the second, $32 times 8 times 8 = 2 \, 048$ numbers reach a dense layer of $2 \, 048 times 64 + 64 = 131 \, 136$ weights.

+ About 0.45 (0.450 in the check script), against 0.557 with ReLU trained the same way, and 0.638 for Lab~4's logistic regression on all 3,072 pixels. Without an activation the two layers collapse into one linear map, so it is logistic regression with extra steps, and after only 10 epochs it has not even reached what Lab~4's fully trained version scored.

+ Test accuracy is about 0.571, 0.686, 0.690 and 0.197. The smallest rate is simply slow: still climbing after 10 epochs. The largest makes the network call every image a live knot, so it scores the share of live knots among the test images, 19.7%: the overshoot from the practice bowl of Chapter~#ref(label("ch:learning"), supplement: none).

+ About 0.699 without dropout, against 0.686 with it in the same script, a difference of about one point. That is smaller than the 1.4 points between this script and the notebook for the very same CNN, so it is no difference you could defend. After 10 epochs training and validation are only about a point apart, so there is little overfitting for dropout to prevent; try it again on a longer run, once the curves start to part.]

#callout("troubleshoot", title: [Troubleshooting])[/ `No module named ’torch’`: #block[
Compare the first line of the Setup output with the environment you installed into. Register the right environment as a kernel, and switch to it.
]

/ `OMP: Error #15` on Windows: #block[
Two OpenMP runtimes are loaded. The Setup cell sets `KMP_DUPLICATE_LIB_OK` before importing NumPy; restart the kernel so it takes effect.
]

/ `mat1 and mat2 shapes cannot be multiplied`: #block[
A `Linear` layer's input size does not match the flattened tensor. Print the shapes with the loop from Question~6.
]

/ `Invalid device id`: #block[
You set `CUDA_VISIBLE_DEVICES` to an empty string. Use `-1`.
]

/ Tensors on different devices: #block[
Use `.to(DEVICE)` for the model and data, and `.cpu()` before plotting.
]

/ An image looks scrambled when plotted: #block[
PyTorch keeps colour first, $3 times 32 times 32$; matplotlib wants it last. Use `.permute(1, 2, 0)` before `imshow`, as Question~2 does.
]]

#callout("verification", title: [Verification checklist])[- The device in use is printed with the PyTorch version.

- The training and validation curves are both plotted, and you can tell a zigzag from overfitting.

- The dense network and the CNN are compared with Lab~4's baseline on the same test boards, and your CNN score is within about 0.02 of 0.70.

- The weakest types and the largest confusions are read from your own output, and inspected as images.

- `models/wood_cnn.pt` and its card are saved, and the reloaded model matches the one in memory.]
