subroutine READ_HYBRID15_CLR_FORCING
!----------------------------------------------------------------------!
use PARS_MOD
use VARS_MOD
!----------------------------------------------------------------------!
implicit none
!----------------------------------------------------------------------!
open (10,file='/rds/user/adf10/rds-mb425-geogscratch/adf10/&
&TRENDYGCB2026/CO2field/global_co2_ann_1700_2025.txt',status='old')
do kyr_ce = 1700, eyr
  read (10,*) ikyr, co2_ppm (kyr_ce)
end do
close (10)
!----------------------------------------------------------------------!
! Read binary of lons and lats.
!----------------------------------------------------------------------!
!OPEN (10,FILE=trim(home_dir)//"/utilities/extract_clm/data/lonslats.bin", &
!      FORM="UNFORMATTED",STATUS="UNKNOWN")
OPEN (10,FILE='lonslats.bin', FORM="UNFORMATTED",STATUS="UNKNOWN")
READ (10) lon, lat
CLOSE (10)
!----------------------------------------------------------------------!
! Read binaries of x and y coordinates.
!----------------------------------------------------------------------!
!OPEN (10,FILE=trim(home_dir)//"/utilities/extract_clm/data/coords.bin", &
!      FORM="UNFORMATTED",STATUS="UNKNOWN")
OPEN (10,FILE='coords.bin', FORM="UNFORMATTED",STATUS="UNKNOWN")
READ (10) x_k, y_k
CLOSE (10)
!----------------------------------------------------------------------!
kw = 0
ic_count = 0
open (21,file='latlons.txt',status='unknown')
do kl = 1, nland

  l  = lon(x_k(kl)) - 0.25
  rt = lon(x_k(kl)) + 0.25
  t  = lat(y_k(kl)) + 0.25
  b  = lat(y_k(kl)) - 0.25

  !if ((l <= 19.01) .and. (rt >= 3.04)) then
  !  if ((t >= 45.0) .and. (b <= 54.39)) then
  ! For High Fen, Cambs (Google AI).
  if ((l <= -0.257) .and. (rt >= -0.257)) then
    if ((t >= 54.1054) .and. (b <= 54.1054)) then
      write (20,'(i5,2f14.10)') kl,lon(x_k(kl)),lat(y_k(kl))
      write (*,*) l,rt,t,b,kl
      ic_count = ic_count + 1
      kw = kl
    end if
  end if
end do
write (*,*) 'Found ',ic_count,'gridboxe(s)'
close (21)
write (*,*) 'Using kw = ', kw
!----------------------------------------------------------------------!
allocate (tmp_global  (nland,ntimes))
allocate (pre_global  (nland,ntimes))
allocate (tswrf_global(nland,ntimes))
allocate (dlwrf_global(nland,ntimes))
allocate (spfh_global (nland,ntimes))
allocate (pres_global (nland,ntimes))
allocate (ugrd_global (nland,ntimes))
allocate (vgrd_global (nland,ntimes))
!----------------------------------------------------------------------!
ivar = 1
ikyr = 1
do kyr_ce = syr, eyr
  write (*,*) 'processing ', kyr_ce
  write (cyr,'(i4)') kyr_ce
  !--------------------------------------------------------------------!
  ! tmp (K)
  !--------------------------------------------------------------------!
  filename = '/rds/user/adf10/rds-mb425-geogscratch/adf10/&
   &TRENDYGCB2026/binaries/tmp/crujra.v4.10.5d.tmp.'//cyr//&
   &'.365d.noc.bin'
  !--------------------------------------------------------------------!
  open (10, file = filename, form = 'unformatted', status = 'old')
  read (10) tmp_global
  close (10)
  !--------------------------------------------------------------------!
  ! pre (mm/6-hr)
  !--------------------------------------------------------------------!
  filename = '/rds/user/adf10/rds-mb425-geogscratch/adf10/&
  &TRENDYGCB2026/binaries/pre/crujra.v4.10.5d.pre.'//cyr//&
  &'.365d.noc.bin'
  open (10, file = filename, form = 'unformatted', status = 'old')
  read (10) pre_global
  close (10)
  !--------------------------------------------------------------------!
  ! tswrf (W/m2)
  !--------------------------------------------------------------------!
  filename = '/rds/user/adf10/rds-mb425-geogscratch/adf10/&
    &TRENDYGCB2026/binaries/tswrf/tswrf_v15_'//cyr//'.bin'
  open (10, file = filename, form = 'unformatted', status = 'old')
  read (10) tswrf_global
  close (10)
  !--------------------------------------------------------------------!
  ! dlwrf (W/m2)
  !--------------------------------------------------------------------!
  filename = '/rds/user/adf10/rds-mb425-geogscratch/adf10/&
    &TRENDYGCB2026/binaries/dlwrf/crujra.v4.10.5d.dlwrf.'//cyr//&
    &'.365d.noc.bin'
  open (10, file = filename, form = 'unformatted', status = 'old')
  read (10) dlwrf_global
  close (10)
  !--------------------------------------------------------------------!
  ! spfh (kg/kg)
  !--------------------------------------------------------------------!
  filename = '/rds/user/adf10/rds-mb425-geogscratch/adf10/&
    &TRENDYGCB2026/binaries/spfh/crujra.v4.10.5d.spfh.'//cyr//&
    &'.365d.noc.bin'
  open (10, file = filename, form = 'unformatted', status = 'old')
  read (10) spfh_global
  close (10)
  !--------------------------------------------------------------------!
  ! pres (Pa)
  !--------------------------------------------------------------------!
  filename = '/rds/user/adf10/rds-mb425-geogscratch/adf10/&
    &TRENDYGCB2026/binaries/pres/crujra.v4.10.5d.pres.'//cyr//&
    &'.365d.noc.bin'
  open (10, file = filename, form = 'unformatted', status = 'old')
  read (10) pres_global
  close (10)
  !--------------------------------------------------------------------!
  ! ugrd; longitudinal (zonal) wind component (m/s)
  !--------------------------------------------------------------------!
  filename = '/rds/user/adf10/rds-mb425-geogscratch/adf10/&
    &TRENDYGCB2026/binaries/ugrd/crujra.v4.10.5d.ugrd.'//cyr//&
    &'.365d.noc.bin'
  open (10, file = filename, form = 'unformatted', status = 'old')
  read (10) ugrd_global
  close (10)
  !--------------------------------------------------------------------!
  ! vgrd; latitudinal (meridional) wind component (m/s)
  !--------------------------------------------------------------------!
  filename = '/rds/user/adf10/rds-mb425-geogscratch/adf10/&
    &TRENDYGCB2026/binaries/vgrd/crujra.v4.10.5d.vgrd.'//cyr//&
    &'.365d.noc.bin'
  open (10, file = filename, form = 'unformatted', status = 'old')
  read (10) vgrd_global
  close (10)
  !--------------------------------------------------------------------!
  tmp   (ikyr,:) = tmp_global   (kw,:)
  pre   (ikyr,:) = pre_global   (kw,:) / sixhr_s
  tswrf (ikyr,:) = tswrf_global (kw,:)
  dlwrf (ikyr,:) = dlwrf_global (kw,:)
  spfh  (ikyr,:) = spfh_global  (kw,:)
  pres  (ikyr,:) = pres_global  (kw,:)
  ugrd  (ikyr,:) = ugrd_global  (kw,:)
  vgrd  (ikyr,:) = vgrd_global  (kw,:)
  !--------------------------------------------------------------------!
  ikyr = ikyr + 1
  !--------------------------------------------------------------------!
end do ! kyr_ce
!----------------------------------------------------------------------!
end subroutine READ_HYBRID15_CLR_FORCING
