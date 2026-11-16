#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#unit("labs", "08-deep-learning-lstm")

#labsection(8, label: <sec:lab08-lstm>)[Deep learning II: an LSTM for time series]

#labproject[Forecast the next hour of electricity demand from the previous twenty-four][
  #strong[Read first.] Chapter~#ref(<ch:sequence>), with Chapter~#ref(<ch:deep-training>) on early stopping, and the time-split rule in Chapter~#ref(<ch:data>). \

  #strong[Goal.] Add up four years of meter readings into one demand series, split it by date, turn it into supervised windows, set three free forecasts any model must beat, train an LSTM that keeps its best epoch, open the test half-year once, find the hours it gets most wrong, and save the weights with the scaling they depend on. \

  #strong[Scenario.] An electricity supplier in Portugal buys power an hour ahead for 158 customers. Buy too little and it pays the spot price for the gap; buy too much and the surplus is wasted. Repeating yesterday’s figure for the same hour costs nothing and is already close, so a network has to beat it by enough to be worth running. \

  #strong[Data.] `all_datasets/time_series/electricity_load/electricity_load_hourly.zip`: hourly electricity use of 158 Portuguese customers from 2011 to 2014, in kWh, from the UCI ElectricityLoadDiagrams20112014 dataset (Trindade, 2015). \

  #strong[Notebook.] `all_experiments/lab08_deep_learning_lstm/lab08_deep_learning_lstm_worked.ipynb`, with a README beside it. \

  #strong[Hand in.] The executed notebook, `results/lab08/`, the weights with their card and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labroadmap([Your map of this lab],
  [A],
  [Build one demand series, split it by date, cut it into windows],
  [2--4],
  [B],
  [Score three free forecasts],
  [5],
  [C],
  [Train the LSTM, test it once, find the hours it gets wrong],
  [6--9],
  [D],
  [Save the weights and the scale, then forecast the first hour of 2015],
  [10],
  [Finish],
  [Save the evidence; then try other lookbacks and a wider LSTM],
  [11--13],
  [After],
  [Exercises, answers, troubleshooting tips and the two checklists],
  [---],
)

#labsetup[
  + Activate your course environment and confirm the data file is in `all_datasets/`. Keep it zipped: pandas reads the CSV inside.
  + From the course folder, start Jupyter, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. It took about four minutes on the laptop CPU behind this sheet, about half of it the Try-it solution. No GPU is needed.
  + A GPU is used when PyTorch can see one. On the laptop GPU tried for this sheet, every number came out the same apart from one digit in Question~9; to match exactly, hide the GPU as Chapter~@ch:toolkit shows.

  ```terminal
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab08_deep_learning_lstm/lab08_deep_learning_lstm_worked.py` runs the same code and writes the same evidence.
]

#labroutine

#exercises[
  #strong[Warm-up on paper.] Take one morning of demand, $60,58,57,70,95,120,125,118$~MWh, and a lookback of 3. Questions~4, 5 and~13 will check you.

  + How many windows do you get, and what are the first two with their targets? (Five: $[60,58,57] arrow.r 70$, and $[58,57,70] arrow.r 95$.)
  + Compute the MAE of #emph[last hour], which predicts each target as the last value in its window. (Errors 13, 25, 25, 5, 7, so 15.0.)
  + An LSTM layer with one input and $h$ hidden units has $4 times (h+h times h+h+h)$ weights. How many does the whole model have with $h=64$ and a linear output layer? ($17","152+65=17","217$.)
]

#labquestion(1)[Setup][
  Run this first. `start_pytorch()`, from `all_experiments/course_setup.py`, imports PyTorch, installing the CPU build once if it is missing, and picks `DEVICE`: an NVIDIA GPU (`cuda`) or Apple GPU (`mps`) when PyTorch can see one, otherwise the CPU. `start_lab()` then returns the folders to read from and write to. The first line printed is the Python actually running the notebook; if it is not the environment you installed PyTorch into, change the kernel.
]

#labanswer[
  #labcode("lab08_deep_learning_lstm", 1)

  #readcode[
    - The setup is Lab~7’s. `copy` is new: it makes an independent copy of a model's weights, which the training loop uses to remember its best epoch.
  ]

  #refoutput[
    ```terminal
    Python 3.13.9 at C:\ProgramData\anaconda3\python.exe
    PyTorch 2.11.0+cu128 | device: cpu
    course folder: MACHINE LEARNING
    reads all_datasets/, writes results/lab08/ and models/
    ```
  ]
]

