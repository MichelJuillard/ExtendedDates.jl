using ExtendedDates
using Documenter

DocMeta.setdocmeta!(ExtendedDates, :DocTestSetup, :(using ExtendedDates); recursive=true)

makedocs(;
    modules=[ExtendedDates],
    authors="Lilith Hafner <Lilith.Hafner@gmail.com>, MichelJuillard <michel.juillard@mjui.fr>, and contributors",
    repo="https://github.com/DynareJulia/ExtendedDates.jl/blob/{commit}{path}#{line}",
    sitename="ExtendedDates.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://DynareJulia.github.io/ExtendedDates.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/DynareJulia/ExtendedDates.jl",
    devbranch="main",
)
