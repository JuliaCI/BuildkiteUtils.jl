using BuildkiteUtils, Test

@test success(`$(BuildkiteUtils.agent()) --version`)

@test isempty(keys(BuildkiteUtils.METADATA))

BuildkiteUtils.METADATA["aa"] = "hello"

@test keys(BuildkiteUtils.METADATA) == ["aa"]
@test BuildkiteUtils.METADATA["aa"] == "hello"

