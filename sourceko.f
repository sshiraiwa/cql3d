c
c
      subroutine sourceko ! must be called for k=kelecg only
      implicit integer (i-n), real*8 (a-h,o-z)
      save
c
c.......................................................................

c  Computes Marshall Rosenbluth's knock-on source 
c    (which differs from Besedin-Pankratov expression.)
c    Source is obtained as the bounce-average of
c       n_e(s)*dn_r*v_r*(d(sigma)/d(gamma))*d(gamma)/d^3u,
c       where dn_r=runaway electrons at given energy gamma,
c       cross-section sigma on p. 240, of Heitler, Quantum Theory
c       of Radiation, 3rd edition, 
c       s is poloidal distance, and d^3 is momentum-space-per-mass
c       volume element at given s.
c       Numerical method in Harvey et al, Phys. of Plasmas, 2000. 
c
c.......................................................................
c      save
      include 'param.h'
      include 'comm.h'
CMPIINSERT_INCLUDE     

c      The ii0m1 method is an alternative translation from
c      pitch angle at given poloidal position to equatorial
c      plane pitch angle index (see below).
c      dimension ii0m1(jx,jfl,lz)

      character*8 ifirst
      data ifirst/"first"/
c
c     write(*,*) 'In SOURCEKO'
c
c     Should probably replace jfl with jx, etc (bh, 980501).
      !write(*,*)'sourceko jfl=', jfl 
      !if (jfl.lt.jx) stop 'in sourceko'  ! YuP:  Why needed?
      
      if (n.lt.nonko .or. n.gt.noffko .or. 
     +       knockon.eq."disabled")  return
     
      k=kelecg
c
c     At the first call, set up quantities which need only be calculated
c       once: the p_par,p_perp intersection points between source 
c       lines associated with each parallel velocity grid point and the
c       u-grid.  Also,  area elements, and source factors.
c       Momenta p_par and p_prp, are measured in units of mc. 
c       Similarly, momenta area is in units of (mc)**c.

      if (ifirst.eq."first") then
         ifirst="notfirst"
         call bcast(ppars,zero,jx*jfl)
         call bcast(pprps,zero,jx*jfl)
c  pparea storage can be removed:   call bcast(pparea,zero,jx*jfl)
         call bcast(faci,zero,jx*jfl)

c     Set up parallel grid  for fl:
         call fle("setup",0)

         jflh=1

c        For avoiding divide errors (due to roundoff):
         abit=1.e-12
         onepabit=1.+abit
         onemabit=1.-abit

c    Determine index of u-contour intercepted by source line from each
c     parallel velocity such that gamma(j-1) satisfies
c     gamma(j-1)<= 0.5*(gamma_prime_1 +1),
c     but gamma(j) does not satisfy this relation.
          do jf=jflh,jfl
            gamap1=sqrt(xl(jf)*xl(jf)*cnorm2i+1.) !cnorm2i=0 when relativ.eq."disabled"
            xmx1=5.e-1*sqrt(xl(jf)*xl(jf)+(2.*gamap1-2.e0)*cnorm2)
            jmaxxl(jf)=luf(xmx1*onemabit,x,jx)
         enddo
         jmaxxl(jflh)=1

         do jf=jflh+1,jfl
            xpar1p=xl(jf)
cYuP            ppar1p=xpar1p*cnormi*onepabit !cnormi=0 when relativ.eq."disabled"
            ppar1p=xpar1p*onepabit/cnorm !YuP[07-2016] cannot have ppar1p or ppar1p2=0
            ppar1p2=ppar1p*ppar1p
            gam1p=sqrt(ppar1p2+1.)
            gam1pm1=gam1p-1.
            gam1p2=gam1p*gam1p
            gam1p2m1=gam1p2-1.
            alf1=2.*(gam1p-1.)
            aaa=(1./alf1)-(1./ppar1p2) !cannot have ppar1p2=0
            bbb=1./ppar1p
            
            do j=2,jmaxxl(jf)-1
