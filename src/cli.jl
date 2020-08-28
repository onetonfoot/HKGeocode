using Comonicon, Base.Iterators, DataFrames, CSV
using ProgressMeter

"""
HKGeocode is a small CLI to geocode Hong Kong addresses

# Arguments

- `input`: A file with each address on new line or stdin 

# Options

- `-n, --n_parallel <number>`: The number of requests to make in parallel
"""
@main function hk_geo_code(
    input::String="";
    n_parallel::Int=1,
    )

    lines = if isempty(input)
        if bytesavailable(stdin) > 0
            readlines(stdin)
        else
            error("No input provided")
        end
    elseif isfile(input)
        readlines(input)
    else input isa String
        split(input, "\n")
    end

    missing_row = (building_name = missing,
                   building_no = missing,
                   street_name = missing, 
                   lat = missing,
                   long = missing,
                   score = missing)
    results = []

    chunks = collect(partition(lines, n_parallel))

    @showprogress "Geo Coding " for chunk in chunks
        result_chunk = Array{Any}(undef, length(chunk))
        @sync for (i, addr) in enumerate(chunk)
            @async try
                row = hk_geocode(addr)
                result_chunk[i] = row
            catch
                result_chunk[i] = missing_row
            end
        end
        append!(results, result_chunk)
    end

    df = DataFrame(results)
    CSV.write(stdout, df)
end

# import Comonicon: cmd_name, Types
# How to rename the command?
# cmd_name(::Types.EntryCommand) = "hk-geocode"
# m = CASTED_COMMANDS["main"]
# typeof(m)
# m.root.name = "hk-geocode"