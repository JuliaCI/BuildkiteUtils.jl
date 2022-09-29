module BuildkiteUtils

AGENT_BINARY = Ref{String}()
agent() = AGENT_BINARY[]

function __init__()
    AGENT_BINARY[] = joinpath(get(ENV, "BUILDKITE_BIN_PATH", ""), "buildkite-agent")
end

# meta-data dictionary
struct MetaDataDict <: AbstractDict{String, String}
end

"""
    BuildkiteUtils.METADATA

A dict-like object for setting and getting [build
meta-data](https://buildkite.com/docs/pipelines/build-meta-data)

```
x = BuildkiteUtils.METADATA[key]   # get meta-data
BuildkiteUtils.METADATA[key] = val # set meta-data
keys(BuildkiteUtils.METADATA)      # list of meta-data keys
haskey(BuildkiteUtils.METADATA)    # check if key exists
"""
const METADATA = MetaDataDict()

function Base.getindex(::MetaDataDict, key::AbstractString)
    read(`$(agent()) meta-data get $key`, String)
end
function Base.get(::MetaDataDict, key::AbstractString, default::AbstractString)
    read(`$(agent()) meta-data get $key --default $default`, String)
end
function Base.setindex!(::MetaDataDict, value, key::AbstractString)
    run(pipeline(`$(agent()) meta-data set $key`, stdin=IOBuffer(string(value))))
end
function Base.haskey(::MetaDataDict, key::AbstractString)
    success(`$(agent()) meta-data exists $key`)
end
function Base.keys(::MetaDataDict)
    readlines(`$(agent()) meta-data keys`)
end


# artifact
"""
    BuildkiteUtils.artifact_upload(pattern::AbstractString)

Upload all artifacts in the current directory matching `pattern`.

See [Uploading artifacts](https://buildkite.com/docs/agent/v3/cli-artifact#uploading-artifacts).
"""
function artifact_upload(pattern::AbstractString)
    run(`$(agent()) artifact upload $pattern`)
end

"""
    BuildkiteUtils.artifact_search(pattern::AbstractString; [step,] [build])

List all uploaded artifacts matching `pattern`.

Optional keyword arguments
 - `step` will limit to artifacts in a given `step` (either the key or the step
ID),
 - `build` allows downloading artifact from a given build ID.

"""
function artifact_search(pattern::AbstractString="*"; step=nothing, build=nothing)
    format = "%p\n"
    cmd = `$(agent()) artifact search  --format $format`
    if !isnothing(step)
        cmd = `$cmd --step $step`
    end
    if !isnothing(build)
        cmd = `$cmd --build $build`
    end
    cmd = `$cmd $pattern`
    readlines(ignorestatus(cmd))
end

"""
    BuildkiteUtils.artifact_download(pattern::AbstractString, destination::AbstractString=".";
       [step,] [build])

Download all artifacts matching `pattern` to `destination`.

Optional keyword arguments
 - `step` will limit to artifacts in a given `step` (either the key or the step
ID),
 - `build` allows downloading artifact from a given build ID.

"""
function artifact_download(pattern::AbstractString, destination::AbstractString="."; step=nothing, build=nothing)
    cmd = `$(agent()) artifact download`
    if !isnothing(step)
        cmd = `$cmd --step $step`
    end
    if !isnothing(build)
        cmd = `$cmd --build $build`
    end
    cmd = `$cmd $pattern $destination`
    run(cmd)
end

# annotation
"""
    BuildkiteUtils.annotate(data; context=nothing, style=nothing, append=false)

Annotates the current build with `data`: this is a Markdown-formatted string.

- `context`: a unique identifier for a given annotation. The default will use
  the default context.
- `style`: one of
  - `nothing` (default style)
  - `"success"`
  - `"info"`
  - `"warning"`
  - `"error"`
- `append`: if `true`, will add to the existing annotation with the same
  context, otherwise will replace it.

See [`buildkite-agent annotate`](https://buildkite.com/docs/agent/v3/cli-annotate) for more information.
"""
function annotate(data; context=nothing, style=nothing, append=false)
    cmd = `$(agent()) annotate`
    if !isnothing(context)
        cmd = `$cmd --context $context`
    end
    if !isnothing(style)
        cmd = `$cmd --style $style`
    end
    if append
        cmd = `$cmd --append`
    end
    run(pipeline(cmd, stdin=IOBuffer(string(data))))
end


end # module BuildkiteUtils
