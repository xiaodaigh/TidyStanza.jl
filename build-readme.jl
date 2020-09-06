# Weave readme
using Pkg
cd("c:/git/Dply/")
Pkg.activate("c:/git/Dply/readme-env")

using Weave

weave("README.jmd", out_path=:pwd, doctype="github")

if false
    tangle("README.jmd")
end
