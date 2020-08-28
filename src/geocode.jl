using HTTP, JSON3
using JSON3.StructTypes

parse_float(x) = parse(Float64, x)
parse_int(x) = parse(Int, x)

# another option but not documented and reutrns northing and eastings
# const url = "https://geodata.gov.hk/gs/api/v1.0.0/locationSearch"

# Documentation for this API can be found here
# https://www.als.ogcio.gov.hk/docs/Data_Dictionary_for_ALS_EN.pdf
const url = "https://www.als.ogcio.gov.hk/lookup"


function make_request(address)
    query = Dict(:q => address, :n => 1)
    headers = [
        "Accept" => "application/json"
    ]
    res = HTTP.get(url, headers, query=query)
    s = res.body |> String
    j = JSON3.read(s)
end

function hk_geocode(address)
    j = make_request(address)
    a = j.SuggestedAddress[1]

    # TODO: Chinese Address
    building_name = a.Address.PremisesAddress.EngPremisesAddress.BuildingName |> titlecase
    building_no = a.Address.PremisesAddress.EngPremisesAddress.EngStreet.BuildingNoFrom |> parse_int
    street_name = a.Address.PremisesAddress.EngPremisesAddress.EngStreet.StreetName |> titlecase
    lat = a.Address.PremisesAddress.GeospatialInformation.Latitude |> parse_float
    long = a.Address.PremisesAddress.GeospatialInformation.Longitude |> parse_float
    score = a[:ValidationInformation][:Score]

    (building_name = building_name,
    building_no = building_no,
    street_name = street_name, 
    lat = lat, 
    long = long,
    score = score) 
end