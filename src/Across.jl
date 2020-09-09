struct Where
    fn::Any
end

where(args...; kwargs...) = Where(args...; kwargs...)

struct Across
    innames::Any
    fn::Any
    outnames::Any

    Across(innames, fn::AbstractVector; names = nothing) = new(innames, fn, names)
    Across(innames, fn::Tuple; names = nothing) = new(innames, fn, names)
    Across(innames, fn::NamedTuple; names = nothing) = new(innames, fn, names)
    Across(innames, fn; names = "{col}") = new(innames, (fn,), names)

end

across(args...; kwargs...) = Across(args...; kwargs...)
