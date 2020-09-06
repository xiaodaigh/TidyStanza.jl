## Hadleyverse

Trying to implement {tidyverse}, including {dplyr}, APIs in Julia

Currently, only `dplyr::across` is implemented

### Examples:

#### `Dply.Across` and `Dply.Where`

* `Dply.Across` and `Dply.across` are synonyms and have the same API as `dplyr::across`
* `Dply.Where` and `Dply.where` are synonyms and have the same API as `dplyr::across(where(...), ...)`

By default, they are NOT exported, and the recommended way is to use `Dply.across` and `Dply.where`
to refer to them. However, in the examples below, for brevity, I have imported `across` and `where`
directly into the namespace.

````julia

using Dply: across, where


### load some helper packages
using DataFrames
using Statistics # for using mean
using Pipe: @pipe # for @pipe macro
using RDatasets # for iris dataset

iris = dataset("datasets", "iris");

# a glimpse of the data
first(iris, 8)
````


````
8×5 DataFrame
│ Row │ SepalLength │ SepalWidth │ PetalLength │ PetalWidth │ Species │
│     │ Float64     │ Float64    │ Float64     │ Float64    │ Cat…    │
├─────┼─────────────┼────────────┼─────────────┼────────────┼─────────┤
│ 1   │ 5.1         │ 3.5        │ 1.4         │ 0.2        │ setosa  │
│ 2   │ 4.9         │ 3.0        │ 1.4         │ 0.2        │ setosa  │
│ 3   │ 4.7         │ 3.2        │ 1.3         │ 0.2        │ setosa  │
│ 4   │ 4.6         │ 3.1        │ 1.5         │ 0.2        │ setosa  │
│ 5   │ 5.0         │ 3.6        │ 1.4         │ 0.2        │ setosa  │
│ 6   │ 5.4         │ 3.9        │ 1.7         │ 0.4        │ setosa  │
│ 7   │ 4.6         │ 3.4        │ 1.4         │ 0.3        │ setosa  │
│ 8   │ 5.0         │ 3.4        │ 1.5         │ 0.2        │ setosa  │
````



````julia

# R"""
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), mean))
# """

@pipe iris |>
  groupby(_, :Species) |>
  combine(_, across(startswith("Sepal"), mean))
````


````
3×3 DataFrame
│ Row │ Species    │ SepalLength │ SepalWidth │
│     │ Cat…       │ Float64     │ Float64    │
├─────┼────────────┼─────────────┼────────────┤
│ 1   │ setosa     │ 5.006       │ 3.428      │
│ 2   │ versicolor │ 5.936       │ 2.77       │
│ 3   │ virginica  │ 6.588       │ 2.974      │
````



````julia

# R"""
# iris %>%
    # as_tibble() %>%
    # mutate(across(where(is.factor), as.character))
# """

# define a convenience function for checking if column is categorical
iscatarray(arr) = typeof(arr) <: CategoricalArray

@pipe iris |>
  transform(_, across(where(iscatarray), Vector{String})) |>
  first(_, 8)

@pipe iris |>
  transform(_, across(where(iscatarray), col->string.(col))) |>
  first(_, 8)
````


````
8×5 DataFrame
│ Row │ SepalLength │ SepalWidth │ PetalLength │ PetalWidth │ Species │
│     │ Float64     │ Float64    │ Float64     │ Float64    │ String  │
├─────┼─────────────┼────────────┼─────────────┼────────────┼─────────┤
│ 1   │ 5.1         │ 3.5        │ 1.4         │ 0.2        │ setosa  │
│ 2   │ 4.9         │ 3.0        │ 1.4         │ 0.2        │ setosa  │
│ 3   │ 4.7         │ 3.2        │ 1.3         │ 0.2        │ setosa  │
│ 4   │ 4.6         │ 3.1        │ 1.5         │ 0.2        │ setosa  │
│ 5   │ 5.0         │ 3.6        │ 1.4         │ 0.2        │ setosa  │
│ 6   │ 5.4         │ 3.9        │ 1.7         │ 0.4        │ setosa  │
│ 7   │ 4.6         │ 3.4        │ 1.4         │ 0.3        │ setosa  │
│ 8   │ 5.0         │ 3.4        │ 1.5         │ 0.2        │ setosa  │
````



