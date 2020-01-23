module ErlangLossSolver

using ArgParse
using CSV
using DelimitedFiles
using Parsers

using Debugger

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

    customer_indexes = Dict{String,Int64}()
    stock_indexes = Dict{String,Int64}()
    pairs = []
    mu = Dict{String,Float64}()
    stock_levels = Dict{String, Array{Int64}}()

    customer_index = 1
    stock_index = 1
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
                if (occursin("LW", data) || "CW" == data)
                  push!(stock_indexes, data => stock_index)
                  stock_index += 1
                elseif occursin("C", data)
                  push!(customer_indexes, data => customer_index)
                  customer_index += 1
                end

                push!(nodes, data)
              end

              previous_element = data
              push!(previous_elements, data)
          end
        end
    end


    number_of_customers = length(customer_indexes)
    number_of_storages = length(stock_indexes)
    connections = zeros(Float64, number_of_customers, number_of_storages)

    for pair in pairs
      if logging
        println("pair: $pair: ")
      end

      customer = pair[1]
      storage = pair[2]
      println("customer: $customer, storage: $storage")
      customer_index = customer_indexes[customer]
      storage_index = stock_indexes[storage]
      println("customer index: $customer_index, storage_index: $storage_index")
      value = pair[3]

      connections[customer_index, storage_index] = value
    end

    return connections, [customer_indexes, stock_indexes], pairs, nodes, mu, stock_levels
end

end
