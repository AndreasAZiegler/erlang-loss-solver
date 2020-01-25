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

function parseInput(file_name::String)
    input_file = readdlm(file_name, '\n')

    T = 0
    customer_indexes = Dict{String,Int64}()
    stock_indexes = Dict{String,Int64}()
    pairs = []
    mu = Dict{String,Float64}()
    stock_levels = Dict{String,Int64}()

    customer_index = 1
    stock_index = 1
    nodes = Set{String}()
    for (row_index, line) in enumerate(input_file)
        row = split(line, ",")
        @debug "$row"

        customer = row[1]
        previous_element = ""
        previous_elements = []

        for (col_index, data) in enumerate(row)
            @debug "$data, "
            if previous_element == "T"
                T = parse(Float64, data)
            elseif length(row) == 2 && col_index == 2 && occursin("C", previous_elements[1])
                push!(mu, previous_element => parse(Float64, data))
            elseif length(row) == 2 && col_index == 2 &&
                   (length(previous_elements) >= 0 && occursin("LW", previous_elements[1]))
                first_element = previous_elements[1]
                @debug "$first_element"
                previous_element = data
                push!(previous_elements, data)
                if length(previous_elements) > 1
                    push!(
                        stock_levels,
                        previous_elements[1] => parse(Int64, previous_elements[2]),
                    )
                end
            elseif checkIfStringIsNumber(data)
                @debug "Add entry: [$customer, $previous_element, $data]"
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
        @debug "pair: $pair: "

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
)::String
    row = connections[customer_index, :]
    row[row .== 0.0] .= typemax(Float64)

    storage_index = argmin(row)
    storage_name = collect(keys(stock_indexes))[storage_index]
    @debug "row: $row"
    @debug "argmin: $storage_index"
    @debug "storage name: $storage_name"

    return storage_name
end

function calculateCustomerAlpha(
    customers_alphas::Dict{String,Float64},
    customers_theta::Dict{String,Float64},
    probabilities::Dict{String,Float64},
    customer_mu::Array{Float64},
    connections::Array{Float64,2},
    storage_indexes::Dict{String,Int64},
    customer_indexes::Dict{String,Int64},
    distance::Float64,
)

    for (row_index, connection_row) in enumerate(eachrow(connections))
        @debug "col index: $row_index, connection_col: $connection_row"
        closest_storage_name = findClosestStorage(connections, storage_indexes, row_index)
        closest_storage_probability = probabilities[closest_storage_name]

        customer_alpha = 0
        for (col_index, cell) in enumerate(connection_row)
            @debug "row index: $col_index, cell: $cell"
            storage_name = collect(keys(storage_indexes))[col_index]

            if storage_name == "CW"
                theta = closest_storage_probability * customer_mu[row_index]
                @info "theta customer: $row_index storage: $storage_name $theta"
                push!(customers_theta, collect(keys(customer_indexes))[row_index] => theta)

                continue
            end

            if (0 < cell <= distance)
                storage_probability = probabilities[storage_name]
                remote_storage_probability = 1.0
                if (cell > 1)
                    remote_storage_probability = closest_storage_probability
                end
                alpha =
                    (1 - storage_probability) *
                    remote_storage_probability *
                    customer_mu[row_index]
                @info "alpha customer: $row_index storage: $storage_name $alpha"
                customer_alpha = customer_alpha + alpha

            end
        end
        @info ""
        push!(
            customers_alphas,
            collect(keys(customer_indexes))[row_index] => customer_alpha,
        )
    end
end

function calculateStorageE(
    probabilities::Dict{String,Float64},
    customer_mu::Array{Float64},
    storages_E::Dict{String,Float64},
    connections::Array{Float64,2},
    stock_indexes::Dict{String,Int64},
    distance::Float64,
    T::Float64,
)

    for (col_index, connection_col) in enumerate(eachcol(connections))
        @debug "col index: $col_index, connection_col: $connection_col"

        storage_E = 0
        for (row_index, cell) in enumerate(connection_col)
            @debug "row index: $row_index, cell: $cell"

            if (0 < cell <= distance)
                @info "mu: customer: $row_index $(customer_mu[row_index]) "
                storage_prabability = 1
                if (cell > 1)
                    storage_name = findClosestStorage(connections, stock_indexes, row_index)
                    storage_prabability = probabilities[storage_name]
                end
                storage_E = storage_E + storage_prabability * customer_mu[row_index] * T
            end
        end
        @info ""
        push!(storages_E, collect(keys(stock_indexes))[col_index] => storage_E)
    end
end

function runOneIteration!(
    probabilities::Dict{String,Float64},
    customer_mu::Array{Float64},
    storages_E::Dict{String,Float64},
    connections::Array{Float64,2},
    stock_indexes::Dict{String,Int64},
    stock_levels::Dict{String,Int64},
    distance::Float64,
    T::Float64,
)

    calculateStorageE(
        probabilities,
        customer_mu,
        storages_E,
        connections,
        stock_indexes,
        distance,
        T,
    )

    @info "storages E: $storages_E"

    push!(stock_levels, "CW" => 1)

    for (storage_index, storage) in enumerate(stock_indexes)
        storage_name = storage[1]
        @info ""
        @info "storage name: $storage_name"
        E = storages_E[storage_name]
        m = stock_levels[storage_name]
        @info "E: $E  m: $m"

        nominator = ((E^m) / factorial(m))
        denominator = 0
        for i in collect(0:m)
            denominator = denominator + (E^i / factorial(i))
        end

        probability = nominator / denominator
        @info "nominator: $nominator denominator: $denominator"
        @info "probability: $probability"

        push!(probabilities, storage_name => probability)
    end

    @info "probabilities of not meting the need:"
    @info "probabilities: $probabilities"
end

function initialize!(
    probabilities::Dict{String,Float64},
    customer_mu::Array{Float64},
    storages_E::Dict{String,Float64},
    connections::Array{Float64,2},
    stock_indexes::Dict{String,Int64},
    stock_levels::Dict{String,Int64},
    max_num_iterations::Float64,
    T::Float64,
)
    @info "Maximal number of initialization iterations: $max_num_iterations"

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
        )
    end

    @info "### Problem initialized ###"
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
    stock_levels::Dict{String,Int64},
    max_num_iterations::Float64,
    T::Float64,
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
        )

        if haveWeConverged(probabilities, old_probabilities)
            converged = true
        end
        iteration = iteration + 1
    end
    @info "Converged after $iteration iterations"
end

end
