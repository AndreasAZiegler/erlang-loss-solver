module ErlangLossSolverApplication

include("./ErlangLossSolver.jl")
using .ErlangLossSolver

function printParsedInput(
    T::Float64,
    connections::Array{Float64,2},
    customer_indexes::Dict{String,Int64},
    storage_indexes::Dict{String,Int64},
    pairs::Array{Any,1},
    nodes::Set{String},
    mu::Dict{String,Float64},
    storage_levels::Dict{String,Int64},
)
    @debug "T: $T"
    @debug "customer indexes: $customer_indexes"
    @debug "storage indexes: $storage_indexes"
    @debug "pairs: $pairs"
    @debug "nodes: $nodes"
    @debug "mu: $mu"
    @debug "storage levels: $storage_levels"
    @debug "connections: $connections"

    keys_string = "    "
    for (key, value) in sort(collect(storage_indexes), by = x -> x[2])
        keys_string = string(keys_string, key, "  ")
    end
    @info "$keys_string "
    println("Problem structure:")
    println("T = ", T)
    println("$keys_string ")
    for (row_index, connetions_row) in enumerate(eachrow(connections))
        customer = collect(keys(customer_indexes))[row_index]
        @info "$customer $connetions_row"
        println("$customer $connetions_row")
    end
end

function main(input_file_name::String)
    @info "$input_file_name"
    println("Input file name: $input_file_name\n")

    T, connections, indexes, pairs, nodes, customer_mu, storage_levels =
        ErlangLossSolver.parseInput(input_file_name)
    customer_indexes = indexes[1]
    storage_indexes = indexes[2]

    ErlangLossSolverApplication.printParsedInput(
        T,
        connections,
        customer_indexes,
        storage_indexes,
        pairs,
        nodes,
        customer_mu,
        storage_levels,
    )

    customer_mu_array = collect(values(customer_mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}()

    max_num_iterations = maximum(connections)

    # Initialize problem
    ErlangLossSolver.initialize!(
        probabilities,
        customer_mu_array,
        storages_E,
        connections,
        storage_indexes,
        storage_levels,
        max_num_iterations,
        T,
    )

    # Run until convergence
    ErlangLossSolver.runUntilConvergence!(
        probabilities,
        customer_mu_array,
        storages_E,
        connections,
        storage_indexes,
        storage_levels,
        max_num_iterations,
        T,
    )

    ErlangLossSolver.calculateFillrates(
        probabilities,
        customer_mu,
        storages_E,
        connections,
        customer_indexes,
        storage_indexes,
        storage_levels,
        max_num_iterations,
        T,
    )
end

end
