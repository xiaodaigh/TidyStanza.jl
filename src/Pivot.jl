"""
    pivot_wider(df::AbstractDataFrame; names_from =  names_cols, values_from = values_cols)

A function to widen a data frame (i.e. unstack)  but in the framework of dplyr.
The reference page for the R function is [https://tidyr.tidyverse.org/reference/pivot_wider.html](https://tidyr.tidyverse.org/reference/pivot_wider.html)

# Examples
```
df = DataFrame(x = repeat(1:3,inner = 2,outer = 2),
       a = repeat(4:6,inner = 2,outer = 2),
       b = repeat(7:9,inner = 2,outer = 2),
       val1 = ["ce_val1_1","cf_val1_1","ce_val1_2","cf_val1_2","ce_val1_3","cf_val1_3","de_val1_1",
               "df_val1_1","de_val1_2","df_val1_2","de_val1_3","df_val1_3"],
       val2 = ["ce_val2_1","cf_val2_1","ce_val2_2","cf_val2_2","ce_val2_3","cf_val2_3","de_val2_1",
               "df_val2_1","de_val2_2","df_val2_2","de_val2_3","df_val2_3"],
       cname1 = repeat(["c", "d"], inner = 6),
       cname2 = repeat(["e", "f"], 6)
       )
```
12×7 DataFrame
│ Row │ x     │ a     │ b     │ val1      │ val2      │ cname1 │ cname2 │
│     │ Int64 │ Int64 │ Int64 │ String    │ String    │ String │ String │
├─────┼───────┼───────┼───────┼───────────┼───────────┼────────┼────────┤
│ 1   │ 1     │ 4     │ 7     │ ce_val1_1 │ ce_val2_1 │ c      │ e      │
│ 2   │ 1     │ 4     │ 7     │ cf_val1_1 │ cf_val2_1 │ c      │ f      │
│ 3   │ 2     │ 5     │ 8     │ ce_val1_2 │ ce_val2_2 │ c      │ e      │
│ 4   │ 2     │ 5     │ 8     │ cf_val1_2 │ cf_val2_2 │ c      │ f      │
│ 5   │ 3     │ 6     │ 9     │ ce_val1_3 │ ce_val2_3 │ c      │ e      │
│ 6   │ 3     │ 6     │ 9     │ cf_val1_3 │ cf_val2_3 │ c      │ f      │
│ 7   │ 1     │ 4     │ 7     │ de_val1_1 │ de_val2_1 │ d      │ e      │
│ 8   │ 1     │ 4     │ 7     │ df_val1_1 │ df_val2_1 │ d      │ f      │
│ 9   │ 2     │ 5     │ 8     │ de_val1_2 │ de_val2_2 │ d      │ e      │
│ 10  │ 2     │ 5     │ 8     │ df_val1_2 │ df_val2_2 │ d      │ f      │
│ 11  │ 3     │ 6     │ 9     │ de_val1_3 │ de_val2_3 │ d      │ e      │
│ 12  │ 3     │ 6     │ 9     │ df_val1_3 │ df_val2_3 │ d      │ f      │

```
pivot_wider(df; names_from = [:cname1,:cname2], values_from = [:val1,:val2])
```
3×11 DataFrame
│ Row │ x     │ a     │ b     │ val1_c_e  │ val1_c_f  │ val1_d_e  │ val1_d_f  │ val2_c_e  │ val2_c_f  │ val2_d_e  │ val2_d_f  │
│     │ Int64 │ Int64 │ Int64 │ String?   │ String?   │ String?   │ String?   │ String?   │ String?   │ String?   │ String?   │
├─────┼───────┼───────┼───────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────┤
│ 1   │ 1     │ 4     │ 7     │ ce_val1_1 │ cf_val1_1 │ de_val1_1 │ df_val1_1 │ ce_val2_1 │ cf_val2_1 │ de_val2_1 │ df_val2_1 │
│ 2   │ 2     │ 5     │ 8     │ ce_val1_2 │ cf_val1_2 │ de_val1_2 │ df_val1_2 │ ce_val2_2 │ cf_val2_2 │ de_val2_2 │ df_val2_2 │
│ 3   │ 3     │ 6     │ 9     │ ce_val1_3 │ cf_val1_3 │ de_val1_3 │ df_val1_3 │ ce_val2_3 │ cf_val2_3 │ de_val2_3 │ df_val2_3 │
"""
pivot_wider(
    df::AbstractDataFrame,
    names_from::Union{Symbol,<:AbstractString},
    values_from::Union{Symbol,<:AbstractString},
) = pivot_wider(df, [names_from], [values_from])

pivot_wider(
    df::AbstractDataFrame,
    names_from::Union{Symbol,<:AbstractString},
    values_from,
) = pivot_wider(df, [names_from], values_from)

pivot_wider(
    df::AbstractDataFrame,
    names_from,
    values_from::Union{Symbol,<:AbstractString},
) = pivot_wider(df, names_from, [values_from])


pivot_wider(
    df::AbstractDataFrame;
    names_from = error("Hadleyverse.pivot_wider: you must specify `names_from`"),
    values_from = error("Hadleyverse.pivot_wider: you must specify `values_from`"),
) = pivot_wider(df, names_from, values_from)


function pivot_wider(df::AbstractDataFrame, names_from, values_from)
    if eltype(names_from) == Symbol
        names_from = string.(names_from)
    end

    if eltype(values_from) == Symbol
        values_from = string.(values_from)
    end
    ## Defining id_cols as all columns other than names and values columns
    id_cols = setdiff(names(df), names_from, values_from)
    ## create key column if not present as unstack wont work without it.
    if length(id_cols)==0
        tmp_key = gensym()
        df[!, tmp_key] = 1:size(df,1)
        id_cols = tmp_key
    end


    # Concatenating multiple name columns with "_" and creating a single name column created with gensym
    tmp_name = gensym()
    df[!, tmp_name] = [join(Array(r), "_") for r in eachrow(select(df, names_from))]

    # Broadcast unstacking on all value columns
    wide_dfs = [unstack(df, id_cols, tmp_name, value, renamecols = x -> string(value)*"_"*x) for value in values_from]

    # remove created temporary column names in the dataset
    select!(df, Not(tmp_name))
    if @isdefined tmp_key
        select!(df, Not(tmp_key))
    end

    # check if there are multiple dataframes
    if length(wide_dfs) >= 2
        # remove all id columns for any other frame other than the first
        select!.(@view(wide_dfs[2:end]), Ref(Not(id_cols)))
        # concatenate all the dataframes horizontally
        res = hcat(wide_dfs..., makeunique = true)
    else
        res = wide_dfs[1]
    end

    # remove  key column if not in original dataframe
    if @isdefined tmp_key
        select!(res, Not(id_cols))
    else
        res
    end
end