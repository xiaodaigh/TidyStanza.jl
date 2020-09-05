using DataFrames
using Statistics # for using mean
using Pipe: @pipe # for @pipe macro
using RDatasets # for iris dataset

iris = dataset("datasets", "iris")


# R"""
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), mean))
# """

@pipe iris |>
  groupby(_, :Species) |>
  summarize(_, filter(startswith("Sepal"), names(_)))


# R"""
# iris %>%
    # as_tibble() %>%
    # mutate(across(where(is.factor), as.character))
# """

typeof.(eachcol(iris)) .<: CategoricalArray
n = names(iris)[typeof.(eachcol(iris)) .<: CategoricalArray]

@pipe iris |>
  transform(_, n .=> (col->string.(col)) .=> n)

# A purrr-style formula
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), ~mean(.x, na.rm = TRUE)))
@pipe iris |>
  groupby(_, :Species) |>
  combine(_, filter(startswith("Sepal"), names(_)) .=> x->mean(x |> skipmissing) )


# A named list of functions
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), list(mean = mean, sd = sd)))

# this doesn't work
@pipe iris |>
  groupby(_, :Species) |>
  combine(_, filter(startswith("Sepal"), names(iris)) .=> [mean, std])

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, [name=>fn for name in filter(startswith("Sepal"), names(_)), fn in [mean, std]]...)

function across(names, fns)
    [name => fn for name in names, fn in fns]
end

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, across(filter(startswith("Sepal"), names(_)), [mean, std])...)

struct DplyrAcross
    innames
    fn
    outnames
end

DplyrAcross(innames, fn) = DplyrAcross(innames, fn, nothing)

import DataFrames.combine

function DataFrames.combine(df, da::DplyrAcross)
    input_cols = filter(da.innames, names(df))

    if isnothing(da.outnames)
        pairs = [col => fn for col in input_cols, fn in da.fn]
        return combine(df,  pairs...)
    else
        error("not implemented yet")
    end
end

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, DplyrAcross(startswith("Sepal"), [mean, std]))


# Use the .names argument to control the output names
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), mean, .names = "mean_{col}"))


DplyrAcross(innames, fn; names = nothing) = DplyrAcross(innames, fn, names)

function DataFrames.combine(df, da::DplyrAcross)
    input_cols = filter(da.innames, names(df))

    if isnothing(da.outnames)
        pairs = [col => fn for col in input_cols, fn in da.fn]
        return combine(df,  pairs...)
    else
        outcols = [
            replace(
                replace(da.outnames, "{col}" => col),
                "{fn}" => string(fn)
            )
             for col in input_cols, fn in keys(da.fn)]

        in_fn_out_iterator = zip(Iterators.product(input_cols, da.fn), outcols)

        pairs = [col => fn => outcol for ((col, fn), outcol) in in_fn_out_iterator]

        return combine(df,  pairs...)
    end
end

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, DplyrAcross(startswith("Sepal"), [mean]; names = "mean_{col}"))

# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), list(mean = mean, sd = sd), .names = "{col}.{fn}"))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, DplyrAcross(startswith("Sepal"), (mean = mean, std = std); names = "{col}.{fn}"))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, DplyrAcross(startswith("Sepal"), (mean = mean, std = std); names = "{col}_{fn}"))

# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), list(mean, sd), .names = "{col}.fn{fn}"))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, DplyrAcross(startswith("Sepal"), [mean, std]; names = "{col}_fn{fn}"))


using Dply

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, Dply.Across(startswith("Sepal"), (mean, std); names = "{col}_fn{fn}"))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, Dply.across(startswith("Sepal"), (mean = mean, std=std); names = "{col}_fn_{fn}"))
