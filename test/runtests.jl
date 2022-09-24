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
    png(p, joinpath(dir, "sinx.png"))

    cd(dir) do
        BuildkiteUtils.artifact_upload("*.png")
    end

    newdir = mktempdir()
    BuildkiteUtils.artifact_download("*.png", newdir)
    @test readdir(newdir) == ["sinx.png"]
    @test read(joinpath(dir, "sinx.png")) == read(joinpath(newdir, "sinx.png"))
end



