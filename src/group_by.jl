export group_by

macro group_by(data, ex)
    @capture(ex, args__)
    esc(
        :(
            group_by($data)
        )
    )
end

function group_by(args...; kwargs...)
    @info "group_by: The equivalent function in DataFrames.jl is `groupby`"
    groupby(args...; kwargs...)
end


