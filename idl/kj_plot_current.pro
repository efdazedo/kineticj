pro kj_plot_current, noIterate=noIterate

    noIterate = 0
    useAORSA = 1

	@constants

	cd, current=currentDir

	cfg = kj_read_cfg (currentDir)	

	cdfId = ncdf_open(cfg['eField_fName'])

		ncdf_varget, cdfId, 'freq', freq 
		ncdf_varget, cdfId, 'r', r 

		ncdf_varget, cdfId, 'e_r_re', er_re
		ncdf_varget, cdfId, 'e_r_im', er_im
		ncdf_varget, cdfId, 'e_p_re', ep_re
		ncdf_varget, cdfId, 'e_p_im', ep_im
		ncdf_varget, cdfId, 'e_z_re', ez_re
		ncdf_varget, cdfId, 'e_z_im', ez_im

		ncdf_varget, cdfId, 'jP_r_re', jPr_re
		ncdf_varget, cdfId, 'jP_r_im', jPr_im
		ncdf_varget, cdfId, 'jP_p_re', jPt_re
		ncdf_varget, cdfId, 'jP_p_im', jPt_im
		ncdf_varget, cdfId, 'jP_z_re', jPz_re
		ncdf_varget, cdfId, 'jP_z_im', jPz_im

	ncdf_close, cdfId

	wrf = freq * 2 * !pi

	spline_sigma = 0.01

	fileList = file_search ( 'output/jP*' )

	cdfId = ncdf_open(fileList[0])
	ncdf_varget, cdfId, 't', t
	nCdf_close, cdfId
	
	nT = n_elements(t)
	nF = n_elements(fileList)

	j1x = fltArr ( nT, nF )

	j1xc = complexArr ( nF )
	j1yc = complexArr ( nF )
	j1zc = complexArr ( nF )

	j1x = complexArr ( nF )
	j1y = complexArr ( nF )
	j1z = complexArr ( nF )

	xF = fltArr ( nF )

	for f=0,nF-1 do begin

		cdfId = ncdf_open(fileList[f])

			ncdf_varget, cdfId, 'x', x
			ncdf_varget, cdfId, 't', t

			ncdf_varget, cdfId, 'j1xc_re', j1xc_re 
			ncdf_varget, cdfId, 'j1xc_im', j1xc_im

			ncdf_varget, cdfId, 'j1yc_re', j1yc_re 
			ncdf_varget, cdfId, 'j1yc_im', j1yc_im

			ncdf_varget, cdfId, 'j1zc_re', j1zc_re 
			ncdf_varget, cdfId, 'j1zc_im', j1zc_im


		nCdf_close,	cdfId 

		xF[f] = x

		j1xc[f] = complex(j1xc_re,j1xc_im)
		j1yc[f] = complex(j1yc_re,j1yc_im)
		j1zc[f] = complex(j1zc_re,j1zc_im)

        j1x[f] = j1xc[f]
        j1y[f] = j1yc[f]
        j1z[f] = j1zc[f]
	
	endfor

