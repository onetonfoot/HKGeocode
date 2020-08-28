using Test, HKGeocode
using HKGeocode: make_request

@testset "geocode" begin
    @test hk_geocode("Moko Prince Edwards") isa NamedTuple
end