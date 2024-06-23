-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- exec sp_I_tblLctnTpe @lctn_tpe='Z',@lctn_tpe_dsc='z111'
-- Select * from  tblLctnTpe
-- =============================================
CREATE     PROCEDURE [dbo].[sp_D_tblLctns]
(
    -- Add the parameters for the stored procedure here
			@lctn_Id int 
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

   Delete from  tblLctns where lctn_Id = @lctn_Id
   End