if not keyword_set(noIterate) then begin

	jROut  = complex(spline(xf,real_part(j1x),r,spline_sigma),spline(xf,imaginary(j1x),r,spline_sigma))
	jTOut  = complex(spline(xf,real_part(j1y),r,spline_sigma),spline(xf,imaginary(j1y),r,spline_sigma))    
	jZOut  = complex(spline(xf,real_part(j1z),r,spline_sigma),spline(xf,imaginary(j1z),r,spline_sigma))    

	; Write kj_jP in file

	nc_id = nCdf_create ('output/kj_jP.nc', /clobber )

	nCdf_control, nc_id, /fill
	
	nr_id = nCdf_dimDef ( nc_id, 'nR', n_elements(r) )
	nx_id = nCdf_dimDef ( nc_id, 'nX', n_elements(r) )
	ny_id = nCdf_dimDef ( nc_id, 'nY', 1 )
	ns_id = nCdf_dimDef ( nc_id, 'nSpec', 1 )
	scalar_id = nCdf_dimDef ( nc_id, 'scalar', 1 )

	freq_id = nCdf_varDef ( nc_id, 'freq', scalar_id, /float )
	r_id = nCdf_varDef ( nc_id, 'r', nr_id, /float )
	z_id = nCdf_varDef ( nc_id, 'z', ny_id, /float )

	jP_r_re_id = nCdf_varDef ( nc_id, 'jP_r_re', [nx_id,ny_id,ns_id], /float )
	jP_r_im_id = nCdf_varDef ( nc_id, 'jP_r_im', [nx_id,ny_id,ns_id], /float )
	jP_p_re_id = nCdf_varDef ( nc_id, 'jP_t_re', [nx_id,ny_id,ns_id], /float )
	jP_p_im_id = nCdf_varDef ( nc_id, 'jP_t_im', [nx_id,ny_id,ns_id], /float )
	jP_z_re_id = nCdf_varDef ( nc_id, 'jP_z_re', [nx_id,ny_id,ns_id], /float )
	jP_z_im_id = nCdf_varDef ( nc_id, 'jP_z_im', [nx_id,ny_id,ns_id], /float )

	nCdf_control, nc_id, /enDef

	nCdf_varPut, nc_id, freq_id, freq

	nCdf_varPut, nc_id, r_id, r
    z = [0]
	nCdf_varPut, nc_id, z_id, z

	nCdf_varPut, nc_id, jP_r_re_id, real_part(jROut)
	nCdf_varPut, nc_id, jP_r_im_id, imaginary(jROut) 
	nCdf_varPut, nc_id, jP_p_re_id, real_part(jTOut)
	nCdf_varPut, nc_id, jP_p_im_id, imaginary(jTOut) 
	nCdf_varPut, nc_id, jP_z_re_id, real_part(jZOut)
	nCdf_varPut, nc_id, jP_z_im_id, imaginary(jZOut) 

	nCdf_close, nc_id

endif

    OverplotAR2 = 1
    if(OverplotAR2)then begin
        ar2Run = '/Users/dg6/scratch/aorsa2d/colestock-kashuba-reference'
        ar2 = ar2_read_solution(ar2Run,1) 
        ar2SpecNo = fix(cfg['species_number'])
    endif

    jpRange = max(abs([j1x,j1y,j1z]))
    p=plot(xf,j1x,layout=[1,3,1],yRange=[-jpRange,jpRange],title='j1x',thick=2)
    p=plot(xf,imaginary(j1x),/over,color='r',thick=2)
    if(OverPlotAR2)then begin
        p=plot(ar2.r,ar2.jp_r[*,*,ar2SpecNo],/over,color='black',lineStyle=0)
        p=plot(ar2.r,imaginary(ar2.jp_r[*,*,ar2SpecNo]),/over,color='r',lineStyle=0)
    endif

    p=plot(xf,j1y,layout=[1,3,2],/current,yRange=[-jpRange,jpRange],title='j1y',thick=3)
    p=plot(xf,imaginary(j1y),/over,color='r',thick=3)
    if(OverPlotAR2)then begin
        p=plot(ar2.r,ar2.jp_t[*,*,ar2SpecNo],/over,color='black',lineStyle=0)
        p=plot(ar2.r,imaginary(ar2.jp_t[*,*,ar2SpecNo]),/over,color='r',lineStyle=0)
    endif

    p=plot(xf,j1z,layout=[1,3,3],/current,yRange=[-jpRange,jpRange],title='j1z',thick=3)
    p=plot(xf,imaginary(j1z),/over,color='r',thick=3)
    if(OverPlotAR2)then begin
        p=plot(ar2.r,ar2.jp_z[*,*,ar2SpecNo],/over,color='black',lineStyle=0)
        p=plot(ar2.r,imaginary(ar2.jp_z[*,*,ar2SpecNo]),/over,color='r',lineStyle=0)
    endif

	; Interpolate the E field to the Jp locations to calculated sig33
	E_at_Jp = complex(interpol(er_re,r,xF ,/spline),interpol(er_im,r,xF ,/spline)) 
stop
end
