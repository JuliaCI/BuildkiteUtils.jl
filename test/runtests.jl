using BuildkiteUtils, Test

stage = get(ENV,"BUILDKITE_STEP_KEY","stage1")

@test success(`$(BuildkiteUtils.agent()) --version`)

if stage == "stage1"

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
    end


elseif stage == "stage2"

    newdir = mktempdir()
    BuildkiteUtils.artifact_download("*", newdir; step="stage1")
    @test readdir(newdir) == ["sinx.png"]
    @test read(joinpath(dir, "sinx.png")) == read(joinpath(newdir, "sinx.png"))


end