cYuP               p02=xsq(j)*cnorm2i*onepabit !cnorm2i=0 when relativ.eq."disabled"
               p02=(xsq(j)/cnorm2)*onepabit !YuP
               gam0=sqrt(p02+1.)
               gam0m1=gam0-1.
               gam1pmg=gam1p-gam0
               ccc=-p02/alf1
               ppars(j,jf)=(-bbb+sqrt(bbb*bbb-4.*aaa*ccc))/(2.*aaa)
               pprps(j,jf)=sqrt(p02-ppars(j,jf)*ppars(j,jf))
               pprps2=pprps(j,jf)*pprps(j,jf)
               ppar1pmp=ppar1p-ppars(j,jf)
               ppar1pm2=ppar1pmp*ppar1pmp
c Capital Sigma
               faci(j,jf)=1./(gam1p2m1*
     1              gam0m1*gam0m1*gam1pmg*gam1pmg)*
     2              (gam1pm1*gam1pm1*gam1p2
     3              -gam0m1*gam1pmg*(2.*gam1p2+2.*gam1p-1.
     4              -gam0m1*gam1pmg))

            enddo
         enddo



c     Setup equatorial plane pitch angle bin for 
c     each source contribution.
cc     This is flux surface dependent, so must be recalculated
cc     if multiple flux surfaces are treated.
cc     This would be a large amount of storage for multiple
cc     flux surface runs.  (Could reduce storage by packing
cc     the ii0m1 into byte size words).
cc     It is more exact than the following method, but
cc     the replacement uses less storage.
c
cc     Starting value for lug() below.
c      i0=iyh/2
c
c         do l=1,lz
c            do jf=jflh+1,jfl-1
c               do j=1,jx
cc                 Positive pitch angles:
c                  sinth=pprps(j,jf)*cnorm*xi(j)
c                  i0=lug(sinth,sinz(1,l,lr_),iyh_(l_),i0)
c                  i0m1=i0-1
c                  if (i0m1.eq.0) then
c                     i0m1=1
c                     i0=2
c                  endif
c                  ii0m1(j,jf,l)=i0m1
c               enddo
c            enddo
c         enddo

c     The following method sets up a table of equatorial
c       plane pitch angles, corresponding to uniformly spaced
c       sin(theta) values for each poloidal position il,
c       and radial position ir.
c       This table is used later in the subroutine to find
c       equatorial pitch angle indices using simple divide
c       and multiply operators, and is much faster than
c       redoing the lug-searches.  (Differences (of +/- 1)
c       from the previous lug-method occur in typically 1-5
c       out of jx=350 points, for i0param=1000).

         call ibcast(i0tran,1,(i0param+1)*lz*lrz)
c000123BH         dsinth=0.5*pi/(i0param-1.) !Fix below increases accuracy abit
cBH170927:  But, this correction made a significant difference in the
cBH170927:  calculation of the wh80 test case, to the distribution.
cBH170927:  and the knockon rate. It apparently lead to the somewhat
cBH170927:  unphysical looking "ledge" on f near the runaway velocity.
cBH180416: Temporarily reverting this fix dsinth=1.0/(i0param-1.) !This is corrected value
cBH180416:         dsinth=0.5*pi/(i0param-1.)
         dsinth=1.0d0/(i0param-1)
cBH180416:	 write(*,*)
cBH180416:	 write(*,*) 'souceko: Temporary reversion of dsinth=. NEEDS'
cBH180416:	 write(*,*) '         INVESTIGATION, 180416 !!!!'
cBH180416:	 write(*,*)
         dsinthi=1./dsinth
         do ir=1,lrz
            do il=1,lz
               i0tran(1,il,ir)=1
               i0tran(i0param+1,il,ir)=iyh_(ir)
               i0=iyh_(ir)
               do ii=2,i0param
                  sinth=(ii-1)*dsinth
                  i0=lug(sinth,sinz(1,il,lrindx(ir)),iyh_(ir),i0)
                  i0m1=i0-1
                  if (i0m1.eq.0) then
                     i0m1=1
                  endif
                  i0tran(ii,il,ir)=i0m1
               enddo
            enddo
         enddo



