#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#unit("labs", "07-deep-learning-cnn")

#labsection(7, label: <sec:lab07-cnn>)[Deep learning I: a first neural network and a CNN for images]

#labproject[Train a dense network and a convolutional network on photos of wood defects][
  #strong[Read first.] #chapsref(<ch:deep>, <ch:cnn>): neural networks, how to train them, and convolutional networks. \

  #strong[Goal.] Turn images into tensors, write one training loop and read its curves, compare a dense network and a CNN with Lab~4’s classical baseline, look at what the CNN learned and where it fails, and save the weights with a model card. \

  #strong[Scenario.] The sawmill from Lab~4 wants every defect its camera finds sorted into one of seven types, so that boards can be graded automatically. Lab~4’s PCA and logistic regression got 63.3% of the test images right. Is a neural network worth the extra machinery? Each step up the ladder has to earn its place on the same 3,134 test images, from boards no model has seen. \

  #strong[Data.] `all_datasets/unsupervised/wood_surface_defects/wood_defects.npz`, the wood-defect images from Lab~4: 15,701 colour photos, $32 times 32$ pixels, of seven defect types on sawn boards (Kodytek, Bodzas and Bilik, 2022). \

  #strong[Notebook.] `all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.ipynb`, with a README beside it. \

  #strong[Hand in.] The executed notebook, `results/lab07/`, the weights with their card and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labroadmap([Your map of this lab],
  [A],
  [Turn the images into tensors, with Lab~4’s board-wise splits],
  [2],
  [B],
  [Build a dense network, write the training loop, read the curves],
  [3--5],
  [C],
  [Build and train a CNN; test it once; inspect its mistakes and filters],
  [6--10],
  [D],
  [Save the weights with a card and reload them],
  [11],
  [Finish],
  [Save the evidence; then train longer and try a one-block CNN],
  [12--14],
  [After],
  [Your-turn tasks, expected findings, troubleshooting and the two checklists],
  [---],
)

#labmode[
  + Activate your course environment. PyTorch comes with `requirements.txt`; if it is missing, the Setup cell installs the CPU build once.
  + Check the small worked numbers of Chapters~@ch:deep and~@ch:cnn, which run on NumPy alone. The last line must read `Every number above matches the book.` The CNN chapter's own experiments are in `demo_cnn.py`, which takes about a minute and a half.
  + From the course folder, start Jupyter, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. It took under two minutes on the laptop CPU behind this sheet, most of it the 25-epoch run in the solution. No GPU is needed.
  + To reproduce the sheet’s numbers on a machine with a GPU, hide the GPU first, as Chapter~@ch:toolkit shows. A GPU run is just as valid, and its numbers differ a little.

  ```terminal
  python all_experiments/book_checks/demo_advanced.py
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py` runs the same code and writes the same evidence.
]

#labroutine

#yourturn[
  #strong[Warm-up on paper.] Do these before opening the notebook; Questions~3 and~6 will check you.

  + A colour image of $32 times 32$ pixels holds how many numbers? How many weights has a dense network from those inputs through 128 hidden units to 7 outputs, counting one bias per unit? ($3","072$; $393","344+903=394","247$.)
  + That image passes through a padded $3 times 3$ convolution with 16 filters and a $2 times 2$ max pool. Give the output shape, and the number of weights in the convolution; each filter reads all three colours. ($16 times 16 times 16$; $3 times 16 times 9+16=448$.)
  + After a second such block with 32 filters, how many numbers go into the first dense layer, and how many weights does that layer need for 64 units? ($32 times 8 times 8=2","048$; $2","048 times 64+64=131","136$.)
]

