using CellMLModelRepository
using CellMLToolkit
using CSV, DataFrames
using Test

@show pwd(), readdir()

# curl
df = cellml_metadata()
@test df isa DataFrame
display(df)

# cellml_models()
# fns = readdir(joinpath(@__DIR__, "../data/cellml_models/"); join=true)[1:10] # only do 10
# @show fns 
# @test isfile(fns[1])

# clone
mkpath("$(CellMLModelRepository.datadir)repos/")
workspaces_df = cellml_workspaces()
@test workspaces_df isa DataFrame
cleandf = unique(strip.(dropmissing(workspaces_df)), :repo)
CSV.write("$(CellMLModelRepository.datadir)workspaces.csv", cleandf)
