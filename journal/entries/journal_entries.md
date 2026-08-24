## Journal Entry: Understanding Time Series Cross-Validation

While working through the course notes on model validation, I got stuck on the three cross-validation strategies (walk-forward, expanding window, sliding window). My confusion was conceptual: I couldn't see how you could "validate" on a data point if that point had to be forecasted first — it felt circular, like the model was being checked against its own prediction.

Working through this with Claude cleared it up. The key realisation is that the validation point is never a forecasted value fed back into the model. It is always a **real, already-observed** data point that is temporarily withheld from training. The model is fit only on the data before that point, produces a forecast for it, and that forecast is then compared against the actual observed value to get an error.

We worked through a concrete example to make this stick: 100 data points, an initial training size of 70, leaving 30 possible origins. For each strategy, the origin moves forward one step at a time, but the strategies differ in how the training window behaves as it does:

- **Walk-forward**: the model re-estimates at each new origin using all data up to that point, then forecasts one step ahead.
- **Expanding window**: similar to walk-forward, but the training set grows to include all history up to the current origin (window start is fixed, end grows).
- **Sliding window**: the training set is a fixed-size window that slides forward, dropping older observations as new ones are added.

The other thing I clarified was how this fits into model *comparison*. It's easy to conflate "30 origins" with "30 different models," but they're separate loops:

1. For a single candidate model, fit it once at each of the 30 origins, producing 30 errors, which are averaged into one CV score for that model.
2. Repeat this entire process for each other candidate model under consideration.
3. Compare the averaged scores across models and select the one with the lowest error.

So the validation strategy itself is chosen once, up front, based on the nature of the data (e.g. whether it has structural breaks), and then applied consistently across all candidate models — it isn't something you also search over.

**Takeaway:** cross-validation in a time series context is really just an adaptation of the "train on the past, test on the future" rule, repeated across many origins to get a stable estimate of a model's out-of-sample accuracy, rather than a single potentially lucky/unlucky train-test split.

---

## Journal Entry: Practical 1 — Fitting Time Series Objects to S&P 500 Data

For this practical I replicated the Base R `ts()` workflow from the class slides and then applied it to a real dataset: daily closing prices from the S&P 500 dataset, filtered down to AAPL for 2019 (~252 trading days).

**Base R fundamentals.** I worked through `window()` for subsetting a series by time period, `diff()` for differencing, and `lag()` for shifting a series. The `lag()` function exposed a subtlety I hadn't appreciated: lagged and original series don't automatically align by their time index when combined naively, so `ts.union()` is needed to properly align them into a common matrix before comparison or plotting — otherwise you can silently end up comparing the wrong pairs of observations. I also compared `plot.ts()` against the generic `plot()` for `ts` objects, and used `decompose()` to split the AAPL series into trend, seasonal, and remainder components, noting its known limitation: it struggles with edge effects at the start and end of the series because of how the moving average it relies on is computed.

**Applying this to real data.** Once I moved from the toy examples to the actual AAPL 2019 data, I built both a Base R `ts` object (with `frequency = 252` to reflect trading days) and a `tsibble` version for use with `feasts`.

This is where I hit a real problem: calling `ACF()` on the tsibble threw an "implicit gaps" error. The cause was that the tsibble was indexed by calendar `date`, so weekends and holidays were being interpreted as missing observations even though the series was never meant to include them. The fix was to re-index the tsibble using an integer-based `trading_day` column (from `row_number()`) instead of the calendar date, while keeping `date` as an ordinary column so it could still be used for plotting. This resolved the gap error and let `ACF()` and related `feasts` functions run correctly.

That fix introduced a second problem: once the index was `trading_day` rather than `date`, the default `autoplot()` output no longer showed meaningful calendar labels on the x-axis. I addressed this by rebuilding the plots manually in `ggplot2` — joining a `trading_day` → `date` lookup table onto the `components()` output from STL, and using `scale_x_date()` and `facet_grid()` to reproduce the multi-panel STL decomposition plot with proper monthly date labels, matching the layout style from the class slides.