#labquestion(1)[Setup][
  Run this first, and keep this kernel for the later questions. `start_pytorch()` installs PyTorch once if it is missing, picks the device to train on, and fixes the random seed; `start_lab()` returns the three folders the lab uses, as in every lab.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 1)

  #readcode[
    - `start_pytorch()` installs PyTorch if it is missing, seeds it, and returns the device to compute on: a GPU when one is visible, the CPU otherwise.
    - `torch` holds tensors and the training machinery, and `torch.nn` holds the layers.
    - The rest of the setup is as before.
  ]

  #refoutput[
    ```terminal
    Python 3.13.9 at C:\ProgramData\anaconda3\python.exe
    PyTorch 2.11.0+cu128 | device: cpu
    course folder: MACHINE LEARNING
    reads all_datasets/, writes results/lab07/ and models/
    ```
  ]

  #strong[What it means.] The first line names the Python that runs the kernel, which is the environment PyTorch must be installed in. This sheet’s numbers come from a CPU run.
]

#labpartopen([Part A], [Images as tensors], [Question 2 • Data: wood surface defects], [Turn the defect images into tensors, with the same board-wise splits as Lab~4.])

#labquestion(2)[Turn images into tensors][
  The same defect photos as Lab~4: each is a $32 times 32$ grid of pixels with three colour values from 0 to 255. PyTorch works on #emph[tensors], which are arrays that remember how to compute gradients. A convolutional layer expects images as (batch, channels, height, width), so each image becomes $3 times 32 times 32$, scaled to $[0,1]$. The splits repeat Lab~4’s, with the same seeds: whole boards go to fitting, validation or test, and the test images stay closed until Question~8.
]

#labanswer[
  #include "visuals/07-trace.typ"

  #labcode("lab07_deep_learning_cnn", 2)

  #readcode[
    - `GroupShuffleSplit(...).split(labels, labels, boards)` is called with Lab~4’s seeds, so the same boards land in the test set. The first argument only has to have the right length.
    - The second split divides the development rows. It returns positions within `dev`, so `dev[fit]` and `dev[val]` turn them back into positions within the whole dataset.
    - `torch.tensor(..., dtype=torch.float32)` turns the NumPy images into a tensor. `.permute(0, 3, 1, 2)` reorders the axes from (image, height, width, colour) to (image, colour, height, width), the order that PyTorch's image layers expect.
    - `.to(DEVICE)` moves a tensor to the device the model will run on.
    - The labels become `torch.long`, whole numbers, as the loss function requires.
    - For drawing, `.permute(1, 2, 0).cpu()` puts the colour axis last again and brings the image back to ordinary memory.
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/labs/visuals/07-notebook-reference.png", width: 95%, height: 3cm)
  ]

  #refoutput[
    ```terminal
    fit: (9357, 3, 32, 32)  validation: (3210, 3, 32, 32)  test: (3134, 3, 32, 32)
    ```
  ]

  #strong[What it means.] 9,357 images to fit, 3,210 to validate and 3,134 sealed for the test, exactly Lab~4’s three groups of boards. Each image is three channels of $32 times 32$ values, so a network can compare its results with Lab~4’s on the very same test images.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - 9,357 images to fit, 3,210 to validate, and 3,134 sealed for the test, each $3 times 32 times 32$.
  ]
]

#labpartopen([Part B], [A first neural network and the training loop], [Questions 3--5 • Data: wood surface defects], [Build a dense network, write the training loop, and read its accuracy curves.])

#labquestion(3)[Build a dense network][
  A dense network flattens the 3,072 numbers of an image into a vector, computes 128 weighted sums, passes each through ReLU, and computes 7 class scores from those. Written in `nn.Sequential`, it is four lines.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 3)

  #readcode[
    - `nn.Sequential(...)` chains layers: the output of each is the input of the next.
    - `nn.Flatten()` turns each 3 x 32 x 32 image into one row of 3,072 numbers.
    - `nn.Linear(3 * 32 * 32, 128)` is a dense layer of 128 units, each with a weight for every input and one bias. `nn.ReLU()` replaces negative values by 0.
    - The last layer gives seven scores, one per defect type. They are not probabilities; the loss function deals with that.
    - `sum(p.numel() for p in mlp.parameters())` counts the weights: 3,072 x 128 + 128 in the first layer, and 128 x 7 + 7 in the second.
  ]

  #refoutput[
    ```terminal
    Sequential(
      (0): Flatten(start_dim=1, end_dim=-1)
      (1): Linear(in_features=3072, out_features=128, bias=True)
      (2): ReLU()
      (3): Linear(in_features=128, out_features=7, bias=True)
    )
    trainable weights: 394247
    ```
  ]

  #strong[What it means.] The count matches your warm-up, and almost all of it sits in the first layer, one weight for every pixel value and hidden unit. The classical baseline from Lab~4 has no hidden layer at all.
]