c       second2=second()
c       write(*,*) 'Seconds for sourcko setup = ',second2-second1

      endif              
c  end of setup for knock-on source integral.

c  Formation of knock-on source:

c      second3=second()


c  Constant factor:
c     tpir02=2*pi*r0**2 (cgs), r0=e**2/(mc**2), classical elec radius
      tpir02=2.*pi*(2.8179e-13)**2


cc     Source off below soffvte*vte (soffvte positive),
c                      abs(soffvte)*sqrt(E_c/E)*vte (soffvte negative).
c     E_c=2.*elecr (below, also in subroutine efield).
c     elecr is the Dreicer electric field (as in Kulsrud et al.),
c     converted to volts/cm.
c.......................................................................
c     call a routine to determine runaway critical velocity (used in 
c       sourceko).
c.......................................................................

      call soucrit

c..................................................................
c     Note: the tauee and elecr definition below uses vth(),
c     vth is the thermal velocity =sqrt(T/m) (at t=0 defined in ainpla).
c     But, T==temp(k,lr) can be changed in profiles.f, 
c     in case of iprote (or iproti) equal to "prbola-t" or "spline-t"
c..................................................................
      xvte3=0.
      if (isoucof.eq.0) then
         if (soffvte.gt.0.) then
            xvte3=soffvte*vthe(lr_)/vnorm
         else
            tauee(lr_)=vth(kelec,lr_)**3*fmass(kelec)**2
     1           /(4.*pi*reden(kelec,lr_)*charge**4*
     1           gama(kelec,kelec))
            elecr(lr_)=300.*fmass(kelec)*vth(kelec,lr_)/
     1           (2.*charge*tauee(lr_))
            if(elecfld(lr_).ne.zero) then
               xvte3=abs(soffvte)*sqrt(2.*elecr(lr_)/elecfld(lr_))*
     1              vthe(lr_)/vnorm
            endif
         endif
      else
         if (soffvte.gt.0.) then
            if (faccof.lt.0.7) faccof=0.7
cSC_did_not_like:        xvte3=amin1(soffvte,ucrit(kelec,lr_)*faccof)
c990131            xvte3=amin1(soffvte*vthe(lr_)/vnorm,ucrit(kelec,lr_)*faccof)
            xvte3=min(soffvte*vthe(lr_)/vnorm,ucrit(kelec,lr_)*faccof)
         else
            if (faccof.lt.0.5) faccof=0.5
            xvte3=ucrit(kelec,lr_)*faccof
         endif
      endif
      call lookup(xvte3,x,jx,wtu,wtl,lement)
      jvte3=lement

c  Distribution of primary knockon particles zeroed out (effectively)
c    below velocity soffpr*(above source cutoff velocity):
c    (default soffpr=0.0)

      xsoffpr=soffpr*xvte3
      call lookup(xsoffpr,xl(jflh),jfl,wtu,wtl,lement)
      jsoffpr=min(lement,jfl)


c  Obtain average source for positive and negative v_parallel:


      do l=1,lz

         call fle("calc",l)
         
         den_of_s=0.
         do jf=1,jfl-1
            den_of_s=den_of_s+dxl(jf)*(fl1(jf)+fl2(jf))
         enddo

         flmax=0.
         do jf=1,jfl-1
c990131            flmax=amax1(flmax,fl1(jf))
c990131            flmax=amax1(flmax,fl2(jf))
            flmax=max(flmax,fl1(jf))
            flmax=max(flmax,fl2(jf))
         enddo
         flmin=em100*flmax
c     do jf=jflh-jsoffpr,jflh+jsoffpr
         do jf=1,jsoffpr-1
            fl1(jf)=flmin
            fl2(jf)=flmin
         enddo




         do jf=jflh+1,jfl-1
