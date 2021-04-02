
# too many gross dependencies. I'm hoping we can just use `curl_cellml_models`
# script for shahriar
# using HTTP, Cascadia, Gumbo
# gethtmldoc(url) = parsehtml(String(HTTP.get(url).body))

# function cellml_table()
#     url = "http://models.cellml.org/e/listing/full-list"
#     doc = gethtmldoc(url)
#     dts = eachmatch(sel"dt", doc.root)[2:end]
#     arr = []
#     for dt in dts
#         a = eachmatch(sel"a", dt)
#         length(a) != 1 && error("$dt err")
#         name = nodeText(a[1])
#         push!(arr, [name, a[1].attributes["href"]])
#     end
#     data = permutedims(reduce(hcat, arr))
#     [:name, :url] .=> eachcol(data)
# end

# "used to get the workspace repo urls to git clone "
# function cellml_workspaces()
#     df = DataFrame(cellml_table())
#     repos = []
#     for url in df.url
#         doc = gethtmldoc(url)
#         dds = eachmatch(sel"dd", doc.root)
#         dd = dds[2]
#         as = eachmatch(sel"a", dd)
#         if length(as) == 0
#             repo_url = missing
#         else
#             a = as[1]
#             repo_url = getattr(a, "href")
#         end
#         push!(repos, repo_url)
#     end
#     df[!, :repo]  = repos
#     df
# end