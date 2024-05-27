using EllipticCurve.Utils;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Xml.Linq;

namespace AuthModule.Models
{
    public class tblCustomers
    {
        [Display(Name = "Id")]
        public int CstmrID { get; set; }
        [Display(Name = "First Name")]
        public string CstmrFN { get; set; }
        [Display(Name = "Last Name")]
        public string CstmrLN { get; set; }
        [Display(Name = "Email")]
        public string CstmrEml { get; set; }
        [Display(Name = "Phone1")]
        public string CstmrPhn1 { get; set; }
        [Display(Name = "Phone2")]
        public string CstmrPhn2 { get; set; }
        [Display(Name = "Created Date")]
        public DateTime CstmrCrtdDt { get; set; }
        [Display(Name = "Created By")]
        public string CstmrCrtdBy { get; set; }
        [Display(Name = "Active")]
        public bool CstmrActv { get; set; }
    }
}