#labpartopen([Part A], [From meter readings to windows], [Questions 2--4 • Data: hourly electricity use of 158 customers], [Add up the customers into one demand series, split it by date, and turn it into supervised windows.])

#labquestion(2)[Read the meters and add them up][
  The file holds one column per customer: the kWh used in each hour, four years of them. A supplier that buys electricity an hour ahead cares about the total, so the 158 columns are added up and turned into MWh. That total is the series to forecast.
]

#labanswer[
  #include "visuals/08-trace.typ"

  #labcode("lab08_deep_learning_lstm", 2)

  #readcode[
    - `parse_dates=["hour_start"], index_col="hour_start"` makes the hour the index of the table, so rows can be selected by date.
    - `loads.sum(axis=1)` adds up the customers of each hour: `axis=1` sums across the columns. Dividing by 1,000 turns kWh into MWh.
    - `demand.idxmin()` and `demand.idxmax()` return the hour of the lowest value and of the highest.
    - `demand["2014-01-06":"2014-01-19"]` selects two weeks by their dates. With a date index, both ends are included.
    - `demand.index.dayofweek >= 5` marks Saturdays and Sundays, because Monday is 0.
    - `demand[~weekend].groupby(demand.index[~weekend].hour).mean()` is the average weekday: the mean demand at each of the 24 hours.
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/labs/visuals/08-notebook-reference.png", width: 95%, height: 4.2cm)
  ]

  #refoutput[
    ```terminal
    hours: 35064  customers: 158  first hour: 2011-01-01 00:00:00  last hour: 2014-12-31 23:00:00
    demand per hour: mean 109.8 MWh
    lowest hour: 14.5 MWh at 2014-03-30 01:00:00; highest: 193.6 MWh at 2011-08-10 16:00:00
    ```
  ]

  #strong[What it means.] An average hour needs 109.8~MWh. The lowest hour is not real demand: 30 March 2014 is the night the clocks went forward, and the meters record that hour as almost nothing. Real data has quirks like this, and Question~9 meets the October version. The plot shows one strong daily rhythm, low at night and high in the afternoon, and an average weekend day that looks almost exactly like a weekday.
]

#labquestion(3)[Split by date and scale][
  Rows that are neighbours in time are nearly copies of each other, so the split has to follow the calendar: three years to train, the first half of 2014 to choose settings, and the second half of 2014 as the test period, opened once. The series is then scaled by the highest training hour, so that the network sees numbers near $[0,1]$.
]

#labanswer[
  #labcode("lab08_deep_learning_lstm", 3)

  #readcode[
    - `pd.Series("train", index=demand.index)` labels every hour `train`. The next two lines overwrite the label from 1 January 2014 and again from 1 July 2014.
    - `f"{hours[0]:%d %b %Y}"` prints a date in the form `01 Jan 2011`.
    - `scale` is the highest hour of the training period only. Dividing by it puts the training values between 0 and 1, and later values close to that range.
    - `.to_numpy(dtype=np.float32)` stores the series as the 32-bit numbers that PyTorch uses by default.
  ]

  #refoutput[
    ```terminal
    train       26304 hours, 01 Jan 2011 to 31 Dec 2013
    validation   4344 hours, 01 Jan 2014 to 30 Jun 2014
    test         4416 hours, 01 Jul 2014 to 31 Dec 2014
    scale: 193.6 MWh, the highest training hour
    ```
  ]

  #strong[What it means.] The scale is a training statistic, computed before anything looks at 2014. If a 2014 hour went higher, its scaled value would pass 1. That would be correct, and a sign that no future value leaked into the scale.
]

#labquestion(4)[Build the windows][
  A #emph[window] turns the series into rows: the 24 values before hour $t$ are the input, and the value at hour $t$ is the label. Sliding one hour at a time gives one row per hour. Each row belongs to the period of the hour it predicts.
]

