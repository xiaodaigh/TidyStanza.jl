using DataFrames
using DataConvenience: @>
using TidyStanza

# df <- tibble(a = 1, b = 1, c = 1, d = "a", e = "a", f = "a")

df = DataFrame(a = 1, b = 1, c = 1, d = "a", e = "a", f = "a")

# df %>% relocate(f)
@> df relocate(:f)

# df %>% relocate(a, .after = c)
@> df relocate(:a, after = :c)

# df %>% relocate(f, .before = b)
@> df relocate(:f, before = :b)

# df %>% relocate(a, .after = last_col())
@> df relocate(:a, after = names(df)[end])

last_col() = df->names(df)[end]

@> df relocate(:a, after = last_col())

middle_col() = df->names(df)[end ÷ 2]
@> df relocate(:a, after = middle_col())


using TidyStanza: where

# df %>% relocate(where(is.character))
isstring(x) = eltype(x) <: AbstractString

@> df relocate(where(isstring))

@> df relocate(where(x->eltype(x) <: AbstractString))


# df %>% relocate(where(is.numeric), .after = last_col())
isnumeric(x) = eltype(x) <: Number

@> df relocate(where(isnumeric), after = last_col())

# df %>% relocate(any_of(c("a", "e", "i", "o", "u")))
@> df relocate(intersect(["a", "e", "i", "o", "u"], names(df)))

any_of(cols::AbstractVector{T}) where T = df -> intersect(T.(names(df)), cols)

@> df relocate(any_of(["a", "e", "i", "o", "u"]))


#df2 <- tibble(a = 1, b = "a", c = 1, d = "a")

df2 = DataFrame(a = 1, b = "a", c = 1, d = "a")

#df2 %>% relocate(where(is.numeric), .after = where(is.character))

@> df2 relocate(where(isnumeric), after = where(isstring))


#df2 %>% relocate(where(is.numeric), .before = where(is.character))
@> df2 relocate(where(isnumeric), before = where(isstring))
