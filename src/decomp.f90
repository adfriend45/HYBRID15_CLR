subroutine decomp
use PARS_MOD
use VARS_MOD
implicit none
T_soil = TC
! Temperature and sm modifiers from Manas code (EightPoolCenturyMod.F90)
tmod = q10 ** ((T_soil - T_ref) / 10.0)
tmod = min (one, tmod)
tmod = max (zero, tmod)
denom = saturation_to_field_capacity * swc_field_capacity
! swc is volumetric soil water I think. guess calc like this
! really need soil depth. need to make consistent with hydro
swc = sm / (SM_max / swc_field_capacity)
wfps = 100.0 * swc / denom
wmod = exp (((wfps - wfps_threshold) ** 2) / (-moisture_dry_width))
wmod = min (one, wmod)
wmod = max (zero, wmod)
loss = tmod * wmod * CDM * SOM / tau_SOM
dSOM = litter - loss / CDM
SOM = SOM + dt_s * dSOM
end subroutine decomp