I only got as far as covering Section 6 (`tsibble`/`feasts`/`timetk`) conceptually, since the sandbox environment I was working in couldn't reach CRAN to install the tidyverts packages — I'll need to run that section locally to complete it hands-on.

**Takeaway:** the practical reinforced that `ts` and `tsibble` objects handle time indexing very differently, and that this difference isn't cosmetic — it directly affects which functions (like `ACF()`) will even run. STL also came out as the more robust alternative to `decompose()` for series where the edges of the sample matter, which they do here given the dataset only spans a single year.

---

## Journal Entry: Lecture — AR, MA, ACF/PACF Identification, and ARIMA (Slides 80–125)

Today's lecture covered slides 80 to 125, moving from the individual building blocks of MA and AR models through to how they combine into ARIMA.

**AR vs MA — what each model is built on.** The core distinction is *what* each model regresses on. An AR(p) model expresses the current value as a function of its own **past values** (lagged $y$), while an MA(q) model expresses the current value as a function of **past forecast errors** (lagged $\varepsilon$), not lagged data directly. This is a distinction I hadn't fully separated in my head before — it's easy to see both as "using past information" without registering that one uses realised observations and the other uses the shocks that couldn't be explained by the model.

**Identifying which model fits — ACF and PACF.** The lecture then covered how to read the ACF and PACF plots to identify which model form is appropriate, summarised in the identification table:

| Process | ACF | PACF |
|---|---|---|
| White noise | No significant spikes | No significant spikes |
| AR(p) | Decays gradually | Cuts off after lag p |
| MA(q) | Cuts off after lag q | Decays gradually |
| ARMA(p, q) | Decays gradually | Decays gradually |

The intuition behind the AR case is that the PACF strips out the indirect correlation carried through intervening lags — for an AR(1) process, $y_t$ only depends directly on $y_{t-1}$, so the PACF has a sharp cutoff after lag 1 even though the ACF decays gradually (since $y_t$ is still indirectly related to $y_{t-2}, y_{t-3}, \dots$ through the chain of dependence). MA behaves as the mirror image of this, because an MA(q) process only has direct dependence for q lags, giving a sharp ACF cutoff, while the PACF decays gradually. As I noted, picking an AR model requires the ACF decay + PACF spike pattern to line up, and MA requires the reverse — the two diagnostics have to agree with each other, not just individually look like one shape or another. The lecture was clear that this table is a guide rather than a hard rule, since sample ACFs are noisy and the final model choice also depends on information criteria and residual diagnostics.

**Combining into ARMA and then ARIMA.** Many real series show both patterns simultaneously — persistence from past values *and* short-lived shocks — which is what ARMA is built to capture, combining the AR and MA structures into one model. The lecture noted that an ARMA process doesn't show either "pure" signature on its ACF/PACF (both decay gradually), so identifying an ARMA model needs the two correlograms together with AIC/BIC and diagnostic checks, not just a visual read.

ARIMA then extends ARMA by adding **differencing** to handle non-stationary series. The order $d$ specifies how many times the series is differenced before the ARMA(p,q) structure is fitted, written as $\phi(L)(1-L)^d y_t = c + \theta(L)\varepsilon_t$. The effect of differencing is to remove trend: for a series with a deterministic linear trend, one difference leaves just a constant plus noise, and for a random walk, one difference leaves pure white noise. This matches what I understood from the lecture — differencing is the mechanism that lets ARIMA handle series ARMA alone couldn't, by removing the trend first so the remaining series is stationary enough for the AR/MA machinery to apply.

**What I want to keep in mind:** it's tempting to over-difference in search of stationarity, but the notes flag that this is detectable — an over-differenced series shows inflated variance and a first-lag autocorrelation near -0.5, so if differencing makes the variance go *up* rather than down, that's a sign of having gone one step too far.

**Takeaway:** today connected the ACF/PACF diagnostics directly to model choice for the first time — rather than treating them as abstract plots, they're now a genuine identification tool, and ARIMA makes sense as "ARMA plus a pre-processing step for non-stationarity" rather than a separate model entirely.