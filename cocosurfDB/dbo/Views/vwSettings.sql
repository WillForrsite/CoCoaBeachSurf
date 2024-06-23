
create    view [dbo].[vwSettings] as
select 
[property],
[value],
[date_last_updated]
from settings
