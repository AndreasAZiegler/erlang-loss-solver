using Test

include("./ErlangLossSolver.jl")
using .ErlangLossSolver


@testset "parse input" begin
    filename = "test_parser.csv"
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

    @test isapprox(probabilities["LW1"], 0.40805809275815647)
    @test isapprox(probabilities["LW2"], 0.11329562934890061)
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

    @test isapprox(probabilities["LW1"], 0.40805809275815647)
    @test isapprox(probabilities["LW2"], 0.11329562934890061)

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

    @test isapprox(customers_theta["C1"], 0.04080580927581565)
    @test isapprox(customers_theta["C2"], 0.0816116185516313)
    @test isapprox(customers_theta["C3"], 0.04531825173956025)
    @test isapprox(customers_theta["C4"], 0.022659125869780125)

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

    @test isapprox(probabilities["LW1"], 0.40805809275815647)
    @test isapprox(probabilities["LW2"], 0.11329562934890061)

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

    @test isapprox(customers_theta["C1"], 0.04080580927581565)
    @test isapprox(customers_theta["C2"], 0.0816116185516313)
    @test isapprox(customers_theta["C3"], 0.04531825173956025)
    @test isapprox(customers_theta["C4"], 0.022659125869780125)

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

    @test isapprox(fill_rates["C1"], 0.5919419072418435)
    @test isapprox(fill_rates["C2"], 0.9537688015700526)
    @test isapprox(fill_rates["C3"], 0.9537688015700526)
    @test isapprox(fill_rates["C4"], 0.8867043706510994)

    @test isapprox(overall_time_based_fillrate, 0.7884502161813476)
end
