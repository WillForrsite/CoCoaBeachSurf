using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Permissions;
using System.Web;

namespace AuthModule.Models
{
    public class iVwRsrvtnFrm
    {
        public string htl_id { get; set; }
        public string htl_nme { get; set; }
        public string htl_clrk { get; set; }
        public string htl_rsrvtn_nmbr { get; set; }
        public string shp_id { get; set; }
        public string shp_nme { get; set; }
        public string shp_dt { get; set; }
        public string shp_fc { get; set; }
        public string shp_pd { get; set; }
        public string shp_cst { get; set; }
        public string rsrvtn_ctgry { get; set; }
        public string rsrvtn_type { get; set; }
        public string gst_nme { get; set; }
        public string gst_fnme { get; set; }
        public string gst_lnme { get; set; }
        public string gst_eml { get; set; }
        public string gst_cphn1 { get; set; }
        public string gst_cphn2 { get; set; }
        public string arrvl_dt { get; set; }
        public string arrvl_tm { get; set; }
        public string arrvl_arprt { get; set; }
        public string arrvl_arln { get; set; }
        public string arrvl_flght_nmbr { get; set; }
        public string arrvl_nmbr_pssngrs { get; set; }
        public string arrvl_pckup_tm { get; set; }
        public string arrvl_drpoff_loc { get; set; }
        public string dep_dt { get; set; }
        public string dep_tm { get; set; }
        public string dep_arprt { get; set; }
        public string dep_arln { get; set; }
        public string dep_flght_nmbr { get; set; }
        public string dep_nmbr_pssngrs { get; set; }
        public string dep_pckup_tm { get; set; }
        public string dep_drpoff_loc { get; set; }
        public string whlchr { get; set; }
        public string whlchr_cnfld { get; set; }
        public string addtnl_inf { get; set; }
       
    }
}