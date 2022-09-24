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
    dir = mktempdir()
    subdir = joinpath(dir, "extra")
    mkpath(subdir)
    write(joinpath(subdir, "$step.txt"), "hello world")

    if step == "linux"

        @test BuildkiteUtils.artifact_search("*") == []

        p = plot(identity, sin, -2pi, 2pi)
        png(p, joinpath(dir, "sin x.png"))

        cd(dir) do
            BuildkiteUtils.artifact_upload("*.png")
            BuildkiteUtils.artifact_upload("**/*.txt")
        end

        @test sort(BuildkiteUtils.artifact_search()) == sort(["sin x.png", "extra/linux.txt"])

        newdir = mktempdir()
        BuildkiteUtils.artifact_download("*.png", newdir; step=step)
        @test readdir(newdir) == ["sin x.png"]
        @test read(joinpath(dir, "sin x.png")) == read(joinpath(newdir, "sin x.png"))

    elseif step == "windows"

        @test sort(BuildkiteUtils.artifact_search()) == sort(["sin x.png", "extra/linux.txt"])

        cd(dir) do
            BuildkiteUtils.artifact_upload("**/*.txt")
        end

        @test sort(BuildkiteUtils.artifact_search()) == sort(["sin x.png", "extra/linux.txt", "extra/windows.txt"])
        @test sort(BuildkiteUtils.artifact_search(); step="linux") == sort(["sin x.png", "extra/linux.txt"])
        @test sort(BuildkiteUtils.artifact_search(); step="windows") == sort(["extra/windows.txt"])

        newdir = mktempdir()
        BuildkiteUtils.artifact_download("*.png", newdir; step="linux")
        @test readdir(newdir) == ["sin x.png"]
    end
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
