using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Xml.Linq;

namespace AuthModule.Models
{
    public class tblLocationType
    {
        public tblLocationType() { }
        [Display(Name = "Location Type Id")]
        public Int16 lctn_tpe_Id { get; set; }

        [Display(Name = "Type")]    
        public string lctn_tpe { get; set; }
       
        [Display(Name = "Description")]
        public string lctn_tpe_dsc { get; set; }
        [Display(Name = "Active")]
        public bool lctn_tpe_active { get; set; }
    }
}