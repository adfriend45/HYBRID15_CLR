subroutine grow
use VARS_MOD
implicit none
Raut = MC * Ag_crown / 2.0
npp = (gpp - Raut) / CDM
litter = biomass / tau_biomass
dbiomass = npp - litter
biomass = biomass + dt_s * dbiomass
end subroutine grow
