"""
unstack_name(df::AbstractDataFrame, rowkeys, colkey, value)

A helper function for unstack to name the columns being unstacked using the column name the values are present in.
"""
function unstack_name(df::AbstractDataFrame, rowkeys, colkey, value)
    unstack(df::AbstractDataFrame, rowkeys, colkey, value, renamecols = x -> Symbol(string(value), "_", x))
end



"""
pivot_wider(df::AbstractDataFrame; names_from =  names_cols, values_from = values_cols)

A function to widen a data frame (e.g. unstack)  but in the frameowrk of dplyr.


# Examples
```
df = DataFrame(x = repeat(1:3,inner = 2,outer = 2),
       a = repeat(4:6,inner = 2,outer = 2),
       b = repeat(7:9,inner = 2,outer = 2),
       val1 = ["ce_val1_1","cf_val1_1","ce_val1_2","cf_val1_2","ce_val1_3","cf_val1_3","de_val1_1","df_val1_1","de_val1_2","df_val1_2","de_val1_3","df_val1_3"], 
       val2 = ["ce_val2_1","cf_val2_1","ce_val2_2","cf_val2_2","ce_val2_3","cf_val2_3","de_val2_1","df_val2_1","de_val2_2","df_val2_2","de_val2_3","df_val2_3"], 
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
pivot_wider(df, names_from = [:cname1,:cname2], values_from = [:val1,:val2])
```
3×11 DataFrame
│ Row │ x     │ a     │ b     │ val1_c_e  │ val1_c_f  │ val1_d_e  │ val1_d_f  │ val2_c_e  │ val2_c_f  │ val2_d_e  │ val2_d_f  │
│     │ Int64 │ Int64 │ Int64 │ String?   │ String?   │ String?   │ String?   │ String?   │ String?   │ String?   │ String?   │
├─────┼───────┼───────┼───────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────┤
│ 1   │ 1     │ 4     │ 7     │ ce_val1_1 │ cf_val1_1 │ de_val1_1 │ df_val1_1 │ ce_val2_1 │ cf_val2_1 │ de_val2_1 │ df_val2_1 │
│ 2   │ 2     │ 5     │ 8     │ ce_val1_2 │ cf_val1_2 │ de_val1_2 │ df_val1_2 │ ce_val2_2 │ cf_val2_2 │ de_val2_2 │ df_val2_2 │
│ 3   │ 3     │ 6     │ 9     │ ce_val1_3 │ cf_val1_3 │ de_val1_3 │ df_val1_3 │ ce_val2_3 │ cf_val2_3 │ de_val2_3 │ df_val2_3 │
"""
function pivot_wider(df::AbstractDataFrame; names_from = nothing, values_from = nothing)
 if names_from isa Symbol
    names_from = [names_from]
 end
 if values_from isa Symbol
    values_from = [values_from]
 end
    id_cols = setdiff(Symbol.(names(df)), names_from, values_from)
    dfa = select(df, :)
    dfa[!,:cname_temp] = [join(Array(r), "_") for r in eachrow(select(dfa, names_from))]
    dfb = unstack_name.(Ref(dfa), Ref(id_cols), Ref(:cname_temp), values_from)
    id1 = select(dfb[1], id_cols)
    select!.(dfb, Ref(Not(id_cols)))
    hcat(id1, reduce((df1, df2) -> hcat(df1, df2, makeunique = true), dfb))
end