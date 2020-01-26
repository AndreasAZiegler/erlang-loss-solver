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
Input file name: input_format.csv

Problem structure:
T = 2.0
    LW1  LW2  CW   
C1 [1.0, 0.0, 2.0]
C2 [1.0, 2.0, 2.0]
C3 [2.0, 1.0, 2.0]
C4 [0.0, 1.0, 2.0]

Problem initialized:
E values of storages:
Storage LW1: E = 0.6718204488778056
Storage LW2: E = 1.35
Storage CW: E = 0.3327306733167083

Probabilities of storages:
Storage LW1: probability = 0.4018496420047733
Storage LW2: probability = 0.11169370626989666
Storage CW: probability = 0.24966085044674186

Run until probabilities converged:

Iteration number: 2
E values of storages:
Storage LW1: E = 0.6893549650159174
Storage LW2: E = 1.3607398568019096
Storage CW: E = 0.37514223272673997

Probabilities of storages:
Storage LW1: probability = 0.40805809275815647
Storage LW2: probability = 0.11329562934890061
Storage CW: probability = 0.2728024954792338

Converged after 2 iterations

Print results:
Customer: 1 storage: LW1 α-value =  0.05919419072418435
Customer: 1 storage: CW  θ-value =  0.04080580927581565

Customer: 2 storage: LW1 α-value =  0.1183883814483687
Customer: 2 storage: LW2 α-value =  0.07236537886564182
Customer: 2 storage: CW  θ-value =  0.00924623968598948

Customer: 3 storage: LW1 α-value =  0.026825772367581283
Customer: 3 storage: LW2 α-value =  0.3546817482604398
Customer: 3 storage: CW  θ-value =  0.01849247937197896

Customer: 4 storage: LW2 α-value =  0.1773408741302199
Customer: 4 storage: CW  θ-value =  0.022659125869780125

Cusomters α-values:
Cusomter C1 α-value: 0.05919419072418435
Cusomter C2 α-value: 0.19075376031401053
Cusomter C3 α-value: 0.38150752062802107
Cusomter C4 α-value: 0.1773408741302199

Cusomters θ-values:
Cusomter C1 θ-value: 0.04080580927581565
Cusomter C2 θ-value: 0.00924623968598948
Cusomter C3 θ-value: 0.01849247937197896
Cusomter C4 θ-value: 0.022659125869780125

Calculate fill rates:
Customer C1 fill rate: 0.5919419072418435 = 59.194190724184345%
Customer C2 fill rate: 0.9537688015700526 = 95.37688015700526%
Customer C3 fill rate: 0.9537688015700526 = 95.37688015700526%
Customer C4 fill rate: 0.8867043706510994 = 88.67043706510994%

Overall time based fillrate: 0.8986626064404842 = 89.86626064404842%
```

## Unit tests

To run the unit test, run the following in the command line:

```bash
julia test.jl
```
