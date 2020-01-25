using Test

include("./ErlangLossSolver.jl")
using .ErlangLossSolver


@testset "parse input" begin
    filename = "test_parser.csv"
    @test typeof(filename) == String

    T, connections, indexes, pairs, nodes, mu, stock_levels =
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

    mu_gt = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    @test mu == mu_gt

    stock_levels_gt = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

    @test stock_levels == stock_levels_gt
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

    mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    stock_levels = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

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
        storage_indexes,
        stock_levels,
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

    mu = Dict("C1" => 0.1, "C2" => 0.2, "C3" => 0.4, "C4" => 0.2)

    stock_levels = Dict{String,Int64}("LW1" => 1, "LW2" => 3)

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
        storage_indexes,
        stock_levels,
        max_num_iterations,
        T,
    )

    @test isapprox(probabilities["LW1"], 0.4018496420047733)
    @test isapprox(probabilities["LW2"], 0.11169370626989666)

    ErlangLossSolver.runUntilConvergence!(
        probabilities,
        customer_mu,
        storages_E,
        connections,
        storage_indexes,
        stock_levels,
        max_num_iterations,
        T,
    )

    @test isapprox(probabilities["LW1"], 0.40805809275815647)
    @test isapprox(probabilities["LW2"], 0.11329562934890061)
end
