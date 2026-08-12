!======================================================================!
subroutine HYDRO
!----------------------------------------------------------------------!
use PARS_MOD
use VARS_MOD
!----------------------------------------------------------------------!
implicit none
!----------------------------------------------------------------------!
call ADVANCE_SNOW
rwc (1) = (sm (1) - SM_MIN (1)) / (SM_MAX (1) - SM_MIN (1))
!----------------------------------------------------------------------!
! Run-off (mm/s)
!----------------------------------------------------------------------!
sm_q = rwc (1) ** b_RC * (rain + melt)
!----------------------------------------------------------------------!
! Drainage from top layer mm s-1
!----------------------------------------------------------------------!
perc = (rwc (1) ** b_perc * perc_max) / day_s
!----------------------------------------------------------------------!
! Calculate evaporation from top layer.
!----------------------------------------------------------------------!
call EVAP
!----------------------------------------------------------------------!
! Derivatives of soil moisture in each layer                        (mm)
!----------------------------------------------------------------------!
dsm (1) = rain + melt - aet - sm_q - perc
!----------------------------------------------------------------------!
! Place holder (cm tstep-1).
!----------------------------------------------------------------------!
leaching_water_cm = dt_s * zero
!----------------------------------------------------------------------!
! Impose limits on soil water.
!----------------------------------------------------------------------!
sm (1) = sm (1) + dt_s * dsm (1)
if (sm (1) > SM_MAX (1)) then
  sm_q = sm_q + (sm (1) - SM_MAX (1)) / dt_s
  sm (1) = SM_MAX (1)
end if
if (sm (1) < SM_MIN (1)) then
  aet = aet - (SM_MIN (1) - sm (1)) / dt_s
  sm (1) = SM_MIN (1)
end if
!----------------------------------------------------------------------!
PPT_ann = PPT_ann + dt_s * pre_l
RO_ann  = RO_ann  + dt_s * sm_q
ET_ann  = ET_ann  + dt_s * aet
!----------------------------------------------------------------------!
end subroutine HYDRO
!======================================================================!

!======================================================================!
subroutine EVAP
!----------------------------------------------------------------------!
use PARS_MOD
use VARS_MOD
!----------------------------------------------------------------------!
implicit none
!----------------------------------------------------------------------!
! First use PM without isothermal correction.
! Eqn. 9 of sw85. W m-2
! Latent heat of vapourisation; Henderson-Sellers, Google AI    (J kg-1)
! Works really well cf. Jones new table.
!----------------------------------------------------------------------!
Lv = 1.91846e6 * (tmp_l / (tmp_l - 33.91)) ** 2
!----------------------------------------------------------------------!
! Derivative of CC equation (AI Google).
! Closish to jones new table.
!----------------------------------------------------------------------!
Delta = (Lv * es) / (Rv * tmp_l ** 2) ! Pa K-1
!----------------------------------------------------------------------!
! Isothermal net radiation  (W m-2)
!----------------------------------------------------------------------!
As = (one - asw) * tswrf_l + dlwrf_l - emm * sb * tmp_l ** 4
!----------------------------------------------------------------------!
! Air density (kg m-3)
!----------------------------------------------------------------------!
rho_kg = pres_l / (Ra * tmp_l)
!----------------------------------------------------------------------!
! For bare substrate, eq. 28 (s m-1)
!----------------------------------------------------------------------!
zp0 = 0.01 ! Roughness length of bare substrate (m)
h = 0.3 ! Canopy height (m)
xh = h + 1.2 ! ref. height above canopy (m)
d = 0.63 * h ! zero plane displacemet (m)
z0 = 0.13 * h
u = sqrt (ugrd_l ** 2 + vgrd_l ** 2) ! Wind speed (m s-1)
! eqn. 28 of jones
ras = log (xh / zp0) * log ((d + z0) / zp0) / ((karman ** 2) * u)
gamma = pres_l * cp / (0.622 * Lv) ! Pa K-1
!rss = 0.0 ! wet soil surface (s m-1)
! for fun, based on sw85 (iv). replace with rstom when have it.
!fC = 2.0 * ca_fmol / (ca_fmol + 500.0e-6)
!rss = 1000.0 * (one - rwc) * fC ! intercept reduced from 2000
!----------------------------------------------------------------------!
! Total resistance to moisture from inside leaves to bulk air (s m-1)
!----------------------------------------------------------------------!
rss = rho_mol / (1.6 * gs_crown + eps) + ras
!----------------------------------------------------------------------!
! Substrate ET, wet soil (W m-2)
!LE = (Delta * As + rho_kg * cp * D0 / ras) / &
!     (Delta + gamma * (one + rss / ras))
!----------------------------------------------------------------------!
! With allowing for isothermal As
! Replace ras by rhr (jones)
!----------------------------------------------------------------------!
rr =  rho_kg * cp  /(4.0 * emm * sb * tmp_l ** 3)! jones app 3.
!----------------------------------------------------------------------!
! Parallel sum of conductances to sensible and radiative heat
!----------------------------------------------------------------------!
rhr = one / ((one / ras) + (one / rr))
!----------------------------------------------------------------------!
LE = (Delta * As + rho_kg * cp * D0 / rhr) / &
     (Delta + gamma * (one + rss / rhr))
