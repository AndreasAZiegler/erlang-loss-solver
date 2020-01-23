include("./ErlangLossSolver.jl")
using .ErlangLossSolver

function main()
    parsed_args = ErlangLossSolver.parseCommandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        println("  $arg  =>  $val")
    end

    input_file_name = parsed_args["input"]
    println("$input_file_name")

    logging = parsed_args["log"]

    connections, indexes, pairs, nodes, mu, stock_levels = ErlangLossSolver.parseInput(input_file_name, logging)

    if logging
      println("indexes: $indexes")
      println("pairs: $pairs")
      println("nodes: $nodes")
      println("mu: $mu")
      println("stock levels: $stock_levels")
      println("connections: $connections")
    end

    for (key, value) in sort(collect(indexes), by=x->x[2])
      print("$key,  ")
    end
    println("")
    for connetions_row in eachrow(connections)
        println("$connetions_row")
    end
end

main()
