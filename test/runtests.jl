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

        @test BuildkiteUtils.artifact_search("*") == []

        p = plot(identity, sin, -2pi, 2pi)
        dir = mktempdir()
        png(p, joinpath(dir, "sin x.png"))

        subdir = joinpath(dir, "extra")
        mkpath(subdir)
        write(joinpath(subdir, "hello.txt"), "hello world")

        cd(dir) do
            BuildkiteUtils.artifact_upload("*.png")
            BuildkiteUtils.artifact_upload("**.txt")
        end

        @test BuildkiteUtils.artifact_search() == ["sin x.png", "extra/hello.txt"]

        newdir = mktempdir()
        BuildkiteUtils.artifact_download("*.png", newdir)
        @test readdir(newdir) == ["sin x.png"]
        @test read(joinpath(dir, "sin x.png")) == read(joinpath(newdir, "sin x.png"))
    end


elseif stage == "stage2"



end
