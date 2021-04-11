using EzXML, OrdinaryDiffEq, DataFrames, CSV

function clone(repo)
    run(`git clone $url`)
end

function run_all_repos(csv_file, root, filelist=readdir(root); skip=0)
    df = DataFrame(file=String[], len = Int[], res = Int[], deps = Int[], msg = String[])
    n = 0

    for d in filelist
        path = joinpath(root, d)
        if isdir(path)
            n += run_repo(path, df; dry_run=n<skip)
            CSV.write(csv_file, df)
        end
    end
end

function run_repo(repo, df; file_limit=500000, dry_run=false)
    printstyled("processing repo $repo\n"; color=:blue)
    files = list_top_cellml_files(repo)

    for f in files
        l = filesize(f)
        msg = "OK!"
        k = 0
        m = 0
        if dry_run
            printstyled("\tskipping file $f ($l bytes)\n"; color=:blue)
        else
            printstyled("\tprocessing file $f ($l bytes)\n"; color=:blue)
            try
                if l > file_limit
                    msg = "Too big!"
                    k = 9
                    printstyled("\tfile $f ($l bytes) is too big and is skipped\n"; color=:red)
                else
                    ml = CellModel(f)
                    k = 1
                    m = length(ml.doc.xmls)
                    prob  = ODEProblem(ml, (0,1000.0))
                    k = 2
                    sol = solve(prob, TRBDF2(), dtmax=0.5)
                    k = 3
                end
            catch e
                println(e)
                msg = string(e)
            finally
                push!(df, (f, l, k, m, msg))
                printstyled("$f done with a code $k\n"; color=:green)
            end
        end
    end

    return length(files)
end

function list_top_cellml_files(repo)
    files = [f for f in readdir(repo) if endswith(f,".cellml")]

    if length(files) == 1
        return joinpath.(repo, files)
    end

    imported = Set{String}()
    for f in files
        xml = readxml(joinpath(repo, f))
        for n in CellMLToolkit.list_imports(xml)
            push!(imported, n["xlink:href"])
        end
    end

    if !isempty(imported)
        printstyled("imported files are $imported\n"; color=:yellow)
    end

    joinpath.(repo, [f for f in files if f ∉ imported])
end


##############################################################################

const cellml_files_with_import = [
    "25d",
    "bugbuster",
    "butera_rinzel_smith_II_1999",
    "cardiovascular_circulation_dvad",
    "cardiovascular_circulation_ivad",
    "cardiovascular_circulation_systemic",
    "cardiovascular_circulation_westkessel",
    "cooling_hunter_crampin_CellML_2008",
    "electrecoblu",
    "faville_pullan_sanders_koh_lloyd_smith_2009",
    "garmendia-torres_goldbeter_jacquet_2007",
    "goldbeter_1991",
    "goldbeter_gonze_pourquie_2007",
    "grandi_pasqualini_bers_2010",
    "guyton_aldosterone_2008",
    "guyton_angiotensin_2008",
    "guyton_antidiuretic_hormone_2008",
    "guyton_atrial_natriuretic_peptide_2008",
    "guyton_autonomics_2008",
    "pasek_simurda_christe_2006",
    "saucerman_bers_2008",
    "shi_hose_2009",
    "smith_abdala_koizumi_rybak_paton_2007",
    "terkildsen_niederer_crampin_hunter_smith_2008",
    "virtualbacterialphotography",
    "westermark_lansner_2003"
]
