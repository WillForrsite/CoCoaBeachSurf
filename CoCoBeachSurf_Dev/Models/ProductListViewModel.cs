using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AuthModule.Models
{
    public class ProductListViewModel
    {
        public int ProductId { get; set; }
        public string ProductCode { get; set; } 
        public string ProductDescription { get; set; } 
        public string ProductType { get; set; }
        public int ProductPrice { get; set; }
        public int Active { get; set; }
        public string CreatedBy { get; set; }
    }
}