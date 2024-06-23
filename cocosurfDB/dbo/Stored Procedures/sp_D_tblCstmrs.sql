-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- exec sp_I_tblLctnTpe @lctn_tpe='Z',@lctn_tpe_dsc='z111'
-- Select * from  tblLctnTpe
-- =============================================
Create       PROCEDURE [dbo].[sp_D_tblCstmrs]
(
    -- Add the parameters for the stored procedure here
			@CstmrId int 
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

   Delete from  tblCstmrs where CstmrID=@CstmrId
   End



