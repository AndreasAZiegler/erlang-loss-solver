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

function findClosestStorage(
    connections::Array{Float64,2},
    stock_indexes::Dict{String,Int64},
    customer_index::Int,
    logging::Bool,
)
    row = connections[customer_index, :]
    row[row .== 0.0] .= typemax(Float64)

    storage_index = argmin(row)
    storage_name = collect(keys(stock_indexes))[storage_index]
    if logging
        println("row: ", row)
        println("argmin: ", storage_index)
        println("storage name: ", storage_name)
    end

    return storage_name
end

function runOneIteration!(
    probabilities::Dict{String,Float64},
    customer_mu::Array{Float64},
    storages_E::Dict{String,Float64},
    connections::Array{Float64,2},
    stock_indexes::Dict{String,Int64},
    stock_levels::Dict{String,Array{Int64}},
    distance::Float64,
    T::Float64,
    logging::Bool,
)
    for (col_index, connection_col) in enumerate(eachcol(connections))
        if logging
            println("col index: $col_index, connection_col: $connection_col")
        end

        storage_E = 0
        print("mu: ")
        for (row_index, cell) in enumerate(connection_col)
            if logging
                println("row index: $row_index, cell: $cell")
            end

            if (0 < cell <= distance)
                print(customer_mu[row_index], " ")
                storage_prabability = 1
                if (cell > 1)
                    storage_name =
                        findClosestStorage(connections, stock_indexes, row_index, logging)
                    storage_prabability = probabilities[storage_name]
                end
                #println("storage probability: ", storage_prabability)
                storage_E = storage_E + storage_prabability * customer_mu[row_index] * T
            end
        end
        println("")
        push!(storages_E, collect(keys(stock_indexes))[col_index] => storage_E)
    end

    println("### Problem initialized ###")
    println("storages E: $storages_E")

    push!(stock_levels, "CW" => [1 1])

    for (storage_index, storage) in enumerate(stock_indexes)
        storage_name = storage[1]
        println("")
        println("storage name: ", storage_name)
        E = storages_E[storage_name]
        m = stock_levels[storage_name][2]
        println("E: ", E, " m: ", m)

        nominator = ((E^m) / factorial(m))
        denominator = 0
        for i in collect(0:m)
            denominator = denominator + (E^i / factorial(i))
        end

        probability = nominator / denominator
        println("nominator: ", nominator, " denominator: ", denominator)
        println("probability: ", probability)

        push!(probabilities, storage_name => probability)
    end

    println("probabilities of not meting the need:")
    println("probabilities: ", probabilities)
end

function haveWeConverged(
    new_probabilities::Dict{String,Float64},
    old_probabilities::Dict{String,Float64},
)
    new_values = [value for value in values(new_probabilities)]
    old_values = [value for value in values(old_probabilities)]

    for (index, new_value) in enumerate(new_values)
      if !isapprox(new_value, old_values[index])
        return false
      end
    end

    return true
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
    println("Maximal number of initialization iterations: ", max_num_iterations)

    # Initialize problem
    for distance in collect(1:max_num_iterations)
        runOneIteration!(
            probabilities,
            customer_mu,
            storages_E,
            connections,
            stock_indexes,
            stock_levels,
            distance,
            T,
            logging,
        )
    end

    distance = max_num_iterations
    converged = false
    iteration = 1
    while !converged
        old_probabilities = probabilities
        runOneIteration!(
            probabilities,
            customer_mu,
            storages_E,
            connections,
            stock_indexes,
            stock_levels,
            distance,
            T,
            logging,
        )

        if haveWeConverged(probabilities, old_probabilities)
            converged = true
        end
        iteration = iteration + 1
    end

    println("Converted after ", iteration, " iterations")
end

main()

