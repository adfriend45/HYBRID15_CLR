!======================================================================!
subroutine INIT
!----------------------------------------------------------------------!
use PARS_MOD
use VARS_MOD
!----------------------------------------------------------------------!
implicit none
!----------------------------------------------------------------------!
open (10, file = 'home_dir.txt', status = 'old')
read (10,*) home_dir
close (10)
!----------------------------------------------------------------------!
open (11, file = 'driver.txt', status = 'old')
read (11,*) syr
read (11,*) eyr
read (11,*) nyr_co2
read (11,*) sm
read (11,*) LAI
read (11,*) biomass
close (11)
!----------------------------------------------------------------------!
if (nyr_co2 > 2025) then
  write (*,*) 'nyr_co2 = ', nyr_co2, 'exceeds input file limit of 2025'
  write (*,*) 'Stopping'
  stop
end if
!----------------------------------------------------------------------!
nyr_sim = eyr - syr + 1
allocate (co2_ppm (nyr_co2))
!----------------------------------------------------------------------!
allocate (tmp  (nyr_sim,ntimes))
allocate (pre  (nyr_sim,ntimes))
allocate (tswrf(nyr_sim,ntimes))
allocate (dlwrf(nyr_sim,ntimes))
allocate (spfh (nyr_sim,ntimes))
allocate (pres (nyr_sim,ntimes))
allocate (ugrd (nyr_sim,ntimes))
allocate (vgrd (nyr_sim,ntimes))
!----------------------------------------------------------------------!
open (20, file = trim(home_dir)//'/CLR/HYBRID15_CLR/results/&
     &HYBRID15_CLR_dt_output.txt', status = 'unknown')
!----------------------------------------------------------------------!
call READ_HYBRID15_CLR_FORCING
!----------------------------------------------------------------------!
write (*,*)
write (*,'(a113)') 'kyr_ce   GPP_ann       L_ann     PPT_ann      RO_ann &
            &     ET_ann     NEE_ann     biomass         SOM      Rh_ann'
write (*,'(a113)') '   CE  g[C] m-2 yr-1 g[C] m-2 yr-1 mm yr-1    mm yr-1 &
            &   mm yr-1 g[C] m-2 yr-1 g[DM] m-2  g[DM] m-2 g[C] m-2 yr-1'
!----------------------------------------------------------------------!
! SOM state variables (g[C] m-2).
!----------------------------------------------------------------------!
pool_initial(:) = (/ 80.0, 150.0, 255.0, 30.0, &
                     20.0, 40.0, 4420.0, 3825.0 /)
!----------------------------------------------------------------------!
c_state (:) = pool_initial (:)
!----------------------------------------------------------------------!
end subroutine INIT
!======================================================================!