#labanswer[
  #include "visuals/08-worked-case.typ"

  #labcode("lab08_deep_learning_lstm", 4)

  #readcode[
    - `make_windows` builds one row per hour `t`: `values[t - lookback:t]` is the 24 hours before `t`, and `values[t]` is the label. `np.stack` piles the windows into one array of shape (rows, 24).
    - `period.to_numpy()[hours]` looks up the period of each hour being predicted, so a row goes to the period of its label.
    - `torch.tensor(...).unsqueeze(-1)` adds a last dimension of size 1. An LSTM expects the shape (rows, steps, values per step), and here each step has one value.
    - The last lines multiply by `scale` to print the first window and its label in MWh.
  ]

  #refoutput[
    ```terminal
    windows: (35040, 24)  train: (26280, 24, 1)
     validation: (4344, 24, 1)  test: (4416, 24, 1)
    first window (MWh): [68.9 65.6 66.7 65.9 64.8 66.1] ...
    its label, the next hour: 68.4 MWh at 2011-01-02 00:00:00
    ```
  ]

  #strong[What it means.] $N$ values give $N-24$ windows, matching your warm-up’s rule, and the first 24 training hours have no full window before them. Read the slicing bounds literally: `values[t - lookback:t]` stops before position `t`, which is the label. The first validation row predicts midnight on 1 January 2014 from the last 24 hours of 2013. That is allowed, because those hours are in the past when the forecast is made.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - 35,064 hours, and 109.8~MWh in an average hour.
    - Train on 2011--2013, validate on the first half of 2014, test on the second; the scale is 193.6~MWh.
    - 26,280 training windows of 24 hours each.
  ]
]

#labpartopen([Part B], [Forecasts that cost nothing], [Question 5 • Data: the demand series], [Set the bar that any model has to clear.])

#labquestion(5)[Compute three free forecasts][
  Before any network is trained, three free forecasts set the bar. #emph[Last hour] says the next hour equals the last one. #emph[Same hour yesterday] repeats the value 24 hours back, the first value in each window. #emph[Same hour last week] repeats the value 168 hours back. A model that cannot beat all three has learned nothing worth its cost.
]

#labanswer[
  #labcode("lab08_deep_learning_lstm", 5)

  #readcode[
    - `demand.shift(1)` moves every value one row down, so each hour is paired with the hour before it. `shift(24)` pairs it with the same hour yesterday, and `shift(168)` with the same hour last week.
    - `mae` subtracts a forecast from the demand over the hours of one period and averages the absolute misses. The index lines the two series up hour by hour.
    - The dictionary comprehension scores all three forecasts on the validation period.
  ]

  #refoutput[
    ```terminal
    last hour            validation MAE = 5.77 MWh
    same hour yesterday  validation MAE = 3.07 MWh
    same hour last week  validation MAE = 4.51 MWh
    ```
  ]

  #strong[What it means.] Same hour yesterday is the one to beat. With one strong daily rhythm and little difference at weekends, yesterday is a good guess for today, while the last hour misses every morning ramp and evening fall.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - Validation MAE: last hour 5.77, same hour yesterday 3.07, same hour last week 4.51~MWh.
  ]
]

#labpartopen([Part C], [The LSTM], [Questions 6--9 • Data: the 24-hour windows], [Train an LSTM that keeps its best epoch, open the test period once, and find the hours it gets wrong.])

#labquestion(6)[Build and train the LSTM][
  The model reads the 24 values one at a time, carrying a state of 32 numbers from step to step, and a linear layer turns the final state into one prediction. The training loop is the one from Lab~7 with three changes: the loss is squared error, the score recorded each epoch is the validation MAE in MWh, and the loop keeps a copy of the weights from the best epoch so far. That is #emph[early stopping]: the model you keep is the best epoch, not the last.
]

#labanswer[
  #labcode("lab08_deep_learning_lstm", 6)

  #readcode[
    - `LSTMForecaster` is a class that inherits from `nn.Module`. `__init__` creates the layers, and `forward` says how an input passes through them.
    - `nn.LSTM(input_size=1, hidden_size=32, batch_first=True)` reads one value per step and keeps a state of 32 numbers. `batch_first=True` means the input has the shape (rows, steps, values).
    - `self.lstm(x)` returns the state after every step. `states[:, -1, :]` keeps the last one, `self.head` turns its 32 numbers into one forecast, and `.squeeze(-1)` drops the leftover dimension of size 1.
    - `train_forecaster` is Lab~7’s loop with a different loss: `nn.MSELoss()`, the squared error.
    - After each epoch it measures the validation MAE. When that is the lowest so far, `copy.deepcopy(model.state_dict())` saves a copy of the weights, and at the end `load_state_dict(best_weights)` puts the best copy back.
    - `np.argmin(history) + 1` is the number of the epoch that was kept.
  ]

  #refoutput[
    ```terminal
    trainable weights: 4513
    epoch  1: validation MAE = 4.24 MWh
    epoch  2: validation MAE = 3.72 MWh
    epoch  3: validation MAE = 3.97 MWh
    epoch  4: validation MAE = 3.92 MWh
    epoch  5: validation MAE = 2.83 MWh
    epoch  6: validation MAE = 2.38 MWh
    epoch  7: validation MAE = 2.21 MWh
    epoch  8: validation MAE = 2.20 MWh
    epoch  9: validation MAE = 2.56 MWh
    epoch 10: validation MAE = 2.16 MWh
    epoch 11: validation MAE = 2.21 MWh
    epoch 12: validation MAE = 2.29 MWh
    kept epoch 10: validation MAE = 2.16 MWh
    ```
  ]

  #strong[What it means.] The weight count is $4","480$ in the LSTM plus 33 in the output layer. The first four epochs are worse than same hour yesterday; from epoch 5 the network beats all three free forecasts. The curve is not smooth: epoch 9 is worse than epoch 8, and epochs 11 and 12 are worse than epoch 10. Keeping the best epoch protects you from stopping on an unlucky one.
]

