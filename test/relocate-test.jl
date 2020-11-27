using DataFrames
using DataConvenience
using Chain: @chain
using TidyStanza

# df <- tibble(a = 1, b = 1, c = 1, d = "a", e = "a", f = "a")

df = DataFrame(a = 1, b = 1, c = 1, d = "a", e = "a", f = "a")

# df %>% relocate(f)
@chain df begin
     relocate(:f)
end

# df %>% relocate(a, .after = c)
@chain df begin
     relocate(:a, after = :c)
end

# df %>% relocate(f, .before = b)
@chain df begin
     relocate(:f, before = :b)
end

# df %>% relocate(a, .after = last_col())
@chain df begin
     relocate(:a, after = names(df)[end])
end

last_col() = df->names(df)[end]

@chain df begin
     relocate(:a, after = last_col())
end

middle_col() = df->names(df)[end ÷ 2]
@chain df begin
     relocate(:a, after = middle_col())
end


using TidyStanza: where

# df %>% relocate(where(is.character))
isstring(x) = eltype(x) <: AbstractString

@chain df begin
     relocate(where(isstring))
end

@chain df begin
     relocate(where(x->eltype(x) <: AbstractString))
end


# df %>% relocate(where(is.numeric), .after = last_col())
isnumeric(x) = eltype(x) <: Number

@chain df begin
     relocate(where(isnumeric), after = last_col())
end

# df %>% relocate(any_of(c("a", "e", "i", "o", "u")))
@chain df begin
     relocate(intersect(["a", "e", "i", "o", "u"], names(df)))
end

any_of(cols::AbstractVector{T}) where T = df -> intersect(T.(names(df)), cols)

@chain df begin
     relocate(any_of(["a", "e", "i", "o", "u"]))
end


#df2 <- tibble(a = 1, b = "a", c = 1, d = "a")

df2 = DataFrame(a = 1, b = "a", c = 1, d = "a")

#df2 %>% relocate(where(is.numeric), .after = where(is.character))

@chain df2 begin
     relocate(where(isnumeric), after = where(isstring))
end


#df2 %>% relocate(where(is.numeric), .before = where(is.character))
@chain df2 begin
     relocate(where(isnumeric), before = where(isstring))
end
