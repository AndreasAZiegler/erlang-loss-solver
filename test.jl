using Test

include("./ErlangLossSolver.jl")
using .ErlangLossSolver


@testset "parse input" begin
  filename = "test_parser.csv"
  @test typeof(filename) == String

  T, connections, indexes, pairs, nodes, mu, stock_levels = ErlangLossSolver.parseInput(filename, false)
  
  T_gt = 2

  @test T == T_gt

  connection_gt = [1.0 0.0 2.0; 1.0 2.0 2.0; 2.0 1.0 2.0; 0.0 1.0 2.0]

  @test connections == connection_gt

  customer_indexes_gt = Dict("C1" => 1,"C2" => 2,"C3" => 3,"C4" => 4)
  storage_indexes_gt = Dict("LW1" => 1,"LW2" => 2,"CW" => 3)

  @test indexes[1] == customer_indexes_gt
  @test indexes[2] == storage_indexes_gt

  pairs_gt = Any[Any["C1", "LW1", 1], Any["C1", "CW", 2], Any["C2", "LW1", 1], Any["C2", "LW2", 2], Any["C2", "CW", 2], Any["C3", "LW2", 1], Any["C3", "LW1", 2], Any["C3", "CW", 2], Any["C4", "LW2", 1], Any["C4", "CW", 2]]

  @test pairs == pairs_gt

  nodes_gt = Set(["C1", "C2", "C3", "LW1", "C4", "LW2", "CW"])

  @test nodes == nodes_gt

  mu_gt = Dict("C1" => 0.1,"C2" => 0.2,"C3" => 0.4,"C4" => 0.2)

  @test mu == mu_gt

  stock_levels_gt = Dict{String,Array{Int64,N} where N}("LW1" => [1, 1],"LW2" => [1, 3])

  @test stock_levels == stock_levels_gt
end