#strong[Connect it to the chapter.] The same cell, with the same weights, is applied at every one of the 24 steps.

#include "visuals/08-deep-learning-lstm-chapter.typ"

#labquestion(7)[Read the validation curve][
  Plot the validation error against the three free forecasts.
]

#labanswer[
  #labcode("lab08_deep_learning_lstm", 7)

  #readcode[
    - `plt.plot` draws the LSTM's validation error per epoch, and one `axhline` per free forecast draws the level it has to get under.
    - The dictionary `line_colors` gives each baseline a fixed colour: `C1`, `C2` and `C3` are matplotlib's second, third and fourth default colours.
  ]

  #strong[What it means.] The curve crosses below the best dashed line at epoch 5 and stays between 2.16 and 2.29 after epoch 6, apart from one jump at epoch 9. Whether it has really finished is Exercise~1. The validation half-year chose the epoch, so its 2.16 is now a little optimistic. That is why the test period stays closed until Question~8.
]

#labquestion(8)[Open the test period once][
  Now the second half of 2014, opened once for the three free forecasts and for the LSTM.
]

#labanswer[
  #labcode("lab08_deep_learning_lstm", 8)

  #readcode[
    - `model(X_test).cpu().numpy() * scale` turns the forecasts into MWh, and `pd.Series(..., index=demand.index[period == "test"])` attaches the hour to each one.
    - `lstm_test.reindex(demand.index)` stretches the series over all the hours, with gaps outside the test period, so the same `mae` function can score it.
    - `100 * value / mean_test` expresses each error as a percentage of the average test hour.
  ]

  #refoutput[
    ```terminal
    last hour            test MAE = 6.12 MWh (5.7% of the average hour)
    same hour yesterday  test MAE = 3.69 MWh (3.4% of the average hour)
    same hour last week  test MAE = 4.86 MWh (4.5% of the average hour)
    LSTM                 test MAE = 2.57 MWh (2.4% of the average hour)
    ```
  ]

  #strong[What it means.] The LSTM misses by 2.57~MWh in an average test hour, against 3.69 for same hour yesterday: 30% less error, from 4,513 weights and the last 24 hours alone. Every forecast is worse on the test half-year than on validation, the free ones included, so the second half of 2014 is simply harder to forecast, not a sign that the network overfitted.
]

#labquestion(9)[Find the hours it gets wrong][
  A score is one number. The worst hours, the error by hour of day and one test week plotted hour by hour show #emph[where] the forecast goes wrong.
]

