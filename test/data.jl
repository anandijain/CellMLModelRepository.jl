using CellMLModelRepository
using CellMLToolkit
using CSV, DataFrames
using Test
using Base.Threads

datadir = joinpath(@__DIR__, "../data/")

# curl
df = cellml_metadata()
@test df isa DataFrame
# display(df)

# cellml_models()
# fns = readdir(joinpath(@__DIR__, "../data/cellml_models/"); join=true)[1:10] # only do 10
# @show fns 
# @test isfile(fns[1])

# clone
p = joinpath(datadir, "repos/")
mkpath(p)
reposdf = cellml_repo_table()
@test reposdf isa DataFrame

workspaces_df = cellml_workspaces(reposdf)
@test workspaces_df isa DataFrame

cleandf = unique(strip.(dropmissing(workspaces_df)), :repo)
CSV.write("$(datadir)workspaces.csv", cleandf)
clone_physiome(p, cleandf)

result_df = run_all_repos(p; limit=1)
display(result_df)
mkpath("logs")
CSV.write("logs/physiome.csv", result_df)
