select * from tblARinvoice

select * from tblARpayments
delete from tblARpayments where pmtID = 25007565
select * from tblARinvoice where invNbr like '25229%'

update tblARinvoice set invStatus = 0 where invNbr = '25205htl026APH'

SELECT 
    TrnAmt = CONVERT(VARCHAR(10), 
        CAST(
            CASE 
                WHEN ISNULL(CAST('0.01' AS DECIMAL(10,2)), 0) > 0 
                THEN 0.01 
                ELSE 0.01 
            END 
        AS DECIMAL(10,2))
    )