#labanswer[
  #labcode("lab08_deep_learning_lstm", 9)

  #readcode[
    - `errors` is the forecast minus the truth for every test hour. `.abs().sort_values(ascending=False).head(6)` lists the six largest misses with their dates.
    - `slice("2014-07-07", "2014-07-13")` stores a date range, so the same week can be cut from three series.
    - `errors.abs().groupby(errors.index.hour).mean()` is the average miss at each hour of the day.
    - `gridspec_kw={"width_ratios": [2, 1]}` makes the left chart twice as wide as the right one.
  ]

  #refoutput[
    ```terminal
    largest LSTM errors in the test period (MWh):
    hour_start
    2014-10-26 01:00:00    39.1
    2014-10-26 02:00:00    29.2
    2014-12-31 19:00:00    25.8
    2014-12-25 06:00:00    22.4
    2014-12-31 20:00:00    22.1
    2014-12-25 07:00:00    21.8
    hours of day with the largest MAE: {9: 5.59, 8: 4.94, 6: 3.5}
    ```
  ]

  #strong[What it means.] The largest errors are not random. The top two are 1 and 2~a.m. on 26 October 2014, the night the clocks went back, when the meters record two hours as one: the 1~a.m. reading is far too high, and the forecast for 2~a.m. inherits it from its window. Next come New Year’s Eve evening and Christmas morning, holidays that break the pattern of the day before, which is what the network leans on. By hour of day the morning ramp at 8 and 9~a.m. is hardest, at about twice the average error. In the plotted week the forecast follows every rise and fall, while same hour yesterday overshoots the Sunday afternoon by repeating Saturday. A supplier would handle the clock-change nights and the holidays with rules or a calendar, rather than ask the network to learn them from three examples each.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - 4,513 weights; the loop keeps epoch 10, at 2.16~MWh.
    - Test MAE 2.57~MWh against 3.69 for same hour yesterday.
    - The two worst hours are the night the clocks went back, 26 October 2014.
  ]
]

#labpartopen([Part D], [Save the weights and the scale with them], [Question 10 • Data: the trained LSTM], [Save the weights with the scale they depend on, and make one real forecast.])

#labquestion(10)[Save the weights and the scale][
  The network works only on numbers divided by the training maximum, so that number is part of the model. The card records it beside the lookback, the units and the architecture. The restored model is checked against the one in memory, and then makes one real forecast: the first hour of 2015.
]

#labanswer[
  #labcode("lab08_deep_learning_lstm", 10)

  #readcode[
    - The weights go into one file and the card into another. The card stores `scale`, without which the saved model's outputs cannot be turned back into MWh.
    - `LSTMForecaster()` builds the same empty network, and `load_state_dict` fills in the weights.
    - `torch.tensor(scaled[-LOOKBACK:]).reshape(1, LOOKBACK, 1)` shapes the last 24 hours as one window: one row, 24 steps, one value per step.
    - `restored(last_day).item() * card["scale"]` is the forecast for the next hour in MWh, and `demand.index[-1] + pd.Timedelta(hours=1)` is the hour it belongs to.
  ]

  #refoutput[
    ```terminal
    saved electricity_lstm.pt; reload reproduces the test forecasts: True
    forecast for 2015-01-01 00:00:00: 53.2 MWh
    ```
  ]

  #strong[What it means.] Without the scale of 193.6~MWh in the card, `electricity_lstm.pt` would be useless. The forecast for New Year’s midnight is low, about half an average hour. Given Question~9, treat a holiday forecast with care.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - The card holds the scale, 193.6~MWh, and the reloaded network reproduces every test forecast.
  ]
]

#labpartopen([Finish], [Save the evidence, then try it yourself], [Questions 11--13], [Write the results folder, then extend the lab yourself before reading one worked solution.])

#labquestion(11)[Save the evidence][
  Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.
]

#labanswer[
  #labcode("lab08_deep_learning_lstm", 11)

  #readcode[
    - `baselines.get(name, min(history))` returns a baseline's validation error. For the name `LSTM`, which is not in that dictionary, it falls back to the LSTM's own best.
    - The third table keeps the actual and the forecast values of the first test week, so the chart of Question~9 can be redrawn.
  ]

  #refoutput[
    ```terminal
    Saved: ['first_test_week.csv', 'metrics.csv', 'one_hour_ahead_forecasts_and_errors.png',
     'the_lstm_has_to_beat_three_free_forecasts.png', 'two_weeks_and_the_average_day.png',
     'validation_curve.csv']
    ```
  ]
]

#labquestion(12)[Try it yourself][
  Train the same LSTM with a lookback of 6 hours and of 48 hours: does the network need a whole day of history, and does it gain from two? Then double `hidden_size` to 64 with the 24-hour lookback, and see whether four times the weights buy a better forecast. Attempt it in this empty cell before reading the solution.
]

#labquestion(13)[One solution][
  Two more lookbacks and a wider LSTM, each trained exactly like the one in Question~6.
]

