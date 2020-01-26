include("./ErlangLossSolver.jl")
using .ErlangLossSolver

function main()
    parsed_args = ErlangLossSolver.parseCommandline()

    input_file_name = parsed_args["input"]
    @info "$input_file_name"

    T, connections, indexes, pairs, nodes, customer_mu, storage_levels =
        ErlangLossSolver.parseInput(input_file_name)
    customer_indexes = indexes[1]
    storage_indexes = indexes[2]

    ErlangLossSolver.printParsedInput(
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

main()

