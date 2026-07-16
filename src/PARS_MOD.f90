module PARS_MOD
!----------------------------------------------------------------------!
implicit none
!----------------------------------------------------------------------!
integer, parameter :: ndays  =   365
integer, parameter :: nt     =    48
integer, parameter :: nland  = 67420
integer, parameter :: ntimes =  1460
integer, parameter :: nlon   =   720
integer, parameter :: nlat   =   360
!----------------------------------------------------------------------!
real, parameter :: zero      = 0.0
real, parameter :: one       = 1.0
real, parameter :: eps       = 1.0e-8
!----------------------------------------------------------------------!
real, parameter :: dt_hr     = 0.5
real, parameter :: dt_s      = dt_hr * 60.0 * 60.0
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
! Biomass turnover (fraction s-1)
real, parameter :: tau_biomass = 0.5 * 60.0 * 60.0 * 24.0 * 365.0
! SOM turnover (fraction s-1)
real, parameter :: tau_SOM = 2.0 * 60.0 * 60.0 * 24.0 * 365.0
real, parameter :: q10     = 2.0  ! from Manas namelist
real, parameter :: T_ref   = 25.0 ! from Manas namelist
real, parameter :: saturation_to_field_capacity = 1.72
real, parameter :: swc_field_capacity = 0.5
real, parameter :: wfps_threshold = 60.0
real, parameter :: moisture_dry_width = 800.0
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
