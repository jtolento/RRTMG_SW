!     path:      $Source$
!     author:    $Author$
!     revision:  $Revision$
!     created:   $Date$

!  --------------------------------------------------------------------------
! |                                                                          |
! |  Copyright 2002-2007, Atmospheric & Environmental Research, Inc. (AER).  |
! |  This software may be used, copied, or redistributed as long as it is    |
! |  not sold and this copyright notice is reproduced on each copy made.     |
! |  This model is provided as is without any express or implied warranties. |
! |                       (http://www.rtweb.aer.com/)                        |
! |                                                                          |
!  --------------------------------------------------------------------------

! **************************************************************************
      subroutine rrtmg_sw_init
! **************************************************************************
!  RRTMG Shortwave Radiative Transfer Model for GCMs
!  Atmospheric and Environmental Research, Inc., Cambridge, MA
!
!  This subroutine performs calculations necessary for the initialization
!  of the shortwave model. Input absorption coefficient data for each
!  spectral band are reduced from 224 g-point intervals to 112.
! **************************************************************************

      use parkind, only : jpim, jprb 
      use parrrsw, only : mg, nbndsw, ngpt
      use rrsw_wvn
      use rrsw_vsn, only: hvrini, hnamini

      implicit none

! ------- Local -------

      integer(kind=jpim) :: ibnd, igc, ig, ind, ipr
      integer(kind=jpim) :: igcsm, iprsm

      real(kind=jprb) :: wtsum, wtsm(mg)

      hvrini = '$Revision$'

! Initialize model data
      call swdatinit
      call swcmbdat              ! g-point interval reduction data
      call swaerpr               ! aerosol optical properties
      call swcldpr               ! cloud optical properties
      call swatmref              ! reference MLS profile
      call sw_kgb16              ! molecular absorption coefficients
      call sw_kgb17
      call sw_kgb18
      call sw_kgb19
      call sw_kgb20
      call sw_kgb21
      call sw_kgb22
      call sw_kgb23
      call sw_kgb24
      call sw_kgb25
      call sw_kgb26
      call sw_kgb27
      call sw_kgb28
      call sw_kgb29

! Perform g-point reduction from 16 per band (224 total points) to
! a band dependent number (112 total points) for all absorption
! coefficient input data and Planck fraction input data.
! Compute relative weighting for new g-point combinations.

      igcsm = 0
      do ibnd = 1,nbndsw
         iprsm = 0
         if (ngc(ibnd).lt.mg) then
            do igc = 1,ngc(ibnd)
               igcsm = igcsm + 1
               wtsum = 0.
               do ipr = 1, ngn(igcsm)
                  iprsm = iprsm + 1
                  wtsum = wtsum + wt(iprsm)
               enddo
               wtsm(igc) = wtsum
            enddo
            do ig = 1, ng(ibnd+15)
               ind = (ibnd-1)*mg + ig
               rwgt(ind) = wt(ig)/wtsm(ngm(ind))
            enddo
         else
            do ig = 1, ng(ibnd+15)
               igcsm = igcsm + 1
               ind = (ibnd-1)*mg + ig
               rwgt(ind) = 1.0_jprb
            enddo
         endif
      enddo

! Reduce g-points for absorption coefficient data in each LW spectral band.

      call cmbgb16s
      call cmbgb17
      call cmbgb18
      call cmbgb19
      call cmbgb20
      call cmbgb21
      call cmbgb22
      call cmbgb23
      call cmbgb24
      call cmbgb25
      call cmbgb26
      call cmbgb27
      call cmbgb28
      call cmbgb29

      return
      end

!***************************************************************************
      subroutine swcmbdat
!***************************************************************************

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only: ngc, ngs, ngn, ngb, ngm, wt

      implicit none
      save
 
! ------- Definitions -------
!     Arrays for the g-point reduction from 224 to 112 for the 16 LW bands:
!     This mapping from 224 to 112 points has been carefully selected to 
!     minimize the effect on the resulting fluxes and cooling rates, and
!     caution should be used if the mapping is modified.  The full 224
!     g-point set can be restored with ngpt=224, ngc=16*16, ngn=224*1., etc.
!     ngpt    The total number of new g-points
!     ngc     The number of new g-points in each band
!     ngs     The cumulative sum of new g-points for each band
!     ngm     The index of each new g-point relative to the original
!             16 g-points for each band.  
!     ngn     The number of original g-points that are combined to make
!             each new g-point in each band.
!     ngb     The band index for each new g-point.
!     wt      RRTM weights for 16 g-points.

! Use this set for 112 quadrature point (g-point) model
! ------- Data statements -------
      ngc(:) = (/ 6,12, 8, 8,10,10, 2,10, 8, 6, 6, 8, 6,12 /)
      ngs(:) = (/ 6,18,26,34,44,54,56,66,74,80,86,94,100,112 /)
      ngm(:) = (/ 1,1,2,2,3,3,4,4,5,5,5,5,6,6,6,6, &           ! band 16
                  1,2,3,4,5,6,6,7,8,8,9,10,10,11,12,12, &      ! band 17
                  1,2,3,4,5,5,6,6,7,7,7,7,8,8,8,8, &           ! band 18
                  1,2,3,4,5,5,6,6,7,7,7,7,8,8,8,8, &           ! band 19
                  1,2,3,4,5,6,7,8,9,9,10,10,10,10,10,10, &     ! band 20
                  1,2,3,4,5,6,7,8,9,9,10,10,10,10,10,10, &     ! band 21
                  1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2, &           ! band 22
                  1,1,2,2,3,4,5,6,7,8,9,9,10,10,10,10, &       ! band 23
                  1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8, &           ! band 24
                  1,2,3,3,4,4,5,5,5,5,6,6,6,6,6,6, &           ! band 25
                  1,2,3,3,4,4,5,5,5,5,6,6,6,6,6,6, &           ! band 26
                  1,2,3,4,5,6,7,7,7,7,8,8,8,8,8,8, &           ! band 27
                  1,2,3,3,4,4,5,5,5,5,6,6,6,6,6,6, &           ! band 28
                  1,2,3,4,5,5,6,6,7,7,8,8,9,10,11,12 /)        ! band 29
      ngn(:) = (/ 2,2,2,2,4,4, &                               ! band 16
                  1,1,1,1,1,2,1,2,1,2,1,2, &                   ! band 17
                  1,1,1,1,2,2,4,4, &                           ! band 18
                  1,1,1,1,2,2,4,4, &                           ! band 19
                  1,1,1,1,1,1,1,1,2,6, &                       ! band 20
                  1,1,1,1,1,1,1,1,2,6, &                       ! band 21
                  8,8, &                                       ! band 22
                  2,2,1,1,1,1,1,1,2,4, &                       ! band 23
                  2,2,2,2,2,2,2,2, &                           ! band 24
                  1,1,2,2,4,6, &                               ! band 25
                  1,1,2,2,4,6, &                               ! band 26
                  1,1,1,1,1,1,4,6, &                           ! band 27
                  1,1,2,2,4,6, &                               ! band 28
                  1,1,1,1,2,2,2,2,1,1,1,1 /)                   ! band 29
      ngb(:) = (/ 16,16,16,16,16,16, &                         ! band 16
                  17,17,17,17,17,17,17,17,17,17,17,17, &       ! band 17
                  18,18,18,18,18,18,18,18, &                   ! band 18
                  19,19,19,19,19,19,19,19, &                   ! band 19
                  20,20,20,20,20,20,20,20,20,20, &             ! band 20
                  21,21,21,21,21,21,21,21,21,21, &             ! band 21
                  22,22, &                                     ! band 22
                  23,23,23,23,23,23,23,23,23,23, &             ! band 23
                  24,24,24,24,24,24,24,24, &                   ! band 24
                  25,25,25,25,25,25, &                         ! band 25
                  26,26,26,26,26,26, &                         ! band 26
                  27,27,27,27,27,27,27,27, &                   ! band 27
                  28,28,28,28,28,28, &                         ! band 28
                  29,29,29,29,29,29,29,29,29,29,29,29 /)       ! band 29

! Use this set for full 224 quadrature point (g-point) model
! ------- Data statements -------
!      ngc(:) = (/ 16,16,16,16,16,16,16,16,16,16,16,16,16,16 /)
!      ngs(:) = (/ 16,32,48,64,80,96,112,128,144,160,176,192,208,224 /)
!      ngm(:) = (/ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 16
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 17
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 18
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 19
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 20
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 21
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 22
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 23
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 24
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 25
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 26
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 27
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, &    ! band 28
!                  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 /)    ! band 29
!      ngn(:) = (/ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 16
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 17
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 18
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 19
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 20
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 21
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 22
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 23
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 24
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 25
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 26
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 27
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, &           ! band 28
!                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 /)           ! band 29
!      ngb(:) = (/ 16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16, &   ! band 16
!                  17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17, &   ! band 17
!                  18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18, &   ! band 18
!                  19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19, &   ! band 19
!                  20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20, &   ! band 20
!                  21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21, &   ! band 21
!                  22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22, &   ! band 22
!                  23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23, &   ! band 23
!                  24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24, &   ! band 24
!                  25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25, &   ! band 25
!                  26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26, &   ! band 26
!                  27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27, &   ! band 27
!                  28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28, &   ! band 28
!                  29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29 /)   ! band 29


      wt(:) =  (/ 0.1527534276_jprb, 0.1491729617_jprb, 0.1420961469_jprb, &
                  0.1316886544_jprb, 0.1181945205_jprb, 0.1019300893_jprb, &
                  0.0832767040_jprb, 0.0626720116_jprb, 0.0424925000_jprb, &
                  0.0046269894_jprb, 0.0038279891_jprb, 0.0030260086_jprb, &
                  0.0022199750_jprb, 0.0014140010_jprb, 0.0005330000_jprb, &
                  0.0000750000_jprb /)

      return
      end

!***************************************************************************
      subroutine swaerpr
!***************************************************************************

! Purpose: Define spectral aerosol properties for six ECMWF aerosol types
! as used in the ECMWF IFS model (see module rrsw_aer.F90 for details)
!
! Original: Defined for rrtmg_sw 14 spectral bands, JJMorcrette, ECMWF Feb 2003
! Revision: Reformatted for consistency with rrtmg_lw, MJIacono, AER, Jul 2006

      use parkind, only : jpim, jprb 
      use rrsw_aer, only : rsrtaua, rsrpiza, rsrasya

      implicit none
      save

      rsrtaua( 1, :) = (/ &
        0.10849_jprb, 0.66699_jprb, 0.65255_jprb, 0.11600_jprb, 0.06529_jprb, 0.04468_jprb/)
      rsrtaua( 2, :) = (/ &
        0.10849_jprb, 0.66699_jprb, 0.65255_jprb, 0.11600_jprb, 0.06529_jprb, 0.04468_jprb/)
      rsrtaua( 3, :) = (/ &
        0.20543_jprb, 0.84642_jprb, 0.84958_jprb, 0.21673_jprb, 0.28270_jprb, 0.10915_jprb/)
      rsrtaua( 4, :) = (/ &
        0.20543_jprb, 0.84642_jprb, 0.84958_jprb, 0.21673_jprb, 0.28270_jprb, 0.10915_jprb/)
      rsrtaua( 5, :) = (/ &
        0.20543_jprb, 0.84642_jprb, 0.84958_jprb, 0.21673_jprb, 0.28270_jprb, 0.10915_jprb/)
      rsrtaua( 6, :) = (/ &
        0.20543_jprb, 0.84642_jprb, 0.84958_jprb, 0.21673_jprb, 0.28270_jprb, 0.10915_jprb/)
      rsrtaua( 7, :) = (/ &
        0.20543_jprb, 0.84642_jprb, 0.84958_jprb, 0.21673_jprb, 0.28270_jprb, 0.10915_jprb/)
      rsrtaua( 8, :) = (/ &
        0.52838_jprb, 0.93285_jprb, 0.93449_jprb, 0.53078_jprb, 0.67148_jprb, 0.46608_jprb/)
      rsrtaua( 9, :) = (/ &
        0.52838_jprb, 0.93285_jprb, 0.93449_jprb, 0.53078_jprb, 0.67148_jprb, 0.46608_jprb/)
      rsrtaua(10, :) = (/ &
        1.69446_jprb, 1.11855_jprb, 1.09212_jprb, 1.72145_jprb, 1.03858_jprb, 1.12044_jprb/)
      rsrtaua(11, :) = (/ &
        1.69446_jprb, 1.11855_jprb, 1.09212_jprb, 1.72145_jprb, 1.03858_jprb, 1.12044_jprb/)
      rsrtaua(12, :) = (/ &
        1.69446_jprb, 1.11855_jprb, 1.09212_jprb, 1.72145_jprb, 1.03858_jprb, 1.12044_jprb/)
      rsrtaua(13, :) = (/ &
        1.69446_jprb, 1.11855_jprb, 1.09212_jprb, 1.72145_jprb, 1.03858_jprb, 1.12044_jprb/)
      rsrtaua(14, :) = (/ &
        0.10849_jprb, 0.66699_jprb, 0.65255_jprb, 0.11600_jprb, 0.06529_jprb, 0.04468_jprb/)
 
      rsrpiza( 1, :) = (/ &
        .5230504_jprb, .7868518_jprb, .8531531_jprb, .4048149_jprb, .8748231_jprb, .2355667_jprb/)
      rsrpiza( 2, :) = (/ &
        .5230504_jprb, .7868518_jprb, .8531531_jprb, .4048149_jprb, .8748231_jprb, .2355667_jprb/)
      rsrpiza( 3, :) = (/ &
        .8287144_jprb, .9949396_jprb, .9279543_jprb, .6765051_jprb, .9467578_jprb, .9955938_jprb/)
      rsrpiza( 4, :) = (/ &
        .8287144_jprb, .9949396_jprb, .9279543_jprb, .6765051_jprb, .9467578_jprb, .9955938_jprb/)
      rsrpiza( 5, :) = (/ &
        .8287144_jprb, .9949396_jprb, .9279543_jprb, .6765051_jprb, .9467578_jprb, .9955938_jprb/)
      rsrpiza( 6, :) = (/ &
        .8287144_jprb, .9949396_jprb, .9279543_jprb, .6765051_jprb, .9467578_jprb, .9955938_jprb/)
      rsrpiza( 7, :) = (/ &
        .8287144_jprb, .9949396_jprb, .9279543_jprb, .6765051_jprb, .9467578_jprb, .9955938_jprb/)
      rsrpiza( 8, :) = (/ &
        .8970131_jprb, .9984940_jprb, .9245594_jprb, .7768385_jprb, .9532763_jprb, .9999999_jprb/)
      rsrpiza( 9, :) = (/ &
        .8970131_jprb, .9984940_jprb, .9245594_jprb, .7768385_jprb, .9532763_jprb, .9999999_jprb/)
      rsrpiza(10, :) = (/ &
        .9148907_jprb, .9956173_jprb, .7504584_jprb, .8131335_jprb, .9401905_jprb, .9999999_jprb/)
      rsrpiza(11, :) = (/ &
        .9148907_jprb, .9956173_jprb, .7504584_jprb, .8131335_jprb, .9401905_jprb, .9999999_jprb/)
      rsrpiza(12, :) = (/ &
        .9148907_jprb, .9956173_jprb, .7504584_jprb, .8131335_jprb, .9401905_jprb, .9999999_jprb/)
      rsrpiza(13, :) = (/ &
        .9148907_jprb, .9956173_jprb, .7504584_jprb, .8131335_jprb, .9401905_jprb, .9999999_jprb/)
      rsrpiza(14, :) = (/ &
        .5230504_jprb, .7868518_jprb, .8531531_jprb, .4048149_jprb, .8748231_jprb, .2355667_jprb/)

      rsrasya( 1, :) = (/ &
        0.700610_jprb, 0.818871_jprb, 0.702399_jprb, 0.689886_jprb, .4629866_jprb, .1907639_jprb/)
      rsrasya( 2, :) = (/ &
        0.700610_jprb, 0.818871_jprb, 0.702399_jprb, 0.689886_jprb, .4629866_jprb, .1907639_jprb/)
      rsrasya( 3, :) = (/ &
        0.636342_jprb, 0.802467_jprb, 0.691305_jprb, 0.627497_jprb, .6105750_jprb, .4760794_jprb/)
      rsrasya( 4, :) = (/ &
        0.636342_jprb, 0.802467_jprb, 0.691305_jprb, 0.627497_jprb, .6105750_jprb, .4760794_jprb/)
      rsrasya( 5, :) = (/ &
        0.636342_jprb, 0.802467_jprb, 0.691305_jprb, 0.627497_jprb, .6105750_jprb, .4760794_jprb/)
      rsrasya( 6, :) = (/ &
        0.636342_jprb, 0.802467_jprb, 0.691305_jprb, 0.627497_jprb, .6105750_jprb, .4760794_jprb/)
      rsrasya( 7, :) = (/ &
        0.636342_jprb, 0.802467_jprb, 0.691305_jprb, 0.627497_jprb, .6105750_jprb, .4760794_jprb/)
      rsrasya( 8, :) = (/ &
        0.668431_jprb, 0.788530_jprb, 0.698682_jprb, 0.657422_jprb, .6735182_jprb, .6519706_jprb/)
      rsrasya( 9, :) = (/ &
        0.668431_jprb, 0.788530_jprb, 0.698682_jprb, 0.657422_jprb, .6735182_jprb, .6519706_jprb/)
      rsrasya(10, :) = (/ &
        0.729019_jprb, 0.803129_jprb, 0.784592_jprb, 0.712208_jprb, .7008249_jprb, .7270548_jprb/)
      rsrasya(11, :) = (/ &
        0.729019_jprb, 0.803129_jprb, 0.784592_jprb, 0.712208_jprb, .7008249_jprb, .7270548_jprb/)
      rsrasya(12, :) = (/ &
        0.729019_jprb, 0.803129_jprb, 0.784592_jprb, 0.712208_jprb, .7008249_jprb, .7270548_jprb/)
      rsrasya(13, :) = (/ &
        0.729019_jprb, 0.803129_jprb, 0.784592_jprb, 0.712208_jprb, .7008249_jprb, .7270548_jprb/)
      rsrasya(14, :) = (/ &
        0.700610_jprb, 0.818871_jprb, 0.702399_jprb, 0.689886_jprb, .4629866_jprb, .1907639_jprb/)

      return
      end
 
!***************************************************************************
      subroutine cmbgb16s
!***************************************************************************
!
!  Original version:       MJIacono; July 1998
!  Revision for RRTM_SW:   MJIacono; November 2002
!  Revision for RRTMG_SW:  MJIacono; December 2003
!  Revision for F90 reformatting:  MJIacono; July 2006
!
!  The subroutines CMBGB16->CMBGB29 input the absorption coefficient
!  data for each band, which are defined for 16 g-points and 14 spectral
!  bands. The data are combined with appropriate weighting following the
!  g-point mapping arrays specified in RRTMG_SW_INIT.  Solar source 
!  function data in array SFLUXREF are combined without weighting.  All
!  g-point reduced data are put into new arrays for use in RRTMG_SW.
!
!  band 16:  2600-3250 cm-1 (low key- h2o,ch4; high key - ch4)
!
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg16, only : kao, kbo, selfrefo, forrefo, sfluxrefo, &
                            ka, kb, selfref, forref, sfluxref

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jn, jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf


      do jn = 1,9
         do jt = 1,5
            do jp = 1,13
               iprsm = 0
               do igc = 1,ngc(1)
                  sumk = 0.
                  do ipr = 1, ngn(igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kao(jn,jt,jp,iprsm)*rwgt(iprsm)
                  enddo
                  ka(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jt = 1,5
         do jp = 13,59
            iprsm = 0
            do igc = 1,ngc(1)
               sumk = 0.
               do ipr = 1, ngn(igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kbo(jt,jp,iprsm)*rwgt(iprsm)
               enddo
               kb(jt,jp,igc) = sumk
            enddo
         enddo
      enddo

      do jt = 1,10
         iprsm = 0
         do igc = 1,ngc(1)
            sumk = 0.
            do ipr = 1, ngn(igc)
               iprsm = iprsm + 1
               sumk = sumk + selfrefo(jt,iprsm)*rwgt(iprsm)
            enddo
            selfref(jt,igc) = sumk
         enddo
      enddo

      do jt = 1,3
         iprsm = 0
         do igc = 1,ngc(1)
            sumk = 0.
            do ipr = 1, ngn(igc)
               iprsm = iprsm + 1
               sumk = sumk + forrefo(jt,iprsm)*rwgt(iprsm)
            enddo
            forref(jt,igc) = sumk
         enddo
      enddo

      iprsm = 0
      do igc = 1,ngc(1)
         sumf = 0.
         do ipr = 1, ngn(igc)
            iprsm = iprsm + 1
            sumf = sumf + sfluxrefo(iprsm)
         enddo
         sfluxref(igc) = sumf
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb17
!***************************************************************************
!
!     band 17:  3250-4000 cm-1 (low - h2o,co2; high - h2o,co2)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg17, only : kao, kbo, selfrefo, forrefo, sfluxrefo, &
                            ka, kb, selfref, forref, sfluxref

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jn, jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf


      do jn = 1,9
         do jt = 1,5
            do jp = 1,13
               iprsm = 0
               do igc = 1,ngc(2)
                  sumk = 0.
                  do ipr = 1, ngn(ngs(1)+igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kao(jn,jt,jp,iprsm)*rwgt(iprsm+16)
                  enddo
                  ka(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jn = 1,5
         do jt = 1,5
            do jp = 13,59
               iprsm = 0
               do igc = 1,ngc(2)
                  sumk = 0.
                  do ipr = 1, ngn(ngs(1)+igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kbo(jn,jt,jp,iprsm)*rwgt(iprsm+16)
                  enddo
                  kb(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jt = 1,10
         iprsm = 0
         do igc = 1,ngc(2)
            sumk = 0.
            do ipr = 1, ngn(ngs(1)+igc)
               iprsm = iprsm + 1
               sumk = sumk + selfrefo(jt,iprsm)*rwgt(iprsm+16)
            enddo
            selfref(jt,igc) = sumk
         enddo
      enddo

      do jt = 1,4
         iprsm = 0
         do igc = 1,ngc(2)
            sumk = 0.
            do ipr = 1, ngn(ngs(1)+igc)
               iprsm = iprsm + 1
               sumk = sumk + forrefo(jt,iprsm)*rwgt(iprsm+16)
            enddo
            forref(jt,igc) = sumk
         enddo
      enddo

      do jp = 1,5
         iprsm = 0
         do igc = 1,ngc(2)
            sumf = 0.
            do ipr = 1, ngn(ngs(1)+igc)
               iprsm = iprsm + 1
               sumf = sumf + sfluxrefo(iprsm,jp)
            enddo
            sfluxref(igc,jp) = sumf
         enddo
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb18
!***************************************************************************
!
!     band 18:  4000-4650 cm-1 (low - h2o,ch4; high - ch4)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg18, only : kao, kbo, selfrefo, forrefo, sfluxrefo, &
                            ka, kb, selfref, forref, sfluxref

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jn, jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf


      do jn = 1,9
         do jt = 1,5
            do jp = 1,13
               iprsm = 0
               do igc = 1,ngc(3)
                  sumk = 0.
                  do ipr = 1, ngn(ngs(2)+igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kao(jn,jt,jp,iprsm)*rwgt(iprsm+32)
                  enddo
                  ka(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jt = 1,5
         do jp = 13,59
            iprsm = 0
            do igc = 1,ngc(3)
               sumk = 0.
               do ipr = 1, ngn(ngs(2)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kbo(jt,jp,iprsm)*rwgt(iprsm+32)
               enddo
               kb(jt,jp,igc) = sumk
            enddo
         enddo
      enddo

      do jt = 1,10
         iprsm = 0
         do igc = 1,ngc(3)
            sumk = 0.
            do ipr = 1, ngn(ngs(2)+igc)
               iprsm = iprsm + 1
               sumk = sumk + selfrefo(jt,iprsm)*rwgt(iprsm+32)
            enddo
            selfref(jt,igc) = sumk
         enddo
      enddo

      do jt = 1,3
         iprsm = 0
         do igc = 1,ngc(3)
            sumk = 0.
            do ipr = 1, ngn(ngs(2)+igc)
               iprsm = iprsm + 1
               sumk = sumk + forrefo(jt,iprsm)*rwgt(iprsm+32)
            enddo
            forref(jt,igc) = sumk
         enddo
      enddo

      do jp = 1,9
         iprsm = 0
         do igc = 1,ngc(3)
            sumf = 0.
            do ipr = 1, ngn(ngs(2)+igc)
               iprsm = iprsm + 1
               sumf = sumf + sfluxrefo(iprsm,jp)
            enddo
            sfluxref(igc,jp) = sumf
         enddo
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb19
!***************************************************************************
!
!     band 19:  4650-5150 cm-1 (low - h2o,co2; high - co2)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg19, only : kao, kbo, selfrefo, forrefo, sfluxrefo, &
                            ka, kb, selfref, forref, sfluxref

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jn, jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf


      do jn = 1,9
         do jt = 1,5
            do jp = 1,13
               iprsm = 0
               do igc = 1,ngc(4)
                  sumk = 0.
                  do ipr = 1, ngn(ngs(3)+igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kao(jn,jt,jp,iprsm)*rwgt(iprsm+48)
                  enddo
                  ka(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jt = 1,5
         do jp = 13,59
            iprsm = 0
            do igc = 1,ngc(4)
               sumk = 0.
               do ipr = 1, ngn(ngs(3)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kbo(jt,jp,iprsm)*rwgt(iprsm+48)
               enddo
               kb(jt,jp,igc) = sumk
            enddo
         enddo
      enddo

      do jt = 1,10
         iprsm = 0
         do igc = 1,ngc(4)
            sumk = 0.
            do ipr = 1, ngn(ngs(3)+igc)
               iprsm = iprsm + 1
               sumk = sumk + selfrefo(jt,iprsm)*rwgt(iprsm+48)
            enddo
            selfref(jt,igc) = sumk
         enddo
      enddo

      do jt = 1,3
         iprsm = 0
         do igc = 1,ngc(4)
            sumk = 0.
            do ipr = 1, ngn(ngs(3)+igc)
               iprsm = iprsm + 1
               sumk = sumk + forrefo(jt,iprsm)*rwgt(iprsm+48)
            enddo
            forref(jt,igc) = sumk
         enddo
      enddo

      do jp = 1,9
         iprsm = 0
         do igc = 1,ngc(4)
            sumf = 0.
            do ipr = 1, ngn(ngs(3)+igc)
               iprsm = iprsm + 1
               sumf = sumf + sfluxrefo(iprsm,jp)
            enddo
            sfluxref(igc,jp) = sumf
         enddo
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb20
!***************************************************************************
!
!     band 20:  5150-6150 cm-1 (low - h2o; high - h2o)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg20, only : kao, kbo, selfrefo, forrefo, sfluxrefo, absch4o, &
                            ka, kb, selfref, forref, sfluxref, absch4

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf1, sumf2


      do jt = 1,5
         do jp = 1,13
            iprsm = 0
            do igc = 1,ngc(5)
               sumk = 0.
               do ipr = 1, ngn(ngs(4)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kao(jt,jp,iprsm)*rwgt(iprsm+64)
               enddo
               ka(jt,jp,igc) = sumk
            enddo
         enddo
         do jp = 13,59
            iprsm = 0
            do igc = 1,ngc(5)
               sumk = 0.
               do ipr = 1, ngn(ngs(4)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kbo(jt,jp,iprsm)*rwgt(iprsm+64)
               enddo
               kb(jt,jp,igc) = sumk
            enddo
         enddo
      enddo

      do jt = 1,10
         iprsm = 0
         do igc = 1,ngc(5)
            sumk = 0.
            do ipr = 1, ngn(ngs(4)+igc)
               iprsm = iprsm + 1
               sumk = sumk + selfrefo(jt,iprsm)*rwgt(iprsm+64)
            enddo
            selfref(jt,igc) = sumk
         enddo
      enddo

      do jt = 1,4
         iprsm = 0
         do igc = 1,ngc(5)
            sumk = 0.
            do ipr = 1, ngn(ngs(4)+igc)
               iprsm = iprsm + 1
               sumk = sumk + forrefo(jt,iprsm)*rwgt(iprsm+64)
            enddo
            forref(jt,igc) = sumk
         enddo
      enddo

      iprsm = 0
      do igc = 1,ngc(5)
         sumf1 = 0.
         sumf2 = 0.
         do ipr = 1, ngn(ngs(4)+igc)
            iprsm = iprsm + 1
            sumf1 = sumf1 + sfluxrefo(iprsm)
            sumf2 = sumf2 + absch4o(iprsm)*rwgt(iprsm+64)
         enddo
         sfluxref(igc) = sumf1
         absch4(igc) = sumf2
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb21
!***************************************************************************
!
!     band 21:  6150-7700 cm-1 (low - h2o,co2; high - h2o,co2)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg21, only : kao, kbo, selfrefo, forrefo, sfluxrefo, &
                            ka, kb, selfref, forref, sfluxref

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jn, jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf


      do jn = 1,9
         do jt = 1,5
            do jp = 1,13
               iprsm = 0
               do igc = 1,ngc(6)
                  sumk = 0.
                  do ipr = 1, ngn(ngs(5)+igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kao(jn,jt,jp,iprsm)*rwgt(iprsm+80)
                  enddo
                  ka(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jn = 1,5
         do jt = 1,5
            do jp = 13,59
               iprsm = 0
               do igc = 1,ngc(6)
                  sumk = 0.
                  do ipr = 1, ngn(ngs(5)+igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kbo(jn,jt,jp,iprsm)*rwgt(iprsm+80)
                  enddo
                  kb(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jt = 1,10
         iprsm = 0
         do igc = 1,ngc(6)
            sumk = 0.
            do ipr = 1, ngn(ngs(5)+igc)
               iprsm = iprsm + 1
               sumk = sumk + selfrefo(jt,iprsm)*rwgt(iprsm+80)
            enddo
            selfref(jt,igc) = sumk
         enddo
      enddo

      do jt = 1,4
         iprsm = 0
         do igc = 1,ngc(6)
            sumk = 0.
            do ipr = 1, ngn(ngs(5)+igc)
               iprsm = iprsm + 1
               sumk = sumk + forrefo(jt,iprsm)*rwgt(iprsm+80)
            enddo
            forref(jt,igc) = sumk
         enddo
      enddo

      do jp = 1,9
         iprsm = 0
         do igc = 1,ngc(6)
            sumf = 0.
            do ipr = 1, ngn(ngs(5)+igc)
               iprsm = iprsm + 1
               sumf = sumf + sfluxrefo(iprsm,jp)
            enddo
            sfluxref(igc,jp) = sumf
         enddo
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb22
!***************************************************************************
!
!     band 22:  7700-8050 cm-1 (low - h2o,o2; high - o2)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg22, only : kao, kbo, selfrefo, forrefo, sfluxrefo, &
                            ka, kb, selfref, forref, sfluxref

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jn, jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf


      do jn = 1,9
         do jt = 1,5
            do jp = 1,13
               iprsm = 0
               do igc = 1,ngc(7)
                  sumk = 0.
                  do ipr = 1, ngn(ngs(6)+igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kao(jn,jt,jp,iprsm)*rwgt(iprsm+96)
                  enddo
                  ka(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jt = 1,5
         do jp = 13,59
            iprsm = 0
            do igc = 1,ngc(7)
               sumk = 0.
               do ipr = 1, ngn(ngs(6)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kbo(jt,jp,iprsm)*rwgt(iprsm+96)
               enddo
               kb(jt,jp,igc) = sumk
            enddo
         enddo
      enddo

      do jt = 1,10
         iprsm = 0
         do igc = 1,ngc(7)
            sumk = 0.
            do ipr = 1, ngn(ngs(6)+igc)
               iprsm = iprsm + 1
               sumk = sumk + selfrefo(jt,iprsm)*rwgt(iprsm+96)
            enddo
            selfref(jt,igc) = sumk
         enddo
      enddo

      do jt = 1,3
         iprsm = 0
         do igc = 1,ngc(7)
            sumk = 0.
            do ipr = 1, ngn(ngs(6)+igc)
               iprsm = iprsm + 1
               sumk = sumk + forrefo(jt,iprsm)*rwgt(iprsm+96)
            enddo
            forref(jt,igc) = sumk
         enddo
      enddo

      do jp = 1,9
         iprsm = 0
         do igc = 1,ngc(7)
            sumf = 0.
            do ipr = 1, ngn(ngs(6)+igc)
               iprsm = iprsm + 1
               sumf = sumf + sfluxrefo(iprsm,jp)
            enddo
            sfluxref(igc,jp) = sumf
         enddo
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb23
!***************************************************************************
!
!     band 23:  8050-12850 cm-1 (low - h2o; high - nothing)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg23, only : kao, selfrefo, forrefo, sfluxrefo, raylo, &
                            ka, selfref, forref, sfluxref, rayl

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf1, sumf2


      do jt = 1,5
         do jp = 1,13
            iprsm = 0
            do igc = 1,ngc(8)
               sumk = 0.
               do ipr = 1, ngn(ngs(7)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kao(jt,jp,iprsm)*rwgt(iprsm+112)
               enddo
               ka(jt,jp,igc) = sumk
            enddo
         enddo
      enddo

      do jt = 1,10
         iprsm = 0
         do igc = 1,ngc(8)
            sumk = 0.
            do ipr = 1, ngn(ngs(7)+igc)
               iprsm = iprsm + 1
               sumk = sumk + selfrefo(jt,iprsm)*rwgt(iprsm+112)
            enddo
            selfref(jt,igc) = sumk
         enddo
      enddo

      do jt = 1,3
         iprsm = 0
         do igc = 1,ngc(8)
            sumk = 0.
            do ipr = 1, ngn(ngs(7)+igc)
               iprsm = iprsm + 1
               sumk = sumk + forrefo(jt,iprsm)*rwgt(iprsm+112)
            enddo
            forref(jt,igc) = sumk
         enddo
      enddo

      iprsm = 0
      do igc = 1,ngc(8)
         sumf1 = 0.
         sumf2 = 0.
         do ipr = 1, ngn(ngs(7)+igc)
            iprsm = iprsm + 1
            sumf1 = sumf1 + sfluxrefo(iprsm)
            sumf2 = sumf2 + raylo(iprsm)*rwgt(iprsm+112)
         enddo
         sfluxref(igc) = sumf1
         rayl(igc) = sumf2
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb24
!***************************************************************************
!
!     band 24:  12850-16000 cm-1 (low - h2o,o2; high - o2)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg24, only : kao, kbo, selfrefo, forrefo, sfluxrefo, &
                            abso3ao, abso3bo, raylao, raylbo, &
                            ka, kb, selfref, forref, sfluxref, &
                            abso3a, abso3b, rayla, raylb

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jn, jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf1, sumf2, sumf3


      do jn = 1,9
         do jt = 1,5
            do jp = 1,13
               iprsm = 0
               do igc = 1,ngc(9)
                  sumk = 0.
                  do ipr = 1, ngn(ngs(8)+igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kao(jn,jt,jp,iprsm)*rwgt(iprsm+128)
                  enddo
                  ka(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jt = 1,5
         do jp = 13,59
            iprsm = 0
            do igc = 1,ngc(9)
               sumk = 0.
               do ipr = 1, ngn(ngs(8)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kbo(jt,jp,iprsm)*rwgt(iprsm+128)
               enddo
               kb(jt,jp,igc) = sumk
            enddo
         enddo
      enddo

      do jt = 1,10
         iprsm = 0
         do igc = 1,ngc(9)
            sumk = 0.
            do ipr = 1, ngn(ngs(8)+igc)
               iprsm = iprsm + 1
               sumk = sumk + selfrefo(jt,iprsm)*rwgt(iprsm+128)
            enddo
            selfref(jt,igc) = sumk
         enddo
      enddo

      do jt = 1,3
         iprsm = 0
         do igc = 1,ngc(9)
            sumk = 0.
            do ipr = 1, ngn(ngs(8)+igc)
               iprsm = iprsm + 1
               sumk = sumk + forrefo(jt,iprsm)*rwgt(iprsm+128)
            enddo
            forref(jt,igc) = sumk
         enddo
      enddo

      iprsm = 0
      do igc = 1,ngc(9)
         sumf1 = 0.
         sumf2 = 0.
         sumf3 = 0.
         do ipr = 1, ngn(ngs(8)+igc)
            iprsm = iprsm + 1
            sumf1 = sumf1 + raylbo(iprsm)*rwgt(iprsm+128)
            sumf2 = sumf2 + abso3ao(iprsm)*rwgt(iprsm+128)
            sumf3 = sumf3 + abso3bo(iprsm)*rwgt(iprsm+128)
         enddo
         raylb(igc) = sumf1
         abso3a(igc) = sumf2
         abso3b(igc) = sumf3
      enddo

      do jp = 1,9
         iprsm = 0
         do igc = 1,ngc(9)
            sumf1 = 0.
            sumf2 = 0.
            do ipr = 1, ngn(ngs(8)+igc)
               iprsm = iprsm + 1
               sumf1 = sumf1 + sfluxrefo(iprsm,jp)
               sumf2 = sumf2 + raylao(iprsm,jp)*rwgt(iprsm+128)
            enddo
            sfluxref(igc,jp) = sumf1
            rayla(igc,jp) = sumf2
         enddo
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb25
!***************************************************************************
!
!     band 25:  16000-22650 cm-1 (low - h2o; high - nothing)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg25, only : kao, sfluxrefo, &
                            abso3ao, abso3bo, raylo, &
                            ka, sfluxref, &
                            abso3a, abso3b, rayl

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf1, sumf2, sumf3, sumf4


      do jt = 1,5
         do jp = 1,13
            iprsm = 0
            do igc = 1,ngc(10)
               sumk = 0.
               do ipr = 1, ngn(ngs(9)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kao(jt,jp,iprsm)*rwgt(iprsm+144)
               enddo
               ka(jt,jp,igc) = sumk
            enddo
         enddo
      enddo

      iprsm = 0
      do igc = 1,ngc(10)
         sumf1 = 0.
         sumf2 = 0.
         sumf3 = 0.
         sumf4 = 0.
         do ipr = 1, ngn(ngs(9)+igc)
            iprsm = iprsm + 1
            sumf1 = sumf1 + sfluxrefo(iprsm)
            sumf2 = sumf2 + abso3ao(iprsm)*rwgt(iprsm+144)
            sumf3 = sumf3 + abso3bo(iprsm)*rwgt(iprsm+144)
            sumf4 = sumf4 + raylo(iprsm)*rwgt(iprsm+144)
         enddo
         sfluxref(igc) = sumf1
         abso3a(igc) = sumf2
         abso3b(igc) = sumf3
         rayl(igc) = sumf4
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb26
!***************************************************************************
!
!     band 26:  22650-29000 cm-1 (low - nothing; high - nothing)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg26, only : sfluxrefo, raylo, &
                            sfluxref, rayl

      implicit none

! ------- Local -------
      integer(kind=jpim) :: igc, ipr, iprsm
      real(kind=jprb) :: sumf1, sumf2


      iprsm = 0
      do igc = 1,ngc(11)
         sumf1 = 0.
         sumf2 = 0.
         do ipr = 1, ngn(ngs(10)+igc)
            iprsm = iprsm + 1
            sumf1 = sumf1 + raylo(iprsm)*rwgt(iprsm+160)
            sumf2 = sumf2 + sfluxrefo(iprsm)
         enddo
         rayl(igc) = sumf1
         sfluxref(igc) = sumf2
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb27
!***************************************************************************
!
!     band 27:  29000-38000 cm-1 (low - o3; high - o3)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg27, only : kao, kbo, sfluxrefo, raylo, &
                            ka, kb, sfluxref, rayl

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf1, sumf2


      do jt = 1,5
         do jp = 1,13
            iprsm = 0
            do igc = 1,ngc(12)
               sumk = 0.
               do ipr = 1, ngn(ngs(11)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kao(jt,jp,iprsm)*rwgt(iprsm+176)
               enddo
               ka(jt,jp,igc) = sumk
            enddo
         enddo
         do jp = 13,59
            iprsm = 0
            do igc = 1,ngc(12)
               sumk = 0.
               do ipr = 1, ngn(ngs(11)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kbo(jt,jp,iprsm)*rwgt(iprsm+176)
               enddo
               kb(jt,jp,igc) = sumk
            enddo
         enddo
      enddo

      iprsm = 0
      do igc = 1,ngc(12)
         sumf1 = 0.
         sumf2 = 0.
         do ipr = 1, ngn(ngs(11)+igc)
            iprsm = iprsm + 1
            sumf1 = sumf1 + sfluxrefo(iprsm)
            sumf2 = sumf2 + raylo(iprsm)*rwgt(iprsm+176)
         enddo
         sfluxref(igc) = sumf1
         rayl(igc) = sumf2
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb28
!***************************************************************************
!
!     band 28:  38000-50000 cm-1 (low - o3,o2; high - o3,o2)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg28, only : kao, kbo, sfluxrefo, &
                            ka, kb, sfluxref

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jn, jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf


      do jn = 1,9
         do jt = 1,5
            do jp = 1,13
               iprsm = 0
               do igc = 1,ngc(13)
                  sumk = 0.
                  do ipr = 1, ngn(ngs(12)+igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kao(jn,jt,jp,iprsm)*rwgt(iprsm+192)
                  enddo
                  ka(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jn = 1,5
         do jt = 1,5
            do jp = 13,59
               iprsm = 0
               do igc = 1,ngc(13)
                  sumk = 0.
                  do ipr = 1, ngn(ngs(12)+igc)
                     iprsm = iprsm + 1
                     sumk = sumk + kbo(jn,jt,jp,iprsm)*rwgt(iprsm+192)
                  enddo
                  kb(jn,jt,jp,igc) = sumk
               enddo
            enddo
         enddo
      enddo

      do jp = 1,5
         iprsm = 0
         do igc = 1,ngc(13)
            sumf = 0.
            do ipr = 1, ngn(ngs(12)+igc)
               iprsm = iprsm + 1
               sumf = sumf + sfluxrefo(iprsm,jp)
            enddo
            sfluxref(igc,jp) = sumf
         enddo
      enddo

      return
      end

!***************************************************************************
      subroutine cmbgb29
!***************************************************************************
!
!     band 29:  820-2600 cm-1 (low - h2o; high - co2)
!-----------------------------------------------------------------------

      use parkind, only : jpim, jprb 
      use rrsw_wvn, only : ngc, ngs, ngn, wt, rwgt
      use rrsw_kg29, only : kao, kbo, selfrefo, forrefo, sfluxrefo, &
                            absh2oo, absco2o, &
                            ka, kb, selfref, forref, sfluxref, &
                            absh2o, absco2

      implicit none

! ------- Local -------
      integer(kind=jpim) :: jt, jp, igc, ipr, iprsm
      real(kind=jprb) :: sumk, sumf1, sumf2, sumf3


      do jt = 1,5
         do jp = 1,13
            iprsm = 0
            do igc = 1,ngc(14)
               sumk = 0.
               do ipr = 1, ngn(ngs(13)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kao(jt,jp,iprsm)*rwgt(iprsm+208)
               enddo
               ka(jt,jp,igc) = sumk
            enddo
         enddo
         do jp = 13,59
            iprsm = 0
            do igc = 1,ngc(14)
               sumk = 0.
               do ipr = 1, ngn(ngs(13)+igc)
                  iprsm = iprsm + 1
                  sumk = sumk + kbo(jt,jp,iprsm)*rwgt(iprsm+208)
               enddo
               kb(jt,jp,igc) = sumk
            enddo
         enddo
      enddo

      do jt = 1,10
         iprsm = 0
         do igc = 1,ngc(14)
            sumk = 0.
            do ipr = 1, ngn(ngs(13)+igc)
               iprsm = iprsm + 1
               sumk = sumk + selfrefo(jt,iprsm)*rwgt(iprsm+208)
            enddo
            selfref(jt,igc) = sumk
         enddo
      enddo

      do jt = 1,4
         iprsm = 0
         do igc = 1,ngc(14)
            sumk = 0.
            do ipr = 1, ngn(ngs(13)+igc)
               iprsm = iprsm + 1
               sumk = sumk + forrefo(jt,iprsm)*rwgt(iprsm+208)
            enddo
            forref(jt,igc) = sumk
         enddo
      enddo

      iprsm = 0
      do igc = 1,ngc(14)
         sumf1 = 0.
         sumf2 = 0.
         sumf3 = 0.
         do ipr = 1, ngn(ngs(13)+igc)
            iprsm = iprsm + 1
            sumf1 = sumf1 + sfluxrefo(iprsm)
            sumf2 = sumf2 + absco2o(iprsm)*rwgt(iprsm+208)
            sumf3 = sumf3 + absh2oo(iprsm)*rwgt(iprsm+208)
         enddo
         sfluxref(igc) = sumf1
         absco2(igc) = sumf2
         absh2o(igc) = sumf3
      enddo

      return
      end
