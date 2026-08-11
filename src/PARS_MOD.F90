module PARS_MOD
!----------------------------------------------------------------------!
implicit none
!----------------------------------------------------------------------!
integer, parameter :: ndays   =   365
integer, parameter :: nt      =    48
integer, parameter :: nland   = 67420
integer, parameter :: ntimes  =  1460
integer, parameter :: nlon    =   720
integer, parameter :: nlat    =   360
integer, parameter :: n_pools =     8
integer, parameter :: ip_surface_structural = 1
integer, parameter :: ip_soil_structural    = 2
integer, parameter :: ip_active_som         = 3
integer, parameter :: ip_surface_microbe    = 4
integer, parameter :: ip_surface_metabolic  = 5
integer, parameter :: ip_soil_metabolic     = 6
integer, parameter :: ip_slow_som           = 7
integer, parameter :: ip_passive_som        = 8
!----------------------------------------------------------------------!
real, parameter :: zero      = 0.0
real, parameter :: one       = 1.0
real, parameter :: eps       = 1.0e-8
!----------------------------------------------------------------------!
real, parameter :: dt_years  = one / 365.0
real, parameter :: dt_hr     = 0.5
real, parameter :: dt_s      = dt_hr * 60.0 * 60.0
real, parameter :: day_s     = 24.0 * 60.0 * 60.0
real, parameter :: sixhr_s   =  6.0 * 60.0 * 60.0
real, parameter :: mol_per_J = 2.3e-6
real, parameter :: tf        = 273.15
real, parameter :: Topt_J    = 31.0
real, parameter :: omega_J   = 18.0
real, parameter :: SM_MIN    = 250.0
real, parameter :: SM_MAX    = 1505.0
real, parameter :: b_RC      = 10.5
real, parameter :: swp_max   = -1.1e-3 ! rawls et al., 92, loam REF
real, parameter :: bsoil     = 4.5     ! rawls et al., 92, loam REF
real, parameter :: a_Ksoil   = 2.0 + 3.0 / bsoil !
real, parameter :: Vcmax_top = 30.0e-6
real, parameter :: Jmax_top  = 2.1 * Vcmax_top
real, parameter :: Ksoil_sat = 10**4 ! dewar21 (mol m-2 s-1 MPa-1)
real, parameter :: Kx        = 0.01 !0.01 dewar21; ! 3.0e-5 optimised
real, parameter :: Oi        = 210.0e-3 ! mol mol-1
real, parameter :: lwp_crit  = -2.0 ! dewar18
real, parameter :: gmin      = 5.0e-3
real, parameter :: gmax      = 0.180
real, parameter :: KPh       = exp (0.00963 * (0.02 / 0.001) - 2.43)
real, parameter :: KPAR      = 0.65
real, parameter :: Mw        = 18.015 ! g mol-1
real, parameter :: Ma        = 28.97  ! g mol-1
real, parameter :: MC        = 12.011 ! g[C] mol[C]-1
real, parameter :: asw       = 0.12   ! https://doi.org/10.1029/2020JD033582
real, parameter :: emm       = 0.99   ! Google AI
real, parameter :: sb        = 5.67e-8 ! W m-2 K-4
real, parameter :: cp        = 1012.0! J kg-1 K-1
real, parameter :: karman    = 0.40
real, parameter :: CDM       = 0.474 ! from hybrid14_4; g[C] g[DM]-1
!----------------------------------------------------------------------!
! Biomass turnover (fraction s-1)
!----------------------------------------------------------------------!
real, parameter :: tau_biomass = 0.5 * 60.0 * 60.0 * 24.0 * 365.0
!----------------------------------------------------------------------!
! SOM turnover (fraction s-1)
!----------------------------------------------------------------------!
real, parameter :: tau_SOM = 2.0 * 60.0 * 60.0 * 24.0 * 365.0
!----------------------------------------------------------------------!
real, parameter :: q10     = 2.0  ! from Manas namelist
real, parameter :: T_ref   = 25.0 ! from Manas namelist
real, parameter :: saturation_to_field_capacity = 1.72
real, parameter :: swc_field_capacity = 0.5
real, parameter :: wfps_threshold = 60.0
real, parameter :: moisture_dry_width = 800.0
!----------------------------------------------------------------------!
! Maximum annual SOM decay rates, yr-1, ordered by the 8 pool indices
! above.
!----------------------------------------------------------------------!
real, parameter, dimension (n_pools) :: k_decay_max = &
                      (/ 3.9, 4.8, 7.3, 6.0, 14.8, 18.5, 0.2, 0.0045 /)
