struct Across
    innames
    fn
    outnames

    Across(innames, fn; names = nothing) = new(innames, fn, names)
end

across(args...; kwargs...) = Across(args...; kwargs...)