#labanswer[
  #labcode("lab08_deep_learning_lstm", 13)

  #readcode[
    - `try_setting` repeats Question~6 for one pair of settings: it builds the windows with the given lookback, seeds PyTorch, trains, and returns the best validation error and the number of weights.
    - In `split_by_period(*make_windows(scaled, lookback))`, the `*` passes the three arrays returned by `make_windows` as three arguments. The `_` on the left discards the test tensors, which this comparison must not touch.
    - `verbose=False` silences the line printed after every epoch.
  ]

  #refoutput[
    ```terminal
    lookback =  6 hours, hidden = 32: validation MAE = 3.63 MWh, 4513 weights
    lookback = 48 hours, hidden = 32: validation MAE = 2.14 MWh, 4513 weights
    lookback = 24 hours, hidden = 64: validation MAE = 2.09 MWh, 17217 weights
    lookback = 24 hours, hidden = 32: validation MAE = 2.16 MWh (Question 6)
    ```
  ]

  #strong[What it means.] Six hours of history is clearly worse, 3.63~MWh, which is worse even than same hour yesterday: the network can no longer see the value that free forecast uses. Forty-eight hours gives 2.14, no better than 24 within the epoch-to-epoch wobble, because one day already holds the daily shape. The wider LSTM has 17,217 weights, matching your warm-up, almost four times as many, and reaches 2.09: a gain smaller than the wobble of one model between epochs. A whole day of history matters; more of everything else does not, here.
]

#labpartopen([After the lab], [Exercises, troubleshooting and hand-in], [Exercises • Answers • Troubleshooting • Checklists], [Extend the lab with the exercises, compare with the answers, and check your work against the two checklists before you hand it in.])

#exercises[
  Add new cells at the end of the notebook for these tasks, and record your numbers before reading the answers. Each run of 12 epochs takes about a minute on a laptop CPU, and the 30-epoch run about two and a half.

  + #strong[Train longer.] Train the 24-hour, 32-unit model for 30 epochs, still keeping the best. Which epoch wins, and does the test MAE improve on 2.57?
  + #strong[Give it a clock.] Add a second input channel, the hour of day divided by 23, using `input_size=2`. Does knowing the time help, given that the window already shows the daily shape?
  + #strong[Forecast further ahead.] Change the windows so that they end 2 hours, and then 24 hours, before the hour they predict, and compare each LSTM with the free forecasts at the same distance. Where does the network’s advantage go?
]

#answers[
  + The validation error wobbles between about 2.1 and 2.7 from epoch 7 to epoch 21, then falls again. The best epoch is 29, at 1.56, and the test MAE drops to 1.79, against 2.57 after 12 epochs and 3.69 for same hour yesterday. Twelve epochs stopped on a plateau, not at the bottom. Early stopping can only choose among the epochs you paid for, so give it a generous budget, and stop only when validation has not improved for several epochs in a row.
  + Validation 2.07 against 2.16, and test 2.59 against 2.57: no gain that survives the test period. The 24 values in each window already show where in the day the forecast is, so the clock tells the network nothing new. A feature helps only when it carries information the model cannot already see.
  + Two hours ahead, the LSTM’s test MAE is 2.98 against 3.69 for same hour yesterday: still 19% better, down from 30% at one hour, while last known hour rises to 11.93. At 24 hours ahead the LSTM scores 3.71, no better than same hour yesterday’s 3.69, which at that distance is also the last known hour. The network’s edge comes from the most recent hours; a day-ahead forecast needs other inputs, such as the weather and the calendar.
]

#tip[
  / Validation MAE below 0.1: You are measuring in scaled units, or forgot to multiply back by `scale`. Free forecasts and model must use the same units, MWh.
  / A free forecast looks suspiciously good: Check the alignment: `demand.shift(1)` is the hour before, and `shift(24)` the same hour yesterday. A shift of 0 compares each hour with itself.
  / `Expected 3D input`: An LSTM with `batch_first=True` needs (rows, steps, values per step). `unsqueeze(-1)` adds the last dimension.
  / `best_weights` is `None`: The validation MAE came out as `nan`, so no epoch was ever the best. Look for a missing value in the inputs, or a learning rate so large that training diverged.
  / Very slow on a CPU: Lower the number of epochs only for a quick test. The lookback of 48 is the slowest run in the solution.
]

#labchecklists[
  #checklist[
    - The split follows the calendar, the scale comes from the training years only, and you can state which hour each row predicts.
    - All three free forecasts are computed and reported before the LSTM, on the same hours.
    - The kept epoch is chosen on validation, and the test period is opened once, at the end.
    - The largest errors are listed with their dates, and you can explain the top ones.
    - `models/electricity_lstm.pt` and its card, with the scale, are saved, and the reloaded model matches the one in memory.
  ]
]
