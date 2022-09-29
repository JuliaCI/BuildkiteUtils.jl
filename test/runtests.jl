using BuildkiteUtils, Test

step = ENV["BUILDKITE_STEP_KEY"]

@test success(`$(BuildkiteUtils.agent()) --version`)

@testset "meta-data" begin
    if step == "linux-latest"
        @test keys(BuildkiteUtils.METADATA) == []
        @test !haskey(BuildkiteUtils.METADATA, "test-linux-latest")
    else
        @test "test-linux-latest" in keys(BuildkiteUtils.METADATA)
        @test haskey(BuildkiteUtils.METADATA, "test-linux-latest")
        @test BuildkiteUtils.METADATA["test-linux-latest"] == "hello"
    end

    BuildkiteUtils.METADATA["test-$step"] = "hello"

    if step == "linux-latest"
        @test keys(BuildkiteUtils.METADATA) == ["test-linux-latest"]
        @test haskey(BuildkiteUtils.METADATA, "test-linux-latest")
    else
        @test haskey(BuildkiteUtils.METADATA, "test-linux-latest")
        @test haskey(BuildkiteUtils.METADATA, "test-$step")
        @test "test-$step" in keys(BuildkiteUtils.METADATA)
    end

    @test BuildkiteUtils.METADATA["test-$step"] == "hello"
end

using Plots

@testset "artifact" begin
    dir = mktempdir()
    subdir = joinpath(dir, "extra")
    mkpath(subdir)
    write(joinpath(subdir, "step.txt"), step)

    if step == "linux-latest"

        @test BuildkiteUtils.artifact_search("*") == []

        p = plot(identity, sin, -2pi, 2pi)
        png(p, joinpath(dir, "sin x.png"))

        cd(dir) do
            BuildkiteUtils.artifact_upload("*.png")
            BuildkiteUtils.artifact_upload("**/*.txt")
        end

        @test sort(BuildkiteUtils.artifact_search()) == sort(["sin x.png", "extra/step.txt"])

        newdir = mktempdir()
        BuildkiteUtils.artifact_download("*.png", newdir; step=step)
        @test readdir(newdir) == ["sin x.png"]
        @test read(joinpath(dir, "sin x.png")) == read(joinpath(newdir, "sin x.png"))

    else

        @test sort(BuildkiteUtils.artifact_search(step="linux-latest")) == sort(["sin x.png", "extra/step.txt"])
        @test isempty(BuildkiteUtils.artifact_search(step=step))

        cd(dir) do
            BuildkiteUtils.artifact_upload("**/*.txt")
        end

        if step == "windows"
            @test BuildkiteUtils.artifact_search(step=step) == ["extra\\step.txt"]
        else
            @test BuildkiteUtils.artifact_search(step=step) == ["extra/step.txt"]
        end

        newdir = mktempdir()
        BuildkiteUtils.artifact_download("*.png", newdir; step="linux-latest")
        @test readdir(newdir) == ["sin x.png"]
    end
end

@testset "annotation" begin
    if step == "linux-latest"
        BuildkiteUtils.annotate("Hello from :linux:\n\n")
        BuildkiteUtils.annotate("""
        Success!

        <img src="artifact://sin x.png" alt="sin(x)" height=250 >
        """; style="success", context="xtra")

    elseif step == "linux-v1.6"
        BuildkiteUtils.annotate("and from :linux: v1.6\n\n"; append=true)
    elseif step == "windows"
        BuildkiteUtils.annotate("and from :windows:\n\n"; append=true)
    elseif step == "macos"
        BuildkiteUtils.annotate("and from :macos:\n\n"; append=true)
    end
end
