module ErlangLossSolver

using ArgParse
using DelimitedFiles
using Parsers

using Debugger

export parseCommandline, parseInput

function checkIfStringIsNumber(string)
    :Bool
    numbers = r"^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$"

    return occursin(numbers, string)
end

function parseCommandline()::Dict{String,Any}
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

    T = 0
    customer_indexes = Dict{String,Int64}()
    stock_indexes = Dict{String,Int64}()
    pairs = []
    mu = Dict{String,Float64}()
    stock_levels = Dict{String,Array{Int64}}()

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
            if previous_element == "T"
                T = parse(Float64, data)
            elseif length(row) == 2 && col_index == 2
                push!(mu, previous_element => parse(Float64, data))
            elseif length(row) == 3 &&
                   (length(previous_elements) >= 1 && occursin("LW", previous_elements[1]))
                first_element = previous_elements[1]
                if logging
                    println("$first_element")
                end
                previous_element = data
                push!(previous_elements, data)
                if length(previous_elements) > 2
                    push!(
                        stock_levels,
                        previous_elements[1] => Int64[
                            parse(Int64, previous_elements[2]),
                            parse(Int64, previous_elements[3]),
                        ],
                    )
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

                    if data != "T"
                        push!(nodes, data)
                    end
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
        customer_index = customer_indexes[customer]
        storage_index = stock_indexes[storage]
        value = pair[3]

        connections[customer_index, storage_index] = value
    end

    return T, connections, [customer_indexes, stock_indexes], pairs, nodes, mu, stock_levels
end

function findClosestStorage(
    connections::Array{Float64,2},
    stock_indexes::Dict{String,Int64},
    customer_index::Int,
    logging::Bool,
)::String
    row = connections[customer_index, :]
    row[row .== 0.0] .= typemax(Float64)

    storage_index = argmin(row)
    storage_name = collect(keys(stock_indexes))[storage_index]
    if logging
        println("row: ", row)
        println("argmin: ", storage_index)
        println("storage name: ", storage_name)
    end

    return storage_name
end

function runOneIteration!(
    probabilities::Dict{String,Float64},
    customer_mu::Array{Float64},
    storages_E::Dict{String,Float64},
    connections::Array{Float64,2},
    stock_indexes::Dict{String,Int64},
    stock_levels::Dict{String,Array{Int64}},
    distance::Float64,
    T::Float64,
    logging::Bool,
)
    for (col_index, connection_col) in enumerate(eachcol(connections))
        if logging
            println("col index: $col_index, connection_col: $connection_col")
        end

        storage_E = 0
        print("mu: ")
        for (row_index, cell) in enumerate(connection_col)
            if logging
                println("row index: $row_index, cell: $cell")
            end

            if (0 < cell <= distance)
                print(customer_mu[row_index], " ")
                storage_prabability = 1
                if (cell > 1)
                    storage_name =
                        findClosestStorage(connections, stock_indexes, row_index, logging)
                    storage_prabability = probabilities[storage_name]
                end
                #println("storage probability: ", storage_prabability)
                storage_E = storage_E + storage_prabability * customer_mu[row_index] * T
            end
        end
        println("")
        push!(storages_E, collect(keys(stock_indexes))[col_index] => storage_E)
    end

    println("### Problem initialized ###")
    println("storages E: $storages_E")

    push!(stock_levels, "CW" => [1 1])

    for (storage_index, storage) in enumerate(stock_indexes)
        storage_name = storage[1]
        println("")
        println("storage name: ", storage_name)
        E = storages_E[storage_name]
        m = stock_levels[storage_name][2]
        println("E: ", E, " m: ", m)

        nominator = ((E^m) / factorial(m))
        denominator = 0
        for i in collect(0:m)
            denominator = denominator + (E^i / factorial(i))
        end

        probability = nominator / denominator
        println("nominator: ", nominator, " denominator: ", denominator)
        println("probability: ", probability)

        push!(probabilities, storage_name => probability)
    end

    println("probabilities of not meting the need:")
    println("probabilities: ", probabilities)
end

function initialize!(
    probabilities::Dict{String,Float64},
    customer_mu::Array{Float64},
    storages_E::Dict{String,Float64},
    connections::Array{Float64,2},
    stock_indexes::Dict{String,Int64},
    stock_levels::Dict{String,Array{Int64}},
    max_num_iterations::Float64,
    T::Float64,
    logging::Bool,
)
    println("Maximal number of initialization iterations: ", max_num_iterations)

    for distance in collect(1:max_num_iterations)
        runOneIteration!(
            probabilities,
            customer_mu,
            storages_E,
            connections,
            stock_indexes,
            stock_levels,
            distance,
            T,
            logging,
        )
    end
end

function haveWeConverged(
    new_probabilities::Dict{String,Float64},
    old_probabilities::Dict{String,Float64},
)::Bool
    new_values = [value for value in values(new_probabilities)]
    old_values = [value for value in values(old_probabilities)]

    for (index, new_value) in enumerate(new_values)
        if !isapprox(new_value, old_values[index])
            return false
        end
    end

    return true
end

function runUntilConvergence!(
    probabilities::Dict{String,Float64},
    customer_mu::Array{Float64},
    storages_E::Dict{String,Float64},
    connections::Array{Float64,2},
    stock_indexes::Dict{String,Int64},
    stock_levels::Dict{String,Array{Int64}},
    max_num_iterations::Float64,
    T::Float64,
    logging::Bool,
)

    distance = max_num_iterations
    converged = false
    iteration = 1
    while !converged
        old_probabilities = probabilities
        ErlangLossSolver.runOneIteration!(
            probabilities,
            customer_mu,
            storages_E,
            connections,
            stock_indexes,
            stock_levels,
            distance,
            T,
            logging,
        )

        if haveWeConverged(probabilities, old_probabilities)
            converged = true
        end
        iteration = iteration + 1
    end

    println("Converged after ", iteration, " iterations")

end



end
