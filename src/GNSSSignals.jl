module GNSSSignals

    using Yeppp, DocStringExtensions

    export gen_carrier, get_carrier_phase, gen_sat_code, get_sat_code_phase, init_gpsl1_codes

    include("gpsl1.jl")

    """
    $(SIGNATURES)

    Generates carrier.
    `samples` is the range of samples, `f` the frequency, `φ₀` the phase and `f_s` the sampling frequency.
    # Examples
    ```julia-repl
    julia> gen_carrier(1:4000, 200, 10 * π / 180, 4e6)
    ```
    """
    function gen_carrier(samples, f, φ₀, f_s)
        arg = (2 * π * f / f_s) .* samples .+ φ₀
        sin_sig, cos_sig = Yeppp.sin(arg), Yeppp.cos(arg) # use Yeppp for better performance
        complex.(cos_sig, sin_sig) # or cis.(arg)
    end

    """
    $(SIGNATURES)

    Calculates carrier phase.
    `sample` is the sample, `f` the frequency, `φ₀` the phase and `f_s` the sampling frequency.
    # Examples
    ```julia-repl
    julia> get_carrier_phase(4000, 200, 10 * π / 180, 4e6)
    ```
    """
    function get_carrier_phase(sample, f, φ₀, f_s)
        mod2pi((2 * π * f / f_s) * sample + φ₀)
    end

    """
    $(SIGNATURES)

    Generates the sampled code for a given code.
    `samples` is the range of samples, `f` the frequency, `φ₀` the phase, 
    `f_s` the sampling frequency and `code` the code.
    # Examples
    ```julia-repl
    julia> gen_sat_code(1:4000, 1023e3, 2, 4e6, [1, -1, 1, 1, 1])
    ```
    """
    function gen_sat_code(samples, f, φ₀, f_s, code)
        code_indices = floor.(Int16, f / f_s .* samples .+ φ₀)
        code_indices .= 1 .+ mod.(code_indices - 1, length(code))
        code[code_indices]
    end

    """
    $(SIGNATURES)

    Calculates the code phase.
    `sample` is the sample, `f` the frequency, `φ₀` the phase, 
    `f_s` the sampling frequency and `code_length` the length of the code.
    # Examples
    ```julia-repl
    julia> get_sat_code_phase(4000, 1023e3, 2, 4e6, 1023)
    ```
    """
    function get_sat_code_phase(sample, f, φ₀, f_s, code_length)
        mod(f / f_s * sample + φ₀ + code_length / 2, code_length) - code_length / 2
    end

    """
    $(SIGNATURES)

    Reads codes from a file.
    `filename` is the filename including its path and `code_length` the length of the code.
    # Examples
    ```julia-repl
    julia> read_in_codes("/data/gpsl1codes.bin", 1023)
    ```
    """
    function read_in_codes(filename, code_length)
        file_stats = stat(filename)
        num_prn_codes = floor(Int, file_stats.size / code_length)
        codes = open(filename) do file_stream
            float(read(file_stream, Int8, code_length, num_prn_codes))
        end
    end 

end