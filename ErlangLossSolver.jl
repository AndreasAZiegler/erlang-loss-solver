module ErlangLossSolver

using ArgParse
using CSV
using DelimitedFiles
using Parsers

export parseCommandline, parseInput

function checkIfStringIsNumber(string)
    numbers = r"^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$";

    return occursin(numbers, string)
end

function parseCommandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--input"
            help = "Select input file"
            arg_type = String
        "--log"
            help = "Actevate loggin"
            arg_type = Bool
            default = false
    end

    return parse_args(s)
end

function parseInput(file_name::String, logging::Bool)
    input_file = readdlm(file_name, '\n')
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
        if logging
          println("$row")
        end

        customer = row[1]
        previous_element = ""
        previous_elements = []

        for (col_index, data) in enumerate(row)
          if logging
            print("$data, ")
          end
          if length(row) == 2 && col_index == 2
              push!(mu, previous_element => parse(Float64, data))
          elseif length(row) == 3 && (length(previous_elements) >= 1 && occursin("LW", previous_elements[1]))
              first_element = previous_elements[1]
              if logging
                println("$first_element")
              end
              previous_element = data
              push!(previous_elements, data)
              if length(previous_elements) > 2
                  push!(stock_levels, previous_elements[1] => Int64[parse(Int64,previous_elements[2]), parse(Int64, previous_elements[3])])
              end
          elseif checkIfStringIsNumber(data)
              if logging 
                println("Add entry: [$customer, $previous_element, $data]")
              end
              push!(pairs, [customer, previous_element, parse(Int64, data)])
          else
              if !in(data, nodes)
                if logging
                  println("Added $data to $index")
                end
                push!(indexes, data => index)
                push!(nodes, data)
                index += 1
              end

              previous_element = data
              push!(previous_elements, data)
          end
        end
    end


    number_of_nodes = length(nodes)
    connections = zeros(Float64, number_of_nodes, number_of_nodes)

    for pair in pairs
      if logging
        print("pair: $pair: ")
      end

      pair_1 = pair[1]
      pair_2 = pair[2]
      index_1 = indexes[pair_1]
      index_2 = indexes[pair_2]
      value = pair[3]

      connections[index_1, index_2] = value
    end

    return connections, indexes, pairs, nodes, mu, stock_levels
end

end