#labquestion(4)[Write the training loop and train][
  The training loop is the whole method. Each epoch shuffles the training images and walks through them in batches of 128. For each batch: compute the class scores (forward pass), compute the cross-entropy loss, compute every gradient with `backward()`, and let the optimizer move every weight a small step. After each epoch, accuracy is recorded on the training and validation images. `predict` works in chunks of 2,000, so scoring many images never needs them all in memory at once.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 4)

  #readcode[
    - `predict` runs the model on 2,000 images at a time. `model.eval()` switches dropout off, `torch.no_grad()` skips the bookkeeping that only training needs, and `argmax(dim=1)` picks the class with the highest score.
    - `accuracy` compares predictions with labels: `.float().mean()` is the share that match, and `.item()` turns a one-number tensor into a Python number.
    - In `train_classifier`, `torch.optim.Adam(model.parameters(), lr=lr)` is the rule that updates the weights, and `nn.CrossEntropyLoss()` is the loss for classes.
    - `torch.randperm(len(X))` shuffles the row positions at the start of every epoch, and `order[start:start + batch_size]` takes the next 128 of them.
    - Each batch takes four steps. `optimizer.zero_grad()` clears the old gradients, `loss_fn(model(X[batch]), y[batch])` measures the loss, `loss.backward()` computes the gradient of the loss for every weight, and `optimizer.step()` moves the weights.
    - `torch.manual_seed(42)` fixes the shuffles, so a rerun on the same machine trains in the same way.
  ]

  #refoutput[
    ```terminal
    dense network: validation accuracy by epoch = [0.408, 0.48, 0.552, 0.554, 0.536, 0.485,
     0.561, 0.539, 0.596, 0.556]
    ```
  ]

  #strong[What it means.] This is the recipe from Chapter~@ch:orientation, in eight lines: model, loss, optimizer.
]

#labquestion(5)[Read the accuracy curves][
  Plot the two accuracy lists against the epoch, and read them as you read the tree-depth curve in Lab~3.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 5)

  #readcode[
    - `plot_history` draws the two lists kept by the training loop against the epoch number.
    - `range(1, len(history["train"]) + 1)` numbers the epochs from 1.
    - The file name is built from the title, as in Lab~6.
  ]

  #strong[What it means.] The two curves move together and zigzag: up to 0.596, down to 0.485, never apart. This is not overfitting, which would open a gap between them; it looks like an optimizer whose steps are too large for nearly 400,000 weights fed with raw pixels, so each epoch lands somewhere new. A dense network must learn every pattern separately at every position, and 9,357 images are few for that.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - The dense network has 394,247 weights.
    - Its training and validation curves zigzag together between 0.49 and 0.60, ending at 0.556 on validation.
  ]
]

#labpartopen([Part C], [A convolutional network], [Questions 6--10 • Data: wood surface defects], [Build a CNN, compare it with the dense network on the test images, and look at its mistakes and filters.])

#labquestion(6)[Build a CNN and trace its shapes][
  A CNN keeps the image as a grid. The first layer slides sixteen $3 times 3$ filters, each reading all three colours, across it and produces sixteen feature maps; max pooling halves each map; a second layer does the same with thirty-two filters; the result is flattened and classified by a small dense layer. Printing the shape after each stage shows where the numbers go.
]

