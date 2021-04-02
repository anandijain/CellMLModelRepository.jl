"`curl_cellml_models()`"
module CellMLModelRepository

using JSON3, JSONTables, CSV, DataFrames
using Base.Threads

function curl_metadata(json_path = "data/cellml_exposures.json", csv_path="data/exposures_metadata.csv")
    run(`curl -sL -H 'Accept: application/vnd.physiome.pmr2.json.1' https://models.physiomeproject.org/search -d '{
           "template": {"data": [
               {"name": "Subject", "value": "CellML Model"},
               {"name": "portal_type", "value": "ExposureFile"}
           ]}
       }' -o $(json_path)`)

    s = read(json, String);
    j = JSON3.read(read(json_path, String))
    df = DataFrame(jsontable(j.collection.links))
    select!(df, Not(:rel))
    CSV.write(csv_path, df)
    df
end

"anands preferred method of downloading. no boo boo html parsing"
function curl_cellml_models(dir = "data/cellml_models")
    mkpath(dir)
    df = curl_metadata()
    urls = map(x->x[1:end-5], df.href)
    @sync Threads.@threads for url in urls
        run(`curl $(url) -o "data/cellml_models/$(splitdir(url)[end])"`)
    end
end

export curl_cellml_models

end
