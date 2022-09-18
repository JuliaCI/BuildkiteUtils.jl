# BuildkiteUtils.jl

[![Build status](https://badge.buildkite.com/3a8c508a09776602a246fffa420345a5fc493fb357f8508004.svg)](https://buildkite.com/julialang/buildkiteutils-dot-jl)

This is a collection of utility functions when running Julia jobs on [Buildkite](https://buildkite.com).

## Build meta-data

`BuilkiteUtils.METADATA` is a dict-like object for setting and getting [build meta-data](https://buildkite.com/docs/pipelines/build-meta-data)

```julia
BuilkiteUtils.METADATA["aa"] = "some data" # set
x = BuilkiteUtils.METADATA["aa"]           # get
haskey(BuilkiteUtils.METADATA, "aa")       # check if exists
keys(BuilkiteUtils.METADATA)               # list keys
```