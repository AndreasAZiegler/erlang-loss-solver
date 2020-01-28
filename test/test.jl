using Test

include("../ErlangLossSolver.jl")
using .ErlangLossSolver

using Logging

# Deactivate logging
Logging.disable_logging(Logging.Warn)

@testset "parse input" begin
    filename = "./test_parser.csv"
    @test typeof(filename) == String

    T, connections, indexes, pairs, nodes, customer_mu, storage_levels =
        ErlangLossSolver.parseInput(filename)

    T_gt = 2

    @test T == T_gt

    connections_gt = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]

    @test connections == connections_gt

    customer_indexes_gt = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes_gt = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    @test indexes[1] == customer_indexes_gt
    @test indexes[2] == storage_indexes_gt

    pairs_gt = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    @test pairs == pairs_gt

    nodes_gt = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    @test nodes == nodes_gt

    customer_mu_gt = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    @test customer_mu == customer_mu_gt

    storage_levels_gt = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

    @test storage_levels == storage_levels_gt
end

@testset "initialize" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])
customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

    customer_mu = collect(values(customer_mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}()

    max_num_iterations = maximum(connections)

    # Initialize problem
    ErlangLossSolver.initialize!(
        probabilities,
        customer_mu,
        storages_E,
        connections,
        storage_indexes,
        storage_levels,
        max_num_iterations,
        T,
    )

    @test isapprox(probabilities["LW1"], 0.4018496420047733)
    @test isapprox(probabilities["LW2"], 0.11169370626989666)
end

@testset "Run" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

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

    @test isapprox(probabilities["LW1"], 0.4018496420047733)
    @test isapprox(probabilities["LW2"], 0.11169370626989666)

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

    @test isapprox(probabilities["LW1"], 0.4085067973262592)
    @test isapprox(probabilities["LW2"], 0.11366654338448788)
end

@testset "Calculate alphas" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

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

    @test isapprox(probabilities["LW1"], 0.4018496420047733)
    @test isapprox(probabilities["LW2"], 0.11169370626989666)

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

    @test isapprox(probabilities["LW1"], 0.40805809275815647, atol=1e-3)
    @test isapprox(probabilities["LW2"], 0.11329562934890061, atol=1e-3)

    customers_alphas = Dict{String,Float64}()
    customers_theta = Dict{String,Float64}()

    ErlangLossSolver.calculateCustomerAlpha(
        customers_alphas,
        customers_theta,
        probabilities,
        customer_mu_array,
        connections,
        storage_indexes,
        customer_indexes,
        max_num_iterations,
    )

    @test isapprox(customers_alphas["C1"], 0.05919419072418435, atol=1e-3)
    @test isapprox(customers_alphas["C2"], 0.19075376031401053, atol=1e-3)
    @test isapprox(customers_alphas["C3"], 0.38150752062802107, atol=1e-3)
    @test isapprox(customers_alphas["C4"], 0.1773408741302199, atol=1e-3)

    @test isapprox(customers_theta["C1"], 0.04080580927581565, atol=1e-3)
    @test isapprox(customers_theta["C2"], 0.00924623968598948, atol=1e-3)
    @test isapprox(customers_theta["C3"], 0.01849247937197896, atol=1e-3)
    @test isapprox(customers_theta["C4"], 0.022659125869780125, atol=1e-3)

end

@testset "Calculate fill rates" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

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

    @test isapprox(probabilities["LW1"], 0.4018496420047733)
    @test isapprox(probabilities["LW2"], 0.11169370626989666)

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

    @test isapprox(probabilities["LW1"], 0.40805809275815647, atol=1e-3)
    @test isapprox(probabilities["LW2"], 0.11329562934890061, atol=1e-3)

    customers_alphas = Dict{String,Float64}()
    customers_theta = Dict{String,Float64}()

    ErlangLossSolver.calculateCustomerAlpha(
        customers_alphas,
        customers_theta,
        probabilities,
        customer_mu_array,
        connections,
        storage_indexes,
        customer_indexes,
        max_num_iterations,
    )

    @test isapprox(customers_alphas["C1"], 0.05919419072418435, atol=1e-3)
    @test isapprox(customers_alphas["C2"], 0.19075376031401053, atol=1e-3)
    @test isapprox(customers_alphas["C3"], 0.38150752062802107, atol=1e-3)
    @test isapprox(customers_alphas["C4"], 0.1773408741302199, atol=1e-3)

    @test isapprox(customers_theta["C1"], 0.04080580927581565, atol=1e-3)
    @test isapprox(customers_theta["C2"], 0.00924623968598948, atol=1e-3)
    @test isapprox(customers_theta["C3"], 0.01849247937197896, atol=1e-3)
    @test isapprox(customers_theta["C4"], 0.022659125869780125, atol=1e-3)

    fill_rates, overall_time_based_fillrate  = ErlangLossSolver.calculateFillrates(
        probabilities,
        customer_mu,
        storages_E,
        connections,
        customer_indexes,
        storage_indexes,
        storage_levels,
        max_num_iterations,
        T)

    @test isapprox(fill_rates["C1"], 0.5919419072418435, atol=1e-3)
    @test isapprox(fill_rates["C2"], 0.9537688015700526, atol=1e-3)
    @test isapprox(fill_rates["C3"], 0.9537688015700526, atol=1e-3)
    @test isapprox(fill_rates["C4"], 0.8867043706510994, atol=1e-3)

    @test isapprox(overall_time_based_fillrate, 0.8986626064404842, atol=1e-3)
end

@testset "Example 1: initialize/first iteration" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

    customer_mu = collect(values(customer_mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}()

    max_num_iterations = maximum(connections)

    # Initialize problem
    ErlangLossSolver.initialize!(
        probabilities,
        customer_mu,
        storages_E,
        connections,
        storage_indexes,
        storage_levels,
        max_num_iterations,
        T,
    )

    @test isapprox(probabilities["LW1"], 0.4018496420047733)
    @test isapprox(probabilities["LW2"], 0.11169370626989666)

    customers_alphas = Dict{String,Float64}()
    customers_theta = Dict{String,Float64}()
end

@testset "Example 1: second iteration" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

    customer_mu = collect(values(customer_mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}("LW1" => 0.4018496420047733, "LW2" => 0.11169370626989666)

    max_num_iterations = maximum(connections)

    ErlangLossSolver.runOneIteration!(
            probabilities,
            customer_mu,
            storages_E,
            connections,
            storage_indexes,
            storage_levels,
            max_num_iterations,
            T,
        )

    @test isapprox(probabilities["LW1"], 0.40805809275815647)
    @test isapprox(probabilities["LW2"], 0.11329562934890061)
end

@testset "Example 1: third iteration" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

    customer_mu = collect(values(customer_mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}("LW1" => 0.40805809275815647, "LW2" => 0.11329562934890061)

    max_num_iterations = maximum(connections)

    ErlangLossSolver.runOneIteration!(
            probabilities,
            customer_mu,
            storages_E,
            connections,
            storage_indexes,
            storage_levels,
            max_num_iterations,
            T,
        )

    @test isapprox(probabilities["LW1"], 0.40805809275815647, atol=1e-3)
    @test isapprox(probabilities["LW2"], 0.11329562934890061, atol=1e-3)
end

@testset "Example 1: calculate results" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

    customer_mu_array = collect(values(customer_mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}("LW1" => 0.40805809275815647, "LW2" => 0.11329562934890061)

    max_num_iterations = maximum(connections)

    customers_alphas = Dict{String,Float64}()
    customers_theta = Dict{String,Float64}()

    ErlangLossSolver.calculateCustomerAlpha(
        customers_alphas,
        customers_theta,
        probabilities,
        customer_mu_array,
        connections,
        storage_indexes,
        customer_indexes,
        max_num_iterations,
    )

    @test isapprox(customers_alphas["C1"], 0.05919419072418435)
    @test isapprox(customers_alphas["C2"], 0.19075376031401053)
    @test isapprox(customers_alphas["C3"], 0.38150752062802107)
    @test isapprox(customers_alphas["C4"], 0.1773408741302199)

    @test isapprox(customers_theta["C1"], 0.040805809275815647)
    @test isapprox(customers_theta["C2"], 0.00924623968598948)
    @test isapprox(customers_theta["C3"], 0.01849247937197896)
    @test isapprox(customers_theta["C4"], 0.022659125869780125)

    fill_rates, overall_time_based_fillrate = ErlangLossSolver.calculateFillrates(
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

    @test isapprox(fill_rates["C1"], 0.5919419072418435)
    @test isapprox(fill_rates["C2"], 0.9537688015700526)
    @test isapprox(fill_rates["C3"], 0.9537688015700526)
    @test isapprox(fill_rates["C4"], 0.8867043706510994)

    @test isapprox(overall_time_based_fillrate, 0.8986626064404842)
end

@testset "Example 2: initialize/first iteration" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 2, "LW2" => 3)

    customer_mu = collect(values(customer_mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}()

    max_num_iterations = maximum(connections)

    # Initialize problem
    ErlangLossSolver.initialize!(
        probabilities,
        customer_mu,
        storages_E,
        connections,
        storage_indexes,
        storage_levels,
        max_num_iterations,
        T,
    )

    @test isapprox(probabilities["LW1"], 0.11893140037555237)
    @test isapprox(probabilities["LW2"], 0.09559004353991513)

    customers_alphas = Dict{String,Float64}()
    customers_theta = Dict{String,Float64}()
end

@testset "Example 2: second iteration" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 2, "LW2" => 3)

    customer_mu = collect(values(customer_mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}("LW1" => 0.11893140037555237, "LW2" => 0.09559004353991513)

    max_num_iterations = maximum(connections)

    ErlangLossSolver.runOneIteration!(
            probabilities,
            customer_mu,
            storages_E,
            connections,
            storage_indexes,
            storage_levels,
            max_num_iterations,
            T,
        )

    @test isapprox(probabilities["LW1"], 0.12009116665767765)
    @test isapprox(probabilities["LW2"], 0.09662214521977854)
end

@testset "Example 2: third iteration" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 2, "LW2" => 3)

    customer_mu = collect(values(customer_mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}("LW1" => 0.12009116665767765, "LW2" => 0.09662214521977854)

    max_num_iterations = maximum(connections)

    ErlangLossSolver.runOneIteration!(
            probabilities,
            customer_mu,
            storages_E,
            connections,
            storage_indexes,
            storage_levels,
            max_num_iterations,
            T,
        )

    @test isapprox(probabilities["LW1"], 0.12009116665767765, atol=1e-3)
    @test isapprox(probabilities["LW2"], 0.09662214521977854, atol=1e-3)
end

@testset "Example 2: calculate results" begin
    T = 2.0
    connections = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]
    customer_indexes = Dict("C1" => 1, "C2" => 2, "C3" => 3, "C4" => 4)
    storage_indexes = Dict("LW1" => 1, "LW2" => 2, "CW" => 3)

    pairs = Any[
        Any["C1", "LW1", 1],
        Any["C1", "CW", 2],
        Any["C2", "LW1", 1],
        Any["C2", "LW2", 2],
        Any["C2", "CW", 2],
        Any["C3", "LW2", 1],
        Any["C3", "LW1", 2],
        Any["C3", "CW", 2],
        Any["C4", "LW2", 1],
        Any["C4", "CW", 2],
    ]

    nodes = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

    customer_mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    storage_levels = Dict{String,Int64}("LW1" => 2, "LW2" => 3)

    customer_mu_array = collect(values(customer_mu))
    storages_E = Dict{String,Float64}()
    probabilities = Dict{String,Float64}("LW1" => 0.12009116665767765, "LW2" => 0.09662214521977854)

    max_num_iterations = maximum(connections)

    customers_alphas = Dict{String,Float64}()
    customers_theta = Dict{String,Float64}()

    ErlangLossSolver.calculateCustomerAlpha(
        customers_alphas,
        customers_theta,
        probabilities,
        customer_mu_array,
        connections,
        storage_indexes,
        customer_indexes,
        max_num_iterations,
    )

    @test isapprox(customers_alphas["C1"], 0.08799088333423224)
    @test isapprox(customers_alphas["C2"], 0.19767930677111786)
    @test isapprox(customers_alphas["C3"], 0.3953586135422357)
    @test isapprox(customers_alphas["C4"], 0.1806755709560443)

    @test isapprox(customers_theta["C1"], 0.012009116665767766)
    @test isapprox(customers_theta["C2"], 0.002320693228882151)
    @test isapprox(customers_theta["C3"], 0.004641386457764302)
    @test isapprox(customers_theta["C4"], 0.019324429043955708)

    fill_rates, overall_time_based_fillrate = ErlangLossSolver.calculateFillrates(
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

    @test isapprox(fill_rates["C1"], 0.8799088333423224)
    @test isapprox(fill_rates["C2"], 0.9883965338555892)
    @test isapprox(fill_rates["C3"], 0.9883965338555892)
    @test isapprox(fill_rates["C4"], 0.9033778547802215)

    @test isapprox(overall_time_based_fillrate, 0.9574493051151446)
end
