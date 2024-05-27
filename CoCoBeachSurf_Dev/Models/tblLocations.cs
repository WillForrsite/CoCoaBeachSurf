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
    public class tblLocations
    {
        [Display(Name = "Id")]
        public Int16 lctn_Id { get; set; }
        [Display(Name = "Unique Id")]
        public string lctn_UnqID { get; set; }
        [Display(Name = "Type")]
        public string lctn_tpe { get; set; }
        [Display(Name = "Name")]
        public string lctn_nme { get; set; }
        [Display(Name = "Description")]
        public string lctn_dsc { get; set; }
        [Display(Name = "Address")]
        public string lctn_address { get; set; }
        [Display(Name = "Active")]
        public bool lctn_active { get; set; }
        [Display(Name = "Default")]
        public bool lctn_dflt { get; set; }
    }
}