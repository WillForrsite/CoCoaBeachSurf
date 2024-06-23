-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- select * from tbllctns
-- =============================================
CREATE   PROCEDURE [dbo].[sp_I_tblLctns]
(
    -- Add the parameters for the stored procedure here
			  @lctn_tpe char(2) = null,
			  @lctn_nme varchar(50) = null,
			  @lctn_dsc varchar(50) = null,
			  @lctn_UnqID varchar(24) = null,
			  @lctn_address nvarchar(256) = null,
			  @lctn_active bit =null,
			  @lctn_dflt bit = null,
			  @lctn_Id smallint = 0
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
	If @lctn_Id > 0
	Begin
	UPDATE [dbo].[tblLctns]
   SET [lctn_tpe] = @lctn_tpe
      ,[lctn_nme] = @lctn_nme
      ,[lctn_dsc] = @lctn_dsc
      ,[lctn_UnqID] = @lctn_UnqID
      ,[lctn_address] = @lctn_address
      ,[lctn_active] = @lctn_active
      ,[lctn_dflt] = @lctn_dflt
	WHERE lctn_Id = @lctn_Id
		
	End
	Else
	Begin
		Insert INTO [dbo].[tblLctns]
           ([lctn_tpe]
		   ,[lctn_nme]
           ,[lctn_dsc]
		   ,[lctn_UnqID]
		   ,lctn_address
		   ,lctn_active
		   ,lctn_dflt)
     VALUES
           (@lctn_tpe
           ,@lctn_nme
		   ,@lctn_dsc
		   ,@lctn_UnqID
		   ,@lctn_address
		   ,@lctn_active
		   ,@lctn_dflt
		   )
	End
END




