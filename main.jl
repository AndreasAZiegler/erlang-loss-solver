using ArgParse
using CSV
using DelimitedFiles
using Parsers

function checkIfStringIsNumber(string)
    numbers = r"^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$";

    return occursin(numbers, string)
end

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--input"
            help = "Select input file"
            arg_type = String
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        println("  $arg  =>  $val")
    end

    input_file_name = parsed_args["input"]
    println("$input_file_name")

    input_file = readdlm(input_file_name, '\n')
    #println("$input_file")

    indexes = Dict{String,Int64}()
    pairs = []
    mu = Dict{String,Float64}()
    stock_levels = Dict{String, Array{Int64}}()

    index = 1
    nodes = Set{String}()
    for (row_index, line) in enumerate(input_file)
        #println("$row_index, $line", typeof(line))
        row = split(line, ",")
        println("$row")

        customer = row[1]
        previous_element = ""
        previous_elements = []

        for (col_index, data) in enumerate(row)
          print("$data, ")
          if length(row) == 2 && col_index == 2
              push!(mu, previous_element => parse(Float64, data))
          elseif length(row) == 3 && (length(previous_elements) >= 1 && occursin("LW", previous_elements[1]))
              first_element = previous_elements[1]
              println("$first_element")
              previous_element = data
              push!(previous_elements, data)
              if length(previous_elements) > 2
                  push!(stock_levels, previous_elements[1] => Int64[parse(Int64,previous_elements[2]), parse(Int64, previous_elements[3])])
              end
          elseif checkIfStringIsNumber(data)
              println("Add entry: [$customer, $previous_element, $data]")
              push!(pairs, [customer, previous_element, parse(Int64, data)])
          else
              if !in(data, nodes)
                  println("Added $data to $index")
                  push!(indexes, data => index)
                  push!(nodes, data)
                  index += 1
              end

              previous_element = data
              push!(previous_elements, data)
          end
        end
        println("")
    end

    println("$indexes")
    println("$pairs")
    println("$nodes")
    println("$mu")
    println("$stock_levels")

    number_of_nodes = length(nodes)
    connections = zeros(Float64, number_of_nodes, number_of_nodes)

    for pair in pairs
        print("pair: $pair: ")
        pair_1 = pair[1]
        pair_2 = pair[2]
        index_1 = indexes[pair_1]
        index_2 = indexes[pair_2]
        value = pair[3]
        println("$index_1, $index_2, $value")

        connections[index_1, index_2] = value
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
