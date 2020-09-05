module Dply

export combine

include("Across.jl") # defines the Across type

using DataFrames

import DataFrames: combine

function DataFrames.combine(df, da::Across)
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


end
