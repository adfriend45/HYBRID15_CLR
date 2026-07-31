module VARS_MOD
use PARS_MOD
implicit none
character (len=200) :: home_dir
character (len=  4) :: cyr
character (len=200) :: filename
integer, dimension (nland) :: x_k, y_k
integer :: kyr_ce
integer :: kyr, ikyr
integer :: kday
integer :: kt
integer :: it
integer :: ihr
integer :: ic_count
integer :: k
integer :: kw
integer :: kl
integer :: ip ! SOM pool index (pool no.)
real, dimension (nlon) :: lon ! Longitude (degrees east)
real, dimension (nlat) :: lat ! Latitude (degrees north)
real, dimension (n_pools) :: pool_initial, c_state, decay, k_decay, c_start, input_vec
real, dimension (n_pools) :: transfer_vec, c_end
real :: co2_ppm (2023)
real :: hr
real :: tswrf
real :: pres
real :: tmp
real :: spfh
real :: pre
real :: dlwrf
real :: ugrd
real :: vgrd
real :: D0
real :: D_mol
real :: swp
real :: rho_mol
real :: RT_air
real :: pcp
real :: Jmax_T
real :: Vcmax_T
real :: Kc
real :: Ko
real :: es
real :: ea
real :: rwc
real :: sm
real :: Q_top
real :: TC
real :: PPT
real :: Vcmax_l
real :: Jmax_l
real :: Q_l
real :: Rd_leaf_l
real :: gs_leaf_a , Ag_leaf_a , Rd_leaf_a
real :: gs_leaf_ab, Ag_leaf_ab, Rd_leaf_ab
real :: gs_leaf_b , Ag_leaf_b , Rd_leaf_b
real :: gs_crown  , Ag_crown  , Rd_crown
real :: Ksoil
real :: Ktot
real :: f0
real :: km
real :: gamma_m
real :: ZCAP
real :: x_CAP_V
real :: w_CAP
real :: a_CAP
real :: ca_fmol
real :: gs_leaf_V
real :: Jelec
real :: x_CAP_J
real :: gs_leaf_J
real :: ci
real :: x_CAP
real :: scale
real :: LAI
real :: Abot
real :: raa1
real :: raa2
real :: raa3
real :: raa4
real :: raa5
real :: sm_q
real :: Lv
real :: Delta
real :: As
real :: rho_kg
real :: zp0
real :: h
real :: xh
real :: d
real :: z0
real :: u
real :: ras
real :: gamma
real :: rss
real :: rr
real :: rhr
real :: LE
real :: raa
real :: rac
real :: rsc
real :: AET
real :: PET
real :: dsm
real :: GPP_ann
real :: PPT_ann
real :: RO_ann
real :: ET_ann
real :: l, rt, t, b
real :: tmod
real :: T_soil ! oC
real :: denom
real :: wfps
real :: swc
real :: wmod
real :: amod
real :: texture_modifier
real :: fm_shoot, fm_root
real :: total_litter_day
real :: total_input
real :: shoot_input, root_input
real :: co2
real :: silt_plus_clay, ft, cal, cap, cas, total
real :: leaching_water_cm, leaching_water_day, leaching_cm_day, leached_c
real :: csp
real :: Raut
real :: gpp ! g[C] m-2 s-1
real :: npp ! g[DM] m-2 s-1
real :: litter ! g[DM] m-2 s-1
real :: dbiomass ! g[DM] m-2 s-1
real :: biomass ! g[DM] m-2
real :: SOM ! g[SOM] m-2
real :: L_ann ! g[C] m-2 yr-1
real :: Rh_ann ! g[C] m-2 yr-1
real :: NEE_ann ! g[C] m-2 yr-1
real, allocatable, dimension (:,:) :: tmp_global   ! K
real, allocatable, dimension (:,:) :: pre_global   ! kg m-2 s-1
real, allocatable, dimension (:,:) :: tswrf_global ! W m-2
real, allocatable, dimension (:,:) :: dlwrf_global ! W m-2
real, allocatable, dimension (:,:) :: spfh_global  ! kg[water] kg[air]-1
real, allocatable, dimension (:,:) :: pres_global  ! Pa
real, allocatable, dimension (:,:) :: ugrd_global  ! m s-1
real, allocatable, dimension (:,:) :: vgrd_global  ! m s-1
end module VARS_MOD
