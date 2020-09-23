export relocate, relocate!

relocate(df, args...; kwargs...) = relocate!(copy(df), args...; kwargs...)

function relocate!(df, w::Where; kwargs...)
    tmp = [w.fn(col) for col in eachcol(df)]

    cols = names(df)[tmp]

    relocate!(df, cols...; kwargs...)
end

function relocate!(df, f::Function; kwargs...)
    cols = f(df)

    relocate!(df, cols...; kwargs...)
end

function relocate!(df, cols...; before = nothing, after = nothing)
    if !isnothing(before) && !isnothing(after)
        error("before and after cannot both be populated")
    elseif isnothing(before) && isnothing(after)
        select!(df, cols..., :)
    elseif !isnothing(before)
        if before isa Function
            before_idx = columnindex(df, before(df))
        elseif before isa Where
            tmp = [before.fn(col) for col in eachcol(df)]
            where_cols = names(df)[tmp]
            before_idx = columnindex.(Ref(df), where_cols) |> minimum
        elseif before isa Symbol || before isa AbstractString
            before_idx = columnindex(df, before)
        end

        if cols isa Symbol || cols isa AbstractString
            cols_idx = columnindex(df, cols)
        else
            cols_names = reduce(vcat, names.(Ref(df), cols))
            cols_idx = columnindex.(Ref(df), cols_names)
        end
        select!(df, setdiff(1:before_idx-1, cols_idx), cols_idx, before_idx, :)
    elseif !isnothing(after)
        if after isa Function
            after_idx = columnindex(df, after(df))
        elseif after isa Where
            tmp = [after.fn(col) for col in eachcol(df)]
            where_cols = names(df)[tmp]
            after_idx = columnindex.(Ref(df), where_cols) |> maximum
        elseif after isa Symbol || after isa AbstractString
            after_idx = columnindex(df, after)
        end

        if cols isa Symbol || cols isa AbstractString
            cols_idx = columnindex(df, cols)
        else
            cols_names = reduce(vcat, names.(Ref(df), cols))
            cols_idx = columnindex.(Ref(df), cols_names)
        end

        select!(df, setdiff(1:after_idx, cols_idx), cols_idx, :)
    end
end

