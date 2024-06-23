-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- exec sp_I_tblLctnTpe @lctn_tpe='Z',@lctn_tpe_dsc='z111'
-- Select * from  tblLctnTpe
-- =============================================
CREATE     PROCEDURE [dbo].[sp_D_tblLctnTpe]
(
    -- Add the parameters for the stored procedure here
			  @lctn_tpe char(2) = null,
			  @lctn_tpe_dsc varchar(50) = null
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

   Delete from  tblLctnTpe where lctn_tpe = @lctn_tpe and lctn_tpe_dsc = @lctn_tpe_dsc
END



