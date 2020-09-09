# Weave readme
using Pkg
cd("c:/git/Hadleyverse/")
Pkg.activate("c:/git/Hadleyverse/readme-env")

using Weave

weave("README.jmd", out_path = :pwd, doctype = "github")

if false
    tangle("README.jmd")
end
