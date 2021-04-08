using CellMLModelRepository
using CSV, DataFrames
using Test

df = cellml_metadata()
@test df isa DataFrame

# test suite stuff
curl_cellml_models()
fns = readdir(joinpath(@__DIR__, "../data/cellml_models/"); join=true)[1:10] # only do 10
@test isfile(fns[1])

using Pkg

Pkg.add(url="https://github.com/anandijain/BioXMLSciMLTest.jl")
using BioXMLSciMLTest

files_to_sciml(fns; pmap=true)
df = results_df()
@test df isa DataFrame