!----------------------------------------------------------------------!
! Soil texture fractions. They should sum to 1.
!----------------------------------------------------------------------!
real :: sand_fraction = 0.40
real :: silt_fraction = 0.30
real :: clay_fraction = 0.30
!----------------------------------------------------------------------!
! Litter vegetation controls
!----------------------------------------------------------------------!
real :: root_fraction = 0.60 ! fraction of litter in root
!----------------------------------------------------------------------!
! Litter quality controls.
!----------------------------------------------------------------------!
real :: shoot_lignin_to_n    = 16.0
real :: root_lignin_to_n     = 35.0
real :: shoot_lignin_frac    = 0.12
real :: root_lignin_frac     = 0.22
!----------------------------------------------------------------------!
! Century litter-partition coefficients.  Fm = intercept - slope * L:N.
!----------------------------------------------------------------------!
real :: metabolic_fraction_intercept = 0.85
real :: metabolic_fraction_lignin_n_slope = 0.018
!----------------------------------------------------------------------!
! Decomposition-rate modifiers.
!----------------------------------------------------------------------!
real :: active_texture_coefficient = 0.75
!----------------------------------------------------------------------!
! Pool 1 surface structural litter transfer fractions.
!----------------------------------------------------------------------!
real :: pool1_surface_structural_co2_fraction = 0.30
real :: pool1_surface_structural_transfer_fraction = 0.70
!----------------------------------------------------------------------!
! Pool 2 soil/root structural litter transfer fractions.
!----------------------------------------------------------------------!
real :: pool2_soil_structural_co2_fraction = 0.30
real :: pool2_soil_structural_transfer_fraction = 0.70
!----------------------------------------------------------------------!
! Pool 4: surface microbe.
!----------------------------------------------------------------------!
real :: surface_microbe_co2_fraction = 0.60
real :: surface_microbe_slow_fraction = 0.40
!----------------------------------------------------------------------!
! Pool 5: surface metabolic litter.
!----------------------------------------------------------------------!
real :: surface_metabolic_co2_fraction = 0.55
real :: surface_metabolic_microbe_fraction = 0.45
!----------------------------------------------------------------------!
! Pool 6: soil/root metabolic litter.
!----------------------------------------------------------------------!
real :: soil_metabolic_co2_fraction = 0.55
real :: soil_metabolic_active_fraction = 0.45
!----------------------------------------------------------------------!
! Pool 7: slow SOM.
!----------------------------------------------------------------------!
real :: slow_som_co2_fraction = 0.55
real :: slow_som_passive_base_fraction = 0.003
real :: slow_som_passive_clay_multiplier = 0.009
!----------------------------------------------------------------------!
! Pool 8: passive SOM.
!----------------------------------------------------------------------!
real :: passive_som_co2_fraction = 0.55
real :: passive_som_active_fraction = 0.45
!----------------------------------------------------------------------!
! Active SOM partition coefficients.
real :: active_som_co2_intercept = 0.85
real :: active_som_co2_silt_clay_slope = 0.68
real :: active_som_leach_water_scale = 18.0
real :: active_som_leach_base = 0.01
real :: active_som_leach_sand_multiplier = 0.04
real :: active_som_passive_base_fraction = 0.003
real :: active_som_passive_clay_multiplier = 0.032
!----------------------------------------------------------------------!
! Decomposition-rate modifiers.
!----------------------------------------------------------------------!
real :: structural_lignin_decay_coefficient = 3.0
!----------------------------------------------------------------------!
! Molar gas constant (J mol-1 K-1)
!----------------------------------------------------------------------!
real, parameter :: R = 8.314463
! Water vapour specific gas constant (J kg-1 K-1)
real, parameter :: Rv  = 1.0e3 * R / Mw  ! J kg-1 K-1
! Dry air specific gas constant (J kg-1 K-1)
real, parameter :: Ra  = 1.0e3 * R / Ma  ! J kg-1 K-1
!----------------------------------------------------------------------!
end module PARS_MOD
