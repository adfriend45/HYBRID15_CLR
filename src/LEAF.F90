!======================================================================!
subroutine LEAF (Vcmax, Jmax, Q, Rd_leaf_max, gs_leaf, Ag_leaf, Rd_leaf)
!----------------------------------------------------------------------!
use PARS_MOD
use VARS_MOD
implicit none
!----------------------------------------------------------------------!
real, intent (in) :: Vcmax   ! mol[CO2] m-2 s-1
real, intent (in) :: Jmax    ! mol[e] m-2 s-1
real, intent (in) :: Q       ! mol[E] m-2 s-1
real, intent (in) :: Rd_leaf_max ! mol[CO2] m-2 s-1
real, intent(out) :: gs_leaf ! mol[H2O] m-2 s-1
real, intent(out) :: Ag_leaf ! mol[CO2] m-2 s-1
real, intent(out) :: Rd_leaf ! mol[CO2] m-2 s-1
!----------------------------------------------------------------------!
! Compute leaf-area specific soil hydraulic conductance
!                                               mol(water) m-2 s-1 MPa-1
!----------------------------------------------------------------------!
if (swp < swp_max) then
  Ksoil = Ksoil_sat * (swp_max / (swp - eps)) ** a_Ksoil
else
  Ksoil = Ksoil_sat
end if
!----------------------------------------------------------------------!
! Total leaf-area-specific hydraulic conductance
!                                               mol(water) m-2 s-1 MPa-1
!----------------------------------------------------------------------!
Ktot = one / ((one / (Ksoil + eps) + (one / (Kx + eps))))
!----------------------------------------------------------------------!
f0 = Vcmax
km = Kc * (one + Oi / Ko) ! mol mol-1
gamma_m = km
ZCAP = 1.6 * D_mol * f0 / (Ktot * abs (lwp_crit) * (gamma_m + pcp))
ZCAP = max (ZCAP, eps)
x_CAP_V = one / (one + sqrt (ZCAP))
w_CAP = (ca_fmol - pcp) / (gamma_m + pcp)
a_CAP = one - swp / lwp_crit
!----------------------------------------------------------------------!
! Stomatal conductance for CO2 diffusion (mol[CO2] m-2 s-1)
!----------------------------------------------------------------------!
gs_leaf_V = (f0 / (gamma_m + pcp)) * (x_CAP_V * a_CAP / &
            (x_CAP_V * ZCAP + (one - x_CAP_V) * &
            (x_cap_V * w_CAP + one) + eps))
!----------------------------------------------------------------------!
! friend95; eqn. 28
Jelec = Jmax * Q / (Q + 2.1 * Jmax + eps)
f0 = (one / 4.0) * Jelec !dewar18 table2
km = 2.0 * pcp !dewar18 table2
gamma_m = km
!----------------------------------------------------------------------!
! dewar18 table 3 legend.
ZCAP = 1.6 * D_mol * f0 / (Ktot * abs (lwp_crit) * (gamma_m + pcp))
ZCAP = max (ZCAP, eps)
x_CAP_J = one / (one + sqrt (ZCAP))
w_CAP = (ca_fmol - pcp) / (gamma_m + pcp)
!----------------------------------------------------------------------!
! Stomatal conductance for CO2 diffusion (mol[CO2] m-2 s-1)
!----------------------------------------------------------------------!
gs_leaf_J = (f0 / (gamma_m + pcp)) * (x_CAP_J * a_CAP / &
            (x_CAP_J * ZCAP + (one - x_CAP_J) * &
            (x_CAP_J * w_CAP + one) + eps))
!----------------------------------------------------------------------!
if (gs_leaf_V < gs_leaf_J) then
  gs_leaf = gs_leaf_V + eps
  x_CAP = x_CAP_V
else
  gs_leaf = gs_leaf_J + eps
  x_CAP = x_CAP_J
endif
!----------------------------------------------------------------------!
ci = x_CAP * ca_fmol + pcp * (one - x_CAP)
ci = max (eps, ci)
ci = min (ca_fmol, ci)
!----------------------------------------------------------------------!
! mol[CO2] m-2 s-1
gs_leaf = max (gs_leaf, gmin / 1.6)
gs_leaf = min (gs_leaf, gmax / 1.6)
!----------------------------------------------------------------------!
! mol[CO2] m-2 s-1
!----------------------------------------------------------------------!
Ag_leaf = gs_leaf * (ca_fmol - ci)
!----------------------------------------------------------------------!
! For clean exit.
!----------------------------------------------------------------------!
Rd_leaf = zero
!----------------------------------------------------------------------!
end subroutine LEAF
!======================================================================!
