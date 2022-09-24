using BuildkiteUtils, Test

step = ENV["BUILDKITE_STEP_KEY"]

@test success(`$(BuildkiteUtils.agent()) --version`)

@testset "meta-data" begin
    if step == "linux"
        @test keys(BuildkiteUtils.METADATA) == []
    elseif step == "windows"
        @test keys(BuildkiteUtils.METADATA) == ["aa-linux"]
        @test BuildkiteUtils.METADATA["aa-linux"] == "hello"
    end

    BuildkiteUtils.METADATA["aa-$step"] = "hello"

    if step == "linux"
        @test keys(BuildkiteUtils.METADATA) == ["aa-linux"]
    elseif step == "windows"
        @test keys(BuildkiteUtils.METADATA) == ["aa-linux", "aa-windows"]
    end
    @test BuildkiteUtils.METADATA["aa-$step"] == "hello"
end

using Plots

@testset "artifact" begin

    @test BuildkiteUtils.artifact_search("*"; step=step) == []

    p = plot(identity, sin, -2pi, 2pi)
    dir = mktempdir()
    png(p, joinpath(dir, "sin x.png"))

    subdir = joinpath(dir, "extra")
    mkpath(subdir)
    write(joinpath(subdir, "hello.txt"), "hello world")

    cd(dir) do
        BuildkiteUtils.artifact_upload("*.png")
        BuildkiteUtils.artifact_upload("**/*.txt")
    end

    @test sort(BuildkiteUtils.artifact_search(step=step)) == sort(["sin x.png", "extra/hello.txt"])

    newdir = mktempdir()
    BuildkiteUtils.artifact_download("*.png", newdir; step=step)
    @test readdir(newdir) == ["sin x.png"]
    @test read(joinpath(dir, "sin x.png")) == read(joinpath(newdir, "sin x.png"))
end

@testset "annotation" begin
    if step == "linux"
        BuildkiteUtils.annotate("""
        Hello from :linux:

        <img src="artifact://sin x.png" alt="sin(x)" height=250 >

        """)
        BuildkiteUtils.annotate("Success"; style="success", context="xtra")
    elseif step == "windows"
        BuildkiteUtils.annotate("and from :windows:\n"; append=true)
    end
end
