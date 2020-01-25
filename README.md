# erlang-loss-solver
Tool perform Approximate Evaluation by using the Erlang Loss Formula with the "overflow" process.

## Install

Download [Julia](https://julialang.org/downloads/) and then add the dependencies.

```julia
using Pkg
Pkg.add("ArgParse")
Pkg.add("DelimitedFiles")
Pkg.add("Parsers")
Pkg.add("Test")
```

## Usage

From the command line, use the following command:

```bash
julia main.jl --input <Input File>
```

For the test example (input\_format.csv) the output is the following:

```bash
[ Info: input_format.csv
[ Info:     LW1  LW2  CW   
[ Info: C1 [1.0, 0.0, 2.0]
[ Info: C2 [1.0, 2.0, 2.0]
[ Info: C3 [2.0, 1.0, 2.0]
[ Info: C4 [0.0, 1.0, 2.0]
[ Info: Maximal number of initialization iterations: 2.0
[ Info: mu: customer: 1 0.1 
[ Info: mu: customer: 2 0.2 
[ Info: 
[ Info: mu: customer: 3 0.4 
[ Info: mu: customer: 4 0.2 
[ Info: 
[ Info: 
[ Info: storages E: Dict("LW1" => 0.6000000000000001,"LW2" => 1.2000000000000002,"CW" => 0.0)
[ Info: 
[ Info: storage name: LW1
[ Info: E: 0.6000000000000001  m: 1
[ Info: nominator: 0.6000000000000001 denominator: 1.6
[ Info: probability: 0.37500000000000006
[ Info: 
[ Info: storage name: LW2
[ Info: E: 1.2000000000000002  m: 3
[ Info: nominator: 0.28800000000000014 denominator: 3.2080000000000006
[ Info: probability: 0.08977556109725689
[ Info: 
[ Info: storage name: CW
[ Info: E: 0.0  m: 1
[ Info: nominator: 0.0 denominator: 1.0
[ Info: probability: 0.0
[ Info: probabilities of not meting the need:
[ Info: probabilities: Dict("LW1" => 0.37500000000000006,"LW2" => 0.08977556109725689,"CW" => 0.0)
[ Info: mu: customer: 1 0.1 
[ Info: mu: customer: 2 0.2 
[ Info: mu: customer: 3 0.4 
[ Info: 
[ Info: mu: customer: 2 0.2 
[ Info: mu: customer: 3 0.4 
[ Info: mu: customer: 4 0.2 
[ Info: 
[ Info: mu: customer: 1 0.1 
[ Info: mu: customer: 2 0.2 
[ Info: mu: customer: 3 0.4 
[ Info: mu: customer: 4 0.2 
[ Info: 
[ Info: storages E: Dict("LW1" => 0.6718204488778056,"LW2" => 1.35,"CW" => 0.3327306733167083)
[ Info: 
[ Info: storage name: LW1
[ Info: E: 0.6718204488778056  m: 1
[ Info: nominator: 0.6718204488778056 denominator: 1.6718204488778055
[ Info: probability: 0.4018496420047733
[ Info: 
[ Info: storage name: LW2
[ Info: E: 1.35  m: 3
[ Info: nominator: 0.41006250000000005 denominator: 3.6713125000000004
[ Info: probability: 0.11169370626989666
[ Info: 
[ Info: storage name: CW
[ Info: E: 0.3327306733167083  m: 1
[ Info: nominator: 0.3327306733167083 denominator: 1.3327306733167084
[ Info: probability: 0.24966085044674186
[ Info: probabilities of not meting the need:
[ Info: probabilities: Dict("LW1" => 0.4018496420047733,"LW2" => 0.11169370626989666,"CW" => 0.24966085044674186)
[ Info: ### Problem initialized ###
[ Info: mu: customer: 1 0.1 
[ Info: mu: customer: 2 0.2 
[ Info: mu: customer: 3 0.4 
[ Info: 
[ Info: mu: customer: 2 0.2 
[ Info: mu: customer: 3 0.4 
[ Info: mu: customer: 4 0.2 
[ Info: 
[ Info: mu: customer: 1 0.1 
[ Info: mu: customer: 2 0.2 
[ Info: mu: customer: 3 0.4 
[ Info: mu: customer: 4 0.2 
[ Info: 
[ Info: storages E: Dict("LW1" => 0.6893549650159174,"LW2" => 1.3607398568019096,"CW" => 0.37514223272673997)
[ Info: 
[ Info: storage name: LW1
[ Info: E: 0.6893549650159174  m: 1
[ Info: nominator: 0.6893549650159174 denominator: 1.6893549650159174
[ Info: probability: 0.40805809275815647
[ Info: 
[ Info: storage name: LW2
[ Info: E: 1.3607398568019096  m: 3
[ Info: nominator: 0.4199272585284701 denominator: 3.70647359427502
[ Info: probability: 0.11329562934890061
[ Info: 
[ Info: storage name: CW
[ Info: E: 0.37514223272673997  m: 1
[ Info: nominator: 0.37514223272673997 denominator: 1.37514223272674
[ Info: probability: 0.2728024954792338
[ Info: probabilities of not meting the need:
[ Info: probabilities: Dict("LW1" => 0.40805809275815647,"LW2" => 0.11329562934890061,"CW" => 0.2728024954792338)
[ Info: Converged after 2 iterations
[ Info: Customer: 1
[ Info: Customer: 2
[ Info: Customer: 3
[ Info: Customer: 4
[ Info: alpha customer: 1 storage: LW1 0.05919419072418435
[ Info: theta customer: 1 storage: CW 0.04080580927581565
[ Info: 
[ Info: alpha customer: 2 storage: LW1 0.1183883814483687
[ Info: alpha customer: 2 storage: LW2 0.07236537886564182
[ Info: theta customer: 2 storage: CW 0.0816116185516313
[ Info: 
[ Info: alpha customer: 3 storage: LW1 0.026825772367581283
[ Info: alpha customer: 3 storage: LW2 0.3546817482604398
[ Info: theta customer: 3 storage: CW 0.04531825173956025
[ Info: 
[ Info: alpha customer: 4 storage: LW2 0.1773408741302199
[ Info: theta customer: 4 storage: CW 0.022659125869780125
[ Info: 
[ Info: customers_alphas: Dict("C1" => 0.05919419072418435,"C2" => 0.19075376031401053,"C3" => 0.38150752062802107,"C4" => 0.1773408741302199)
[ Info: customers_mu: Dict("C1" => 0.1,"C2" => 0.2,"C3" => 0.4,"C4" => 0.2)
[ Info: Customer C1:
[ Info:   fill_rate: 0.5919419072418435 = 59.194190724184345%
[ Info: Customer C2:
[ Info:   fill_rate: 0.9537688015700526 = 95.37688015700526%
[ Info: Customer C3:
[ Info:   fill_rate: 0.9537688015700526 = 95.37688015700526%
[ Info: Customer C4:
[ Info:   fill_rate: 0.8867043706510994 = 88.67043706510994%
[ Info: customer_mu: Dict("C1" => 0.1,"C2" => 0.2,"C3" => 0.4,"C4" => 0.2), summed: 0.9000000000000001
[ Info: customers_theta: Dict("C1" => 0.04080580927581565,"C2" => 0.0816116185516313,"C3" => 0.04531825173956025,"C4" => 0.022659125869780125), summed: 0.19039480543678733
[ Info: overall time-based fillrate: 0.7884502161813476
```

## Unit tests

To run the unit test, run the following in the command line:

```bash
julia test.jl
```