c     Skip calc if fl(jf) near minimum value:
            if ((fl1(jf)+fl2(jf)).lt.em100*flmax) go to 99
     
            xpar1p=xl(jf)
            ppar1p=xpar1p*vnorm/clight*onepabit
            ppar1p2=ppar1p*ppar1p
            gam1p=sqrt(ppar1p2+1.)
            
            cnst0=tpir02*den_of_s*dxl(jf)*ppar1p*vnorm/
     +           (gam1p*cnorm)
            cnst1=cnst0*fl1(jf)
            cnst2=cnst0*fl2(jf)



      do j=jvte3,jmaxxl(jf)-2
         wc=x(j)/cnorm
         wc2=wc*wc

         src_mr1=cnst1*faci(j,jf)*gammi(j)*x(j)*dx(j)
         src_mr2=cnst2*faci(j,jf)*gammi(j)*x(j)*dx(j)

c         i0m1=ii0m1(j,jf,l)

         sinth=pprps(j,jf)*cnorm*xi(j)
         isinth=sinth*dsinthi+1.5
         i0m1=i0tran(isinth,l,l_)
c         if(i0m1.ne.i0m1o) then
c            write(*,*) 'l_,l,jf,j,i0m1o,i0m1  ', l_,l,jf,j,i0m1o,i0m1
c         endif

cBH091031         axl=dtau(i0m1,l,lr_)/tau(i0m1,lr_)
cBH091031         if(l.ne.lz .and. lmax(i0m1,lr_).eq.l) then
cBH091031            axl=axl+dtau(i0m1,l+1,lr_)/tau(i0m1,lr_)
cBH091031         endif
         if (eqsym.ne."none") then !i.e. up-down symm
            !if not bounce interval
            if(l.eq.lz .or. l.ne.lmax(i0m1,lr_)) then
               axl=dtau(i0m1,l,lr_)/tau(i0m1,lr_)
            else                !bounce interval: additional contribution
               axl=(dtau(i0m1,l,lr_)+dtau(i0m1,l+1,lr_))/tau(i0m1,lr_)
            endif
         else  !eqsym="none"
            if (l.lt.lz_bmax(lr_) .and. l.eq.lmax(i0m1,lr_))then
               !trapped, with tips between l and l+1 (above midplane)
               axl=(dtau(i0m1,l,lr_)+dtau(i0m1,l+1,lr_))/tau(i0m1,lr_)
               !-YuP  Note: dtau(i,l+1,lr_)=0
            elseif (l.gt.lz_bmax(lr_) .and. l.eq.lmax(i0m1+iyh,lr_))then
               !trapped, with tips between l and l-1 (below midplane)     
               axl=(dtau(i0m1,l,lr_)+dtau(i0m1,l-1,lr_))/tau(i0m1,lr_) !NB:l-1
               !-YuP  Note: dtau(i,l-1,lr_)=0
            else
               axl=dtau(i0m1,l,lr_)/tau(i0m1,lr_)
               !passing (i<itl), or trapped but with tips at other l;
               !also, at l=lz_bmax, includes last trapped particle i=itl
               !(for such particle, lmax(itl)=lz_bmax; see micxinil)
            endif
         endif
         dtaudt=axl

         i0m1m=iy+1-i0m1

         source(i0m1,j,k,indxlr_)=source(i0m1,j,k,indxlr_)+
     +               dtaudt*src_mr1*cosz(i0m1,l,lr_)/(coss(i0m1,l_)
     +               *cynt2(i0m1,l_)*cint2(j)*bbpsi(l,lr_))
         source(i0m1m,j,k,indxlr_)=source(i0m1m,j,k,indxlr_)+
     +               dtaudt*src_mr2*cosz(i0m1m,l,lr_)/(coss(i0m1m,l_)
     +               *cynt2(i0m1m,l_)*cint2(j)*bbpsi(l,lr_))


      enddo
 99   continue
      enddo
      enddo

c     Symmetrize trapped particles
      do  j=jvte3,jx
         do  i=itl,iyh
            ii=iy+1-i
            source(i,j,k,indxlr_)=0.5*(source(i,j,k,indxlr_)
     +  	+source(ii,j,k,indxlr_)) ! for k=kelecg
            source(ii,j,k,indxlr_)=source(i,j,k,indxlr_)
         enddo	
      enddo	

