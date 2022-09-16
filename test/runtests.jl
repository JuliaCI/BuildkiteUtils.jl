using BuildkiteUtils

@show BuildkiteUtils.agent()

@show keys(BuildkiteUtils.METADATA)
BuildkiteUtils.METADATA["aa"] = "hello"

@show keys(BuildkiteUtils.METADATA)
@show BuildkiteUtils.METADATA["aa"]
