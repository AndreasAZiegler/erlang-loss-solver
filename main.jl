include("./ErlangLossSolver.jl")
include("./ErlangLossSolverApplication.jl")
using .ErlangLossSolver
using .ErlangLossSolverApplication

using Logging

function main()
    # Deactivate logging
    Logging.disable_logging(Logging.Warn)

    # Parse args
    parsed_args = ErlangLossSolver.parseCommandline()

    input_file_name = parsed_args["input"]
    accuracy = parsed_args["accuracy"]

    ErlangLossSolverApplication.main(input_file_name, accuracy)
end

main()
