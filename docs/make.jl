using Documenter
using BuildkiteUtils

makedocs(
    sitename = "BuildkiteUtils",
    format = Documenter.HTML(),
    modules = [BuildkiteUtils]
)

Documenter.deploydocs(
    repo = "github.com/JuliaCI/BuildkiteUtils.jl.git",
    push_preview = true,
    devbranch = "main",
    forcepush = true,
)
