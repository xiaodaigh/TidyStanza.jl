# Weave readme
using Pkg
cd("c:/git/TidyStanza/")
Pkg.activate("c:/git/TidyStanza/readme-env")

using Weave

weave("README.jmd", out_path = :pwd, doctype = "github")

if false
    tangle("README.jmd")
end


using DataFrames
using DataFramesMeta
using DataConvenience

df = DataFrame(a = 1:3)

abc(fn, df) = fn(df)

x_thread = @> df begin
    x-> abc(x) do df
        print(df)
    end
end