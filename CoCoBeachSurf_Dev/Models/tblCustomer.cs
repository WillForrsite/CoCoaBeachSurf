using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AuthModule.Models
{
    public class tblCustomer
    {
        public int CustId { get; set; }
        public string CustEmail { get; set; }   
        public string CustFN { get; set; }
        public string CustLN { get; set; } = string.Empty;
        public string CustPhn { get; set; }
        public string CustMbl { get; set; }
        public string CustState { get; set; }
        public string CustStreet { get; set; }
        public string CustCountry { get; set; }
        public string CustPOAddress { get; set; } 
        public string CustCity { get; set; }        
        public string CustZipCode { get; set; }
        public DateTime CreatedDate { get; set; }
        public string CreatedBy { get; set; }



    }
}