````julia

# A purrr-style formula
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), ~mean(.x, na.rm = TRUE)))
@pipe iris |>
  groupby(_, :Species) |>
  combine(_, across(startswith("Sepal"), x->mean(x |> skipmissing)))
````


````
3×3 DataFrame
│ Row │ Species    │ SepalLength │ SepalWidth │
│     │ Cat…       │ Float64     │ Float64    │
├─────┼────────────┼─────────────┼────────────┤
│ 1   │ setosa     │ 5.006       │ 3.428      │
│ 2   │ versicolor │ 5.936       │ 2.77       │
│ 3   │ virginica  │ 6.588       │ 2.974      │
````



````julia

# A named list of functions
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), list(mean = mean, sd = sd)))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, across(startswith("Sepal"), (mean, std)))
````


````
3×5 DataFrame. Omitted printing of 1 columns
│ Row │ Species    │ SepalLength_mean │ SepalWidth_mean │ SepalLength_std │
│     │ Cat…       │ Float64          │ Float64         │ Float64         │
├─────┼────────────┼──────────────────┼─────────────────┼─────────────────┤
│ 1   │ setosa     │ 5.006            │ 3.428           │ 0.35249         │
│ 2   │ versicolor │ 5.936            │ 2.77            │ 0.516171        │
│ 3   │ virginica  │ 6.588            │ 2.974           │ 0.63588         │
````



````julia

# Use the .names argument to control the output names
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), mean, .names = "mean_{col}"))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, across(startswith("Sepal"), mean; names = "mean_{col}"))
````


````
3×3 DataFrame
│ Row │ Species    │ mean_SepalLength │ mean_SepalWidth │
│     │ Cat…       │ Float64          │ Float64         │
├─────┼────────────┼──────────────────┼─────────────────┤
│ 1   │ setosa     │ 5.006            │ 3.428           │
│ 2   │ versicolor │ 5.936            │ 2.77            │
│ 3   │ virginica  │ 6.588            │ 2.974           │
````



````julia

# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), list(mean = mean, sd = sd), .names = "{col}_{fn}"))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, across(startswith("Sepal"), (mean = mean, std = std); names = "{col}_{fn}"))
````


````
3×5 DataFrame. Omitted printing of 1 columns
│ Row │ Species    │ SepalLength_mean │ SepalWidth_mean │ SepalLength_std │
│     │ Cat…       │ Float64          │ Float64         │ Float64         │
├─────┼────────────┼──────────────────┼─────────────────┼─────────────────┤
│ 1   │ setosa     │ 5.006            │ 3.428           │ 0.35249         │
│ 2   │ versicolor │ 5.936            │ 2.77            │ 0.516171        │
│ 3   │ virginica  │ 6.588            │ 2.974           │ 0.63588         │
````



````julia

# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), list(mean, sd), .names = "{col}.fn{fn}"))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, across(startswith("Sepal"), (mean, std); names = "{col}_fn{fn}"))
````


````
3×5 DataFrame. Omitted printing of 1 columns
│ Row │ Species    │ SepalLength_fn1 │ SepalWidth_fn1 │ SepalLength_fn2 │
│     │ Cat…       │ Float64         │ Float64        │ Float64         │
├─────┼────────────┼─────────────────┼────────────────┼─────────────────┤
│ 1   │ setosa     │ 5.006           │ 3.428          │ 0.35249         │
│ 2   │ versicolor │ 5.936           │ 2.77           │ 0.516171        │
│ 3   │ virginica  │ 6.588           │ 2.974          │ 0.63588         │
````


