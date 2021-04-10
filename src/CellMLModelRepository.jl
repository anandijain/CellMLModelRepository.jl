"""functions to grab the physiome model repository.

to just get a folder of cellml files, use `cellml_models`


"""
module CellMLModelRepository

using JSON3, JSONTables, CSV, DataFrames
using Base.Threads, Downloads

using HTTP, Cascadia, Gumbo
using OrdinaryDiffEq

const datadir = joinpath(@__DIR__, "../data/")
mkpath(datadir)

include("curl.jl")
include("repos.jl")

export cellml_models, cellml_metadata
export cellml_workspaces

end
