
# too many gross dependencies. I'm hoping we can just use `curl_cellml_models`
# script for shahriar
# using HTTP, Cascadia, Gumbo
# using OrdinaryDiffEq

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


function clone(repo)
    run(`git clone $url`)
end

function run_all_repos(root; skip=0)
    res = Int[]
    n = 0
    for d in readdir(root)
        path = joinpath(root, d)
        if isdir(path)
            n += run_repo(path, res; dry_run=n<skip)
        end
    end
end

function run_repo(repo, res; file_limit=500000, dry_run=false)
    printstyled("processing repo $repo\n"; color=:blue)
    files = list_top_cellml_files(repo)
    n = 0
    for f in files
        l = filesize(f)
        if l > file_limit
            printstyled("\tfile $f ($l bytes) is too big and is skipped\n"; color=:red)
        else
            n += 1
            if dry_run
                printstyled("\tskipping file $f ($l bytes)\n"; color=:blue)
            else
                printstyled("\tprocessing file $f ($l bytes)\n"; color=:blue)
                k = 0
                try
                    ml = CellModel(f)
                    k = 1
                    prob  = ODEProblem(ml, (0,1000.0))
                    k = 2
                    sol = solve(prob, TRBDF2(), dtmax=0.5)
                    k = 3
                catch e
                    println(e)
                finally
                    push!(res, k)
                    n0 = length(res)
                    n1 = sum(res .== 1)
                    n2 = sum(res .== 2)
                    n3 = sum(res .== 3)
                    printstyled("$f done with a code $k:\t$n0\t$n1\t$n2\t$n3\n"; color=:green)
                end
            end
        end
    end

    return n
end

function list_top_cellml_files(repo)
    files = [f for f in readdir(repo) if endswith(f,".cellml")]

    if length(files) == 1
        return joinpath.(repo, files)
    end

    imported = Set{String}()
    for f in files
        xml = readxml(joinpath(repo, f))
        for n in list_imports(xml)
            push!(imported, n["xlink:href"])
        end
    end

    if !isempty(imported)
        printstyled("imported files are $imported\n"; color=:yellow)
    end

    joinpath.(repo, [f for f in files if f ∉ imported])
end
