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

plotly()

@testset "artifact" begin
    dir = mktempdir()
    subdir = joinpath(dir, "extra")
    mkpath(subdir)
    write(joinpath(subdir, "step.txt"), step)

    if step == "linux-latest"

        @test BuildkiteUtils.artifact_search("*") == []
        X = range(-2pi,2pi,length=30)
        p = plot(X, sin.(X))

        savefig(p, joinpath(dir, "sin x.html"))
        savefig(p, joinpath(dir, "sin x.svg"))

        cd(dir) do
            BuildkiteUtils.artifact_upload("*.svg")
            BuildkiteUtils.artifact_upload("*.html")
            BuildkiteUtils.artifact_upload("**/*.txt")
        end

        @test sort(BuildkiteUtils.artifact_search()) == sort(["sin x.html", "sin x.svg", "extra/step.txt"])

        newdir = mktempdir()
        BuildkiteUtils.artifact_download("*.svg", newdir; step=step)
        @test readdir(newdir) == ["sin x.svg"]
        @test read(joinpath(dir, "sin x.svg")) == read(joinpath(newdir, "sin x.svg"))

    else

        @test sort(BuildkiteUtils.artifact_search(step="linux-latest")) == sort(["sin x.html", "sin x.svg", "extra/step.txt"])
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
        BuildkiteUtils.artifact_download("*.svg", newdir; step="linux-latest")
        @test readdir(newdir) == ["sin x.svg"]
    end
end

@testset "annotation" begin
    if step == "linux-latest"
        BuildkiteUtils.annotate("Hello from :linux:\n\n")
        BuildkiteUtils.annotate("""
        Success!

         <a href="artifact://sin x.html"><img src="artifact://sin x.svg" alt="sin(x)" height=250 ></a>
        """; style="success", context="xtra")

    elseif step == "linux-v1.6"
        BuildkiteUtils.annotate("and from :linux: v1.6\n\n"; append=true)
    elseif step == "windows"
        BuildkiteUtils.annotate("and from :windows:\n\n"; append=true)
    elseif step == "macos"
        BuildkiteUtils.annotate("and from :macos:\n\n"; append=true)
    end
end
