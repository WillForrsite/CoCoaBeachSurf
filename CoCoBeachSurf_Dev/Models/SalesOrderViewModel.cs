using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace AuthModule.Models
{
    public class SalesOrderViewModel
    {
          
        public int Date { get; set; }      
        public string PhoneNumber { get; set; }        
        public string MobileNumber { get; set; }      
        public string FirstName { get; set; }         
        public string LastName { get; set; }      
        public string Email { get; set; }       
        public string Region { get; set; }                  
        public string PostalCode { get; set; }      
        public string Country { get; set; }    
        public string Fax { get; set; }       
        public string FaxNumber { get; set;
        }

    }
}