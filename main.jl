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
    stock_levels::Dict{String,Array{Int64}},
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
    storages_mu = Dict{String,Float64}()
    # Initialize problem
    for (col_index, connection_col) in enumerate(eachcol(connections))
        if logging
            println("col index: $col_index, connection_col: $connection_col")
        end

        storage_mu = 0
        for (row_index, cell) in enumerate(connection_col)
            if logging
                println("row index: $row_index, cell: $cell")
            end

            if (cell == 1)
                storage_mu = storage_mu + customer_mu[row_index] * T
            end
        end
        push!(storages_mu, collect(keys(stock_indexes))[col_index] => storage_mu)
    end

    println("### Problem initialized ###")
    println("storages mu: $storages_mu")

    push!(stock_levels, "CW" => [1 1])

    probabilities = Dict{String,Float64}()
    for (storage_index, storage) in enumerate(stock_indexes)
        storage_name = storage[1]
        println("storage name: ", storage_name)
        E = storages_mu[storage_name]
        m = stock_levels[storage_name][2]
        println("E: ", E, " m: ", m)

        nominator = ((E^m) / factorial(m))
        denominator = 0
        for i in collect(0:m)
            denominator = denominator + (E^i / factorial(i))
        end

        probability = nominator / denominator
        println("nominator: ", nominator, " denominator: ", denominator)

        push!(probabilities, storage_name => probability)
    end

    println("probabilities: ", probabilities)
end

main()