#labanswer[
  #include "visuals/07-worked-case.typ"

  #labcode("lab07_deep_learning_cnn", 6)

  #readcode[
    - `nn.Conv2d(3, 16, kernel_size=3, padding=1)` slides 16 filters of 3 x 3 over the three colour layers. `padding=1` adds a border of zeros, so the output keeps the 32 x 32 size.
    - `nn.MaxPool2d(2)` keeps the largest value in each 2 x 2 square, which halves the height and the width.
    - After two blocks the image has become 32 maps of 8 x 8. `nn.Flatten()` makes them one row of 2,048 numbers for the dense layers.
    - `nn.Dropout(0.2)` sets a random fifth of the 64 values to zero during training, which makes the network harder to overfit.
    - The loop passes one image through the layers one at a time. `isinstance(layer, (...))` picks the layers whose output shape is worth printing, and `sample.shape[1:]` leaves out the batch dimension.
  ]

  #refoutput[
    ```terminal
    trainable weights: 136679
    Conv2d     -> (16, 32, 32)
    MaxPool2d  -> (16, 16, 16)
    Conv2d     -> (32, 16, 16)
    MaxPool2d  -> (32, 8, 8)
    Flatten    -> (2048,)
    Linear     -> (64,)
    Linear     -> (7,)
    ```
  ]

  #strong[What it means.] Padding keeps each convolution at the same spatial size, and each pool halves it: 32, 16, 8. The two convolutions hold only 5,088 weights (448 and 4,640); the first `Linear` layer holds 131,136 of the 136,679. Its 2,048 inputs must match the flattened tensor, and that mismatch is the commonest bug when changing an architecture. The CNN has a third of the dense network’s weights.
]

#labquestion(7)[Train the CNN][
  The same loop trains it; nothing else changes.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 7)

  #readcode[
    - The same `train_classifier` trains the CNN: the loop does not care what is inside the model.
    - `torch.manual_seed(42)` before building the network and again before training makes the starting weights and the shuffles repeatable.
  ]

  #refoutput[
    ```terminal
    CNN: validation accuracy by epoch = [0.503, 0.593, 0.62, 0.657, 0.656, 0.676, 0.683,
     0.697, 0.666, 0.704]
    ```
  ]

  #strong[What it means.] Convolution needs a different architecture and no different training code. The CNN starts ahead of the dense network (0.503 against 0.408 after one epoch), climbs almost steadily, and ends ten epochs at 0.704, still rising, with training at 0.718: little overfitting yet.
]

#strong[Connect it to the chapter.] Every network in this lab is this picture with different layers.

#include "visuals/07-deep-learning-cnn-chapter.typ"

#labquestion(8)[Open the test images once][
  Now the test boards, opened once for each model. The first number is Lab~4’s result for PCA and logistic regression on the same 3,134 images.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 8)

  #readcode[
    - `test_scores` holds three test accuracies. The first is typed in from Lab~4, which used the same test boards.
    - `accuracy(mlp, X_test, y_test)` and `accuracy(cnn, X_test, y_test)` are the first and only use of the test images.
    - `plt.ylim(0.5, 0.9)` zooms the bar chart in on the range where the three models differ.
  ]

  #refoutput[
    ```terminal
    PCA + logistic (Lab 4)   test accuracy = 0.6331
    dense network            test accuracy = 0.5491
    CNN                      test accuracy = 0.7001
    ```
  ]

  #strong[What it means.] The ladder is not a ladder. The dense network scores #emph[below] Lab~4’s linear model: more weights, and a hidden layer, do not help when every pattern must be learned again at every position. The CNN beats both, by seven points over PCA and fifteen over the dense network, with a third of the dense network’s weights: a filter that finds the dark ring of a knot in one place finds it everywhere. Differences between runs are smaller but real here: the book’s check script trains the same CNN with a different shuffle order and gets 0.686. The ranking holds.
]

