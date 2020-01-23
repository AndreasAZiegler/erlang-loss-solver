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
    customer_indexes = indexes[1]
    stock_indexes = indexes[2]

    if logging
      println("customer indexes: $customer_indexes")
      println("stock indexes: $stock_indexes")
      println("pairs: $pairs")
      println("nodes: $nodes")
      println("mu: $mu")
      println("stock levels: $stock_levels")
      println("connections: $connections")
    end

    print("    ")
    for (key, value) in sort(collect(stock_indexes), by=x->x[2])
      print("$key,  ")
    end
    println("")
    for (row_index, connetions_row) in enumerate(eachrow(connections))
      customer = collect(keys(customer_indexes))[row_index]
      #println("customer: $customer")
      println("$customer $connetions_row")
    end
end

main()
