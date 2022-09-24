using BuildkiteUtils, Test

@test success(`$(BuildkiteUtils.agent()) --version`)

@testset "meta-data" begin
    @test isempty(keys(BuildkiteUtils.METADATA))

    BuildkiteUtils.METADATA["aa"] = "hello"

    @test keys(BuildkiteUtils.METADATA) == ["aa"]
    @test BuildkiteUtils.METADATA["aa"] == "hello"
end

using Plots

@testset "artifact" begin
    p = plot(sin, (-3,3))
    dir = mktempdir()
    png(p, joinpath(dir, "sin x.png"))

    cd(dir) do
        BuildkiteUtils.artifact_upload("*.png")
    end

    @show BuildkiteUtils.artifacts("*")
    sleep(1)
    @show BuildkiteUtils.artifacts("*")

    newdir = mktempdir()
    BuildkiteUtils.artifact_download("sin x.png", newdir; step=ENV["BUILDKITE_STEP_ID"])
    @test readdir(newdir) == ["sin x.png"]
    @test read(joinpath(dir, "sin x.png")) == read(joinpath(newdir, "sin x.png"))
end