#labquestion(9)[Inspect the CNN’s mistakes][
  Which types does the CNN still confuse? Recall per type, a confusion matrix on the test boards, and the misclassified images themselves answer that.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 9)

  #readcode[
    - `.cpu().numpy()` brings the tensors back as NumPy arrays, for scikit-learn and pandas.
    - `(guess[truth == c] == c).mean()` is the recall of type `c`: among the images that truly are `c`, the share predicted as `c`.
    - `ConfusionMatrixDisplay.from_predictions(...)` draws the 7 x 7 table of truth against prediction, and `xticks_rotation=45` tilts the labels so that they fit.
    - `torch.nonzero(test_pred != y_test).flatten()[:10]` gives the positions of the first ten mistakes.
  ]

  #refoutput[
    ```terminal
    test recall by type:
    live knot          0.448
    quartzity          0.679
    resin              0.721
    knot with crack    0.737
    crack              0.745
    marrow             0.794
    dead knot          0.858
    ```
  ]

  #strong[What it means.] This run makes 940 errors out of 3,134, and they are not spread evenly. Dead knots, dark and sharply ringed, are found 86% of the time; live knots only 45%. The largest cell in the matrix by far is a live knot read as a knot with a crack (246 times), followed by live knot as dead knot (87) and knot with crack as live knot (63). The three knot types blur into one another, the same confusion Lab~4’s PCA model showed. Then look at the images: a live knot with a dark streak read as cracked, a crack in curving grain read as quartzity. At $32 times 32$ pixels a fine crack is a line one or two pixels wide, and some of these would be hard for a grader too. A count cannot show you that.
]

#labquestion(10)[Look at the learned filters][
  What did the first layer learn? Its sixteen filters are $3 times 3$ grids of weights for each colour; added over the three colours, they can be drawn directly, along with the sixteen maps they make of one test image.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 10)

  #readcode[
    - `cnn[0]` is the first layer of the `Sequential`, and `cnn[0].weight` is its filters: a tensor of shape 16 x 3 x 3 x 3.
    - `.detach()` separates the values from the training machinery, and `.sum(dim=1)` adds the three colour layers of each filter, which leaves sixteen 3 x 3 grids.
    - `vmin=-limit, vmax=limit` centres the colour scale on zero, so blue is negative and red is positive in every panel.
    - `cnn[1](cnn[0](X_test[:1]))` applies the first convolution and its ReLU to one image. The result is sixteen feature maps of 32 x 32.
    - `axes.flat` walks through the 2 x 8 grid of panels one at a time.
  ]

  #strong[What it means.] Several filters have a warm side and a cool side: they respond to a change of brightness in one direction, an edge, like the filter you worked by hand in Chapter~#ref(<ch:cnn>). The maps of a test knot with a crack show the division of labour: some light up the dark knot, some the bright wood around it, some only the outline of the knot or the edges of the photo, and one stays almost blank for this image. Nobody told the network to look for edges or knots; they are what reduces the loss.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - The CNN has 136,679 weights and reaches 0.704 validation accuracy after 10 epochs.
    - Test accuracy: 0.633 for Lab~4’s PCA model, 0.549 for the dense network, 0.700 for the CNN.
    - Live knots are found only 45% of the time, most often read as knots with cracks.
  ]
]

#labpartopen([Part D], [Save the weights with a card], [Question 11 • Data: the trained CNN], [Save the weights with a model card, and check that they reload.])

