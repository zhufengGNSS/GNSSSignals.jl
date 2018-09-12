"""
$(SIGNATURES)

Returns functions to generate sampled code and code phase for the GPS L1 signal.
# Examples
```julia-repl
julia> gen_gpsl1_code, get_gpsl1_code_phase = init_gpsl1_codes()
julia> gen_gpsl1_code(samples, f, φ₀, f_s, sat)
julia> get_code_phase(sample, f, φ₀, f_s)
```
"""
function GPSL1()
    code_length = 1023
    codes = read_in_codes(joinpath(Base.Pkg.dir("GNSSSignals"), "data/codes_gps_l1.bin"), code_length)
    GPSL1(codes, code_length, 1023e3, 1.57542e9)
end

function read_real_signal(filename, length_to_read)
    file_stats = stat(filename)
    #num_samples = floor(Int, file_stats.size / 4)
    signal_interleaved = open(filename) do file_stream
        read(file_stream, Float32; all=true)
    end
    signal = Complex64(signal_interleaved[1:2:end], signal_interleaved[2:2:end])
    signal_interleaved = nothing; #'clear' the variable
    gc() # run garbage collector so memory gets cleared
end