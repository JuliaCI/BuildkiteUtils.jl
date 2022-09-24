module BuildkiteUtils

AGENT_BINARY = Ref{String}()
agent() = AGENT_BINARY[]

function __init__()
    AGENT_BINARY[] = joinpath(get(ENV, "BUILDKITE_BIN_PATH", ""), "buildkite-agent")
end


# meta-data dictionary
struct MetaDataDict <: AbstractDict{String, String}
end
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

function artifact_upload(pattern::AbstractString)
    run(`$(agent()) artifact upload $pattern`)
end

function artifacts(pattern::AbstractString)
    readlines(`$(agent()) artifact search $pattern`)
end

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