#labquestion(11)[Save the weights with a card][
  `torch.save` writes the learned weights (the #emph[state dict]) to a file. Loading them requires building the same architecture first, which is why `make_cnn` and the model card belong beside the file. The reloaded model is checked against the in-memory one before the file is trusted.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 11)

  #readcode[
    - `cnn.state_dict()` is a dictionary of every weight tensor, by layer name, and `torch.save` writes it to a file. The file holds numbers only, not the code of the network.
    - The card records what the file cannot: the classes, the input format, the architecture and the training settings.
    - To load, `make_cnn()` builds an untrained network of the same shape, and `load_state_dict(torch.load(...))` fills in the saved weights. `map_location=DEVICE` loads them onto this machine's device, and `weights_only=True` refuses to load anything other than tensors.
    - `torch.equal(predict(restored, X_test), test_pred)` checks that the restored network predicts exactly as before.
  ]

  #refoutput[
    ```terminal
    saved wood_cnn.pt (537 KB); reload reproduces predictions: True
    ```
  ]

  #strong[What it means.] 537~KB is the 136,679 weights at four bytes each, plus a little bookkeeping. The card records the seven types, the input format, the architecture, the training settings and the test score. Without it, the weights are just numbers.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - `wood_cnn.pt` is 537~KB, and the reloaded network reproduces every test prediction.
  ]
]

#labpartopen([Finish], [Save the evidence, then try it yourself], [Questions 12--14], [Write the results folder, then extend the lab yourself before reading one worked solution.])

#labquestion(12)[Save the evidence][
  Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 12)

  #readcode[
    - `curves` puts the four accuracy lists side by side, one row per epoch.
    - `pd.Series(test_scores, name="test_accuracy").rename_axis("model")` turns the dictionary of test scores into a two-column table.
  ]

  #refoutput[
    ```terminal
    Saved: ['cnn_accuracy_per_epoch.png', 'cnn_confusion_matrix_on_the_test_boards.png',
     'dense_network_accuracy_per_epoch.png', 'metrics.csv', 'one_training_image_of_each_type.png',
     'ten_of_the_cnn_s_mistakes.png', 'the_first_layer_s_sixteen_views.png',
     'the_sixteen_3x3_filters_of_the_first_convolutional_layer.png',
     'three_models_one_set_of_test_boards.png', 'training_curves.csv']
    ```
  ]
]

#labsubhead[Try it yourself]

#labquestion(13)[Try it yourself][
  Train the CNN for 25 epochs and read the accuracy curves: does the validation curve stop improving, and what is the training curve doing by then? Then build a CNN with only the first convolutional block (delete the second `Conv2d`, `ReLU` and `MaxPool2d`; the flattened size becomes $16 times 16 times 16$), and see whether the second block earns its keep. Attempt it in this empty cell before reading the solution.
]

#labquestion(14)[One solution][
  The CNN trained for 25 epochs, then a one-block CNN.
]

#labanswer[
  #labcode("lab07_deep_learning_cnn", 14)

  #readcode[
    - Part 1 rebuilds the CNN with the same seed and trains it for 25 epochs. `np.argmax(long_history["validation"]) + 1` is the epoch with the best validation accuracy; 1 is added because positions start at 0.
    - Part 2 defines a CNN with one block only. After one pooling the maps are 16 x 16, so the flattened row has 16 x 16 x 16 = 4,096 numbers, and the first dense layer is sized to match.
    - The last two lines print the number of weights and the test accuracy of both CNNs, one under the other.
  ]

  #refoutput[
    ```terminal
    25 epochs: best validation 0.7408 at epoch 24; last epoch: training 0.7490, validation 0.7361
    one-block CNN: weights = 263111  test accuracy = 0.6812
    two-block CNN: weights = 136679  test accuracy = 0.7001
    ```
  ]

  #strong[What it means.] Validation keeps climbing to 0.741 at epoch 24, and training, at 0.749, is barely ahead of it: after 25 epochs this small CNN is still learning and has hardly begun to overfit, so more epochs would pay. Early stopping would keep the best epoch, which here is almost the last. The one-block CNN has almost twice the weights, 263,111, because its flattened vector is $16 times 16 times 16=4","096$ long, and it scores lower, 0.681 against 0.700. The second block earns its keep twice: its pooling shrinks the map before the expensive dense layer, and its filters can combine the first layer’s edges into larger shapes, such as the ring of a knot.
]

