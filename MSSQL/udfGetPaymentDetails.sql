CREATE OR ALTER FUNCTION dbo.udfGetPaymentDetails
(
    @pmtRsrvtnID CHAR(6)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.pmtRsrvtnID,
--        p.pmtSessionKey AS esKey,
        p.pmtRequestID AS orderRequestID,
        p.pmtFPAmt AS chargeAmount,
        --p.pmtDecision,
        --p.pmtAuthCode,
        --p.pmtReasonCode,
        --p.pmtTrnDesc,
        --p.pmtTrnKey,
        --p.pmtPosSyncId,
        --p.pmtxWorkflowID,
        --p.pmtStatusDesc,
        --p.pmtCrtdDt,
        --p.pmtModDt,
        m.mode
    FROM dbo.tblRsvrtnPmt p
    CROSS APPLY dbo.udfGetRefundMode(p.pmtCrtdDt) m
    WHERE @pmtRsrvtnID = '*' OR p.pmtRsrvtnID = @pmtRsrvtnID
);