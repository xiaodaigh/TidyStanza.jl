export relocate

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
        if before isa Where
            tmp = [before.fn(col) for col in eachcol(df)]
            where_cols = names(df)[tmp]
            before_idx = columnindex.(Ref(df), where_cols) |> minimum
        else
            before_idx = columnindex(df, before)
        end

        cols_idx = columnindex.(Ref(df), cols)
        select!(df, setdiff(1:before_idx-1, cols_idx), cols..., before_idx, :)
    elseif !isnothing(after)
        if after isa Function
            after_idx = columnindex(df, after(df))
        elseif after isa Where
            tmp = [after.fn(col) for col in eachcol(df)]
            where_cols = names(df)[tmp]
            after_idx = columnindex.(Ref(df), where_cols) |> maximum
        else
            after_idx = columnindex(df, after)
        end
        cols_idx = columnindex.(Ref(df), cols)

        select!(df, setdiff(1:after_idx, cols_idx), cols..., :)
    end
end