#labpartopen([After the lab], [Your turn, troubleshooting and hand-in], [Your-turn tasks • Expected findings • Troubleshooting • Checklists], [Extend the lab with the Your-turn tasks, compare with the expected findings, and check your work against the two checklists before you hand it in.])

#yourturn[
  Add new cells at the end of the notebook for these tasks, and record your numbers before reading the expected findings. Each run trains for 10 epochs, a few seconds to a minute on a laptop CPU. Compare the size of each effect with the differences between runs you have already seen.

  + #strong[Take the ReLU away.] Rebuild the dense network without `nn.ReLU()`, keeping both linear layers. Predict the test accuracy, given what Chapter~@ch:deep says about stacked linear layers.
  + #strong[Move the learning rate.] Train the CNN with learning rates 0.0001, 0.001, 0.01 and 0.1. Which fails, and how?
  + #strong[Drop the dropout.] Rebuild the CNN with `nn.Dropout(0.0)`. Does dropout earn its place after 10 epochs?
]

#expectedfindings[
  #strong[Warm-up.] $32 times 32 times 3=3","072$ numbers; $3","072 times 128+128=393","344$ and $128 times 7+7=903$, so 394,247 weights. The first block gives $16 times 16 times 16$, with $3 times 16 times 9+16=448$ weights; after the second, $32 times 8 times 8=2","048$ numbers reach a dense layer of $2","048 times 64+64=131","136$ weights.

  + About 0.45 (0.450 in the check script), against 0.557 with ReLU trained the same way, and 0.638 for Lab~4’s logistic regression on all 3,072 pixels. Without an activation the two layers collapse into one linear map, so it is logistic regression with extra steps, and after only 10 epochs it has not even reached what Lab~4’s fully trained version scored.
  + Test accuracy is about 0.571, 0.686, 0.690 and 0.197. The smallest rate is simply slow: still climbing after 10 epochs. The largest makes the network call every image a live knot, so it scores the share of live knots among the test images, 19.7%: the overshoot from the practice bowl of Chapter~#ref(<ch:learning>).
  + About 0.699 without dropout, against 0.686 with it in the same script, a difference of about one point. That is smaller than the 1.4 points between this script and the notebook for the very same CNN, so it is no difference you could defend. After 10 epochs training and validation are only about a point apart, so there is little overfitting for dropout to prevent; try it again on a longer run, once the curves start to part.
]

#troubleshoot[
  / `No module named 'torch'`: Compare the first line of the Setup output with the environment you installed into. Register the right environment as a kernel, and switch to it.
  / `OMP: Error #15` on Windows: Two OpenMP runtimes are loaded. The Setup cell sets `KMP_DUPLICATE_LIB_OK` before importing NumPy; restart the kernel so it takes effect.
  / `mat1 and mat2 shapes cannot be multiplied`: A `Linear` layer’s input size does not match the flattened tensor. Print the shapes with the loop from Question~6.
  / `Invalid device id`: You set `CUDA_VISIBLE_DEVICES` to an empty string. Use `-1`.
  / Tensors on different devices: Use `.to(DEVICE)` for the model and data, and `.cpu()` before plotting.
  / An image looks scrambled when plotted: PyTorch keeps colour first, $3 times 32 times 32$; matplotlib wants it last. Use `.permute(1, 2, 0)` before `imshow`, as Question~2 does.
]

#labchecklists[
  #verification[
    - The device in use is printed with the PyTorch version.
    - The training and validation curves are both plotted, and you can tell a zigzag from overfitting.
    - The dense network and the CNN are compared with Lab~4’s baseline on the same test boards, and your CNN score is within about 0.02 of 0.70.
    - The weakest types and the largest confusions are read from your own output, and inspected as images.
    - `models/wood_cnn.pt` and its card are saved, and the reloaded model matches the one in memory.
  ]
]
