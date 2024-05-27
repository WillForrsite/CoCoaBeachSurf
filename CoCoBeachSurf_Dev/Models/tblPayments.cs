using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AuthModule.Models
{
    public class tblPayments
    {
        public Guid OrderId { get; set; }
        public int PmtType { get; set; }   
        public decimal PmtAmt { get; set; }
        public string PmtRef { get; set; } 
        public string PmtNote { get; set; }
        public DateTime PmtDate { get; set; }
        public string PmtTypeDesc { get; set; }

    }
}