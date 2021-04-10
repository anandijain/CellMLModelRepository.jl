using CellMLModelRepository
using CellMLToolkit
using CSV, DataFrames
using Test

# curl
df = cellml_metadata()
@test df isa DataFrame
cellml_models()
fns = readdir(joinpath(@__DIR__, "../data/cellml_models/"); join=true)[1:10] # only do 10
@show fns 
@test isfile(fns[1])

# clone
mkpath("$(CellMLModelRepository.datadir)repos/")
df = cellml_workspaces()
@test df isa DataFrame
cleandf = unique(strip.(dropmissing(df)), :repo)
CSV.write("$(CellMLModelRepository.datadir)workspaces.csv", cleandf)
