-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[sp_I_VwRsrvtnFrm]
(
    -- Add the parameters for the stored procedure here
			  @htl_id  int					= null
             ,@htl_nme  varchar(50)  		= null
             ,@htl_clrk  varchar(50)   		= null
             ,@htl_rsrvtn_nmbr  varchar(50)    = null
             ,@shp_id  int  				= null
             ,@shp_nme  varchar(50)    		= null
             ,@shp_dt  varchar(50)    			= null
             ,@shp_fc  varchar(50)    			= null
             ,@shp_pd  int  				= null
             ,@shp_cst  numeric(2)  		= null
--             ,@rsrvtn_ctgry  int  			= null
             ,@rsrvtn_type  int  			= null
			 ,@rsrvtn_nbr  nvarchar(128)  			= null
             --,@gst_nme  varchar(50)   		= null
			 ,@gst_fnme varchar(50)			= null
			 ,@gst_lnme varchar(50)				 = null
             ,@gst_eml  varchar(50)   		= null
             ,@gst_cphn1  varchar(50)    		= null
             ,@gst_cphn2  varchar(50)  		= null
             ,@arrvl_dt  varchar(50)    		= null
             ,@arrvl_tm  varchar(50)   		= null
             ,@arrvl_arprt  varchar(50)  	= null
             ,@arrvl_arln  varchar(50)  		= null
             ,@arrvl_flght_nmbr  varchar(50) = null 
             ,@arrvl_nmbr_pssngrs  int  	= null
             ,@arrvl_pckup_tm  varchar(50)  	= null
             ,@arrvl_drpoff_loc  varchar(50) = null 
             ,@dep_dt  varchar(50)  			= null
             ,@dep_tm  varchar(50)  			= null
             ,@dep_arprt  varchar(50)  		= null
             ,@dep_arln  varchar(50)  		= null
             ,@dep_flght_nmbr  varchar(50)  	= null
             ,@dep_nmbr_pssngrs  int  		= null
             ,@dep_pckup_tm  varchar(50)  	= null
             ,@dep_drpoff_loc  varchar(50)  	= null
             ,@whlchr  int  				= null
             ,@whlchr_cnfld  int  			= null
             ,@addtnl_inf  varchar(256)  		= null
			 ,@CreatedBy nvarchar(128)			= null
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    INSERT INTO [dbo].[iVwRsrvtnFrm]
           ([htl_id]
           ,[htl_nme]
           ,[htl_clrk]
           ,[htl_rsrvtn_nmbr]
           ,[shp_id]
           ,[shp_nme]
           ,[shp_dt]
           ,[shp_fc]
           ,[shp_pd]
           ,[shp_cst]
--           ,[rsrvtn_ctgry]
			,[rsrvtn_nbr]
           ,[rsrvtn_type]
           --,[gst_nme]
		   ,[gst_fnme]
		   ,[gst_lnme]
           ,[gst_eml]
           ,[gst_cphn1]
           ,[gst_cphn2]
           ,[arrvl_dt]
           ,[arrvl_tm]
           ,[arrvl_arprt]
           ,[arrvl_arln]
           ,[arrvl_flght_nmbr]
           ,[arrvl_nmbr_pssngrs]
           ,[arrvl_pckup_tm]
           ,[arrvl_drpoff_loc]
           ,[dep_dt]
           ,[dep_tm]
           ,[dep_arprt]
           ,[dep_arln]
           ,[dep_flght_nmbr]
           ,[dep_nmbr_pssngrs]
           ,[dep_pckup_tm]
           ,[dep_drpoff_loc]
           ,[whlchr]
           ,[whlchr_cnfld]
           ,[addtnl_inf]
		   ,[CrtdBy]
		   )
     VALUES
	 (
		 @htl_id				
		,@htl_nme 			
		,@htl_clrk 			
		,@htl_rsrvtn_nmbr 	
		,@shp_id 			
		,@shp_nme 			
		,@shp_dt 			
		,@shp_fc 			
		,@shp_pd 			
		,@shp_cst 			
--		,@rsrvtn_ctgry 	
		,@rsrvtn_nbr
		,@rsrvtn_type 		
		--,@gst_nme 	
		,@gst_fnme 
		,@gst_lnme 
		,@gst_eml 			
		,@gst_cphn1 			
		,@gst_cphn2 			
		,@arrvl_dt 			
		,@arrvl_tm 			
		,@arrvl_arprt 		
		,@arrvl_arln 		
		,@arrvl_flght_nmbr 	
		,@arrvl_nmbr_pssngrs 
		,@arrvl_pckup_tm 	
		,@arrvl_drpoff_loc 	
		,@dep_dt 			
		,@dep_tm 			
		,@dep_arprt 			
		,@dep_arln 			
		,@dep_flght_nmbr 	
		,@dep_nmbr_pssngrs 	
		,@dep_pckup_tm 		
		,@dep_drpoff_loc 	
		,@whlchr 			
		,@whlchr_cnfld 		
		,@addtnl_inf 		
		,@CreatedBy
)
END