!----------------------------------------------------------------------!
! based on sw85 eqn. 12
!----------------------------------------------------------------------!
h = height
xh = h + 1.2
d = 0.63 * h ! zero plane displacemet (m)
z0 = 0.13 * h
u = sqrt (ugrd_l ** 2 + vgrd_l ** 2) ! Wind speed (m s-1)
raa1 = log ((xh - d) / z0)
raa2 = (karman ** 2) * u
raa3 = log ((xh - d) / (h - d))
raa4 = h / (2.5 * (h - d))
raa5 = exp (2.5 * (one - (d + z0) / h)) - one
raa = (raa1 / raa2) * (raa3 + raa4 * raa5)
rac = 25.0 / (2.0 * min (4.0, LAI))
rsc = rho_mol / (1.6 * gs_crown + eps)
rhr = one / (one / (raa + rac) + (one / rr))
LE = (Delta * As + rho_kg * cp * D0 / rhr) / &
     (Delta + gamma * (one + rsc / rhr))
!----------------------------------------------------------------------!
! mm s-1
pet = LE / Lv
!pet = 5.0 / (4.0 * dt)
!----------------------------------------------------------------------!
!for fun aet = rwc ** b_AET * pet
aet = pet
!----------------------------------------------------------------------!
end subroutine EVAP
!======================================================================!

!======================================================================!
subroutine ADVANCE_SNOW
!----------------------------------------------------------------------!
! Uses method of Merz et al. (2022).
!----------------------------------------------------------------------!
use PARS_MOD
use VARS_MOD
!----------------------------------------------------------------------!
implicit none
!----------------------------------------------------------------------!
if (TC <= (TS - DT)) then
  x = zero
else if (TC >= (TS + DT)) then
  x = one
else
  x = ((TC - (TS - DT)) / ((TS + DT) - (TS - DT))) ** b_S
end if
rain = x * pre_l
snow = pre_l - rain
if ((day_s * rain) <= ((DDF_R - DDF_NR) / DDF_INC)) then
  ddf = DDF_NR + ((DDF_R - DDF_NR) / DDF_INC) * rain
else
  ddf = DDF_NR
end if
if (TC >= TM) then
  melt = ((TC - TM) * ddf)
else
  melt = zero
end if
melt = min (melt, snowpack)
melt = melt / day_s
snowpack = snowpack + dt_s * (snow - melt)
!----------------------------------------------------------------------!
end subroutine ADVANCE_SNOW
!======================================================================!
