"`curl_cellml_models()`"
module CellMLModelRepository

using JSON3, JSONTables, CSV, DataFrames
using Base.Threads, Downloads

const datadir = joinpath(@__DIR__, "../data/")
mkpath(datadir)

function cellml_metadata(;json_path = "$(datadir)cellml_exposures.json", csv_path="$(datadir)exposures_metadata.csv")
    run(`curl -sL -H 'Accept: application/vnd.physiome.pmr2.json.1' https://models.physiomeproject.org/search -d '{
           "template": {"data": [
               {"name": "Subject", "value": "CellML Model"},
               {"name": "portal_type", "value": "ExposureFile"}
           ]}
       }' -o $(json_path)`)

    s = read(json_path, String);
    j = JSON3.read(read(json_path, String))
    df = DataFrame(jsontable(j.collection.links))
    select!(df, Not(:rel))
    CSV.write(csv_path, df)
    df
end

"anands preferred method of downloading. no boo boo html parsing"
function cellml_models(;dir = "$(datadir)cellml_models/", csv_path="$(datadir)exposures_metadata.csv")
    if isfile(csv_path) 
        df = CSV.read(csv_path, DataFrame)
    else
        df = cellml_metadata(;csv_path=csv_path)
    end
    urls = map(x->x[1:end-5], df.href)
    @sync Threads.@threads for url in urls
        Downloads.download(url, "$(dir)$(splitdir(url)[end])")
    end
end

export cellml_models, cellml_metadata

end
