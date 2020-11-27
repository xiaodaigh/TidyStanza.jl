# Weave readme
using Pkg
cd("c:/git/TidyStanza/")
Pkg.activate("c:/git/TidyStanza/readme-env")
Pkg.update()
upcheck()

using Weave

weave("README.jmd", out_path = :pwd, doctype = "github")

if false
    tangle("README.jmd")
end
