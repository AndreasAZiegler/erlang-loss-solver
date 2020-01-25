include("./ErlangLossSolver.jl")
using .ErlangLossSolver

function printParsedInput(
    T::Float64,
    connections::Array{Float64,2},
    customer_indexes::Dict{String,Int64},
    stock_indexes::Dict{String,Int64},
    pairs::Array{Any,1},
    nodes::Set{String},
    mu::Dict{String,Float64},
    stock_levels::Dict{String,Int64},
    logging::Bool,
)
    if logging
        println("T: $T")
        println("customer indexes: $customer_indexes")
        println("stock indexes: $stock_indexes")
        println("pairs: $pairs")
        println("nodes: $nodes")
        println("mu: $mu")
        println("stock levels: $stock_levels")
        println("connections: $connections")
    end

    print("    ")
    for (key, value) in sort(collect(stock_indexes), by = x -> x[2])
        print("$key,  ")
    end
    println("")
    for (row_index, connetions_row) in enumerate(eachrow(connections))
        customer = collect(keys(customer_indexes))[row_index]
        println("$customer $connetions_row")
    end
end

function main()
    parsed_args = ErlangLossSolver.parseCommandline()

    input_file_name = parsed_args["input"]
    println("$input_file_name")

    logging = parsed_args["log"]

    T, connections, indexes, pairs, nodes, mu, stock_levels =
        ErlangLossSolver.parseInput(input_file_name, logging)
    customer_indexes = indexes[1]
    stock_indexes = indexes[2]

    printParsedInput(
        T,
        connections,
        customer_indexes,
        stock_indexes,
        pairs,
        nodes,
        mu,
        stock_levels,
        logging,
    )

    customer_mu = collect(values(mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}()

    max_num_iterations = maximum(connections)

    # Initialize problem
    ErlangLossSolver.initialize!(
        probabilities,
        customer_mu,
        storages_E,
        connections,
        stock_indexes,
        stock_levels,
        max_num_iterations,
        T,
        logging,
    )

    ErlangLossSolver.runUntilConvergence!(
        probabilities,
        customer_mu,
        storages_E,
        connections,
        stock_indexes,
        stock_levels,
        max_num_iterations,
        T,
        logging,
    )
end

main()


