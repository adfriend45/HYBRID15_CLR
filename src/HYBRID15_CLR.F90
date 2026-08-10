!======================================================================!
program HYBRID15_CLR
!----------------------------------------------------------------------!
! Code to simulate NEE using process-based photosynthesis, respiration,
! and soil decomposition approaches.
!----------------------------------------------------------------------!
use PARS_MOD
use VARS_MOD
!----------------------------------------------------------------------!
implicit none
!----------------------------------------------------------------------!
write (*,*)
write (*,*) 'HYBRID15_CLR running'
write (*,*)
!----------------------------------------------------------------------!
! Read forcings and initalise all state variables etc.
!----------------------------------------------------------------------!
call INIT
!----------------------------------------------------------------------!
kyr_ce = syr
do ikyr = 1, nyr_sim
  ca_fmol = co2_ppm (kyr_ce) / 1.0e6 ! mol[CO2] mol[air]-1
  GPP_ann = zero
  Rh_ann   = zero ! Annual soil respiration flux (g[C] m-2 yr-1)
  L_ann   = zero ! Annual litter flux (g[C] m-2 yr-1)
  PPT_ann = zero
  RO_ann  = zero
  ET_ann  = zero
  NEE_ann = zero
  it = 0
  do kday = 1, ndays
    hr = 0.0 - dt_hr
    total_litter_day = zero
    leaching_water_day = zero
    do kt = 1, nt
      !----------------------------------------------------------------!
      if (mod (kt-1,12) == 0) it = it + 1
      !----------------------------------------------------------------!
      hr = hr + dt_hr
      !----------------------------------------------------------------!
      write (20,'(3i5,4f12.4)') kyr_ce, kday, kt, hr, &
                                co2_ppm (kyr_ce), tswrf, sm
      !----------------------------------------------------------------!
      ! Set local climate variables for this timepoint.
      !----------------------------------------------------------------!
      tmp_l   = tmp   (ikyr,it) ! Air temperature                    (K)
      TC      = tmp_l - tf      ! Air temperature                   (oC)
      pre_l   = pre   (ikyr,it) ! Precipitation                (mm/6-hr)
      tswrf_l = tswrf (ikyr,it) ! Tot dnwd SW flx, sfc, time mean (W/m2)
      dlwrf_l = dlwrf (ikyr,it) ! Dnwd LW rad flx                 (W/m2)
      spfh_l  = spfh  (ikyr,it) ! Specific humidity              (kg/kg)
      pres_l  = pres  (ikyr,it) ! Pressure                          (Pa)
      ugrd_l  = ugrd  (ikyr,it) ! Zonal component of wnd speed     (m/s)
      vgrd_l  = vgrd  (ikyr,it) ! Merdional component of wnd speed (m/s)
      !----------------------------------------------------------------!
      ! Compute crown photosynthesis, respiration, and conductance.
      !----------------------------------------------------------------!
      call CROWN
      !----------------------------------------------------------------!
      ! Advance soil hydrology.
      !----------------------------------------------------------------!
      call HYDRO
      !----------------------------------------------------------------!
      ! Advance biomass.
      !----------------------------------------------------------------!
      call GROW
      !----------------------------------------------------------------!
      ! g[DM] m-2 day-1
      !----------------------------------------------------------------!
      total_litter_day = total_litter_day + dt_s * litter
      !----------------------------------------------------------------!
      ! Water leaching in day (cm day-1)
      !----------------------------------------------------------------!
      leaching_water_day = leaching_water_day + leaching_water_cm
      !----------------------------------------------------------------!
      ! Accumulate annual diagnostics.
      !----------------------------------------------------------------!
      GPP_ann = GPP_ann + dt_s * gpp
      NEE_ann = NEE_ann + dt_s * (Raut - gpp)
      !----------------------------------------------------------------!
    end do ! kt
    !------------------------------------------------------------------!
    ! Daily total plant C input to soil decomposition routine.
    !------------------------------------------------------------------!
    total_input = CDM * total_litter_day
    L_ann= L_ann + total_input
    !------------------------------------------------------------------!
    ! Advance SOM.
    !------------------------------------------------------------------!
    leaching_water_day = leaching_cm_day ! I think!
    call DECOMP
    !------------------------------------------------------------------!
    ! Accumulate annual diagnostics.
    !------------------------------------------------------------------!
    NEE_ann = NEE_ann + co2
    !------------------------------------------------------------------!
  end do ! kday
  !--------------------------------------------------------------------!
  write (*,'(i5,9f12.4)') kyr_ce, GPP_ann, L_ann, PPT_ann, &
  RO_ann, ET_ann, NEE_ann, biomass, SOM, Rh_ann
  !--------------------------------------------------------------------!
  kyr_ce = kyr_ce + 1
  !--------------------------------------------------------------------!
end do ! kyr
!----------------------------------------------------------------------!
close (20)
write (*,*)
write (*,*) 'HYBRID15_CLR finished'
write (*,*)
!----------------------------------------------------------------------!
end program HYBRID15_CLR
!======================================================================!