c..................................................................
c     For primary distribution formed from the pitch angle averaged
c       reduced distribution, reverse the direction of source if
c       the electric field is positive.
c..................................................................

      if (elecfld(lr_).gt.0.) then
         do  j=jvte3,jx
            do  i=1,itl-1
               ii=iy+1-i
               source(ii,j,k,indxlr_)=source(i,j,k,indxlr_)
               source(i,j,k,indxlr_)=0.0
            enddo	
         enddo
      endif

c..................................................................
c     Compute source rate in (particles/sec/cc)
c..................................................................

          s1=0.
          do j=jvte3,jx
          do i=1,iy
             s1=s1+
     +          source(i,j,k,indxlr_)*cynt2(i,l_)*cint2(j)*vptb(i,lr_)
          enddo
          enddo
          s1=s1/zmaxpsi(lr_)
          srckotot(lr_)=s1

c..................................................................
c     Compute pitch angle averaged source rate 
c     in (particles/sec/cc) divided by du=vnorm*dx(j)
c     (Can examine this with CDBX).
c..................................................................

          call bcast(tam30,zero,jx)
          do i=1,iy
             do j=1,jx
                tam30(j)=tam30(j)+source(i,j,k,indxlr_)*
     +               cynt2(i,l_)*vptb(i,lr_)*
     +               cint2(j)/(vnorm*dx(j)*zmaxpsi(lr_))
             enddo
          enddo

c          second4=second()

c       write(*,*) 'Seconds for sourcko calc = ',second4-second3


c..................................................................
c     If knockon.eq."fpld_dsk":
c        write source out to disk file "fpld_disk", and stop, 
c     If knockon.eq."fpld_ds1":
c        write source*dtr+(previous step f(since no preloading in it)
c        to disk file "fpld_dsk1", and previous step f to disk file
c        "fpld_dsk2",     and stop. 
c..................................................................
           
      if (n.eq.nstop) then
      if (knockon.eq."fpld_dsk") then
         call dcopy(iyjx2,source(0,0,k,l_),1,temp1(0,0),1)
         call dscal(iyjx2,dtr,temp1(0,0),1)
         iunit=20
         open (unit=iunit,file='fpld_dsk',status='unknown')
         !do 80 k=1,1 !  k=kelecg
            write (iunit,1000) ((temp1(i,j),i=1,iy),j=1,jx)
 80      continue
         close(unit=iunit)
         call tdoutput(2)
c990307         call geglxx(0)
         call pgend
         stop 'Wrote disk file from subroutine souceko: fpld_dsk'
      endif
      if (knockon.eq."fpld_ds1") then
         call dcopy(iyjx2,source(0,0,k,l_),1,temp1(0,0),1)
         call dscal(iyjx2,dtr,temp1(0,0),1)
         do j=1,jx
            do i=1,iy
               temp1(i,j)=temp1(i,j)+f_(i,j,k,1)
            enddo
         enddo
         iunit=20
         open (unit=iunit,file='fpld_dsk1',status='unknown')
         !do 81 k=1,1  !  k=kelecg
            write (iunit,1000) ((temp1(i,j),i=1,iy),j=1,jx)
 81      continue
         close(unit=iunit)
         open (unit=iunit,file='fpld_dsk2',status='unknown')
         !do 82 k=1,1  !  k=kelecg
            write (iunit,1000) ((f_(i,j,k,1),i=1,iy),j=1,jx)
 82      continue
         close(unit=iunit)
         call tdoutput(2)
c990307         call geglxx(0)
         call pgend
         stop 'Wrote disk files from subroutine souceko: fpld_dskx'
      endif
      endif
 1000 format(5(1pe16.7))
            


          
c..................................................................
c     As passed to subroutine souplt:
c..................................................................
      xlncur(1,lr_)=s1*zmaxpsi(lr_)

 999  return
      end
