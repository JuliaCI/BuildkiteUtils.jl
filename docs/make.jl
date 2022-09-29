using Documenter
using BuildkiteUtils

makedocs(
    sitename = "BuildkiteUtils",
    format = Documenter.HTML(),
    modules = [BuildkiteUtils]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
