module BuildkiteUtils

AGENT_BINARY = Ref{String}()
agent() = AGENT_BINARY[]

function __init__()
    AGENT_BINARY[] = joinpath(get(ENV, "BUILDKITE_BIN_PATH", ""), "buildkite-agent")
end

struct MetaDataDict <: AbstractDict{String, String}
end

const METADATA = MetaDataDict()

function Base.getindex(::MetaDataDict, key::String)
    read(`$(agent()) meta-data get $key`, String)
end
function Base.setindex!(::MetaDataDict, value, key::String)
    run(pipeline(`$(agent()) meta-data set $key`, stdin=IOBuffer(string(value))))
end
function Base.haskey(::MetaDataDict, key::String)
    success(`$(agent()) meta-data exists $key`)
end
function Base.keys(::MetaDataDict)
    readlines(`$(agent()) meta-data keys`)
end


end # module BuildkiteUtils
